export function formatUsd(value) {
  if (value === null || value === undefined || value === "") return "—";
  const raw = String(value).trim();
  if (raw.startsWith("$")) return raw;
  return `$${raw}`;
}

export function formatPercentage(value) {
  if (value === null || value === undefined || value === "") return "—";
  const raw = String(value).trim();
  return raw.endsWith("%") ? raw : `${raw}%`;
}

export function formatAmount(value) {
  if (value === null || value === undefined || value === "") return "—";
  return String(value);
}

export function shortAddress(address) {
  if (!address) return "—";
  const value = String(address);
  if (value.length <= 12) return value;
  return `${value.slice(0, 6)}...${value.slice(-4)}`;
}

export function formatDateTime(value) {
  if (!value) return "—";
  const date = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(date.getTime())) return "—";
  return `${date.toISOString().replace("T", " ").slice(0, 19)} UTC`;
}

export function formatHealthFactor(value) {
  if (value === null || value === undefined || value === "") return "—";
  if (String(value).toLowerCase() === "infinity") return "∞";
  return String(value);
}

export function getHealthFactorLabel(status, statusLabel) {
  if (statusLabel) return String(statusLabel);
  if (status) return String(status);
  return "—";
}

export function formatPriceDisplay(priceUsd, priceStatus) {
  if (priceStatus === "missing" || priceUsd === null || priceUsd === undefined) {
    return "Price unavailable";
  }
  return formatUsd(priceUsd);
}

export function formatValueDisplay(valueUsd, priceStatus) {
  if (valueUsd === null || valueUsd === undefined) {
    if (priceStatus === "missing") return "Price unavailable";
    return "—";
  }
  if (valueUsd === "0.00" || valueUsd === "0") return formatUsd(valueUsd);
  return formatUsd(valueUsd);
}

export function portfolioReportFilename(date = new Date()) {
  const iso = date instanceof Date ? date.toISOString() : new Date(date).toISOString();
  return `cryprice-portfolio-report-${iso.slice(0, 10)}.pdf`;
}
