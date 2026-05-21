import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { ok } from "node:assert";
import { test } from "node:test";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");

test("on-chain price asset_id migration preserves constraints and indexes", () => {
  const src = readFileSync(
    join(root, "src/db/migrateOnchainPriceAssetIdBigint.js"),
    "utf8",
  );

  ok(src.includes("ALTER COLUMN asset_id TYPE BIGINT USING asset_id::bigint"));
  ok(src.includes("DROP CONSTRAINT IF EXISTS current_onchain_prices_pkey"));
  ok(src.includes("ADD CONSTRAINT current_onchain_prices_pkey"));
  ok(src.includes("FOREIGN KEY (asset_id) REFERENCES public.assets(id)"));
  ok(src.includes("CREATE UNIQUE INDEX IF NOT EXISTS ux_onchain_prices_unique_point"));
  ok(src.includes("ON onchain_prices(network_id, asset_id, collected_at)"));
});
