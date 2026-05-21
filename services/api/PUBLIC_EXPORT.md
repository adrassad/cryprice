# CryPrice Backend Public Export

This repository is a **sanitized public edition** derived from a private CryPrice backend codebase. The private repository is not published here.

Use this file when syncing or reviewing **what is included vs excluded** from the public tree.

---

## Included in this export

- **Portfolio API** — routes, services, repositories, cache, cron, tests (`src/services/portfolio/`, `src/api/routes/portfolio.route.js`)
- **Wallet and user routes** — authenticated wallet management and user profile (`wallets.route.js`, `users.route.js`)
- **PDF export** — server-side portfolio report generation
- **Protocol asset modules** — asset sync and protocol exposure helpers
- **Token icon service** — routes, services, tests (no binary icon cache or `data/token-icons/` directory)
- **Account link tokens** — repository and authenticated Telegram linking middleware
- **Auth** — Google Sign-In, JWT, `/auth/link/telegram` deep-link flow (backend-generated link only; no public bot CTA in clients)
- **Cron jobs** — protocol asset, portfolio, token icon, price, and Health Factor refresh (safe subsets)
- **Documentation** — `docs/API_PORTFOLIO.md`, `docs/API_PORTFOLIO_FRONTEND_HANDOFF.md`

---

## Intentionally excluded

Do **not** sync the following from the private backend:

| Category | Excluded items |
|----------|----------------|
| **Billing / subscription** | `src/services/subscription/**`, subscription enforcement, paid-feature gates |
| **Payments** | `payments_pending` DDL, payment instruction locales, Stripe/payment env |
| **Admin** | `admin.guard.js`, `users.command.js`, `upgradetopro.command.js`, `upgrade.handler.js`, admin support relay scene, `ADMIN_ID` env |
| **Price alerts (PRO-gated)** | `priceAlert.service.js`, `alerts/` modules, `getAllProUsers`-based alert fan-out |
| **Operational artifacts** | `node_modules/`, `dist/`, production filesystem paths, binary token icon cache, debug scripts |
| **Secrets** | Real values in `.env`; only placeholders in `.env.example` |

Legacy `subscription_*` columns were removed from the public-edition `users` schema. Commercial enforcement logic is excluded.

---

## Sanitization rules

- `.env.example` uses placeholder values only; `TOKEN_ICONS_DIR` examples stay generic.
- Bot profile and support flows must not expose subscription upgrade or payment instructions.
- Telegram is documented as **authenticated in-app linking after Google sign-in**, not a standalone public bot destination.
- Merge (do not blindly overwrite) shared bootstrap files: `server.js`, `init.js`, `runtime.js`, `bootstrap.js`, `env.js`, `cron/index.js`, `wallet.service.js`, bot commands/scenes.

---

## Related documentation

- Architecture: [`README.md`](README.md), [`../../docs/architecture.md`](../../docs/architecture.md)
- Security: [`../../docs/SECURITY_MODEL.md`](../../docs/SECURITY_MODEL.md)
- Environment placeholders: [`.env.example`](.env.example)

**Do not put real secrets or production URLs in this document or anywhere in the repo.**
