# Public export notes

This directory was produced as a **public-safe snapshot** from the private Cryprice backend. The private repository was used **read-only**; all edits live here under `cryprice/backend-public`.

## Removed entirely

| Area | Reason |
|------|--------|
| `src/bot/commands/users.command.js` | Admin user directory |
| `src/bot/commands/upgradetopro.command.js` | Subscription upgrade / payment orchestration |
| `src/bot/guards/admin.guard.js` | Admin-only guard |
| `src/bot/handlers/upgrade.handler.js` | “Upgrade to Pro” callbacks |
| `src/services/subscription/` | Subscription tier checks and `upgradeToPro` |
| `src/services/alerts/` | Price alerts mailed only to “Pro” users via Telegram |
| `payments_pending` DDL in `src/db/init.js` | Payment pipeline storage |
| `src/db/verify/` | Operational SQL snippets not required to run this export |
| `ADMIN_ID` and related bot forwarding | Removes hidden operator linkage |
| `.env`, secrets, `node_modules`, logs | Never shipped |

## Behaviour changes vs private

- **Wallet limits:** enforced by `MAX_WALLETS_PER_USER` (default `50`) instead of subscription tiers (`src/services/wallet/wallet.service.js`).
- **Positions / HF / wallet scenes:** subscription asserts removed; commands remain usable for any user within wallet limits.
- **Cron price sync:** still updates prices; **no mass Telegram price-alert fan-out** to Pro users (alert module removed).
- **`/support`:** static message — no admin inbox or reply sessions (`src/bot/commands/support.command.js`).
- **`wallet` bot command:** admin-only `/wallets` pagination removed; users keep `/add_wallet` via scene + keyboard.
- **REST `user` payloads:** `toPublicUser` no longer exposes `subscription_level` / `subscription_end` (`src/services/auth/auth.service.js`).
- **User repo:** `updateUser` only allows `threshold_hf`; new Telegram/API users get `subscription_end` **NULL** instead of a timed trial insert.

## Database schema

Legacy columns `subscription_level` / `subscription_end` remain on `users` for compatibility with existing databases but are **not used for gating** in this codebase.

## Docs / packaging

- `.env.example` lists placeholders only (no production credentials).
- `docs/AUTH.md` JSON samples updated for the trimmed user object.
- `package.json` metadata points at this public package name; broken `webpack` build script replaced with `node --check`.

## Verification checklist

After pulling this tree:

1. `rg subscription\\.service src` → should be empty.
2. `rg 'ADMIN_ID|upgradetopro|users\\.command' src` → should be empty.
3. No `.env` in git — only `.env.example`.
4. `npm install && npm run build && npm test`.
