import { strictEqual, ok, deepStrictEqual } from "node:assert";
import { test } from "node:test";

import {
  LOGO_SOURCE,
  canReplaceLogoSource,
} from "../../src/services/asset/tokenIcon.service.js";
import {
  buildTrustWalletLogoUrl,
  buildTrustWalletLogoUrlsToTry,
  getTrustWalletChainSlug,
  isAllowedTrustWalletUrl,
  isSupportedTrustWalletChainId,
  normalizeTrustWalletAddress,
  validateTrustWalletPngBytes,
} from "../../src/services/asset/trustWalletIconSource.service.js";
import { isPngBuffer } from "../../src/services/asset/tokenIconGenerator.service.js";

const PNG_SIGNATURE = Buffer.from([
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a,
]);

test("getTrustWalletChainSlug maps supported chain ids", () => {
  strictEqual(getTrustWalletChainSlug(1), "ethereum");
  strictEqual(getTrustWalletChainSlug(42161), "arbitrum");
  strictEqual(getTrustWalletChainSlug(8453), "base");
  strictEqual(getTrustWalletChainSlug(43114), "avalanchec");
  strictEqual(getTrustWalletChainSlug(999), null);
});

test("normalizeTrustWalletAddress rejects invalid addresses", () => {
  strictEqual(normalizeTrustWalletAddress(""), null);
  strictEqual(normalizeTrustWalletAddress("USDC"), null);
  strictEqual(normalizeTrustWalletAddress("0x123"), null);
});

test("buildTrustWalletLogoUrl uses checksum address for USDC", () => {
  const url = buildTrustWalletLogoUrl(
    1,
    "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
  );
  strictEqual(
    url,
    "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png",
  );
  ok(isAllowedTrustWalletUrl(url));
});

test("buildTrustWalletLogoUrlsToTry includes lowercase fallback", () => {
  const urls = buildTrustWalletLogoUrlsToTry(
    1,
    "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
  );
  deepStrictEqual(urls, [
    "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png",
    "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48/logo.png",
  ]);
});

test("isAllowedTrustWalletUrl rejects arbitrary hosts and paths", () => {
  ok(
    !isAllowedTrustWalletUrl(
      "https://evil.example/trustwallet/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png",
    ),
  );
  ok(
    !isAllowedTrustWalletUrl(
      "https://raw.githubusercontent.com/other/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png",
    ),
  );
  ok(!isAllowedTrustWalletUrl("https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xABC/logo.svg"));
  ok(
    !isAllowedTrustWalletUrl(
      "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/../other/logo.png",
    ),
  );
});

test("validateTrustWalletPngBytes accepts PNG magic bytes only", () => {
  ok(
    validateTrustWalletPngBytes(
      Buffer.concat([PNG_SIGNATURE, Buffer.from("x")]),
    ),
  );
  ok(!validateTrustWalletPngBytes(Buffer.from("not-a-png")));
  ok(isPngBuffer(Buffer.concat([PNG_SIGNATURE, Buffer.from("x")])));
});

test("overwrite policy allows trust_wallet over generated but not manual", () => {
  ok(canReplaceLogoSource(LOGO_SOURCE.GENERATED, LOGO_SOURCE.TRUST_WALLET));
  ok(canReplaceLogoSource(null, LOGO_SOURCE.TRUST_WALLET));
  ok(!canReplaceLogoSource(LOGO_SOURCE.MANUAL, LOGO_SOURCE.TRUST_WALLET));
  ok(isSupportedTrustWalletChainId(1));
  ok(!isSupportedTrustWalletChainId(56));
});
