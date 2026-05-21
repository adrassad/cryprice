/**
 * Pure validation for Redis read-through: corrupted/mismatched payloads must fall back to DB.
 */
export function isValidPortfolioSnapshot(walletId, snapshot) {
  if (snapshot == null || typeof snapshot !== "object") return false;
  if (String(snapshot.walletId) !== String(walletId)) return false;
  if (!Array.isArray(snapshot.native)) return false;
  if (!Array.isArray(snapshot.positions)) return false;
  return true;
}
