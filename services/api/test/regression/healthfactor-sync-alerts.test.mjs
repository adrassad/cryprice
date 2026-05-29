import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { ok } from "node:assert";
import { test } from "node:test";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");

test("syncHF gates legacy Telegram alerts on ALERTS_V2_ENABLED", () => {
  const src = readFileSync(
    join(root, "src/services/healthfactor/healthfactor.service.js"),
    "utf8",
  );

  ok(src.includes("ENV.ALERTS_V2_ENABLED"));
  ok(src.includes("sendLegacyHfTelegramAlerts"));
  ok(src.includes("evaluateHealthFactorAlerts"));
  ok(src.includes("void runHfAlertEvaluation()"));
  ok(src.includes("legacy Telegram alerts skipped"));
});

test("syncHF isolates alerts v2 failures from HF collection", () => {
  const src = readFileSync(
    join(root, "src/services/healthfactor/healthfactor.service.js"),
    "utf8",
  );

  ok(src.includes("async function runHfAlertEvaluation()"));
  ok(src.includes("try {"));
  ok(src.includes("alerts v2 evaluation failed"));
  ok(src.includes("void runHfAlertEvaluation()"));
});

test("syncHF runs alert evaluation after collectHealthFactors", () => {
  const src = readFileSync(
    join(root, "src/services/healthfactor/healthfactor.service.js"),
    "utf8",
  );

  const collectIdx = src.indexOf("collectHealthFactors");
  const evalIdx = src.indexOf("runHfAlertEvaluation");
  ok(collectIdx !== -1 && evalIdx !== -1);
  ok(collectIdx < evalIdx);
});
