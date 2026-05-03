# CryPrice marketing site

Public landing page for **CryPrice** — React, TypeScript, and Vite. Source lives in the monorepo under `apps/marketing`.

## Features

- CEX + DEX price aggregation (product overview)
- Links to the web app, monorepo, and backend packages
- Author section and tech stack

## Commands

```bash
npm install
npm run dev
```

```bash
npm run build    # production bundle → dist/
npm run preview  # serve dist locally
npm run lint
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
