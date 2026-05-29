# Public API

Overview of the CryPrice REST API served by [`services/api`](../services/api).

For implemented route details, see [`services/api/README.md`](../services/api/README.md). For authentication, see [`services/api/docs/AUTH.md`](../services/api/docs/AUTH.md).

---

## Base URL

| Environment | URL |
|-------------|-----|
| Local | `http://localhost:3000` (default `PORT_API`) |
| Production | Configured per deployment (not published in this repository) |

The root `.env.example` defines `CRYPRICE_PUBLIC_API_URL` for client configuration.

---

## Authentication

- **Public read-only endpoints** (health, assets, current prices, networks) operate without authentication.
- **Protected endpoints** (user portfolio, wallet configuration, alert settings) require a valid JWT bearer token obtained via Google Sign-In (`POST /auth/google`).
- Rate limiting is applied per route group in the API server.

---

## Implemented endpoints (selection)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Service liveness check |
| GET | `/assets` | Indexed assets |
| GET | `/prices/current/onchain` | Latest on-chain prices |
| GET | `/prices/current/offchain` | Latest off-chain prices |
| GET | `/networks` | Enabled blockchain networks |
| POST | `/auth/google` | Google Sign-In token exchange (when configured) |
| POST | `/auth/refresh` | Refresh session (when configured) |
| POST | `/auth/logout` | Revoke refresh token |
| GET | `/auth/me` | Current user profile (JWT) |
| POST | `/auth/link/telegram` | Issue Telegram deep-link token for authenticated linking |
| GET | `/users/me` | Current user profile (JWT) |
| PATCH | `/users/me` | Update profile fields (JWT) |
| GET/POST/PATCH/DELETE | `/wallets` | Monitored wallet addresses (JWT) |
| GET | `/portfolio` | Aggregated portfolio dashboard (JWT) |
| GET | `/portfolio/export/pdf` | Server-side PDF export (JWT) |
| GET | `/alerts` | In-app alert inbox (JWT) |
| PATCH | `/alerts/:id/read` | Mark alert read (JWT) |
| GET/POST/PATCH | `/alert-rules` | Health Factor alert rule settings (JWT) |
| GET | `/static/token-icons/:chainId/:file` | Token icon PNG (public read; path-validated) |

Additional portfolio sub-routes may exist for legacy or internal shapes — see [`services/api/docs/API_PORTFOLIO.md`](../services/api/docs/API_PORTFOLIO.md).

---

## Versioning

Route versioning (e.g., `/v1/` prefix) may be introduced as the API stabilizes. Current routes are served at the root path level.

---

## Client packages

- [`packages/api-client`](../packages/api-client) — TypeScript HTTP client (**public stub / planned SDK**)
- [`packages/shared`](../packages/shared) — Shared types and constants (**minimal public stub**)

---

## Public edition note

This document describes the public API surface included in the sanitized repository. Production-only endpoints related to billing, subscription enforcement, and admin operations are intentionally excluded.

OpenAPI specification generation is planned as the API contract stabilizes.

Auth/user identity migration items are tracked in [`docs/DEFERRED_PHASE_2B_AUTH_IDENTITY.md`](DEFERRED_PHASE_2B_AUTH_IDENTITY.md).
