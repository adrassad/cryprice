import { strictEqual, ok } from "node:assert";
import { test } from "node:test";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import {
  formatAlertForTelegram,
  formatHealthFactorAlertForTelegram,
  getHFIcon,
} from "../../src/services/alerts/alertTelegram.formatter.js";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");

test("getHFIcon exact threshold mapping and boundaries", () => {
  strictEqual(getHFIcon(Infinity), "♾️");
  strictEqual(getHFIcon("infinity"), "♾️");
  strictEqual(getHFIcon(2.01), "💚");
  strictEqual(getHFIcon(2.0), "💛");
  strictEqual(getHFIcon(1.51), "💛");
  strictEqual(getHFIcon(1.5), "🧡");
  strictEqual(getHFIcon(1.21), "🧡");
  strictEqual(getHFIcon(1.2), "❤️");
  strictEqual(getHFIcon(1.01), "❤️");
  strictEqual(getHFIcon(1.0), "💔");
  strictEqual(getHFIcon(0.99), "💔");
  strictEqual(getHFIcon(null), "");
});

test("health_factor_breach warning message matches compact structure", () => {
  const message = formatHealthFactorAlertForTelegram({
    alert: {
      type: "health_factor_breach",
      severity: "warning",
      title: "Health Factor below your alert threshold",
      wallet_address: "0x31d1234567890abcdef1234567890abcdefadc1",
      previous_hf: "2.00",
      current_hf: "1.66",
      payload: { threshold_hf: 2.0 },
    },
    networkName: "arbitrum",
  });

  ok(message.startsWith("💛 <b>1.66</b>"));
  ok(message.includes("⚠️ <b>Warning</b>"));
  ok(message.includes("Health Factor below your alert threshold"));
  ok(message.includes("📉 Arbitrum: 💛 2.00 → 💛 <b>1.66</b>"));
  ok(message.includes("💼: <b>0x31d1...adc1</b>"));
  ok(!message.includes("🌐 Network:"));
  ok(!message.includes("📉 Change:"));
  ok(message.includes("🎯 Alert threshold: 2.00"));
  ok(!message.includes("Health Factor below threshold"));
  ok(!message.includes("Liquidation"));
});

test("health_factor_breach critical uses Critical label", () => {
  const message = formatAlertForTelegram({
    alert: {
      type: "health_factor_breach",
      severity: "critical",
      wallet_address: "0x1234567890abcdef1234567890abcdef12345678",
      previous_hf: "1.50",
      current_hf: "1.10",
      payload: { threshold_hf: 1.2 },
    },
    networkName: "ethereum",
  });

  ok(message.startsWith("❤️ <b>1.10</b>"));
  ok(message.includes("🚨 <b>Critical</b>"));
  ok(message.includes("Health Factor below your alert threshold"));
  ok(!message.includes("Warning</b>"));
  ok(!message.includes("Liquidation</b>"));
});

test("liquidation breach shows Liquidation headline and embedded network line", () => {
  const message = formatHealthFactorAlertForTelegram({
    alert: {
      type: "health_factor_breach",
      severity: "critical",
      wallet_address: "0x31d1234567890abcdef1234567890abcdefadc1",
      previous_hf: "1.08",
      current_hf: "0.98",
      payload: { threshold_hf: 1.2 },
    },
    networkName: "Arbitrum",
  });

  ok(message.startsWith("💔 <b>0.98</b>"));
  ok(message.includes("🚨 <b>Liquidation</b>"));
  ok(message.includes("Critical situation: your position may be liquidated"));
  ok(!message.includes("Health Factor below"));
  ok(!message.includes("🚨 <b>Critical</b>"));
  ok(message.includes("📉 Arbitrum: ❤️ 1.08 → 💔 <b>0.98</b>"));
  ok(message.includes("🎯 Alert threshold: 1.20"));
});

test("health_factor_recovery uses Recovery label and upward trend line", () => {
  const message = formatHealthFactorAlertForTelegram({
    alert: {
      type: "health_factor_recovery",
      severity: "info",
      wallet_address: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      previous_hf: "1.10",
      current_hf: "1.51",
      payload: { threshold_hf: 1.2 },
    },
    networkName: "Arbitrum",
  });

  ok(message.startsWith("💛 <b>1.51</b>"));
  ok(message.includes("✅ <b>Recovery</b>"));
  ok(message.includes("Health Factor recovered above your alert threshold"));
  ok(message.includes("📈 Arbitrum: ❤️ 1.10 → 💛 <b>1.51</b>"));
  ok(!message.includes("Liquidation"));
  ok(!message.includes("📉 Change:"));
});

test("HF formatter handles missing previous_hf and current_hf", () => {
  const missingPrev = formatHealthFactorAlertForTelegram({
    alert: {
      type: "health_factor_breach",
      severity: "warning",
      wallet_address: "0x1234567890abcdef1234567890abcdef12345678",
      previous_hf: null,
      current_hf: "1.51",
      payload: { threshold_hf: 1.2 },
    },
    networkName: "arbitrum",
  });
  ok(missingPrev.includes("📉 Arbitrum: -- → 💛 <b>1.51</b>"));

  const missingCurr = formatHealthFactorAlertForTelegram({
    alert: {
      type: "health_factor_recovery",
      severity: "info",
      wallet_address: "0x1234567890abcdef1234567890abcdef12345678",
      previous_hf: "1.50",
      current_hf: null,
      payload: { threshold_hf: 1.2 },
    },
    networkName: "arbitrum",
  });
  ok(missingCurr.startsWith("<b>--</b>"));
  ok(missingCurr.includes("📈 Arbitrum: 🧡 1.50 → <b>--</b>"));
});

test("HF values format to 2 decimals", () => {
  const message = formatHealthFactorAlertForTelegram({
    alert: {
      type: "health_factor_breach",
      severity: "warning",
      wallet_address: "0x1234567890abcdef1234567890abcdef12345678",
      previous_hf: "1.5",
      current_hf: "1.514",
      payload: { threshold_hf: 2 },
    },
    networkName: "ethereum",
  });

  ok(message.includes("<b>1.51</b>"));
  ok(message.includes("🧡 1.50 →"));
  ok(message.includes("📉 Ethereum:"));
});

test("buildAlertCopy uses liquidation semantics for HF <= 1.00", async () => {
  const { buildAlertCopy, resolveHealthFactorSemanticState } = await import(
    "../../src/services/alerts/healthFactorAlert.utils.js",
  );

  strictEqual(
    resolveHealthFactorSemanticState(0.98, {
      alertType: "health_factor_breach",
    }),
    "liquidation",
  );
  strictEqual(
    resolveHealthFactorSemanticState(1.08, {
      alertType: "health_factor_breach",
    }),
    "critical",
  );
  strictEqual(
    resolveHealthFactorSemanticState(1.66, {
      alertType: "health_factor_breach",
    }),
    "warning",
  );
  strictEqual(
    resolveHealthFactorSemanticState(1.55, {
      alertType: "health_factor_recovery",
    }),
    "recovery",
  );

  const liquidationCopy = buildAlertCopy(
    { kind: "breach", currentHf: 0.98, previousHf: 1.08 },
    { thresholdHf: 1.2 },
  );
  strictEqual(liquidationCopy.title, "Liquidation");
  ok(liquidationCopy.message.includes("Critical situation"));

  const warningCopy = buildAlertCopy(
    { kind: "breach", currentHf: 1.66, previousHf: 2.0 },
    { thresholdHf: 2.0 },
  );
  ok(warningCopy.title.includes("alert threshold"));

  const recoveryCopy = buildAlertCopy(
    { kind: "recovery", currentHf: 2.3, previousHf: 1.9 },
    { thresholdHf: 2.0 },
  );
  ok(recoveryCopy.message.includes("above your alert threshold"));
});

test("HF formatter escapes HTML in wallet line", () => {
  const message = formatHealthFactorAlertForTelegram({
    alert: {
      type: "health_factor_breach",
      severity: "critical",
      title: "Risk <script>",
      wallet_address: "0x1234567890abcdef1234567890abcdef12345678",
      previous_hf: "1.20",
      current_hf: "1.10",
      payload: { threshold_hf: 1.2 },
    },
    networkName: "ethereum",
  });

  ok(!message.includes("<script>"));
  ok(message.includes("0x1234...5678"));
});

test("alert delivery service uses claim/deliver/fail flow", () => {
  const src = readFileSync(
    join(root, "src/services/alerts/alertDelivery.service.js"),
    "utf8",
  );
  ok(src.includes("deliverPendingAlerts"));
  ok(src.includes("claimPendingDelivery"));
  ok(src.includes("markDeliveryDelivered"));
  ok(src.includes("markDeliveryFailed"));
  ok(src.includes("NotificationService.sendToUser"));
  ok(src.includes("DEFAULT_MAX_ATTEMPTS = 3"));
  ok(src.includes('parse_mode: "HTML"'));
});

test("HF sync triggers non-blocking telegram delivery after v2 evaluation", () => {
  const src = readFileSync(
    join(root, "src/services/healthfactor/healthfactor.service.js"),
    "utf8",
  );
  ok(src.includes("deliverPendingAlerts"));
  ok(src.includes("void runTelegramAlertDelivery()"));
  ok(src.includes("finally"));
});

test("NotificationService returns delivery result", () => {
  const src = readFileSync(join(root, "src/bot/notification.service.js"), "utf8");
  ok(src.includes("return { ok: true }"));
  ok(src.includes("return { ok: false"));
});
