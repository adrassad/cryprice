import express from "express";

/** Shared read-only security flags for public API trust responses. */
export const API_TRUST_SECURITY = Object.freeze({
  publicAddressesOnly: true,
  noWalletConnection: true,
  noSeedPhrases: true,
  noPrivateKeys: true,
  noSignatures: true,
  noTransactionSigning: true,
  noTransactions: true,
  noCustody: true,
});

/** Public read-only API identity payload for GET /. No secrets or env data. */
export const API_IDENTITY_PAYLOAD = Object.freeze({
  name: "CryPrice API",
  description:
    "Read-only API for public address monitoring, portfolio visibility, and DeFi risk context.",
  status: "ok",
  readOnly: true,
  security: API_TRUST_SECURITY,
  authentication: Object.freeze({
    provider: "Google OAuth",
    purpose: "CryPrice account access only",
    notWalletAccess: true,
  }),
  notifications: Object.freeze({
    telegram: "optional user-configured alerts only",
  }),
  disclaimer:
    "Read-only monitoring API for public address and DeFi risk data. See cryprice.dev/security for details.",
  links: Object.freeze({
    website: "https://cryprice.dev",
    app: "https://app.cryprice.dev",
    security: "https://cryprice.dev/security",
    trust: "https://cryprice.dev/trust",
    transparency: "https://cryprice.dev/transparency",
    privacy: "https://cryprice.dev/privacy",
    terms: "https://cryprice.dev/terms",
    contact: "mailto:support@cryprice.dev",
    contactPage: "https://cryprice.dev/contact",
  }),
});

/** Minimal identity context appended to unknown-route 404 JSON. No secrets or env data. */
export const API_NOT_FOUND_TRUST_PAYLOAD = Object.freeze({
  service: "CryPrice API",
  readOnly: true,
  links: Object.freeze({
    website: "https://cryprice.dev",
    app: "https://app.cryprice.dev",
    security: "https://cryprice.dev/security",
    trust: "https://cryprice.dev/trust",
    transparency: "https://cryprice.dev/transparency",
  }),
});

export function sendApiIdentity(_req, res) {
  res.status(200).json(API_IDENTITY_PAYLOAD);
}

const router = express.Router();

router.get("/", sendApiIdentity);

export default router;
