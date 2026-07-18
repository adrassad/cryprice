import { JsonRpcProvider } from "ethers";

const HTTP_URL_RE = /^https?:\/\//i;

/**
 * Parse primary + optional comma-separated RPC URL list.
 * Primary is listed first; duplicates (case-insensitive) are removed.
 *
 * @returns {{ urls: string[], invalid: string[] }}
 */
export function parseRpcUrls(primaryUrl, urlsList) {
  const invalid = [];
  const candidates = [];

  const primaryTrimmed =
    primaryUrl != null ? String(primaryUrl).trim() : "";
  const listTrimmed = urlsList != null ? String(urlsList).trim() : "";

  if (primaryTrimmed) candidates.push(primaryTrimmed);
  if (listTrimmed) {
    for (const part of listTrimmed.split(",")) {
      candidates.push(part);
    }
  }

  const urls = [];
  const seen = new Set();

  for (const raw of candidates) {
    const trimmed = String(raw).trim();
    if (!trimmed) continue;

    if (!HTTP_URL_RE.test(trimmed)) {
      invalid.push(trimmed);
      continue;
    }

    const key = trimmed.toLowerCase();
    if (seen.has(key)) continue;

    seen.add(key);
    urls.push(trimmed);
  }

  return { urls, invalid };
}

/**
 * Mask RPC URL for logs: hostname only (no path, query, or API keys).
 */
export function maskRpcUrl(url) {
  if (url == null || String(url).trim() === "") return "(empty)";
  try {
    return new URL(String(url).trim()).hostname || "(invalid-url)";
  } catch {
    return "(invalid-url)";
  }
}

function logInvalidRpcEntries(networkName, invalid) {
  for (const entry of invalid) {
    const masked = HTTP_URL_RE.test(entry)
      ? maskRpcUrl(entry)
      : "(invalid-url)";
    console.warn(
      `[RPC] ${networkName}: skipping invalid RPC URL (must start with http:// or https://): ${masked}`,
    );
  }
}

/**
 * Attach parsed RPC_URL / RPC_URLS to a network config entry.
 * Throws when the network is enabled and no valid URLs remain.
 */
export function applyRpcEnvToNetwork(network, { primaryUrl, urlsList }) {
  const { urls, invalid } = parseRpcUrls(primaryUrl, urlsList);
  logInvalidRpcEntries(network.name, invalid);

  if (network.ENABLED !== false && urls.length === 0) {
    const prefix = String(network.name).toUpperCase();
    throw new Error(
      `[RPC] No valid RPC URLs configured for enabled network "${network.name}". Set ${prefix}_RPC_URL or ${prefix}_RPC_URLS.`,
    );
  }

  return {
    ...network,
    RPC_URL: urls[0],
    RPC_URLS: urls,
  };
}

/**
 * Create a JsonRpcProvider for the first configured RPC URL.
 * Public edition uses the primary endpoint only (no multi-RPC failover module).
 *
 * @param {string[]} rpcUrls
 * @param {{ chainId?: number, networkName?: string }} [options]
 * @param {{ createJsonRpcProvider?: (url: string) => import('ethers').JsonRpcProvider }} [deps]
 */
export function createNetworkProvider(
  rpcUrls,
  { chainId, networkName } = {},
  deps = {},
) {
  const urls = Array.isArray(rpcUrls) ? rpcUrls.filter(Boolean) : [];

  if (urls.length === 0) {
    throw new Error(
      `[RPC] No valid RPC URLs configured for network "${networkName ?? "unknown"}".`,
    );
  }

  const createJson =
    deps.createJsonRpcProvider ??
    ((url) => new JsonRpcProvider(url, chainId ?? undefined));

  return createJson(urls[0]);
}

export function logNetworkRpcConfiguration(networksConfig) {
  for (const network of Object.values(networksConfig)) {
    if (network?.ENABLED === false) continue;

    const urls = network.RPC_URLS ?? [];
    const masked = urls.map((url) => maskRpcUrl(url));
    console.log(
      `[RPC] ${network.name}: ${urls.length} endpoint(s) configured → ${masked.join(", ") || "(none)"}`,
    );
  }
}
