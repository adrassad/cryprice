# Architecture

## Overview

CryPrice is Multi-Chain DeFi Risk Monitoring Infrastructure with a read-only monitoring architecture.

| Component | Role |
|-----------|------|
| **services/api** | Node.js/Express API, blockchain adapters, scheduled sync, caching, alerting |
| **packages/shared** | Shared DTO types, errors, API constants |
| **packages/api-client** | TypeScript HTTP client for API consumers |
| **apps/web** | Flutter Web and mobile client |
| **apps/marketing** | Static React/Vite marketing site |

---

## Data flows

1. Clients (Flutter app, marketing site, SDK, examples) call **services/api**.
2. The API normalizes blockchain reads, applies rate limits, and returns structured responses.
3. Protocol adapters (currently Aave V3) fetch position and Health Factor data across supported networks.
4. PostgreSQL stores users, wallets, positions, and price snapshots.
5. Redis backs caching and rate limiting.
6. Scheduled cron jobs refresh assets, prices, and Health Factor data.
7. Authenticated Telegram alerts are delivered through an in-app linking flow after Google sign-in.

---

## Read-only design

- No private key storage or transaction execution.
- Wallet addresses are monitored via read-only RPC calls.
- Backend-calculated totals and allocation series ensure consistency across clients.
- Sensitive integrations (OAuth, JWT, Telegram, RPC providers) are mediated by the API service via environment configuration.

---

## Protocol and network scope

**Implemented:**

- Protocol: Aave V3
- Networks: Ethereum, Arbitrum, Avalanche, Base

**Planned:**

- Additional protocol adapters
- Risk Insights
- Historical analytics

See [`roadmap.md`](roadmap.md) for planned work.

---

## Public edition

This repository is a sanitized public edition. Production-only modules (billing, subscription enforcement, admin tooling, deployment infrastructure) are intentionally excluded.

See [`SECURITY_MODEL.md`](SECURITY_MODEL.md) and [`../services/api/PUBLIC_EXPORT.md`](../services/api/PUBLIC_EXPORT.md).

---

## Related documentation

- [`CASE_STUDY.md`](CASE_STUDY.md) — product case study
- [`TECHNICAL_CONTRIBUTIONS.md`](TECHNICAL_CONTRIBUTIONS.md) — engineering contributions
- [`setup.md`](setup.md) — local development setup
- [`public-api.md`](public-api.md) — API contract overview
- [`../services/api/README.md`](../services/api/README.md) — API service details
