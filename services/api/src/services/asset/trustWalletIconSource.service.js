import { getAddress } from "ethers";
import { ENV } from "../../config/env.js";
import { isPngBuffer } from "./tokenIconGenerator.service.js";
import { parsePositiveChainId } from "./tokenIcon.service.js";

export const TRUST_WALLET_CHAIN_SLUGS = Object.freeze({
  1: "ethereum",
  42161: "arbitrum",
  8453: "base",
  43114: "avalanchec",
});

export const TRUST_WALLET_RAW_HOST = "raw.githubusercontent.com";
export const TRUST_WALLET_PATH_PREFIX =
  "/trustwallet/assets/master/blockchains/";

const EVM_ADDRESS_INPUT_PATTERN = /^0x[a-fA-F0-9]{40}$/;

export function getTrustWalletChainSlug(chainId) {
  const parsed = parsePositiveChainId(chainId);
  if (parsed === null) return null;
  return TRUST_WALLET_CHAIN_SLUGS[parsed] ?? null;
}

export function isSupportedTrustWalletChainId(chainId) {
  return getTrustWalletChainSlug(chainId) != null;
}

export function normalizeTrustWalletAddress(raw) {
  if (typeof raw !== "string") return null;
  const trimmed = raw.trim();
  if (!EVM_ADDRESS_INPUT_PATTERN.test(trimmed)) return null;
  try {
    return getAddress(trimmed);
  } catch {
    return null;
  }
}

export function isAllowedTrustWalletUrl(urlString) {
  try {
    const url = new URL(urlString);
    if (url.protocol !== "https:") return false;
    if (url.hostname !== TRUST_WALLET_RAW_HOST) return false;
    if (!url.pathname.startsWith(TRUST_WALLET_PATH_PREFIX)) return false;
    if (!url.pathname.endsWith("/logo.png")) return false;

    const remainder = url.pathname.slice(TRUST_WALLET_PATH_PREFIX.length);
    const segments = remainder.split("/").filter(Boolean);
    if (segments.length !== 4) return false;
    if (segments.some((segment) => segment === "." || segment === "..")) {
      return false;
    }
    if (segments[1] !== "assets") return false;
    if (segments[3] !== "logo.png") return false;

    const slug = segments[0];
    const addressSegment = segments[2];
    if (!Object.values(TRUST_WALLET_CHAIN_SLUGS).includes(slug)) return false;
    if (!/^0x[a-fA-F0-9]{40}$/.test(addressSegment)) return false;

    return true;
  } catch {
    return false;
  }
}

export function buildTrustWalletLogoUrl(chainId, address) {
  const slug = getTrustWalletChainSlug(chainId);
  const checksumAddress = normalizeTrustWalletAddress(address);
  if (!slug || !checksumAddress) return null;

  return `https://${TRUST_WALLET_RAW_HOST}${TRUST_WALLET_PATH_PREFIX}${slug}/assets/${checksumAddress}/logo.png`;
}

export function buildTrustWalletLogoUrlsToTry(chainId, address) {
  const slug = getTrustWalletChainSlug(chainId);
  const checksumAddress = normalizeTrustWalletAddress(address);
  if (!slug || !checksumAddress) return [];

  const base = `https://${TRUST_WALLET_RAW_HOST}${TRUST_WALLET_PATH_PREFIX}${slug}/assets`;
  const urls = [`${base}/${checksumAddress}/logo.png`];
  const lowercase = checksumAddress.toLowerCase();
  if (lowercase !== checksumAddress) {
    urls.push(`${base}/${lowercase}/logo.png`);
  }
  return urls.filter(isAllowedTrustWalletUrl);
}

export function validateTrustWalletPngBytes(bytes) {
  if (!Buffer.isBuffer(bytes) && !(bytes instanceof Uint8Array)) {
    return false;
  }
  return isPngBuffer(bytes);
}

async function readResponseBodyWithLimit(response, maxBytes) {
  const contentLength = Number(response.headers.get("content-length"));
  if (Number.isFinite(contentLength) && contentLength > maxBytes) {
    throw new Error(`Trust Wallet icon exceeds max size of ${maxBytes} bytes`);
  }

  if (!response.body) {
    const buffer = Buffer.from(await response.arrayBuffer());
    if (buffer.length > maxBytes) {
      throw new Error(`Trust Wallet icon exceeds max size of ${maxBytes} bytes`);
    }
    return buffer;
  }

  const reader = response.body.getReader();
  const chunks = [];
  let total = 0;

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    total += value.length;
    if (total > maxBytes) {
      await reader.cancel().catch(() => {});
      throw new Error(`Trust Wallet icon exceeds max size of ${maxBytes} bytes`);
    }
    chunks.push(Buffer.from(value));
  }

  return Buffer.concat(chunks);
}

/**
 * Download a Trust Wallet logo PNG from a pre-built allowlisted URL.
 * Returns { ok: true, bytes } | { ok: false, status, notFound, error }
 */
export async function downloadTrustWalletLogoPng(url, options = {}) {
  if (!isAllowedTrustWalletUrl(url)) {
    return { ok: false, status: null, notFound: false, error: "URL not allowlisted" };
  }

  const timeoutMs = options.timeoutMs ?? ENV.TOKEN_ICON_DOWNLOAD_TIMEOUT_MS;
  const maxBytes = options.maxBytes ?? ENV.TOKEN_ICON_MAX_BYTES;
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const response = await fetch(url, {
      method: "GET",
      redirect: "follow",
      signal: controller.signal,
      headers: {
        Accept: "image/png",
        "User-Agent": "CryPrice-Backend/1.0",
      },
    });

    if (!isAllowedTrustWalletUrl(response.url)) {
      return {
        ok: false,
        status: response.status,
        notFound: false,
        error: "Redirect left allowlisted Trust Wallet host/path",
      };
    }

    if (response.status === 404) {
      return { ok: false, status: 404, notFound: true, error: null };
    }

    if (response.status !== 200) {
      return {
        ok: false,
        status: response.status,
        notFound: false,
        error: `Unexpected HTTP status ${response.status}`,
      };
    }

    const bytes = await readResponseBodyWithLimit(response, maxBytes);
    if (!validateTrustWalletPngBytes(bytes)) {
      return {
        ok: false,
        status: response.status,
        notFound: false,
        error: "Response is not a valid PNG",
      };
    }

    return { ok: true, bytes, status: 200 };
  } catch (err) {
    const message =
      err?.name === "AbortError"
        ? `Trust Wallet download timed out after ${timeoutMs}ms`
        : err?.message ?? String(err);
    return { ok: false, status: null, notFound: false, error: message };
  } finally {
    clearTimeout(timer);
  }
}

/**
 * Try checksum URL first, then lowercase fallback on 404.
 */
export async function fetchTrustWalletLogoForAsset(chainId, address, options = {}) {
  const urls = buildTrustWalletLogoUrlsToTry(chainId, address);
  if (!urls.length) {
    return { ok: false, notFound: false, error: "Unsupported chain or invalid address" };
  }

  let lastResult = null;
  for (const url of urls) {
    const result = await downloadTrustWalletLogoPng(url, options);
    if (result.ok) {
      return { ...result, url };
    }
    lastResult = result;
    if (!result.notFound) {
      return result;
    }
  }

  return lastResult ?? { ok: false, notFound: true, error: null };
}
