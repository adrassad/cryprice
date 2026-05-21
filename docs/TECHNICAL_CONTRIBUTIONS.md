# Technical Contributions

## Overview

CryPrice demonstrates full-stack DeFi infrastructure engineering across frontend, backend, blockchain data ingestion, monitoring, alerting, and reporting. The public repository reflects the core architecture and implemented monitoring capabilities while excluding production-only operational modules.

---

## Contributions

### Multi-wallet, multi-chain portfolio aggregation

Read-only aggregation of wallet holdings and DeFi positions across Ethereum, Arbitrum, Avalanche, and Base. Users configure monitored wallet addresses; the backend fetches and normalizes position data through blockchain adapters.

### Aave V3 supplied and borrowed position monitoring

Protocol adapter layer for Aave V3 reads supplied and borrowed positions per wallet and network. Position data feeds Health Factor computation, allocation series, and portfolio reporting.

### Health Factor risk classification and threshold alerting

Health Factor values are normalized across networks and classified into risk tiers. Configurable thresholds trigger alert delivery through the authenticated Telegram linking flow.

### Backend-calculated allocation series

Portfolio allocation percentages and totals are computed server-side for consistency. Clients receive pre-calculated series rather than performing independent aggregation.

### Server-side PDF portfolio reporting

Portfolio snapshots are rendered into PDF documents on the backend, keeping report generation logic centralized and independent of client rendering capabilities.

### Authenticated Telegram alert flow after Google sign-in

Telegram is integrated as an alert channel linked through an in-app authenticated flow after Google sign-in. The backend mediates bot communication; there is no standalone public bot entry point.

### Protocol-adapter architecture for future DeFi integrations

Blockchain protocol reads are isolated behind adapter modules with a registry pattern. Aave V3 is the first implemented adapter; the structure supports adding protocols without rewriting core services.

### Read-only wallet monitoring architecture

The system is designed around read-only RPC calls. No private keys are stored, no transactions are signed or broadcast, and no asset custody occurs.

### Flutter feature-first app architecture

The Flutter client (`apps/web`) uses a feature-first structure with BLoC/Cubit state management, compile-time configuration for API endpoints, and separation of data, domain, and presentation layers.

### Public API and client package structure

TypeScript packages (`packages/shared`, `packages/api-client`) provide typed interfaces for API consumers. The API service exposes REST endpoints with rate limiting, JWT authentication, and structured error responses.

---

## Engineering Principles

### Read-only safety

All blockchain interaction is read-only. The architecture assumes no private key access and no transaction execution capability.

### Separation of backend and frontend responsibilities

Sensitive integrations (OAuth verification, JWT issuance, Telegram, RPC providers, price ingestion) are backend responsibilities. The frontend consumes authenticated REST APIs.

### No frontend secrets

API keys, bot tokens, and JWT secrets are never embedded in client code. OAuth client IDs are supplied at compile time via dart-define; all other credentials are backend environment variables.

### Explicit implemented vs planned scope

Documentation and marketing copy distinguish between currently implemented capabilities (Aave V3, four networks) and planned work (Risk Insights, additional adapters, historical analytics, export formats, PWA notifications).

### Reproducible public edition

The public repository is a sanitized export suitable for architecture review and collaboration. Production-only modules (billing, subscription enforcement, admin tooling, deployment infrastructure) are intentionally excluded. See [`SECURITY_MODEL.md`](SECURITY_MODEL.md) and [`../services/api/PUBLIC_EXPORT.md`](../services/api/PUBLIC_EXPORT.md).
