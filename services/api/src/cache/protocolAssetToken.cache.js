import { redis } from "../redis/redis.client.js";

export const PROTOCOL_ASSET_TOKENS_TTL_SECONDS = 60 * 60 * 24;

function normalizeProtocol(protocol) {
  return String(protocol ?? "").trim().toLowerCase();
}

function normalizeAddress(address) {
  return String(address ?? "").trim().toLowerCase();
}

function normalizeRole(tokenRole) {
  return String(tokenRole ?? "").trim().toLowerCase();
}

function byProtocolNetworkKey(protocol, networkId) {
  return `protocol_asset_tokens:${normalizeProtocol(protocol)}:network:${networkId}`;
}

function activeByNetworkKey(networkId) {
  return `protocol_asset_tokens:network:${networkId}:active`;
}

function byAddressKey(networkId, tokenAddress) {
  return `protocol_asset_token:network:${networkId}:address:${normalizeAddress(tokenAddress)}`;
}

function byUnderlyingKey(protocol, networkId, underlyingAssetId) {
  return `protocol_asset_tokens:${normalizeProtocol(protocol)}:network:${networkId}:underlying_asset:${underlyingAssetId}`;
}

function byRoleKey(protocol, networkId, tokenRole) {
  return `protocol_asset_tokens:${normalizeProtocol(protocol)}:network:${networkId}:role:${normalizeRole(tokenRole)}`;
}

async function getJson(key, fallback) {
  if (!redis || redis.status === "end") return fallback;

  try {
    const raw = await redis.get(key);
    if (!raw) return fallback;
    return JSON.parse(raw);
  } catch (err) {
    console.warn("⚠️ Redis protocol asset cache get failed:", err.message);
    try {
      await redis.del(key);
    } catch {
      // Ignore cleanup failures; DB fallback is the source of truth.
    }
    return fallback;
  }
}

async function setJson(key, payload) {
  if (!redis || redis.status === "end") return;

  try {
    await redis.set(
      key,
      JSON.stringify(payload),
      "EX",
      PROTOCOL_ASSET_TOKENS_TTL_SECONDS,
    );
  } catch (err) {
    console.warn("⚠️ Redis protocol asset cache set failed:", err.message);
  }
}

async function delKeys(keys) {
  if (!redis || redis.status === "end") return;
  const uniqueKeys = [...new Set(keys.filter(Boolean))];
  if (!uniqueKeys.length) return;

  try {
    await redis.del(...uniqueKeys);
  } catch (err) {
    console.warn("⚠️ Redis protocol asset cache invalidate failed:", err.message);
  }
}

export async function getProtocolAssetTokensByProtocolAndNetworkCache(
  protocol,
  networkId,
) {
  return getJson(byProtocolNetworkKey(protocol, networkId), null);
}

export async function setProtocolAssetTokensByProtocolAndNetworkCache(
  protocol,
  networkId,
  rows,
) {
  await setJson(byProtocolNetworkKey(protocol, networkId), rows);
}

export async function getActiveProtocolAssetTokensByNetworkCache(networkId) {
  return getJson(activeByNetworkKey(networkId), null);
}

export async function setActiveProtocolAssetTokensByNetworkCache(networkId, rows) {
  await setJson(activeByNetworkKey(networkId), rows);
}

export async function getProtocolAssetTokenByAddressCache(
  networkId,
  tokenAddress,
) {
  return getJson(byAddressKey(networkId, tokenAddress), null);
}

export async function setProtocolAssetTokenByAddressCache(
  networkId,
  tokenAddress,
  row,
) {
  await setJson(byAddressKey(networkId, tokenAddress), row);
}

export async function getProtocolAssetTokensByUnderlyingCache(
  protocol,
  networkId,
  underlyingAssetId,
) {
  return getJson(byUnderlyingKey(protocol, networkId, underlyingAssetId), null);
}

export async function setProtocolAssetTokensByUnderlyingCache(
  protocol,
  networkId,
  underlyingAssetId,
  rows,
) {
  await setJson(byUnderlyingKey(protocol, networkId, underlyingAssetId), rows);
}

export async function getProtocolAssetTokensByRoleCache(
  protocol,
  networkId,
  tokenRole,
) {
  return getJson(byRoleKey(protocol, networkId, tokenRole), null);
}

export async function setProtocolAssetTokensByRoleCache(
  protocol,
  networkId,
  tokenRole,
  rows,
) {
  await setJson(byRoleKey(protocol, networkId, tokenRole), rows);
}

export async function invalidateProtocolAssetTokensByProtocolAndNetwork(
  protocol,
  networkId,
) {
  await delKeys([byProtocolNetworkKey(protocol, networkId), activeByNetworkKey(networkId)]);
}

export async function invalidateProtocolAssetTokenByAddress(
  networkId,
  tokenAddress,
) {
  await delKeys([byAddressKey(networkId, tokenAddress)]);
}

export async function invalidateProtocolAssetTokensByUnderlying(
  protocol,
  networkId,
  underlyingAssetId,
) {
  await delKeys([byUnderlyingKey(protocol, networkId, underlyingAssetId)]);
}

export async function invalidateProtocolAssetTokensByRole(
  protocol,
  networkId,
  tokenRole,
) {
  await delKeys([byRoleKey(protocol, networkId, tokenRole)]);
}

export async function invalidateProtocolAssetTokenCachesForRows(
  protocol,
  networkId,
  rows,
) {
  const keys = [byProtocolNetworkKey(protocol, networkId), activeByNetworkKey(networkId)];

  for (const row of Array.isArray(rows) ? rows : []) {
    if (row.token_address) keys.push(byAddressKey(networkId, row.token_address));
    if (row.underlying_asset_id) {
      keys.push(byUnderlyingKey(protocol, networkId, row.underlying_asset_id));
    }
    if (row.token_role) keys.push(byRoleKey(protocol, networkId, row.token_role));
  }

  await delKeys(keys);
}
