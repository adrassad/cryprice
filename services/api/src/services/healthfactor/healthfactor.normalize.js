/**
 * Pure normalization of adapter `healthFactor` (not the full `{ healthFactor, collected_at }` object).
 * Adapter returns healthFactor from parseHealthFactor: null, Infinity (MaxUint256 / no debt), or finite number.
 *
 * @param {number | null | undefined} hf
 * @returns {{ healthfactor: number | null, skip: boolean }} skip=true → return early without persisting
 */
export function normalizeAdapterHealthFactor(hf) {
  if (hf == null) return { healthfactor: null, skip: true };
  if (hf === Infinity) return { healthfactor: Infinity, skip: false };
  if (!Number.isFinite(hf)) return { healthfactor: null, skip: true };
  return { healthfactor: Number(Number(hf).toFixed(2)), skip: false };
}
