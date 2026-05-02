# Cryprice backend (public export)

Reference backend for monitoring **Aave Health Factor**, wallet-linked positions, on-chain/off-chain prices, and optional **Google JWT auth**. This tree is a **sanitized snapshot**: commercial admin flows, payments, and subscription gating were removed (see `PUBLIC_EXPORT.md`).

## Requirements

- Node.js 20+
- PostgreSQL
- Redis
- Telegram bot token (`BOT_TOKEN`)
- RPC URLs and block explorer API keys per chain (see `.env.example`)

## Setup

```bash
cp .env.example .env
# Fill DATABASE_URL, BOT_TOKEN, Redis, RPC/explorer keys, optional GEMINI_* and GOOGLE_CLIENT_ID / JWT_*.

npm install
npm run build
npm test
npm start
```

`npm start` connects Redis, bootstraps DB DDL/migrations from `src/db/init.js`, starts cron jobs, the Telegram bot, and the HTTP API on `PORT_API` (default `3000`).

## REST API (selection)

| Prefix | Purpose |
|--------|---------|
| `/health` | Liveness |
| `/assets` | Indexed assets |
| `/prices/current/onchain`, `/prices/current/offchain` | Latest prices |
| `/networks` | Enabled chains |
| `/auth/*` | Google sign-in + JWT (requires configured `GOOGLE_CLIENT_ID` + `JWT_ACCESS_SECRET`; see `docs/AUTH.md`) |

Rate limiting middleware is applied per-route (see `src/api/server.js`).

## Telegram bot

User flows: wallets, HF/positions, thresholds, optional `ai:` Gemini prompts. **`/support`** only shows a static notice (no operator relay in this export).

## Security

- Never commit `.env` or real credentials.
- Rotate any token that ever touched an untrusted clone.
- Restrict explorer/RPC keys with provider dashboards where possible.

## License

See `LICENSE`.
