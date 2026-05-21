# Security Model

## Read-only by design

CryPrice does not store private keys, does not custody assets, and does not execute transactions. All blockchain interaction uses read-only RPC calls to fetch position, price, and Health Factor data.

Monitoring provides visibility and alerting — it does not guarantee liquidation prevention and is not financial advice.

---

## Data access

### Authenticated portfolio access

Portfolio data, wallet configuration, and alert settings require authenticated sessions. The API uses bearer token authentication (JWT) for protected routes.

### Wallet addresses are monitored read-only

Users provide wallet addresses for monitoring. CryPrice reads on-chain state through RPC providers but never requests or stores private keys, seed phrases, or signing capabilities.

### Backend APIs use bearer auth where required

Public read-only endpoints (health checks, asset lists, current prices) may operate without authentication. User-specific data and configuration endpoints require valid JWT tokens.

### Telegram linking happens after sign-in

Telegram alert delivery is enabled through an authenticated in-app linking flow after Google sign-in. Users explicitly connect their Telegram account to their CryPrice session. There is no standalone public bot entry point in the product documentation or repository.

---

## Secrets

### Production secrets are excluded from the public repository

Real API keys, JWT secrets, Telegram bot tokens, Google OAuth secrets, database URLs, Redis passwords, RPC provider URLs, and deployment credentials are never committed.

### Environment files must not be committed

`.env` files are gitignored. Only `.env.example` files with placeholder values are tracked. Copy example files locally and fill in real values outside of version control.

### Placeholder names in documentation are allowed

Environment variable names (e.g., `DATABASE_URL`, `JWT_ACCESS_SECRET`, `BOT_TOKEN`) appear in source code, tests, and documentation as references to required configuration — not as embedded secrets.

---

## Public edition

### Private production modules are intentionally excluded

This repository is a sanitized public edition. The following are **not** part of the public tree:

- Billing and subscription enforcement logic
- Payment processing integrations
- Private admin tooling and operator dashboards
- Production deployment configurations and infrastructure details

Some database schema fields related to subscription tiers may remain in the public export as structural artifacts, but the commercial enforcement logic that operates on them is excluded.

### Production deployment details are excluded

Server IPs, SSH credentials, container orchestration configs, CI/CD secrets, and provider-specific deployment scripts are not published in this repository.

For export provenance and sanitization notes, see [`../services/api/PUBLIC_EXPORT.md`](../services/api/PUBLIC_EXPORT.md).

---

## User safety

- **CryPrice is not financial advice.** Monitoring data is informational; users are responsible for their own risk management decisions.
- **Monitoring does not guarantee liquidation prevention.** Health Factor alerts provide visibility into position risk but cannot prevent market-driven liquidations.
- **Read-only architecture limits attack surface.** Without private key storage or transaction execution, the primary security concern is protecting authenticated session data and backend credentials — which are managed through standard JWT, environment variable, and rate-limiting practices.
