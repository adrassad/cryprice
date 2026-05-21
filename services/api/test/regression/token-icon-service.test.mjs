import { strictEqual } from "node:assert";
import { test } from "node:test";

import {
  LOGO_STATUS,
  appendLogoCacheBuster,
  buildLogoCacheBuster,
  buildPublicUrlForAssetLogo,
} from "../../src/services/asset/tokenIcon.service.js";

const SAMPLE_HASH =
  "a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3";

test("buildPublicUrlForAssetLogo returns cache-busted URL with logo_content_hash", () => {
  strictEqual(
    buildPublicUrlForAssetLogo(
      {
        logo_status: LOGO_STATUS.READY,
        logo_local_path:
          "1/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48.png",
        logo_content_hash: SAMPLE_HASH,
      },
      1,
    ),
    `/static/token-icons/1/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48.png?v=${SAMPLE_HASH}`,
  );
});

test("buildPublicUrlForAssetLogo falls back to logo_updated_at when hash missing", () => {
  strictEqual(
    buildPublicUrlForAssetLogo(
      {
        logo_status: LOGO_STATUS.READY,
        logo_local_path:
          "1/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48.png",
        logo_updated_at: "2026-05-21T12:00:00.000Z",
      },
      1,
    ),
    "/static/token-icons/1/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48.png?v=1779364800000",
  );
});

test("buildLogoCacheBuster prefers content hash over updated_at", () => {
  strictEqual(
    buildLogoCacheBuster({
      logo_content_hash: SAMPLE_HASH,
      logo_updated_at: "2026-05-21T12:00:00.000Z",
    }),
    SAMPLE_HASH,
  );
});

test("appendLogoCacheBuster leaves URL unchanged when buster missing", () => {
  strictEqual(
    appendLogoCacheBuster("/static/token-icons/1/0xabc.png", null),
    "/static/token-icons/1/0xabc.png",
  );
});

test("buildPublicUrlForAssetLogo returns null for invalid or mismatched metadata", () => {
  strictEqual(
    buildPublicUrlForAssetLogo(
      {
        logo_status: LOGO_STATUS.READY,
        logo_local_path: "../../../etc/passwd",
      },
      1,
    ),
    null,
  );
  strictEqual(
    buildPublicUrlForAssetLogo(
      {
        logo_status: LOGO_STATUS.READY,
        logo_local_path:
          "42161/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48.png",
      },
      1,
    ),
    null,
  );
  strictEqual(
    buildPublicUrlForAssetLogo(
      {
        logo_status: LOGO_STATUS.PENDING,
        logo_local_path:
          "1/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48.png",
      },
      1,
    ),
    null,
  );
});
