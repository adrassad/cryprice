/**
 * Pure helpers shared by sync path (testable, null-safe).
 */

import { resolveNativeLogoUrl } from "../asset/tokenIcon.service.js";

export function computeDesiredPositiveAssetIds(collected) {
  const ids = new Set();
  const nets = collected?.networks;
  if (!Array.isArray(nets)) return ids;

  for (const n of nets) {
    if (!n || n.status !== "ok") continue;
    const tokens = n.tokens;
    if (!Array.isArray(tokens)) continue;
    for (const t of tokens) {
      if (!t || t.assetId == null || t.assetId === "") continue;
      ids.add(String(t.assetId));
    }
  }
  return ids;
}

export function extractNativePositions(collected) {
  const out = [];
  const nets = collected?.networks;
  if (!Array.isArray(nets)) return out;

  for (const n of nets) {
    if (!n || n.status !== "ok" || n.native == null || typeof n.native !== "object") {
      continue;
    }
    const sym = n.native.symbol;
    const bal = n.native.balanceRaw;
    if (bal == null || bal === "") continue;

    out.push({
      kind: "native",
      networkId: n.networkId,
      networkName: n.networkName,
      chainId: n.chainId,
      symbol: sym != null ? String(sym) : "",
      decimals:
        typeof n.native.decimals === "number" && Number.isFinite(n.native.decimals)
          ? n.native.decimals
          : Number(n.native.decimals) || 0,
      balanceRaw: String(bal),
    });
  }
  return out;
}

export async function enrichNativePositionsWithLogoUrl(positions) {
  if (!Array.isArray(positions) || !positions.length) {
    return positions ?? [];
  }

  return Promise.all(
    positions.map(async (position) => ({
      ...position,
      logo_url:
        position?.chainId != null
          ? await resolveNativeLogoUrl(position.chainId)
          : null,
    })),
  );
}
