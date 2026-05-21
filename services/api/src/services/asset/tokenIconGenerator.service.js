import { createHash } from "node:crypto";
import sharp from "sharp";
import {
  normalizeEvmAddress,
  parsePositiveChainId,
} from "./tokenIcon.service.js";

export const DEFAULT_ICON_SIZE = 128;
export const MAX_ICON_SIZE = 192;
export const MAX_SYMBOL_INITIALS = 3;

const PNG_SIGNATURE = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);

function escapeXml(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&apos;");
}

/**
 * Derive 1–3 uppercase initials from a token symbol.
 * Non-alphanumeric characters are stripped; empty symbols become "?".
 */
export function deriveSymbolInitials(symbol) {
  const cleaned = String(symbol ?? "")
    .trim()
    .toUpperCase()
    .replace(/[^A-Z0-9]/g, "");

  if (!cleaned) return "?";
  return cleaned.slice(0, MAX_SYMBOL_INITIALS);
}

function clampSize(size) {
  const parsed = Number(size);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return DEFAULT_ICON_SIZE;
  }
  return Math.min(Math.floor(parsed), MAX_ICON_SIZE);
}

function hslToHex(h, s, l) {
  const saturation = s / 100;
  const lightness = l / 100;
  const chroma = (1 - Math.abs(2 * lightness - 1)) * saturation;
  const huePrime = h / 60;
  const x = chroma * (1 - Math.abs((huePrime % 2) - 1));
  let r1 = 0;
  let g1 = 0;
  let b1 = 0;

  if (huePrime >= 0 && huePrime < 1) [r1, g1, b1] = [chroma, x, 0];
  else if (huePrime < 2) [r1, g1, b1] = [x, chroma, 0];
  else if (huePrime < 3) [r1, g1, b1] = [0, chroma, x];
  else if (huePrime < 4) [r1, g1, b1] = [0, x, chroma];
  else if (huePrime < 5) [r1, g1, b1] = [x, 0, chroma];
  else [r1, g1, b1] = [chroma, 0, x];

  const m = lightness - chroma / 2;
  const toByte = (value) => Math.round((value + m) * 255);

  const r = toByte(r1);
  const g = toByte(g1);
  const b = toByte(b1);
  return `#${[r, g, b].map((part) => part.toString(16).padStart(2, "0")).join("")}`;
}

function relativeLuminance(hex) {
  const value = hex.replace("#", "");
  const channels = [0, 2, 4].map((offset) => {
    const raw = parseInt(value.slice(offset, offset + 2), 16) / 255;
    return raw <= 0.03928 ? raw / 12.92 : ((raw + 0.055) / 1.055) ** 2.4;
  });
  return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2];
}

export function deriveBackgroundColor(chainId, identityKey) {
  const parsedChainId = parsePositiveChainId(chainId);
  if (parsedChainId === null) {
    throw new Error("Invalid chainId for placeholder icon color");
  }
  if (typeof identityKey !== "string" || identityKey.trim() === "") {
    throw new Error("identityKey is required for placeholder icon color");
  }

  const hash = createHash("sha256")
    .update(`${parsedChainId}:${identityKey.trim().toLowerCase()}`)
    .digest();

  const hue = hash.readUInt16BE(0) % 360;
  const saturation = 52 + (hash[2] % 23);
  const lightness = 40 + (hash[3] % 16);
  return hslToHex(hue, saturation, lightness);
}

export function deriveTextColor(backgroundHex) {
  return relativeLuminance(backgroundHex) > 0.45 ? "#111827" : "#ffffff";
}

function buildPlaceholderSvg({ size, backgroundColor, textColor, initials }) {
  const fontSize = initials.length >= 3 ? Math.floor(size * 0.34) : Math.floor(size * 0.4);
  const safeInitials = escapeXml(initials);

  return `
<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}" viewBox="0 0 ${size} ${size}">
  <circle cx="${size / 2}" cy="${size / 2}" r="${size / 2}" fill="${backgroundColor}" />
  <text
    x="50%"
    y="50%"
    fill="${textColor}"
    font-family="Arial, Helvetica, sans-serif"
    font-size="${fontSize}"
    font-weight="700"
    text-anchor="middle"
    dominant-baseline="central"
  >${safeInitials}</text>
</svg>`;
}

export async function generatePlaceholderIconPng({
  chainId,
  symbol,
  identityKey,
  size = DEFAULT_ICON_SIZE,
}) {
  const parsedChainId = parsePositiveChainId(chainId);
  if (parsedChainId === null) {
    throw new Error("Invalid chainId for placeholder icon generation");
  }
  if (typeof identityKey !== "string" || identityKey.trim() === "") {
    throw new Error("identityKey is required for placeholder icon generation");
  }

  const iconSize = clampSize(size);
  const initials = deriveSymbolInitials(symbol);
  const backgroundColor = deriveBackgroundColor(parsedChainId, identityKey);
  const textColor = deriveTextColor(backgroundColor);
  const svg = buildPlaceholderSvg({
    size: iconSize,
    backgroundColor,
    textColor,
    initials,
  });

  const pngBuffer = await sharp(Buffer.from(svg)).png().toBuffer();
  if (!pngBuffer.subarray(0, PNG_SIGNATURE.length).equals(PNG_SIGNATURE)) {
    throw new Error("Generated icon is not a valid PNG");
  }

  return pngBuffer;
}

export async function generateErc20PlaceholderIcon({
  chainId,
  address,
  symbol,
  size = DEFAULT_ICON_SIZE,
}) {
  const normalizedAddress = normalizeEvmAddress(address);
  if (!normalizedAddress) {
    throw new Error("Invalid ERC20 address for placeholder icon generation");
  }

  return generatePlaceholderIconPng({
    chainId,
    symbol,
    identityKey: normalizedAddress,
    size,
  });
}

export async function generateNativePlaceholderIcon({
  chainId,
  symbol,
  size = DEFAULT_ICON_SIZE,
}) {
  return generatePlaceholderIconPng({
    chainId,
    symbol,
    identityKey: "native",
    size,
  });
}

export function isPngBuffer(bytes) {
  return (
    Buffer.isBuffer(bytes) &&
    bytes.length >= PNG_SIGNATURE.length &&
    bytes.subarray(0, PNG_SIGNATURE.length).equals(PNG_SIGNATURE)
  );
}
