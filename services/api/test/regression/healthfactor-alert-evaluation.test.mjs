import { strictEqual, deepStrictEqual } from "node:assert";
import { test } from "node:test";
import {
  evaluateHfTransition,
  hasSeverityWorsened,
  isAtOrBelowThreshold,
  isCooldownActive,
  isSnapshotAlreadyProcessed,
  resolveBreachSeverity,
  shouldSuppressAlertByCooldown,
} from "../../src/services/alerts/healthFactorAlert.utils.js";

test("state-based: previous 1.54 → current 1.55, threshold 2.0 → breach", () => {
  const result = evaluateHfTransition({
    previousHf: 1.54,
    currentHf: 1.55,
    thresholdHf: 2.0,
    rule: { last_triggered_at: null },
  });
  strictEqual(result.kind, "breach");
  strictEqual(result.alertType, "health_factor_breach");
  strictEqual(result.severity, "warning");
});

test("state-based: missing previous → current 1.55, threshold 2.0 → breach", () => {
  const result = evaluateHfTransition({
    previousHf: null,
    currentHf: 1.55,
    thresholdHf: 2.0,
  });
  strictEqual(result.kind, "breach");
  strictEqual(result.reason, "missing_previous");
});

test("state-based: current equals threshold 2.0 → breach", () => {
  const result = evaluateHfTransition({
    previousHf: 2.5,
    currentHf: 2.0,
    thresholdHf: 2.0,
    rule: { last_triggered_at: null },
  });
  strictEqual(result.kind, "breach");
  strictEqual(isAtOrBelowThreshold(2.0, 2.0), true);
});

test("state-based: previous 1.50 → current 1.55, threshold 2.0, cooldown active → suppressed", () => {
  const rule = {
    last_triggered_at: "2026-05-22T12:00:00.000Z",
    cooldown_minutes: 30,
  };
  const now = new Date("2026-05-22T12:10:00.000Z");
  const transition = evaluateHfTransition({
    previousHf: 1.5,
    currentHf: 1.55,
    thresholdHf: 2.0,
    rule,
  });
  strictEqual(transition.kind, "breach");
  strictEqual(
    shouldSuppressAlertByCooldown(transition, rule, { previousHf: 1.5, currentHf: 1.55 }, now),
    true,
  );
});

test("state-based: previous 1.50 → current 1.55, threshold 2.0, cooldown expired → not suppressed", () => {
  const rule = {
    last_triggered_at: "2026-05-22T12:00:00.000Z",
    cooldown_minutes: 30,
  };
  const now = new Date("2026-05-22T12:31:00.000Z");
  const transition = evaluateHfTransition({
    previousHf: 1.5,
    currentHf: 1.55,
    thresholdHf: 2.0,
    rule,
  });
  strictEqual(transition.kind, "breach");
  strictEqual(isCooldownActive(rule, now), false);
  strictEqual(
    shouldSuppressAlertByCooldown(transition, rule, { previousHf: 1.5, currentHf: 1.55 }, now),
    false,
  );
});

test("state-based: severity improves but still below → cooldown still applies", () => {
  const rule = {
    last_triggered_at: "2026-05-22T12:00:00.000Z",
    cooldown_minutes: 30,
  };
  const now = new Date("2026-05-22T12:10:00.000Z");
  const transition = evaluateHfTransition({
    previousHf: 1.1,
    currentHf: 1.3,
    thresholdHf: 2.0,
    rule,
  });
  strictEqual(transition.kind, "breach");
  strictEqual(hasSeverityWorsened(1.1, 1.3), false);
  strictEqual(
    shouldSuppressAlertByCooldown(transition, rule, { previousHf: 1.1, currentHf: 1.3 }, now),
    true,
  );
});

test("state-based: severity worsens to critical → bypasses cooldown", () => {
  const rule = {
    last_triggered_at: "2026-05-22T12:00:00.000Z",
    cooldown_minutes: 30,
  };
  const now = new Date("2026-05-22T12:10:00.000Z");
  const transition = evaluateHfTransition({
    previousHf: 1.3,
    currentHf: 1.1,
    thresholdHf: 2.0,
    rule,
  });
  strictEqual(transition.kind, "breach");
  strictEqual(transition.severity, "critical");
  strictEqual(hasSeverityWorsened(1.3, 1.1), true);
  strictEqual(isCooldownActive(rule, now), true);
  strictEqual(
    shouldSuppressAlertByCooldown(transition, rule, { previousHf: 1.3, currentHf: 1.1 }, now),
    false,
  );
});

test("state-based: previous 1.55 → current 2.01, threshold 2.0 → recovery", () => {
  const result = evaluateHfTransition({
    previousHf: 1.55,
    currentHf: 2.01,
    thresholdHf: 2.0,
  });
  deepStrictEqual(result, {
    kind: "recovery",
    severity: "info",
    alertType: "health_factor_recovery",
    previousHf: 1.55,
    currentHf: 2.01,
  });
});

test("evaluateHfTransition crossing down still produces breach", () => {
  const result = evaluateHfTransition({
    previousHf: 1.5,
    currentHf: 1.1,
    thresholdHf: 1.2,
    rule: { last_triggered_at: "2026-05-22T11:00:00.000Z" },
  });
  strictEqual(result.kind, "breach");
  strictEqual(result.severity, "critical");
  strictEqual(result.reason, "crossed_below");
});

test("evaluateHfTransition breach above 1.2 but at/below custom threshold is warning", () => {
  const result = evaluateHfTransition({
    previousHf: 1.6,
    currentHf: 1.4,
    thresholdHf: 1.5,
  });
  strictEqual(result.kind, "breach");
  strictEqual(result.severity, "warning");
});

test("evaluateHfTransition detects recovery to Infinity (no debt)", () => {
  const result = evaluateHfTransition({
    previousHf: 1.1,
    currentHf: Infinity,
    thresholdHf: 1.2,
  });
  strictEqual(result.kind, "recovery");
  strictEqual(result.severity, "info");
});

test("evaluateHfTransition skips invalid current HF", () => {
  strictEqual(
    evaluateHfTransition({ previousHf: 1.5, currentHf: NaN, thresholdHf: 1.2 }).reason,
    "invalid_hf",
  );
});

test("evaluateHfTransition returns none when current HF above threshold", () => {
  strictEqual(
    evaluateHfTransition({
      previousHf: 2.5,
      currentHf: 2.5,
      thresholdHf: 2.0,
    }).reason,
    "above_threshold",
  );
});

test("evaluateHfTransition returns none when Infinity stays safe", () => {
  strictEqual(
    evaluateHfTransition({
      previousHf: Infinity,
      currentHf: Infinity,
      thresholdHf: 1.2,
    }).reason,
    "above_threshold",
  );
});

test("isCooldownActive respects rule cooldown_minutes", () => {
  const now = new Date("2026-05-22T12:00:00.000Z");
  strictEqual(
    isCooldownActive(
      { last_triggered_at: "2026-05-22T11:45:00.000Z", cooldown_minutes: 30 },
      now,
    ),
    true,
  );
  strictEqual(
    isCooldownActive(
      { last_triggered_at: "2026-05-22T11:00:00.000Z", cooldown_minutes: 30 },
      now,
    ),
    false,
  );
});

test("isSnapshotAlreadyProcessed prevents reprocessing same HF snapshot", () => {
  strictEqual(
    isSnapshotAlreadyProcessed(
      "2026-05-22T11:00:00.000Z",
      "2026-05-22T11:05:00.000Z",
    ),
    true,
  );
  strictEqual(
    isSnapshotAlreadyProcessed(
      "2026-05-22T11:10:00.000Z",
      "2026-05-22T11:05:00.000Z",
    ),
    false,
  );
});

test("resolveBreachSeverity marks HF below 1.2 as critical", () => {
  strictEqual(resolveBreachSeverity(1.19), "critical");
  strictEqual(resolveBreachSeverity(1.25), "warning");
});

test("recovery is never suppressed by cooldown", () => {
  const rule = {
    last_triggered_at: "2026-05-22T12:00:00.000Z",
    cooldown_minutes: 30,
  };
  const now = new Date("2026-05-22T12:05:00.000Z");
  const recoveryTransition = evaluateHfTransition({
    previousHf: 1.1,
    currentHf: 1.5,
    thresholdHf: 1.2,
  });
  strictEqual(recoveryTransition.kind, "recovery");
  strictEqual(
    shouldSuppressAlertByCooldown(recoveryTransition, rule, { previousHf: 1.1, currentHf: 1.5 }, now),
    false,
  );
});

test("first evaluation with last_triggered_at null marks first_evaluation reason", () => {
  const result = evaluateHfTransition({
    previousHf: 1.54,
    currentHf: 1.55,
    thresholdHf: 2.0,
    rule: { last_triggered_at: null },
  });
  strictEqual(result.kind, "breach");
  strictEqual(result.reason, "first_evaluation");
});
