import cron from "node-cron";
import pLimit from "p-limit";
import { ENV } from "../config/env.js";
import { db } from "../db/index.js";
import { loadAssetsToCache } from "../services/asset/asset.service.js";
import { loadNetworksToCache } from "../services/network/network.service.js";
import {
  generateErc20PlaceholderIcon,
  generateNativePlaceholderIcon,
} from "../services/asset/tokenIconGenerator.service.js";
import {
  buildErc20IconFileName,
  hashIconBytes,
  iconFileExists,
  LOGO_SOURCE,
  LOGO_STATUS,
  markAssetIconFailed,
  markAssetLogoSkipped,
  NATIVE_ICON_FILE,
  persistAssetIcon,
  readIconFileHash,
  writeIconFile,
  canReplaceLogoSource,
} from "../services/asset/tokenIcon.service.js";
import {
  fetchTrustWalletLogoForAsset,
  isSupportedTrustWalletChainId,
  TRUST_WALLET_CHAIN_SLUGS,
} from "../services/asset/trustWalletIconSource.service.js";

const STARTUP_DELAY_MS = 60_000;
const CONCURRENCY_LIMIT = 8;
const TRUST_WALLET_CONCURRENCY_LIMIT = 3;
const WEEKLY_CRON = "0 4 * * 0";

let isRunning = false;
let startupSyncTimer = null;

async function processNativeNetworkIcon(network) {
  const chainId = network.chain_id;
  const png = await generateNativePlaceholderIcon({
    chainId,
    symbol: network.native_symbol,
  });
  const contentHash = hashIconBytes(png);
  const fileExists = await iconFileExists(chainId, NATIVE_ICON_FILE);

  if (fileExists) {
    try {
      const existingHash = await readIconFileHash(chainId, NATIVE_ICON_FILE);
      if (existingHash === contentHash) {
        return { skipped: true, reason: "unchanged" };
      }
    } catch {
      // Missing or unreadable file — regenerate below.
    }
  }

  const writeResult = await writeIconFile({
    chainId,
    fileName: NATIVE_ICON_FILE,
    bytes: png,
  });

  return {
    skipped: writeResult.skippedWrite,
    reason: writeResult.skippedWrite ? "unchanged" : "written",
    chainId,
    kind: "native",
  };
}

async function processAssetIcon(asset, chainId) {
  if (
    asset.logo_source &&
    !canReplaceLogoSource(asset.logo_source, LOGO_SOURCE.GENERATED) &&
    asset.logo_status === LOGO_STATUS.READY
  ) {
    return { skipped: true, reason: "protected_source" };
  }

  const fileName = buildErc20IconFileName(asset.address);
  const fileExists = await iconFileExists(chainId, fileName);
  const png = await generateErc20PlaceholderIcon({
    chainId,
    address: asset.address,
    symbol: asset.symbol,
  });
  const contentHash = hashIconBytes(png);

  const needsGeneration =
    asset.logo_status !== LOGO_STATUS.READY ||
    !asset.logo_local_path ||
    !fileExists ||
    asset.logo_content_hash !== contentHash;

  if (!needsGeneration) {
    return { skipped: true, reason: "unchanged" };
  }

  const result = await persistAssetIcon({
    assetId: asset.id,
    chainId,
    address: asset.address,
    source: LOGO_SOURCE.GENERATED,
    bytes: png,
  });

  return {
    skipped: Boolean(result.skipped),
    reason: result.reason ?? (result.skipped ? "unchanged" : "written"),
    assetId: asset.id,
    kind: "erc20",
  };
}

function hasReadyGeneratedFallback(asset) {
  return (
    asset.logo_source === LOGO_SOURCE.GENERATED &&
    asset.logo_status === LOGO_STATUS.READY &&
    Boolean(asset.logo_local_path)
  );
}

async function processTrustWalletAsset(asset) {
  const chainId = asset.chain_id;

  if (!isSupportedTrustWalletChainId(chainId)) {
    return { skipped: true, reason: "unsupported_chain" };
  }

  if (
    asset.logo_source === LOGO_SOURCE.MANUAL ||
    !canReplaceLogoSource(asset.logo_source, LOGO_SOURCE.TRUST_WALLET)
  ) {
    return { skipped: true, reason: "protected_source" };
  }

  if (
    asset.logo_source === LOGO_SOURCE.TRUST_WALLET &&
    asset.logo_status === LOGO_STATUS.READY &&
    asset.logo_content_hash
  ) {
    const fileName = buildErc20IconFileName(asset.address);
    if (await iconFileExists(chainId, fileName)) {
      return { skipped: true, reason: "unchanged_trust_wallet" };
    }
  }

  const download = await fetchTrustWalletLogoForAsset(chainId, asset.address);
  if (!download.ok) {
    if (download.notFound) {
      if (hasReadyGeneratedFallback(asset)) {
        return { skipped: true, reason: "not_found_keep_generated" };
      }
      await markAssetLogoSkipped(asset.id, "Trust Wallet logo not found");
      return { skipped: true, reason: "not_found" };
    }

    if (hasReadyGeneratedFallback(asset)) {
      return { skipped: true, reason: "download_failed_keep_generated" };
    }

    await markAssetIconFailed(
      asset.id,
      download.error ?? "Trust Wallet download failed",
    );
    return { skipped: true, reason: "download_failed" };
  }

  const result = await persistAssetIcon({
    assetId: asset.id,
    chainId,
    address: asset.address,
    source: LOGO_SOURCE.TRUST_WALLET,
    bytes: download.bytes,
    allowOverwriteProtected:
      asset.logo_source === LOGO_SOURCE.TRUST_WALLET &&
      !(await iconFileExists(chainId, buildErc20IconFileName(asset.address))),
  });

  return {
    skipped: Boolean(result.skipped),
    reason: result.reason ?? (result.skipped ? "unchanged_hash" : "downloaded"),
    assetId: asset.id,
    kind: "trust_wallet",
  };
}

export async function syncTrustWalletTokenIcons({ reason = "manual" } = {}) {
  if (!ENV.TOKEN_ICON_TRUST_WALLET_SYNC_ENABLED) {
    console.log(
      `⏭ Trust Wallet icon sync skipped — disabled (${reason})`,
      new Date().toISOString(),
    );
    return { skipped: true, reason: "disabled" };
  }

  const supportedChainIds = Object.keys(TRUST_WALLET_CHAIN_SLUGS).map(Number);
  const assets = await db.assets.findAssetsForTrustWalletIconSync(
    supportedChainIds,
  );

  const summary = {
    reason,
    eligible: assets.length,
    downloaded: 0,
    skipped: 0,
    failed: 0,
  };

  const limit = pLimit(TRUST_WALLET_CONCURRENCY_LIMIT);
  const networkIds = new Set();

  await Promise.all(
    assets.map((asset) =>
      limit(async () => {
        networkIds.add(asset.network_id);
        try {
          const result = await processTrustWalletAsset(asset);
          if (result.reason === "download_failed") {
            summary.failed += 1;
          } else if (result.skipped) {
            summary.skipped += 1;
          } else {
            summary.downloaded += 1;
          }
        } catch (err) {
          summary.failed += 1;
          console.error(
            "❌ Trust Wallet icon sync failed for asset:",
            new Date().toISOString(),
            {
              assetId: asset.id,
              chainId: asset.chain_id,
              address: asset.address,
              error: err?.message ?? err,
            },
          );
          try {
            if (hasReadyGeneratedFallback(asset)) {
              return;
            }
            await markAssetIconFailed(asset.id, err);
          } catch (markErr) {
            console.error(
              "❌ Failed to mark Trust Wallet icon failure:",
              new Date().toISOString(),
              {
                assetId: asset.id,
                error: markErr?.message ?? markErr,
              },
            );
          }
        }
      }),
    ),
  );

  for (const networkId of networkIds) {
    try {
      await loadAssetsToCache(networkId);
    } catch (err) {
      console.error(
        "❌ Failed to refresh asset cache after Trust Wallet sync:",
        new Date().toISOString(),
        { networkId, error: err?.message ?? err },
      );
    }
  }

  return summary;
}

export async function syncGeneratedTokenIcons({ reason = "manual" } = {}) {
  if (!ENV.TOKEN_ICON_GENERATION_ENABLED) {
    console.log(
      `⏭ Token icon generation skipped — disabled (${reason})`,
      new Date().toISOString(),
    );
    return { skipped: true, reason: "disabled" };
  }

  const networks = (await db.networks.findAll({ limit: 1000 })).filter(
    (network) => network.enabled,
  );

  const summary = {
    reason,
    networks: networks.length,
    nativeWritten: 0,
    nativeSkipped: 0,
    nativeFailed: 0,
    assetsWritten: 0,
    assetsSkipped: 0,
    assetsFailed: 0,
  };

  const limit = pLimit(CONCURRENCY_LIMIT);

  await Promise.all(
    networks.map((network) =>
      limit(async () => {
        try {
          const result = await processNativeNetworkIcon(network);
          if (result.skipped) summary.nativeSkipped += 1;
          else summary.nativeWritten += 1;
        } catch (err) {
          summary.nativeFailed += 1;
          console.error(
            "❌ Native token icon generation failed:",
            new Date().toISOString(),
            {
              networkId: network.id,
              chainId: network.chain_id,
              symbol: network.native_symbol,
              error: err?.message ?? err,
            },
          );
        }
      }),
    ),
  );

  for (const network of networks) {
    const assets = await db.assets.findByNetwork(network.id);

    await Promise.all(
      assets.map((asset) =>
        limit(async () => {
          try {
            const result = await processAssetIcon(asset, network.chain_id);
            if (result.skipped) summary.assetsSkipped += 1;
            else summary.assetsWritten += 1;
          } catch (err) {
            summary.assetsFailed += 1;
            console.error(
              "❌ Asset token icon generation failed:",
              new Date().toISOString(),
              {
                assetId: asset.id,
                networkId: network.id,
                chainId: network.chain_id,
                address: asset.address,
                symbol: asset.symbol,
                error: err?.message ?? err,
              },
            );
            try {
              await markAssetIconFailed(asset.id, err);
            } catch (markErr) {
              console.error(
                "❌ Failed to mark asset icon as failed:",
                new Date().toISOString(),
                {
                  assetId: asset.id,
                  error: markErr?.message ?? markErr,
                },
              );
            }
          }
        }),
      ),
    );
  }

  for (const network of networks) {
    try {
      await loadAssetsToCache(network.id);
    } catch (err) {
      console.error(
        "❌ Failed to refresh asset cache after token icon sync:",
        new Date().toISOString(),
        {
          networkId: network.id,
          error: err?.message ?? err,
        },
      );
    }
  }

  try {
    await loadNetworksToCache();
  } catch (err) {
    console.error(
      "❌ Failed to refresh network cache after token icon sync:",
      new Date().toISOString(),
      err,
    );
  }

  return summary;
}

export async function runTokenIconSync({ reason = "manual" } = {}) {
  if (isRunning) {
    console.log(
      `⏭ Token icon sync skipped — already running (${reason})`,
      new Date().toISOString(),
    );
    return;
  }

  isRunning = true;

  console.log(
    `⏱ Token icon generation sync started (${reason})`,
    new Date().toISOString(),
  );

  try {
    if (ENV.TOKEN_ICON_GENERATION_ENABLED) {
      const summary = await syncGeneratedTokenIcons({ reason });
      console.log(
        `✅ Token icon generation sync completed (${reason})`,
        new Date().toISOString(),
        summary,
      );
    } else {
      console.log(
        `⏭ Token icon generation skipped — disabled (${reason})`,
        new Date().toISOString(),
      );
    }

    if (ENV.TOKEN_ICON_TRUST_WALLET_SYNC_ENABLED) {
      console.log(
        `⏱ Trust Wallet icon sync started (${reason})`,
        new Date().toISOString(),
      );
      const trustWalletSummary = await syncTrustWalletTokenIcons({ reason });
      console.log(
        `✅ Trust Wallet icon sync completed (${reason})`,
        new Date().toISOString(),
        trustWalletSummary,
      );
    }
  } catch (err) {
    console.error(
      `❌ Token icon generation sync failed (${reason}):`,
      new Date().toISOString(),
      err,
    );
  } finally {
    isRunning = false;
  }
}

export async function startTokenIconSyncCron() {
  return runTokenIconSync({ reason: "cron" });
}

/** Register the recurring job. Call from startCrons() only — not at module import time. */
export function scheduleTokenIconCron() {
  return cron.schedule(WEEKLY_CRON, startTokenIconSyncCron, {
    scheduled: true,
    timezone: "UTC",
  });
}

/**
 * One delayed post-startup run to backfill icons without blocking API startup.
 */
export function scheduleTokenIconStartupSync(delayMs = STARTUP_DELAY_MS) {
  if (startupSyncTimer) {
    console.log(
      "⏭ Token icon delayed startup sync already scheduled",
      new Date().toISOString(),
    );
    return startupSyncTimer;
  }

  console.log(
    `⏳ Token icon delayed startup sync scheduled in ${delayMs}ms`,
    new Date().toISOString(),
  );

  startupSyncTimer = setTimeout(() => {
    console.log(
      "⏱ Token icon delayed startup sync triggered",
      new Date().toISOString(),
    );
    void runTokenIconSync({ reason: "startup_delayed" });
  }, delayMs);

  return startupSyncTimer;
}
