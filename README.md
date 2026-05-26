# CryPrice

**Multi-Chain DeFi Risk Monitoring Infrastructure**

CryPrice is a read-only DeFi monitoring system for portfolio visibility, Aave V3 Health Factor tracking, protocol exposure, allocation intelligence, authenticated Telegram alerts, and server-side portfolio reporting.

Built by **Andrei Sharapov**, a Systems Architect & Full-Stack Developer focused on DeFi risk infrastructure, portfolio intelligence, and blockchain data systems.

---

## What CryPrice does

CryPrice aggregates wallet holdings and DeFi positions across multiple chains into a single monitoring layer. It tracks supplied and borrowed Aave V3 positions, classifies Health Factor risk, surfaces protocol and network exposure, and delivers allocation intelligence computed on the backend.

Supporting capabilities include authenticated Telegram alert delivery after Google sign-in, server-side PDF portfolio reports, and a Price Calculator utility for cross-rate and venue comparison.

CryPrice does **not** store private keys, custody assets, or execute transactions.

---

## Why it matters

DeFi risk is fragmented across wallets, networks, protocols, dashboards, and alert channels. Borrowing and lending users often monitor collateral, debt, liquidation proximity, and protocol exposure from multiple disconnected tools.

CryPrice brings these signals into one read-only monitoring layer so meaningful risk changes surface without juggling separate monitors.

---

## Repository structure

| Path | Purpose |
|------|---------|
| [`apps/marketing`](apps/marketing) | React/Vite marketing landing |
| [`apps/web`](apps/web) | Flutter Web and mobile client |
| [`services/api`](services/api) | Node.js/Express API, blockchain adapters, scheduled sync, alerting |
| [`packages/api-client`](packages/api-client) | TypeScript HTTP client for the public API |
| [`packages/shared`](packages/shared) | Shared types and constants |
| [`docs`](docs) | Architecture, setup, security model, case study |
| [`examples`](examples) | Minimal integration examples |

---

## Current public scope

**Implemented in this repository:**

- **Protocol:** Aave V3
- **Networks:** Ethereum, Arbitrum, Avalanche, Base
- Multi-wallet, multi-chain portfolio visibility
- Supplied and borrowed DeFi position tracking
- Health Factor monitoring and threshold alerting
- Backend-calculated allocation series
- Authenticated Telegram linking after Google sign-in
- Server-side PDF portfolio reports
- Price Calculator (supporting utility)
- React/Vite marketing site
- Flutter Web app with feature-first architecture

**Intentionally excluded from the public edition:**

Production-only modules such as billing, subscription enforcement, payment processing, private admin tooling, and deployment-specific infrastructure are not part of this repository. See [`docs/SECURITY_MODEL.md`](docs/SECURITY_MODEL.md) and [`services/api/PUBLIC_EXPORT.md`](services/api/PUBLIC_EXPORT.md).

---

## Architecture overview

CryPrice follows a read-only monitoring architecture:

1. **Clients** (`apps/web`, marketing site, SDK consumers) call the API with bearer authentication where required.
2. **API service** (`services/api`) mediates blockchain reads, price ingestion, Health Factor computation, caching, and alerting.
3. **Blockchain adapters** normalize protocol-specific reads (currently Aave V3) across supported networks.
4. **PostgreSQL** stores users, wallets, positions, and price snapshots.
5. **Redis** backs caching and rate limiting.
6. **Scheduled jobs** refresh assets, prices, and Health Factor data.
7. **Telegram** delivers alerts through an authenticated in-app linking flow after Google sign-in — not as a standalone public bot entry point.

The frontend does not store secrets. Sensitive integrations (OAuth, JWT, Telegram, RPC providers) are mediated by the backend via environment configuration.

See [`docs/architecture.md`](docs/architecture.md) for details.

---

## Apps and services

### Marketing (`apps/marketing`)

Static React/Vite landing with product overview, tech stack, and repository links.

```bash
cd apps/marketing
npm ci
npm run dev
```

### Web app (`apps/web`)

Flutter client for portfolio monitoring, price lookup, and authenticated flows.

```bash
cd apps/web
flutter pub get
flutter run
```

Configure the API base URL at compile time:

```bash
flutter run --dart-define=CRYPRICE_BACKEND_BASE_URL=http://127.0.0.1:3000
```

### API service (`services/api`)

Node.js/Express backend with PostgreSQL, Redis, blockchain adapters, cron jobs, and Telegram alert delivery.

```bash
cd services/api
cp .env.example .env
npm install
npm test
npm start
```

See [`services/api/README.md`](services/api/README.md) and [`docs/setup.md`](docs/setup.md).

---

## Technical highlights

- Protocol-adapter architecture for extensible DeFi integrations
- Backend-calculated totals and allocation series (not client-side aggregation)
- Multi-chain Aave V3 Health Factor normalization and risk classification
- On-chain and off-chain price ingestion with caching
- Google Sign-In + JWT session API
- Authenticated Telegram alert linking (in-app, post sign-in)
- Server-side PDF portfolio reporting
- Public TypeScript client packages for API consumers (**stubs / planned SDK** — see `packages/`)

See [`docs/TECHNICAL_CONTRIBUTIONS.md`](docs/TECHNICAL_CONTRIBUTIONS.md).

---

## Security model

CryPrice is read-only by design. It does not store private keys, does not custody assets, and does not execute transactions. Monitoring does not guarantee liquidation prevention and is not financial advice.

Production secrets, deployment credentials, and commercially sensitive modules are excluded from this public edition.

See [`docs/SECURITY_MODEL.md`](docs/SECURITY_MODEL.md). To report vulnerabilities, see [`SECURITY.md`](SECURITY.md).

---

## Public edition scope

This repository is a **sanitized public edition** of CryPrice. It includes architecture, core monitoring logic, and integration patterns suitable for review and collaboration. Production-only operational modules are intentionally excluded.

For export provenance and sanitization notes, see [`services/api/PUBLIC_EXPORT.md`](services/api/PUBLIC_EXPORT.md).

---

## Roadmap

**Planned (not yet implemented):**

- Risk Insights
- Additional protocol adapters beyond Aave V3
- Historical analytics
- CSV/XLSX export
- PWA notifications

See [`docs/roadmap.md`](docs/roadmap.md).

---

## Documentation

| Document | Description |
|----------|-------------|
| [`docs/CASE_STUDY.md`](docs/CASE_STUDY.md) | Product case study |
| [`docs/TECHNICAL_CONTRIBUTIONS.md`](docs/TECHNICAL_CONTRIBUTIONS.md) | Engineering contributions |
| [`docs/SECURITY_MODEL.md`](docs/SECURITY_MODEL.md) | Security and public edition scope |
| [`SECURITY.md`](SECURITY.md) | Vulnerability reporting |
| [`docs/DEFERRED_PHASE_2B_AUTH_IDENTITY.md`](docs/DEFERRED_PHASE_2B_AUTH_IDENTITY.md) | Deferred auth/identity migration (Phase 2B) |
| [`docs/architecture.md`](docs/architecture.md) | System architecture |
| [`docs/setup.md`](docs/setup.md) | Local development setup |
| [`docs/public-api.md`](docs/public-api.md) | API contract overview |
| [`docs/roadmap.md`](docs/roadmap.md) | Roadmap |
| [`services/api/README.md`](services/api/README.md) | API service documentation |
| [`services/api/docs/AUTH.md`](services/api/docs/AUTH.md) | Authentication flow |

---

## Getting started

1. Clone the repository.
2. Copy environment files from `.env.example` variants (never commit real secrets).
3. Optionally start PostgreSQL via [`docker-compose.example.yml`](docker-compose.example.yml).
4. Start the API service, then the web app or marketing site.

Full instructions: [`docs/setup.md`](docs/setup.md).

---

## License

See [LICENSE](LICENSE).
