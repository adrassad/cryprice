import { strictEqual, ok } from "node:assert";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { test } from "node:test";
import Decimal from "decimal.js";

import {
  calculateUsdValue,
  formatTokenBalance,
  formatUsd,
  sumRawBalances,
  sumUsdValues,
} from "../../src/services/portfolio/portfolio.math.js";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");

test("formatTokenBalance formats 18 decimal raw balances", () => {
  strictEqual(
    formatTokenBalance("1234567890123456789", 18),
    "1.234567890123456789",
  );
});

test("formatTokenBalance formats 6 decimal raw balances", () => {
  strictEqual(formatTokenBalance("250000000", 6), "250.0");
  strictEqual(formatTokenBalance("123456789", 6), "123.456789");
});

test("sumRawBalances sums integer strings using BigInt", () => {
  strictEqual(
    sumRawBalances([
      "9007199254740993",
      "9007199254740993",
      "14",
    ]),
    "18014398509482000",
  );
});

test("calculateUsdValue multiplies token balance and price with Decimal", () => {
  strictEqual(calculateUsdValue("250.0", "1.0001"), "250.03");
  strictEqual(calculateUsdValue("1.23456789", "2000.12345678"), "2469.29");
});

test("calculateUsdValue returns null for missing price", () => {
  strictEqual(calculateUsdValue("250.0", null), null);
});

test("calculateUsdValue preserves actual zero price as zero USD", () => {
  strictEqual(calculateUsdValue("250.0", "0"), "0.00");
  strictEqual(calculateUsdValue("250.0", "0.000000000000000000"), "0.00");
});

test("sumUsdValues ignores missing values and returns formatted string total", () => {
  strictEqual(sumUsdValues(["100.01", null, "250.03", "0.00"]), "350.04");
  strictEqual(sumUsdValues([null, null]), "0.00");
});

test("formatUsd accepts Decimal or string and rounds half up to cents", () => {
  strictEqual(formatUsd(new Decimal("1.005")), "1.01");
  strictEqual(formatUsd("1.004"), "1.00");
});

test("portfolio math helper avoids unsafe Number conversion paths", () => {
  const src = readFileSync(
    join(root, "src/services/portfolio/portfolio.math.js"),
    "utf8",
  );

  ok(!src.includes("Number("));
  ok(src.includes("BigInt("));
  ok(src.includes("new Decimal("));
  ok(src.includes("formatUnits("));
});
