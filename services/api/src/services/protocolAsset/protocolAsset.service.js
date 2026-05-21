import { getProtocolAssetTokens } from "../../blockchain/index.js";
import { networksRegistry } from "../../blockchain/networks/index.js";
import { db } from "../../db/index.js";
import { getEnabledNetworks } from "../network/network.service.js";
import {
  getActiveProtocolAssetTokensByNetworkCache,
  getProtocolAssetTokenByAddressCache,
  getProtocolAssetTokensByProtocolAndNetworkCache,
  getProtocolAssetTokensByRoleCache,
  getProtocolAssetTokensByUnderlyingCache,
  invalidateProtocolAssetTokensByProtocolAndNetwork,
  invalidateProtocolAssetTokensByRole,
  invalidateProtocolAssetTokenCachesForRows,
  setActiveProtocolAssetTokensByNetworkCache,
  setProtocolAssetTokenByAddressCache,
  setProtocolAssetTokensByProtocolAndNetworkCache,
  setProtocolAssetTokensByRoleCache,
  setProtocolAssetTokensByUnderlyingCache,
} from "../../cache/protocolAssetToken.cache.js";

const ADAPTER_PROTOCOL = "aave";
const PROTOCOL = "aave_v3";
const PROTOCOL_TOKEN_ROLES = [
  "supply_token",
  "stable_debt_token",
  "variable_debt_token",
];
const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

function logCacheEvent(message, ...args) {
  if (process.env.DEBUG_PROTOCOL_ASSET_CACHE !== "true") return;
  console.log(message, ...args);
}

function emptySummary() {
  return {
    protocol: PROTOCOL,
    networksProcessed: 0,
    reservesProcessed: 0,
    tokensUpserted: 0,
    skipped: 0,
    skippedZeroAddress: 0,
    errors: [],
  };
}

function isAaveConfigured(networkName) {
  const protocolConfig = networksRegistry[networkName]?.config?.protocols?.aave;
  return Boolean(protocolConfig?.ADDRESSES_PROVIDER);
}

function normalizeAddress(address) {
  if (!address || typeof address !== "string") return null;
  return address.trim().toLowerCase();
}

function isZeroAddress(address) {
  return normalizeAddress(address) === ZERO_ADDRESS;
}

function pushError(summary, error) {
  summary.errors.push({
    network: error.network ?? null,
    underlyingAddress: error.underlyingAddress ?? null,
    tokenAddress: error.tokenAddress ?? null,
    tokenRole: error.tokenRole ?? null,
    message: error.message ?? "Unknown protocol asset sync error",
  });
}

function buildMetadata(mapping, syncedAt) {
  return {
    ...(mapping.metadata ?? {}),
    source: mapping.metadata?.source ?? "aave_data_provider",
    underlyingAddress: normalizeAddress(mapping.underlying?.address),
    underlyingSymbol: mapping.underlying?.symbol ?? null,
    adapterProtocol: ADAPTER_PROTOCOL,
    syncedAt,
  };
}

function buildProtocolAssetTokenRows(
  network,
  mapping,
  underlyingAsset,
  syncedAt,
  summary,
) {
  const metadata = buildMetadata(mapping, syncedAt);
  const tokens = Array.isArray(mapping.tokens) ? mapping.tokens : [];
  let skippedZeroAddress = 0;

  const rows = tokens
    .map((token) => ({
      network_id: network.id,
      protocol: mapping.protocol ?? PROTOCOL,
      underlying_asset_id: underlyingAsset.id,
      token_address: normalizeAddress(token.address),
      token_symbol: token.symbol ?? null,
      token_decimals: token.decimals ?? null,
      token_role: token.tokenRole,
      price_asset_id: underlyingAsset.id,
      metadata,
      is_active: true,
    }))
    .filter((row) => {
      if (!row.token_address || !row.token_role) return false;
      if (isZeroAddress(row.token_address)) {
        skippedZeroAddress += 1;
        return false;
      }
      return true;
    });

  if (skippedZeroAddress > 0) {
    summary.skippedZeroAddress += skippedZeroAddress;
    summary.skipped += skippedZeroAddress;
    logCacheEvent(
      "Protocol asset zero-address tokens skipped",
      network.name,
      mapping.underlying?.symbol ?? mapping.underlying?.address,
      skippedZeroAddress,
    );
  }

  return rows;
}

export async function listProtocolAssetTokensByProtocolAndNetwork(
  protocol,
  networkId,
) {
  const cached = await getProtocolAssetTokensByProtocolAndNetworkCache(
    protocol,
    networkId,
  );
  if (cached) {
    logCacheEvent("Protocol asset token cache hit", protocol, networkId);
    return cached;
  }

  logCacheEvent("Protocol asset token cache miss", protocol, networkId);
  const rows = await db.protocolAssetTokens.findByProtocolAndNetwork(
    protocol,
    networkId,
  );
  await setProtocolAssetTokensByProtocolAndNetworkCache(protocol, networkId, rows);
  return rows;
}

export async function listActiveProtocolAssetTokensByNetwork(networkId) {
  const cached = await getActiveProtocolAssetTokensByNetworkCache(networkId);
  if (cached) {
    logCacheEvent("Protocol asset active cache hit", networkId);
    return cached;
  }

  logCacheEvent("Protocol asset active cache miss", networkId);
  const rows = await db.protocolAssetTokens.findActiveByNetwork(networkId);
  await setActiveProtocolAssetTokensByNetworkCache(networkId, rows);
  return rows;
}

export async function findProtocolAssetTokenByAddress(networkId, tokenAddress) {
  const cached = await getProtocolAssetTokenByAddressCache(networkId, tokenAddress);
  if (cached) {
    logCacheEvent("Protocol asset address cache hit", networkId, tokenAddress);
    return cached;
  }

  logCacheEvent("Protocol asset address cache miss", networkId, tokenAddress);
  const rows = await db.protocolAssetTokens.findByTokenAddress(
    networkId,
    tokenAddress,
  );
  const row = rows[0] ?? null;
  await setProtocolAssetTokenByAddressCache(networkId, tokenAddress, row);
  return row;
}

export async function listProtocolAssetTokensByUnderlying(
  protocol,
  networkId,
  underlyingAssetId,
) {
  const cached = await getProtocolAssetTokensByUnderlyingCache(
    protocol,
    networkId,
    underlyingAssetId,
  );
  if (cached) {
    logCacheEvent(
      "Protocol asset underlying cache hit",
      protocol,
      networkId,
      underlyingAssetId,
    );
    return cached;
  }

  logCacheEvent(
    "Protocol asset underlying cache miss",
    protocol,
    networkId,
    underlyingAssetId,
  );
  const rows = await db.protocolAssetTokens.findByUnderlyingAssetId(
    protocol,
    networkId,
    underlyingAssetId,
  );
  await setProtocolAssetTokensByUnderlyingCache(
    protocol,
    networkId,
    underlyingAssetId,
    rows,
  );
  return rows;
}

export async function listProtocolAssetTokensByRole(protocol, networkId, tokenRole) {
  const cached = await getProtocolAssetTokensByRoleCache(
    protocol,
    networkId,
    tokenRole,
  );
  if (cached) {
    logCacheEvent("Protocol asset role cache hit", protocol, networkId, tokenRole);
    return cached;
  }

  logCacheEvent("Protocol asset role cache miss", protocol, networkId, tokenRole);
  const rows = await db.protocolAssetTokens.findByRole(
    protocol,
    networkId,
    tokenRole,
  );
  await setProtocolAssetTokensByRoleCache(protocol, networkId, tokenRole, rows);
  return rows;
}

async function syncAaveMapping(network, mapping, summary, syncedAt) {
  summary.reservesProcessed += 1;

  const underlyingAddress = normalizeAddress(mapping.underlying?.address);
  if (!underlyingAddress) {
    summary.skipped += 1;
    console.warn(
      "⚠️ Protocol asset sync skipped reserve without underlying address",
      network.name,
    );
    return [];
  }

  const underlyingAsset = await db.assets.findByAddress(
    network.id,
    underlyingAddress,
  );
  if (!underlyingAsset) {
    summary.skipped += 1;
    console.warn(
      "⚠️ Protocol asset sync skipped missing underlying asset",
      network.name,
      underlyingAddress,
    );
    return [];
  }

  const rows = buildProtocolAssetTokenRows(
    network,
    mapping,
    underlyingAsset,
    syncedAt,
    summary,
  );
  if (!rows.length) {
    summary.skipped += 1;
    console.warn(
      "⚠️ Protocol asset sync skipped reserve without derivative tokens",
      network.name,
      underlyingAddress,
    );
    return [];
  }

  const upsertedRows = [];
  for (const row of rows) {
    try {
      const upserted = await db.protocolAssetTokens.upsertProtocolAssetToken(row);
      if (upserted) upsertedRows.push(upserted);
      summary.tokensUpserted += 1;
    } catch (e) {
      summary.skipped += 1;
      pushError(summary, {
        network: network.name,
        underlyingAddress,
        tokenAddress: row.token_address,
        tokenRole: row.token_role,
        message: e.message,
      });
      console.warn(
        "⚠️ Protocol asset token upsert failed",
        network.name,
        row.token_role,
        row.token_address,
        e.message,
      );
    }
  }
  return upsertedRows;
}

async function syncAaveNetwork(network, summary, syncedAt) {
  if (!isAaveConfigured(network.name)) {
    return;
  }

  summary.networksProcessed += 1;
  console.log(`Protocol asset 🔗${network.name} `, network.id);

  let mappings = [];
  try {
    mappings = await getProtocolAssetTokens(network.name, ADAPTER_PROTOCOL);
  } catch (e) {
    pushError(summary, {
      network: network.name,
      message: e.message,
    });
    console.warn(
      "⚠️ Protocol asset sync failed for network",
      network.name,
      e.message,
    );
    return;
  }

  const upsertedRows = [];
  for (const mapping of Array.isArray(mappings) ? mappings : []) {
    try {
      const rows = await syncAaveMapping(network, mapping, summary, syncedAt);
      upsertedRows.push(...rows);
    } catch (e) {
      summary.skipped += 1;
      pushError(summary, {
        network: network.name,
        underlyingAddress: normalizeAddress(mapping?.underlying?.address),
        message: e.message,
      });
      console.warn(
        "⚠️ Protocol asset sync reserve failed",
        network.name,
        normalizeAddress(mapping?.underlying?.address) ?? "unknown",
        e.message,
      );
    }
  }

  await invalidateProtocolAssetTokensByProtocolAndNetwork(PROTOCOL, network.id);
  await Promise.all(
    PROTOCOL_TOKEN_ROLES.map((tokenRole) =>
      invalidateProtocolAssetTokensByRole(PROTOCOL, network.id, tokenRole),
    ),
  );

  if (upsertedRows.length) {
    await invalidateProtocolAssetTokenCachesForRows(
      PROTOCOL,
      network.id,
      upsertedRows,
    );
    console.log(
      "✅ Protocol asset token cache invalidated",
      network.name,
      upsertedRows.length,
    );
  }
}

export async function syncAaveProtocolAssetTokens() {
  console.log("⏱ Protocol asset sync started");

  const summary = emptySummary();
  const syncedAt = new Date().toISOString();
  const networks = Object.values(await getEnabledNetworks()).filter(
    (network) => network?.enabled !== false,
  );

  for (const network of networks) {
    try {
      await syncAaveNetwork(network, summary, syncedAt);
    } catch (e) {
      pushError(summary, {
        network: network?.name,
        message: e.message,
      });
      console.warn(
        "⚠️ Protocol asset sync network failed",
        network?.name ?? "unknown",
        e.message,
      );
    }
  }

  console.log("✅ Protocol asset sync finished", summary);
  return summary;
}
