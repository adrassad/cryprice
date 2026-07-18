# Public Sync Policy

CryPrice public repository is a **sanitized public edition**. Private repositories are the source of truth; this repository is an export suitable for open review and collaboration.

## Source repositories

Private source repositories (names and paths are intentionally generic — never commit real local machine paths):

- `<private-backend-repository>` — full backend source
- `<private-frontend-repository>` — full Flutter client source
- `<private-marketing-repository>` — full marketing site source

Public repository:

- https://github.com/adrassad/cryprice

## Mapping

| Private source | Public path |
|----------------|-------------|
| Backend | `services/api` |
| Frontend | `apps/web` |
| Marketing | `apps/marketing` |

## Policy

- **Private repositories are the source of truth** for production development.
- **This public repository is a sanitized export** — not a full production replica.
- **Secrets must never be exported** (API keys, JWT secrets, bot tokens, database URLs with credentials, RPC keys, etc.).
- **Private deployment configs must never be exported** (server IPs, SSH users, nginx/pm2/systemd configs, CI deploy secrets).
- **Admin, payment, billing, and private operator modules must never be exported.**
- **Local machine paths, usernames, and private repo absolute paths must never appear** in the public tree.

## Always excluded from export

- `.env`, `.env.*` (real values)
- `src/investor/` and `/invest` investor decks (marketing private only)
- Payment, billing, subscription enforcement, premium plans
- Admin tooling, admin bot commands, operator scripts
- Production deployment scripts and infrastructure details
- User/customer data, wallet data dumps, logs, backups
- `node_modules`, `dist`, `build`, `.dart_tool`, coverage, caches
- `android/local.properties`
- Public Telegram **bot** CTAs (standalone product-entry links to the bot). Founder personal contact links on marketing trust/contact pages are allowed.

## Allowed in public export

- Read-only DeFi monitoring logic
- Portfolio aggregation
- Aave V3 Health Factor monitoring
- Wallet/profile UI
- Authenticated Telegram linking after Google sign-in
- Token icon infrastructure without binary cache
- PDF export
- Tests and documentation
- `.env.example` with placeholders only

## Required checks before publish

Run grep checks for:

- secrets and real credentials
- payment/billing/subscription/admin modules
- public Telegram links outside authenticated backend deep-link generation
- generated build artifacts tracked by git
- `backend-public` references
- `AaveRadar` branding leaks
- local machine paths (`/Users/`, private repo names with absolute paths)

Run validation:

- `scripts/public-sync-check.sh` (when available locally)
- marketing lint/build
- API test/build
- Flutter gen-l10n/analyze/test
- packages typecheck

## Public positioning

CryPrice is **Multi-Chain DeFi Risk Monitoring Infrastructure**.

Do not mention immigration, visa, or USCIS-related framing in public docs.

Planned features must be marked as planned, not as shipped.
