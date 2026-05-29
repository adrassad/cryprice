const CRITICAL_HF = 1.2;

export function isInfinityLike(value) {
  if (value === Infinity) return true;
  if (typeof value === "string" && value.trim().toLowerCase() === "infinity") {
    return true;
  }
  const n = Number(value);
  return Number.isFinite(n) && n > 1e20;
}

/**
 * @returns {{ kind: 'finite', value: number } | { kind: 'infinity' } | { kind: 'invalid' }}
 */
export function normalizeHfForEvaluation(value) {
  if (value === null || value === undefined) return { kind: "invalid" };
  if (isInfinityLike(value)) return { kind: "infinity" };

  const n = Number(value);
  if (!Number.isFinite(n)) return { kind: "invalid" };

  return { kind: "finite", value: n };
}

/** @deprecated Prefer isAtOrBelowThreshold for v2 state-based alerts. */
export function isBelowThreshold(hf, thresholdHf) {
  const normalized = normalizeHfForEvaluation(hf);
  const threshold = Number(thresholdHf);
  if (normalized.kind === "invalid" || !Number.isFinite(threshold)) return null;
  if (normalized.kind === "infinity") return false;
  return normalized.value < threshold;
}

/** current_hf <= threshold_hf (Infinity is treated as safe / above threshold). */
export function isAtOrBelowThreshold(hf, thresholdHf) {
  const normalized = normalizeHfForEvaluation(hf);
  const threshold = Number(thresholdHf);
  if (normalized.kind === "invalid" || !Number.isFinite(threshold)) return null;
  if (normalized.kind === "infinity") return false;
  return normalized.value <= threshold;
}

/** current_hf > threshold_hf (Infinity is above any finite threshold). */
export function isAboveThreshold(hf, thresholdHf) {
  const normalized = normalizeHfForEvaluation(hf);
  const threshold = Number(thresholdHf);
  if (normalized.kind === "invalid" || !Number.isFinite(threshold)) return null;
  if (normalized.kind === "infinity") return true;
  return normalized.value > threshold;
}

export function isAtOrAboveThreshold(hf, thresholdHf) {
  const normalized = normalizeHfForEvaluation(hf);
  const threshold = Number(thresholdHf);
  if (normalized.kind === "invalid" || !Number.isFinite(threshold)) return null;
  if (normalized.kind === "infinity") return true;
  return normalized.value >= threshold;
}

export function resolveBreachSeverity(currentHf) {
  const normalized = normalizeHfForEvaluation(currentHf);
  if (normalized.kind === "finite" && normalized.value < CRITICAL_HF) {
    return "critical";
  }
  return "warning";
}

/**
 * User-facing HF semantic state (visual risk from current_hf only).
 * @param {number | typeof Infinity | string | null | undefined} currentHf
 * @param {{ alertType?: string }} [options]
 * @returns {'liquidation' | 'critical' | 'warning' | 'recovery' | 'safe'}
 */
export function resolveHealthFactorSemanticState(currentHf, { alertType } = {}) {
  if (alertType === "health_factor_recovery") {
    return "recovery";
  }

  const normalized = normalizeHfForEvaluation(currentHf);
  if (normalized.kind === "invalid") {
    return "safe";
  }
  if (normalized.kind === "infinity") {
    return "safe";
  }

  if (normalized.value <= 1) {
    return "liquidation";
  }
  if (normalized.value < CRITICAL_HF) {
    return "critical";
  }
  return "warning";
}

function breachSeverityRank(severity) {
  if (severity === "critical") return 2;
  if (severity === "warning") return 1;
  return 0;
}

export function hasSeverityWorsened(previousHf, currentHf) {
  const prevNorm = normalizeHfForEvaluation(previousHf);
  if (prevNorm.kind !== "finite") return false;

  const prevSeverity = resolveBreachSeverity(previousHf);
  const currSeverity = resolveBreachSeverity(currentHf);
  return breachSeverityRank(currSeverity) > breachSeverityRank(prevSeverity);
}

function isPreviousMissing(previousHf) {
  if (previousHf === null || previousHf === undefined) return true;
  return normalizeHfForEvaluation(previousHf).kind === "invalid";
}

/**
 * State-based HF threshold evaluation.
 *
 * Breach: current_hf <= threshold_hf (finite).
 * Recovery: previous_hf <= threshold_hf AND current_hf > threshold_hf.
 *
 * Cooldown / repeat suppression is handled by shouldSuppressAlertByCooldown().
 *
 * @returns {{
 *   kind: 'breach' | 'recovery' | 'none' | 'skip',
 *   reason?: string,
 *   severity?: string,
 *   alertType?: string,
 *   previousHf?: number | typeof Infinity | null,
 *   currentHf?: number | typeof Infinity | null,
 * }}
 */
export function evaluateHfTransition({ previousHf, currentHf, thresholdHf, rule = null } = {}) {
  const threshold = Number(thresholdHf);
  if (!Number.isFinite(threshold)) {
    return { kind: "skip", reason: "invalid_threshold" };
  }

  const currNorm = normalizeHfForEvaluation(currentHf);
  if (currNorm.kind === "invalid") {
    return { kind: "skip", reason: "invalid_hf" };
  }

  const currAbove = isAboveThreshold(currentHf, threshold);
  if (currAbove === null) {
    return { kind: "skip", reason: "invalid_hf" };
  }

  if (currAbove) {
    if (
      !isPreviousMissing(previousHf) &&
      isAtOrBelowThreshold(previousHf, threshold)
    ) {
      return {
        kind: "recovery",
        severity: "info",
        alertType: "health_factor_recovery",
        previousHf,
        currentHf,
      };
    }
    return { kind: "none", reason: "above_threshold" };
  }

  // current_hf <= threshold_hf (at or below)
  if (currNorm.kind === "infinity") {
    return { kind: "none", reason: "above_threshold" };
  }

  return {
    kind: "breach",
    severity: resolveBreachSeverity(currentHf),
    alertType: "health_factor_breach",
    previousHf: isPreviousMissing(previousHf) ? null : previousHf,
    currentHf,
    reason: isPreviousMissing(previousHf)
      ? "missing_previous"
      : rule != null && !rule.last_triggered_at
        ? "first_evaluation"
        : isAboveThreshold(previousHf, threshold)
          ? "crossed_below"
          : "state_below",
  };
}

export function isCooldownActive(rule, now = new Date()) {
  if (!rule?.last_triggered_at) return false;
  const last = new Date(rule.last_triggered_at);
  if (Number.isNaN(last.getTime())) return false;
  const cooldownMinutes = Number(rule.cooldown_minutes ?? 30);
  const cooldownMs = (Number.isFinite(cooldownMinutes) ? cooldownMinutes : 30) * 60_000;
  return now.getTime() - last.getTime() < cooldownMs;
}

/** Cooldown suppresses repeated breach alerts; recovery and severity worsening are not suppressed. */
export function shouldSuppressAlertByCooldown(
  transition,
  rule,
  { previousHf, currentHf } = {},
  now = new Date(),
) {
  if (transition?.kind !== "breach") return false;
  if (hasSeverityWorsened(previousHf, currentHf)) return false;
  return isCooldownActive(rule, now);
}

export function isSnapshotAlreadyProcessed(latestCreatedAt, lastTriggeredAt) {
  if (!latestCreatedAt || !lastTriggeredAt) return false;
  const latest = new Date(latestCreatedAt);
  const last = new Date(lastTriggeredAt);
  if (Number.isNaN(latest.getTime()) || Number.isNaN(last.getTime())) return false;
  return latest.getTime() <= last.getTime();
}

export function formatHfForStorage(hf) {
  const normalized = normalizeHfForEvaluation(hf);
  if (normalized.kind === "infinity") return null;
  if (normalized.kind === "finite") return normalized.value;
  return null;
}

export function formatHfForMessage(hf) {
  const normalized = normalizeHfForEvaluation(hf);
  if (normalized.kind === "infinity") return "∞";
  if (normalized.kind === "finite") return normalized.value.toFixed(2);
  return "n/a";
}

export function buildAlertCopy(transition, { thresholdHf, protocol = "aave" } = {}) {
  const prev = formatHfForMessage(transition.previousHf);
  const curr = formatHfForMessage(transition.currentHf);
  const threshold = Number(thresholdHf).toFixed(2);
  const previousPart =
    transition.previousHf == null ? "" : `, previous ${prev}`;

  if (transition.kind === "breach") {
    const state = resolveHealthFactorSemanticState(transition.currentHf, {
      alertType: "health_factor_breach",
    });

    if (state === "liquidation") {
      return {
        title: "Liquidation",
        message: `Critical situation: your position may be liquidated (Aave ${protocol} HF ${curr}).`,
      };
    }

    if (state === "critical") {
      return {
        title: "Health Factor critical",
        message: `Health Factor below your alert threshold (Aave ${protocol} HF ${curr}, alert threshold ${threshold}${previousPart}).`,
      };
    }

    return {
      title: "Health Factor below your alert threshold",
      message: `Aave ${protocol} HF is ${curr} (alert threshold ${threshold}${previousPart}).`,
    };
  }

  if (transition.kind === "recovery") {
    return {
      title: "Health Factor recovered",
      message: `Health Factor recovered above your alert threshold (Aave ${protocol} HF ${prev} → ${curr}, alert threshold ${threshold}).`,
    };
  }

  return { title: "", message: "" };
}

export const HEALTH_FACTOR_RULE_TYPE = "health_factor_threshold";
