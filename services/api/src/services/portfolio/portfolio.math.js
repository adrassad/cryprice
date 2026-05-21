import Decimal from "decimal.js";
import { formatUnits } from "ethers";

function parseRawBalance(rawValue) {
  if (rawValue === undefined || rawValue === null || rawValue === "") {
    throw new Error("raw balance is required");
  }
  try {
    return BigInt(String(rawValue));
  } catch {
    throw new Error("raw balance must be an integer string");
  }
}

function parseDecimals(decimals) {
  if (!Number.isInteger(decimals) || decimals < 0) {
    throw new Error("decimals must be a non-negative integer");
  }
  return decimals;
}

function toDecimal(value) {
  if (value instanceof Decimal) return value;
  if (value === undefined || value === null || value === "") {
    throw new Error("decimal value is required");
  }
  return new Decimal(String(value));
}

export function sumRawBalances(rawValues) {
  if (!Array.isArray(rawValues)) {
    throw new Error("rawValues must be an array");
  }

  let total = 0n;
  for (const rawValue of rawValues) {
    total += parseRawBalance(rawValue);
  }
  return total.toString();
}

export function formatTokenBalance(balanceRaw, decimals) {
  const raw = parseRawBalance(balanceRaw);
  return formatUnits(raw, parseDecimals(decimals));
}

export function formatUsd(value) {
  return toDecimal(value).toDecimalPlaces(2, Decimal.ROUND_HALF_UP).toFixed(2);
}

export function calculateUsdValue(balance, priceUsd) {
  if (priceUsd === null) return null;

  const balanceDecimal = toDecimal(balance);
  const priceDecimal = toDecimal(priceUsd);
  return formatUsd(balanceDecimal.mul(priceDecimal));
}

export function sumUsdValues(values) {
  if (!Array.isArray(values)) {
    throw new Error("values must be an array");
  }

  let total = new Decimal(0);
  for (const value of values) {
    if (value === null) continue;
    total = total.plus(toDecimal(value));
  }
  return formatUsd(total);
}
