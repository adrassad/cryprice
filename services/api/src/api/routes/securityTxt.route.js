import express from "express";

/** Public security contact metadata for the API subdomain. Static; no env data. */
export const API_SECURITY_TXT =
  [
    "Contact: mailto:security@cryprice.dev",
    "Contact: https://x.com/AdrasSad",
    "Acknowledgments: https://cryprice.dev/trust/#acknowledgments",
    "Policy: https://cryprice.dev/security",
    "Expires: 2027-01-01T00:00:00.000Z",
    "Preferred-Languages: en, ru",
    "Canonical: https://cryprice.dev/.well-known/security.txt",
  ].join("\n") + "\n";

export function sendSecurityTxt(_req, res) {
  res.status(200).type("text/plain; charset=utf-8").send(API_SECURITY_TXT);
}

const router = express.Router();

router.get("/", sendSecurityTxt);

export default router;
