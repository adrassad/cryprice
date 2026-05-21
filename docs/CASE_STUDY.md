# CryPrice Case Study

## Summary

CryPrice is Multi-Chain DeFi Risk Monitoring Infrastructure for read-only portfolio visibility, Aave V3 Health Factor monitoring, protocol exposure, allocation intelligence, authenticated Telegram alerts, and PDF reporting.

The system helps users monitor DeFi borrowing and lending positions across multiple wallets and chains from a single layer — without custody, private keys, or transaction execution.

---

## Problem

DeFi risk is fragmented across wallets, networks, protocols, dashboards, and alert channels. Borrowing and lending users often need to monitor collateral, debt, liquidation proximity, and protocol exposure from multiple disconnected tools.

Key pain points:

- Positions spread across Ethereum, L2s, and alternative L1s require chain-hopping to assess total exposure.
- Health Factor and liquidation proximity are protocol-specific and change with market conditions.
- Allocation and protocol concentration are difficult to compute consistently across wallets.
- Alert delivery is often disconnected from the portfolio view users already rely on.

---

## Solution

CryPrice brings wallet holdings, DeFi positions, Aave Health Factor, allocation data, and alerting into one read-only monitoring layer.

Core capabilities:

- **Multi-wallet, multi-chain visibility** — aggregate read-only views across configured wallet addresses.
- **Aave V3 position tracking** — supplied and borrowed positions with Health Factor classification.
- **Allocation intelligence** — backend-calculated allocation series for consistent totals.
- **Authenticated alerting** — Telegram notifications linked in-app after Google sign-in.
- **Portfolio reporting** — server-side PDF export of portfolio snapshots.
- **Price Calculator** — supporting utility for cross-rate and venue comparison.

---

## Technical Scope

| Layer | Technology |
|-------|------------|
| Marketing site | React, Vite |
| Web client | Flutter (Web and mobile targets) |
| API service | Node.js, Express |
| Database | PostgreSQL |
| Cache | Redis |
| Blockchain | ethers.js, protocol adapters |
| Scheduling | node-cron |
| Auth | Google Sign-In, JWT |
| Alerts | Telegram (authenticated in-app linking) |
| Reporting | Server-side PDF generation |

Infrastructure components include blockchain adapters, scheduled sync jobs for assets/prices/Health Factor, and a repository layer over PostgreSQL.

---

## Architecture Decisions

### Read-only monitoring

CryPrice never stores private keys and never executes transactions. All blockchain interaction is read-only via RPC providers configured through environment variables.

### Backend-calculated totals

Allocation series and portfolio totals are computed on the backend to ensure consistency across clients and avoid divergent client-side aggregation logic.

### Protocol adapter design

DeFi protocol reads are isolated behind adapter modules. Aave V3 is the first implemented adapter; the registry pattern supports additional protocols without rewriting core monitoring logic.

### Authenticated Telegram linking

Telegram alert delivery requires an authenticated session. Users link Telegram through an in-app flow after Google sign-in — not via a standalone public bot entry point.

### Frontend does not store secrets

OAuth client IDs are supplied at compile time. API keys, JWT secrets, Telegram tokens, and RPC credentials live only in backend environment configuration.

### Backend mediates sensitive integrations

The API service handles Google token verification, JWT issuance, Telegram bot communication, and external price/RPC calls. Clients interact through authenticated REST endpoints.

---

## Current Scope

**Implemented:**

| Area | Detail |
|------|--------|
| Protocol | Aave V3 |
| Networks | Ethereum, Arbitrum, Avalanche, Base |
| Monitoring | Read-only wallet and position tracking |
| Risk | Health Factor classification and threshold alerting |
| Auth | Google Sign-In + JWT |
| Alerts | Authenticated Telegram linking |
| Reporting | Server-side PDF portfolio reports |

**Explicitly out of scope:**

- Private key storage or wallet custody
- Transaction execution or signing
- Financial advice or guaranteed liquidation prevention

---

## Planned Work

The following are **planned** and **not yet implemented** in the public repository:

- **Risk Insights** — deeper risk analytics and contextual signals
- **Additional protocol adapters** — beyond Aave V3
- **Historical analytics** — time-series views of portfolio and position changes
- **CSV/XLSX export** — structured data export for external analysis
- **PWA notifications** — browser-based push notifications

These items are documented in [`roadmap.md`](roadmap.md) and should not be presented as currently available.
