import { createHash } from "node:crypto";
import {
  access,
  mkdir,
  readFile,
  rename,
  unlink,
  writeFile,
} from "node:fs/promises";
import path from "node:path";
import { ENV } from "../../config/env.js";
import { db } from "../../db/index.js";

export const NATIVE_ICON_FILE = "native.png";
export const EVM_ADDRESS_PATTERN = /^0x[a-f0-9]{40}$/;

export function getMaxIconBytes() {
  return ENV.TOKEN_ICON_MAX_BYTES;
}

export const LOGO_SOURCE = Object.freeze({
  MANUAL: "manual",
  TRUST_WALLET: "trust_wallet",
  TOKEN_LIST: "token_list",
  GENERATED: "generated",
});

export const LOGO_STATUS = Object.freeze({
  PENDING: "pending",
  READY: "ready",
  FAILED: "failed",
  SKIPPED: "skipped",
});

const LOGO_SOURCE_RANK = Object.freeze({
  [LOGO_SOURCE.MANUAL]: 4,
  [LOGO_SOURCE.TRUST_WALLET]: 3,
  [LOGO_SOURCE.TOKEN_LIST]: 2,
  [LOGO_SOURCE.GENERATED]: 1,
});

const PROTECTED_LOGO_SOURCES = new Set([
  LOGO_SOURCE.MANUAL,
  LOGO_SOURCE.TRUST_WALLET,
]);

function truncateErrorMessage(message, maxLen = 500) {
  const text = message == null ? "" : String(message);
  return text.length <= maxLen ? text : `${text.slice(0, maxLen - 3)}...`;
}

export function parsePositiveChainId(raw) {
  if (raw === undefined || raw === null || raw === "") return null;
  const value = String(raw);
  if (!/^\d+$/.test(value)) return null;
  const chainId = Number(value);
  if (!Number.isSafeInteger(chainId) || chainId <= 0) return null;
  return chainId;
}

export function normalizeEvmAddress(raw) {
  if (typeof raw !== "string") return null;
  const address = raw.trim().toLowerCase();
  return EVM_ADDRESS_PATTERN.test(address) ? address : null;
}

export function buildErc20IconFileName(address) {
  const normalized = normalizeEvmAddress(address);
  if (!normalized) {
    throw new Error("Invalid ERC20 address for token icon path");
  }
  return `${normalized}.png`;
}

export function buildIconRelativePath(chainId, fileName) {
  const parsedChainId = parsePositiveChainId(chainId);
  if (parsedChainId === null) {
    throw new Error("Invalid chainId for token icon path");
  }
  if (fileName !== NATIVE_ICON_FILE && !/^0x[a-f0-9]{40}\.png$/.test(fileName)) {
    throw new Error("Invalid token icon file name");
  }
  return `${parsedChainId}/${fileName}`;
}

function isPathInsideRoot(rootDir, targetPath) {
  const resolvedRoot = path.resolve(rootDir);
  const resolvedTarget = path.resolve(targetPath);
  const relative = path.relative(resolvedRoot, resolvedTarget);
  return (
    relative !== ".." &&
    !relative.startsWith(`..${path.sep}`) &&
    !path.isAbsolute(relative)
  );
}

export function resolveIconAbsolutePath(chainId, fileName) {
  const parsedChainId = parsePositiveChainId(chainId);
  if (parsedChainId === null) {
    throw new Error("Invalid chainId for token icon path");
  }

  if (fileName !== NATIVE_ICON_FILE && !/^0x[a-f0-9]{40}\.png$/.test(fileName)) {
    throw new Error("Invalid token icon file name");
  }

  const iconsRoot = path.resolve(ENV.TOKEN_ICONS_DIR);
  const chainSegment = String(parsedChainId);
  const filePath = path.join(iconsRoot, chainSegment, fileName);

  if (!isPathInsideRoot(iconsRoot, filePath)) {
    throw new Error("Token icon path escapes storage root");
  }

  const relative = path.relative(iconsRoot, filePath);
  const segments = relative.split(path.sep);
  if (segments.length !== 2 || segments[0] !== chainSegment || segments[1] !== fileName) {
    throw new Error("Invalid token icon path shape");
  }

  return filePath;
}

export function buildIconPublicUrl(chainId, fileName) {
  const parsedChainId = parsePositiveChainId(chainId);
  if (parsedChainId === null) {
    throw new Error("Invalid chainId for token icon URL");
  }
  if (fileName !== NATIVE_ICON_FILE && !/^0x[a-f0-9]{40}\.png$/.test(fileName)) {
    throw new Error("Invalid token icon file name");
  }
  return `/static/token-icons/${parsedChainId}/${fileName}`;
}

const LOGO_CONTENT_HASH_PATTERN = /^[a-f0-9]{64}$/;

export function buildLogoCacheBuster(asset) {
  if (!asset || typeof asset !== "object") return null;

  const hash =
    typeof asset.logo_content_hash === "string"
      ? asset.logo_content_hash.trim().toLowerCase()
      : "";
  if (LOGO_CONTENT_HASH_PATTERN.test(hash)) {
    return hash;
  }

  const updatedAt = asset.logo_updated_at;
  if (updatedAt != null && updatedAt !== "") {
    const ms = new Date(updatedAt).getTime();
    if (Number.isFinite(ms)) {
      return String(ms);
    }
  }

  return null;
}

export function appendLogoCacheBuster(publicUrl, cacheBuster) {
  if (!publicUrl || !cacheBuster) return publicUrl;
  return `${publicUrl}?v=${encodeURIComponent(cacheBuster)}`;
}

export function buildNativeIconPaths(chainId) {
  const fileName = NATIVE_ICON_FILE;
  return {
    chainId: parsePositiveChainId(chainId),
    fileName,
    relativePath: buildIconRelativePath(chainId, fileName),
    absolutePath: resolveIconAbsolutePath(chainId, fileName),
    publicUrl: buildIconPublicUrl(chainId, fileName),
  };
}

export function buildErc20IconPaths(chainId, address) {
  const fileName = buildErc20IconFileName(address);
  return {
    chainId: parsePositiveChainId(chainId),
    fileName,
    relativePath: buildIconRelativePath(chainId, fileName),
    absolutePath: resolveIconAbsolutePath(chainId, fileName),
    publicUrl: buildIconPublicUrl(chainId, fileName),
  };
}

export function hashIconBytes(bytes) {
  return createHash("sha256").update(bytes).digest("hex");
}

export async function iconFileExists(chainId, fileName) {
  try {
    const absolutePath = resolveIconAbsolutePath(chainId, fileName);
    await access(absolutePath);
    return true;
  } catch {
    return false;
  }
}

export async function readIconFileHash(chainId, fileName) {
  const absolutePath = resolveIconAbsolutePath(chainId, fileName);
  const bytes = await readFile(absolutePath);
  return hashIconBytes(bytes);
}

export function canReplaceLogoSource(existingSource, nextSource, options = {}) {
  const { allowOverwriteProtected = false, force = false } = options;

  if (force) return true;
  if (!existingSource) return true;
  if (!LOGO_SOURCE_RANK[nextSource]) {
    throw new Error(`Unsupported logo source: ${nextSource}`);
  }
  if (PROTECTED_LOGO_SOURCES.has(existingSource) && !allowOverwriteProtected) {
    return false;
  }
  return LOGO_SOURCE_RANK[nextSource] >= LOGO_SOURCE_RANK[existingSource];
}

async function atomicWriteIconFile(absolutePath, bytes) {
  const directory = path.dirname(absolutePath);
  await mkdir(directory, { recursive: true });

  const tempPath = path.join(
    directory,
    `.${path.basename(absolutePath)}.${process.pid}.${Date.now()}.tmp`,
  );

  try {
    await writeFile(tempPath, bytes);
    await rename(tempPath, absolutePath);
  } catch (err) {
    await unlink(tempPath).catch(() => {});
    throw err;
  }
}

/**
 * Write PNG bytes to the canonical icon path.
 * Skips the filesystem write when the SHA-256 matches the existing file.
 */
export async function writeIconFile({ chainId, fileName, bytes }) {
  if (!Buffer.isBuffer(bytes) && !(bytes instanceof Uint8Array)) {
    throw new Error("Icon bytes must be a Buffer or Uint8Array");
  }
  if (bytes.length === 0) {
    throw new Error("Icon bytes must not be empty");
  }
  if (bytes.length > getMaxIconBytes()) {
    throw new Error(`Icon exceeds max size of ${getMaxIconBytes()} bytes`);
  }

  const absolutePath = resolveIconAbsolutePath(chainId, fileName);
  const relativePath = buildIconRelativePath(chainId, fileName);
  const contentHash = hashIconBytes(bytes);

  let skippedWrite = false;
  try {
    const existingHash = await readIconFileHash(chainId, fileName);
    if (existingHash === contentHash) {
      skippedWrite = true;
    }
  } catch {
    // Missing or unreadable file — proceed with write.
  }

  if (!skippedWrite) {
    await atomicWriteIconFile(absolutePath, bytes);
  }

  return {
    absolutePath,
    relativePath,
    fileName,
    contentHash,
    skippedWrite,
    publicUrl: buildIconPublicUrl(chainId, fileName),
  };
}

export async function markAssetIconFailed(assetId, error, patch = {}) {
  if (assetId == null) {
    throw new Error("assetId is required");
  }

  return db.assets.updateLogoMetadata(assetId, {
    logo_status: LOGO_STATUS.FAILED,
    logo_error: truncateErrorMessage(error?.message ?? error),
    ...patch,
  });
}

export async function markAssetLogoSkipped(assetId, error, patch = {}) {
  if (assetId == null) {
    throw new Error("assetId is required");
  }

  return db.assets.updateLogoMetadata(assetId, {
    logo_status: LOGO_STATUS.SKIPPED,
    logo_error: truncateErrorMessage(error?.message ?? error),
    ...patch,
  });
}

/**
 * Persist icon bytes for an asset row and update logo metadata.
 * Does not overwrite manual/trust_wallet icons unless allowOverwriteProtected is true.
 */
export async function persistAssetIcon({
  assetId,
  chainId,
  address,
  source,
  bytes,
  allowOverwriteProtected = false,
  force = false,
}) {
  if (assetId == null) {
    throw new Error("assetId is required");
  }
  if (!LOGO_SOURCE_RANK[source]) {
    throw new Error(`Unsupported logo source: ${source}`);
  }

  const parsedChainId = parsePositiveChainId(chainId);
  if (parsedChainId === null) {
    throw new Error("Invalid chainId");
  }

  const normalizedAddress = normalizeEvmAddress(address);
  if (!normalizedAddress) {
    throw new Error("Invalid ERC20 address");
  }

  const asset = await db.assets.findById(assetId);
  if (!asset) {
    throw new Error(`Asset not found: ${assetId}`);
  }
  if (String(asset.address).toLowerCase() !== normalizedAddress) {
    throw new Error("Asset address does not match icon write request");
  }

  if (
    !canReplaceLogoSource(asset.logo_source, source, {
      allowOverwriteProtected,
      force,
    })
  ) {
    return {
      skipped: true,
      reason: "protected_source",
      asset,
      publicUrl:
        asset.logo_local_path && asset.logo_status === LOGO_STATUS.READY
          ? buildPublicUrlForAssetLogo(asset, parsedChainId)
          : null,
    };
  }

  const fileName = buildErc20IconFileName(normalizedAddress);
  const contentHash = hashIconBytes(bytes);

  if (
    !force &&
    asset.logo_content_hash === contentHash &&
    asset.logo_status === LOGO_STATUS.READY &&
    asset.logo_local_path === buildIconRelativePath(parsedChainId, fileName) &&
    (await iconFileExists(parsedChainId, fileName))
  ) {
    return {
      skipped: true,
      reason: "unchanged_hash",
      asset,
      contentHash,
      publicUrl: buildPublicUrlForAssetLogo(
        {
          ...asset,
          logo_status: LOGO_STATUS.READY,
          logo_content_hash: contentHash,
        },
        parsedChainId,
      ),
    };
  }

  try {
    const writeResult = await writeIconFile({
      chainId: parsedChainId,
      fileName,
      bytes,
    });

    const updated = await db.assets.updateLogoMetadata(assetId, {
      logo_status: LOGO_STATUS.READY,
      logo_source: source,
      logo_local_path: writeResult.relativePath,
      logo_updated_at: new Date(),
      logo_content_hash: writeResult.contentHash,
      logo_error: null,
    });

    return {
      skipped: writeResult.skippedWrite,
      reason: writeResult.skippedWrite ? "unchanged_hash" : "written",
      asset: updated,
      contentHash: writeResult.contentHash,
      publicUrl: buildPublicUrlForAssetLogo(updated, parsedChainId),
    };
  } catch (err) {
    const existingFileReady =
      asset.logo_status === LOGO_STATUS.READY &&
      Boolean(asset.logo_local_path) &&
      (await iconFileExists(parsedChainId, fileName));

    if (!existingFileReady) {
      await markAssetIconFailed(assetId, err);
    }
    throw err;
  }
}

export function buildPublicUrlForAssetLogo(asset, chainId) {
  if (!asset || asset.logo_status !== LOGO_STATUS.READY || !asset.logo_local_path) {
    return null;
  }

  const parsedChainId = parsePositiveChainId(chainId);
  if (parsedChainId === null) return null;

  const normalizedPath = String(asset.logo_local_path).replace(/\\/g, "/");
  const fileName = path.posix.basename(normalizedPath);
  if (fileName !== NATIVE_ICON_FILE && !/^0x[a-f0-9]{40}\.png$/.test(fileName)) {
    return null;
  }

  const expectedRelativePath = `${parsedChainId}/${fileName}`;
  if (normalizedPath !== expectedRelativePath) {
    return null;
  }

  const baseUrl = buildIconPublicUrl(parsedChainId, fileName);
  return appendLogoCacheBuster(baseUrl, buildLogoCacheBuster(asset));
}

export function buildNativeLogoPublicUrl(chainId) {
  if (parsePositiveChainId(chainId) === null) return null;
  try {
    return buildIconPublicUrl(chainId, NATIVE_ICON_FILE);
  } catch {
    return null;
  }
}

export async function resolveNativeLogoUrl(chainId) {
  try {
    if (!(await iconFileExists(chainId, NATIVE_ICON_FILE))) {
      return null;
    }
    return buildNativeLogoPublicUrl(chainId);
  } catch {
    return null;
  }
}
