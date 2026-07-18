# CryPrice landing — deployment and security checklist

This repository builds the static marketing site for `https://cryprice.dev`. DNS, TLS, and email authentication are configured in Cloudflare (or your DNS provider), not in application code.

Public contact emails:

- **support@cryprice.dev** — general support and contact form delivery
- **security@cryprice.dev** — security reports and `security.txt`
- **privacy@cryprice.dev**, **legal@cryprice.dev**, **press@cryprice.dev**, **founder@cryprice.dev** — role-based inquiries

Contact form: `POST https://api.cryprice.dev/public/contact` (Turnstile verified on the API).

---

## 1. Deploy build output

```bash
npm ci
npm run build
```

Publish the `dist/` directory to your static host / Cloudflare Pages / object storage fronted by Cloudflare.

Verify `dist/.well-known/security.txt` is deployed and reachable.

---

## 2. security.txt

**Source:** `public/.well-known/security.txt` (copied to `dist/.well-known/security.txt` on build)

**Production check:**

```bash
curl -i https://cryprice.dev/.well-known/security.txt
```

Expected fields:

- `Contact: mailto:security@cryprice.dev`
- `Contact: https://x.com/AdrasSad`
- `Acknowledgments: https://cryprice.dev/trust/#acknowledgments`
- `Policy: https://cryprice.dev/security`
- `Canonical: https://cryprice.dev/.well-known/security.txt`

---

## 3. Public trust pages (no login required)

After deploy, each route should return HTTP 200 and must not redirect to `app.cryprice.dev` login:

```bash
curl -I https://cryprice.dev/security
curl -I https://cryprice.dev/privacy
curl -I https://cryprice.dev/terms
curl -I https://cryprice.dev/contact
curl -I https://cryprice.dev/faq
```

**Privacy page — crawler-visible trust text** (`public/_redirects` serves HTML at paths without trailing slash):

```bash
curl -sS https://cryprice.dev/privacy | grep -Ei "wallet address|wallet addresses|public blockchain|Google OAuth|Telegram|read-only|private key|seed|signature|custody|wallet connection"
```

If you still get HTTP 301 with an empty body, the host is not applying `_redirects`; use `curl -sSL` or configure an equivalent rewrite to `privacy/index.html` with HTTP 200.

### Non-existent paths must return HTTP 404

After deploy, suspicious scanner paths must **not** return HTTP 200 with the landing page:

```bash
curl -I https://cryprice.dev/login
curl -I https://cryprice.dev/connect-wallet
curl -I https://cryprice.dev/verify-wallet
curl -I https://cryprice.dev/wallet
curl -I https://cryprice.dev/seed
curl -I https://cryprice.dev/private-key
curl -I https://cryprice.dev/signin
curl -I https://cryprice.dev/signup
curl -I https://cryprice.dev/non-existent-page
```

Expected: `HTTP/2 404` (body from `404.html` when nginx static routing is configured).

Canonical pages must still return HTTP 200:

```bash
curl -I https://cryprice.dev/
curl -I https://cryprice.dev/privacy/
curl -I https://cryprice.dev/terms/
curl -I https://cryprice.dev/security/
curl -I https://cryprice.dev/faq/
curl -I https://cryprice.dev/contact/
```

---

## 4. DMARC DNS record (Cloudflare — manual)

DMARC is a DNS TXT record. **Do not** add DMARC to application runtime or HTML.

In Cloudflare DNS for `cryprice.dev`:

| Field | Value |
|-------|--------|
| **Type** | TXT |
| **Name** | `_dmarc` |
| **Content** | `v=DMARC1; p=none; rua=mailto:support@cryprice.dev; adkim=s; aspf=s` |
| **TTL** | Auto |
| **Proxy** | DNS only (grey cloud / not proxied) |

**Verification:**

```bash
dig TXT _dmarc.cryprice.dev +short
dig @1.1.1.1 TXT _dmarc.cryprice.dev +short
```

Expected output must contain:

```
"v=DMARC1; p=none; rua=mailto:support@cryprice.dev; adkim=s; aspf=s"
```

**Important:** Use `support@cryprice.dev` for `rua=` aggregate reports.

---

## 5. SPF / DKIM (recommended alongside DMARC)

Ensure SPF and DKIM are configured for `cryprice.dev` so DMARC aggregate reports to `support@cryprice.dev` are deliverable. This is outside the landing repository.

---

## 6. HTTP security headers (CDN / origin)

Apply at Cloudflare Transform Rules, Pages `_headers`, or nginx. Example patterns are in `docs/static-hosting-headers.example`.

Recommended (do not weaken existing production headers):

- `Strict-Transport-Security`
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY` or `Content-Security-Policy: frame-ancestors 'none'`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy` (restrict camera, microphone, geolocation, payment)

Verify after deploy:

```bash
curl -I https://cryprice.dev/
```

---

## 7. Cloudflare SSL/TLS

Current expected setting: **Full (strict)** with valid origin certificate.

---

## 8. VirusTotal / vendor false-positive follow-up

After deploy:

1. Re-scan `https://cryprice.dev/` on VirusTotal.
2. Confirm Google Safe Browsing status.
3. Submit false-positive reviews to vendors that still flag the domain.
4. Wait 24–72 hours before retrying X profile website field.

---

## Rollback

**security.txt / site copy:** Revert the git commit and redeploy `dist/`.

**DMARC DNS:** Remove or edit the `_dmarc` TXT record in Cloudflare DNS (DNS only).

**Headers:** Revert Cloudflare Transform Rules or `_headers` to the previous version.

```bash
git revert <commit-sha>
npm run build
# redeploy dist/
```
