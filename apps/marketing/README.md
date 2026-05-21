# CryPrice marketing site

Public landing page for **CryPrice — Multi-Chain DeFi Risk Monitoring Infrastructure**. React, TypeScript, and Vite. Source lives in the monorepo under `apps/marketing`.

This is a **sanitized public edition**: copy does not promote a standalone Telegram bot entry point. Telegram alerts are described as authenticated in-app linking after Google sign-in.

## Sections

- Hero and trust strip
- Architecture snapshot
- Technical contributions
- Milestones and public work
- Roadmap (implemented vs planned)
- SEO/OG/Twitter metadata (`index.html`, `siteContent.ts`)

Backend links point to **`services/api`**.

## Commands

```bash
npm ci
npm run dev
npm run lint
npm run build    # production bundle → dist/
npm run preview  # serve dist locally
```

Optional URL overrides for forks or staging: copy `.env.example` to `.env` and set `VITE_PUBLIC_*` variables (see `src/siteContent.ts` for defaults).

### Logo asset scripts

- `npm run apply:logo-mark` — regenerate `public/assets/cryprice-logo-mark.png` from `scripts/logo-source.png`
- `npm run generate:logo-gif` — regenerate `public/assets/cryprice-logo-spin.gif`

## Security note for contributors

Do not commit `.env`, API keys, analytics secrets, or private deployment URLs. Use `.env.example` placeholders only.

## Links

| Resource    | URL |
| ----------- | --- |
| Monorepo    | [github.com/adrassad/cryprice](https://github.com/adrassad/cryprice) |
| Web app     | [app.cryprice.dev](https://app.cryprice.dev) |
| API source  | [services/api](https://github.com/adrassad/cryprice/tree/main/services/api) |
