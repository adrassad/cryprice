# Public Sync Policy

CryPrice public repository is a sanitized public edition.

## Source repositories

- Backend private: `/path/to/cryprice_backend_private`
- Frontend private: `/path/to/cryprice_frontend_private`
- Marketing private: `/path/to/cryprice_marketing_private`
- Public repo: `/path/to/cryprice`

## Mapping

- Backend → `services/api`
- Frontend → `apps/web`
- Marketing → `apps/marketing`

## Always excluded

- `.env`, `.env.*`
- real secrets, tokens, API keys, RPC URLs, JWT secrets
- payment, billing, subscription enforcement, premium plans
- admin tooling, admin bot commands, operator scripts
- production deployment scripts/configs
- server IPs, SSH users, nginx/pm2/systemd configs
- user/customer data, wallet data dumps, logs, backups
- `node_modules`, `dist`, `build`, `.dart_tool`, coverage, caches
- `android/local.properties`
- public Telegram bot CTAs

## Allowed

- read-only DeFi monitoring logic
- portfolio aggregation
- Aave V3 Health Factor monitoring
- wallet/profile UI
- authenticated Telegram linking after Google sign-in
- token icon infrastructure without binary cache
- PDF export
- tests
- documentation
- `.env.example` with placeholders only

## Required checks

Run grep checks for:
- secrets
- payment/billing/subscription/admin
- public Telegram links
- generated artifacts
- `backend-public`
- `AaveRadar`

## Required validation

- marketing lint/build
- API test/build
- Flutter gen-l10n/analyze/test
- packages typecheck

## Public positioning

CryPrice is Multi-Chain DeFi Risk Monitoring Infrastructure.

Do not mention:
- O-1
- visa
- immigration
- USCIS
- extraordinary ability
- evidence trail

Planned features must be marked as planned.
