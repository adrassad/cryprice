const DEFAULT_HEALTH_FACTOR_THRESHOLD = 1.2;
const DEFAULT_HEALTH_FACTOR_STALE_AFTER_MS = 15 * 60 * 1000;

function parseFiniteNumber(value) {
  if (typeof value === "number") {
    return Number.isFinite(value) ? value : null;
  }
  if (typeof value === "string" && value.trim() !== "") {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : null;
  }
  return null;
}

function isInfinityLike(value) {
  if (value === Infinity) return true;
  if (typeof value === "string" && value.trim().toLowerCase() === "infinity") {
    return true;
  }

  const finite = parseFiniteNumber(value);
  return finite !== null && finite > 1e20;
}

export function normalizeHealthFactorForApi(rawValue) {
  if (rawValue === null || rawValue === undefined || rawValue === "") {
    return {
      value: null,
      numericValue: null,
      isMissing: true,
      isNoDebt: false,
    };
  }

  if (isInfinityLike(rawValue)) {
    return {
      value: "Infinity",
      numericValue: null,
      isMissing: false,
      isNoDebt: true,
    };
  }

  const finite = parseFiniteNumber(rawValue);
  if (finite === null) {
    return {
      value: null,
      numericValue: null,
      isMissing: true,
      isNoDebt: false,
    };
  }

  return {
    value: finite.toFixed(2),
    numericValue: finite,
    isMissing: false,
    isNoDebt: false,
  };
}

export function getHealthFactorStatus(
  value,
  threshold = DEFAULT_HEALTH_FACTOR_THRESHOLD,
) {
  const normalized = normalizeHealthFactorForApi(value);
  if (normalized.isMissing) return "missing";
  if (normalized.isNoDebt) return "no_debt";

  const hf = normalized.numericValue;
  const thresholdValue = parseFiniteNumber(threshold) ?? DEFAULT_HEALTH_FACTOR_THRESHOLD;

  if (hf <= 1) return "liquidation_risk";
  if (hf <= thresholdValue) return "at_risk";
  if (hf <= 1.5) return "warning";
  if (hf <= 2) return "watch";
  return "safe";
}

export function getHealthFactorStatusLabel(status) {
  switch (status) {
    case "no_debt":
      return "No borrow risk";
    case "safe":
      return "Safe";
    case "watch":
      return "Watch";
    case "warning":
      return "Warning";
    case "at_risk":
      return "At risk";
    case "liquidation_risk":
      return "Liquidation risk";
    case "stale":
      return "Stale";
    case "missing":
    default:
      return "Missing";
  }
}

export function isHealthFactorStale(
  collectedAt,
  staleAfterMs = DEFAULT_HEALTH_FACTOR_STALE_AFTER_MS,
  now = new Date(),
) {
  if (collectedAt === null || collectedAt === undefined || collectedAt === "") {
    return false;
  }

  const collectedAtMs =
    collectedAt instanceof Date
      ? collectedAt.getTime()
      : new Date(collectedAt).getTime();
  const nowMs = now instanceof Date ? now.getTime() : new Date(now).getTime();

  if (Number.isNaN(collectedAtMs) || Number.isNaN(nowMs)) return false;

  // HF history currently inserts only changed values, so an unchanged HF may look stale.
  // Treat this as an informational flag rather than overriding the risk status.
  return nowMs - collectedAtMs > staleAfterMs;
}

function itemHealthFactorValue(item) {
  return item?.healthFactor ?? item?.value ?? null;
}

export function selectSummaryHealthFactor(positionHealthItems) {
  const items = Array.isArray(positionHealthItems) ? positionHealthItems : [];
  if (!items.length) {
    return {
      value: null,
      status: "missing",
      statusLabel: getHealthFactorStatusLabel("missing"),
      protocol: null,
      protocolName: null,
      updatedAt: null,
      stale: false,
    };
  }

  let selectedFinite = null;
  let selectedNoDebt = null;

  for (const item of items) {
    const normalized = normalizeHealthFactorForApi(itemHealthFactorValue(item));
    if (normalized.numericValue !== null) {
      if (
        selectedFinite === null ||
        normalized.numericValue < selectedFinite.normalized.numericValue
      ) {
        selectedFinite = { item, normalized };
      }
      continue;
    }

    if (normalized.isNoDebt && selectedNoDebt === null) {
      selectedNoDebt = { item, normalized };
    }
  }

  const selected = selectedFinite ?? selectedNoDebt;
  if (!selected) {
    return {
      value: null,
      status: "missing",
      statusLabel: getHealthFactorStatusLabel("missing"),
      protocol: null,
      protocolName: null,
      updatedAt: null,
      stale: false,
    };
  }

  const threshold = selected.item?.threshold ?? DEFAULT_HEALTH_FACTOR_THRESHOLD;
  const status = getHealthFactorStatus(selected.normalized.value, threshold);

  return {
    value: selected.normalized.value,
    status,
    statusLabel: getHealthFactorStatusLabel(status),
    protocol: selected.item?.protocol ?? null,
    protocolName: selected.item?.protocolName ?? null,
    updatedAt: selected.item?.updatedAt ?? null,
    stale: Boolean(selected.item?.stale),
  };
}
