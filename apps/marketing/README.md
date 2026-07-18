# CryPrice Landing Page

Public marketing site for **CryPrice** — **Multi-Chain DeFi Risk Monitoring Infrastructure**.

CryPrice is a read-only monitoring platform for DeFi users who borrow, lend, and manage risk across multiple wallets and networks. It does not execute transactions, store private keys, or provide financial advice.

## Product highlights

- Read-only wallet monitoring across Ethereum, Arbitrum, Avalanche, and Base
- Multi-wallet portfolio visibility and backend-calculated allocation views
- Aave V3 Health Factor monitoring and supplied/borrowed position tracking
- Protocol and network exposure views
- Telegram alerts configured after sign-in and in-app account linking
- Server-side PDF portfolio reports
- CEX/DEX price calculator as a supporting utility (not the core product)

**Implemented:** Aave V3 monitoring, portfolio aggregation, Health Factor alerts, PDF export, authenticated Telegram flow.

**Planned:** Risk Insights, additional DeFi protocol adapters, historical analytics, CSV/XLSX export.

## Founder

Built by **Andrei Sharapov** — Systems Architect & Full-Stack Developer focused on DeFi risk infrastructure, portfolio intelligence, and blockchain data systems.

Public profiles: [GitHub](https://github.com/adrassad) · [X](https://x.com/AdrasSad) · [LinkedIn](https://www.linkedin.com/in/adrassad)

## Technical contributions

- Multi-wallet, multi-chain portfolio aggregation
- Aave V3 supplied and borrowed position monitoring
- Health Factor risk classification and threshold alerting
- Backend-calculated allocation intelligence
- Server-side PDF portfolio reporting
- Authenticated Telegram alert flow after Google sign-in
- Protocol-adapter architecture for future DeFi integrations
- Read-only architecture with no private key custody

## Project milestones

- Price aggregation prototype
- Multi-wallet portfolio dashboard
- Aave V3 Health Factor monitoring
- Telegram account linking and risk alerts
- PDF portfolio reporting
- Planned: Risk Insights and additional protocol adapters

## Tech stack

**CryPrice product**

- Flutter Web (portfolio dashboard, wallet management, EN/RU localization)
- Node.js + Express backend (read-only aggregation, alerting, PDF export)
- PostgreSQL, Redis, Telegram bot (in-app linking)

**This repository**

- React, TypeScript, Vite (static marketing site)

## Getting started

```bash
npm install
npm run dev
```

Open the local URL printed in the terminal to preview the site.

### Contact form (Turnstile)

The `/contact` form requires a Cloudflare Turnstile **site key** at build time:

```bash
# apps/marketing/.env (local) or Cloudflare Pages → Environment variables (production)
VITE_TURNSTILE_SITE_KEY=your_turnstile_site_key
```

The matching secret (`TURNSTILE_SECRET_KEY`) belongs only on the API (`POST /public/contact`). Without the site key, the form shows as temporarily unavailable and falls back to email links.

## Links

| Resource | Link |
| --- | --- |
| Marketing site | [cryprice.dev](https://cryprice.dev/) |
| Main app | [app.cryprice.dev](https://app.cryprice.dev) |
| API | [api.cryprice.dev](https://api.cryprice.dev) |
| Trust hub | [cryprice.dev/trust](https://cryprice.dev/trust) |
| Transparency | [cryprice.dev/transparency](https://cryprice.dev/transparency) |
| Security | [cryprice.dev/security](https://cryprice.dev/security) |
| Contact | [cryprice.dev/contact](https://cryprice.dev/contact) |
| Repository | [github.com/adrassad/cryprice](https://github.com/adrassad/cryprice) |
| Author — X | [x.com/AdrasSad](https://x.com/AdrasSad) |
| Author — GitHub | [github.com/adrassad](https://github.com/adrassad) |
