# CryPrice Frontend

CryPrice Frontend is a Flutter Web application for **multi-chain DeFi portfolio intelligence and risk monitoring**. It visualizes wallet holdings, DeFi supplied/borrowed positions, Aave Health Factor, allocation, protocol exposure, current token prices, and exportable reports using data from the CryPrice backend.

**Live:** [https://cryprice.dev](https://cryprice.dev)

**Dart package:** `cryprice_frontend` (pubspec name). **Product / app name:** **CryPrice**.

CryPrice is **not** just a crypto tracker. It is **Multi-Chain DeFi Risk Monitoring Infrastructure**.

---

## Product Positioning

CryPrice is **Multi-Chain DeFi Risk Monitoring Infrastructure**, focused on:

- **Portfolio visibility** across linked wallets and networks
- **DeFi protocol exposure** (supplied collateral and borrowed debt)
- **Lending/borrowing risk** via Health Factor monitoring
- **Aave V3 Health Factor** display (protocol support is backend-driven; see below)
- **Allocation intelligence** with backend-provided chart series
- **User-friendly reporting** (PDF export)

The app also includes a **Price Calculator** that fetches aggregated CEX/DEX quotes from the CryPrice backend — a supporting utility, not the core product.

---

## Key Features

| Feature | Status |
|--------|--------|
| Google authentication (OAuth 2.0 ID token → backend session) | **Implemented** |
| Multi-wallet portfolio dashboard | **Implemented** |
| Multi-chain wallet holdings | **Implemented** |
| DeFi supplied / borrowed positions | **Implemented** |
| Aave V3 Health Factor & risk status (via portfolio API) | **Implemented** |
| Protocol & wallet filters | **Implemented** |
| DeFi grouping by protocol → network → wallet | **Implemented** |
| Allocation charts (assets, debts, protocols, networks) | **Implemented** |
| Wallet-scoped allocation | **Implemented** |
| Current token prices in portfolio rows | **Implemented** |
| PDF portfolio export (backend-generated) | **Implemented** |
| Telegram account linking & linked status | **Implemented** |
| Profile & wallet management (add / edit label / delete) | **Implemented** |
| EN / RU localization (gen_l10n) | **Implemented** (profile UI partially hardcoded RU) |
| Dark / light theme (user-controlled, persisted) | **Implemented** |
| Price Calculator (CEX off-chain + DEX on-chain quotes) | **Implemented** |
| LLM-powered Risk Insights | **Planned** |
| Portfolio risk factor explanations | **Planned** |
| Protocol risk summaries & incident interpretation | **Planned** |
| Dedicated Health Factor Calculator tab | **Planned** (placeholder UI today) |
| Additional DeFi protocols beyond backend support | **Planned** (frontend is protocol-agnostic) |

**Current DeFi protocol support:** primary implemented protocol is **Aave V3** (`aave-v3`). The frontend is **protocol-extensible** and renders backend-provided protocol data. Planned backend integrations include Fluid, Lido, BENQI, Uniswap V3/V4, and others.

---

## Architecture

- **Flutter** (Dart SDK `^3.7.2`; platforms: Web, Android, iOS, macOS, Linux, Windows)
- **Feature-first Clean Architecture** — `data` / `domain` / `presentation` per feature
- **BLoC / Cubit** state management (`flutter_bloc`)
- **get_it** dependency injection (`lib/core/di/di.dart`)
- **Dio** HTTP clients for backend APIs
- **flutter_secure_storage** for access/refresh tokens
- **google_sign_in** for Google OAuth (Web client id via `--dart-define`)
- **flutter_localizations** + **gen_l10n** (ARB files in `lib/l10n/`)
- **Material 3** + **Google Fonts**

### Folder overview

```
lib/
├── core/
│   ├── config/          # Backend base URL, auth config
│   ├── cubit/           # LocaleCubit (EN/RU)
│   ├── di/              # get_it setup
│   ├── download/        # Web file download helper (PDF export)
│   ├── navigation/      # AppSection enum
│   ├── network/         # API error parsing
│   ├── shell/           # AppShell, nav, theme/locale command menu
│   ├── theme/           # CrypriceTheme (light/dark)
│   ├── utils/
│   └── widgets/         # Shared widgets (e.g. TokenIcon)
├── features/
│   ├── auth/            # Google sign-in, token session, AuthCubit
│   ├── crypto_price/    # Price Calculator (TitleCubit)
│   ├── health_factor/   # Placeholder page (coming soon)
│   ├── portfolio/       # Portfolio dashboard, allocation, PDF export
│   ├── profile/         # User profile, wallets, Telegram linking
│   ├── theme/           # ThemeCubit
│   └── risk_insights/   # (planned) LLM-backed risk explanations via backend API
├── gen_l10n/            # Generated localization (do not edit by hand)
├── l10n/                # app_en.arb, app_ru.arb
└── main.dart            # Bootstrap, MultiBlocProvider, AppAuthGate
```

### App bootstrap

1. `main()` → `setupDependencies()` (get_it)
2. Restore session: `AuthCubit.restore()`, `LocaleCubit.loadLocale()`, `ThemeCubit.loadTheme()`
3. `AppAuthGate`:
   - **Unauthenticated** → `LoginPage` (Google sign-in; auto-prompt on Web)
   - **Authenticated** → `AppShell` with three sections: Price Calculator, Portfolio, Health Factor Calculator (placeholder)

Protected API calls use `AuthSessionService` to attach `Authorization: Bearer <accessToken>` and refresh tokens when needed.

### Future module: `features/risk_insights`

Recommended future feature name: **`risk_insights`** (not `ai_risk` or provider-specific names). The frontend should remain **decoupled from any LLM vendor**; insights will be fetched as structured data from the CryPrice backend.

Planned layout:

```
lib/features/risk_insights/
├── data/           # API client, DTOs for backend-generated insights
├── domain/         # Entities, repository, use cases
└── presentation/   # Cubit, pages, widgets (summaries, factor lists, detail panels)
```

---

## Future: Risk Insights / LLM Analysis Layer

**Status: planned — not implemented in the frontend today.**

CryPrice is designed to support a future **Risk Insights** layer where backend-generated portfolio, protocol, allocation, Health Factor, market, and incident data can be converted into **human-readable explanations**. The frontend should treat this as a dedicated feature module under `features/risk_insights` and must **not** be coupled to any specific LLM provider.

### Intended data flow

**Backend (future):**

- Collects portfolio, risk, news, and protocol data
- Runs LLM or rules-based analysis server-side
- Returns **structured risk insights** via a dedicated API endpoint

**Frontend (future):**

- Displays risk summaries and risk factors
- Lets users inspect *why* a position or protocol is flagged
- Does **not** call LLM providers directly with private wallet data unless explicitly designed, audited, and secured

### Security constraints

- **LLM API keys must never be stored in the frontend.**
- Any LLM inference should go through the **CryPrice backend**.
- Private wallet and risk data must be handled with least-privilege access and clear user consent.

---

## Portfolio System

### Backend endpoint

`GET /portfolio` (authenticated)

### Main response blocks (frontend model)

| Block | Purpose |
|-------|---------|
| `summary` | High-level counts, totals, optional global Health Factor |
| `totals` | Wallet / supplied / borrowed / gross / net USD breakdown |
| `wallets[]` | Per-wallet summary cards (values + HF) |
| `protocolSummaries[]` | Protocol-level summary cards (e.g. Aave V3) |
| `walletHoldings` | Normal on-chain wallet assets (not DeFi positions) |
| `protocolPositions.supplied` | DeFi supplied / collateral positions |
| `protocolPositions.borrowed` | DeFi debt / liabilities |
| `defiRisk` | Global HF + `positionsHealth[]` per wallet/network/protocol |
| `allocation` | Chart-ready allocation series (see below) |
| `networks[]` | Legacy network-grouped assets (still supported) |

### Frontend rules

- **`walletHoldings`** = regular wallet token balances
- **`protocolPositions.supplied`** = supplied DeFi positions
- **`protocolPositions.borrowed`** = liabilities; displayed as **positive USD values** (backend convention)
- **`netValueUsd`** and portfolio totals come from the **backend** — the frontend does **not** recalculate financial totals
- **Filtering** (wallet id, protocol id) selects backend-provided scope fields and visible rows; no local financial math
- **DeFi UI** groups positions by **protocol → network → wallet** using nested `wallets[]` on position rows
- **Current token prices** shown per row (`priceUsd`, `priceStatus`: ok / missing / stale / unknown)

---

## Allocation Charts

The backend provides ready-to-render series under `allocation`:

- `allocation.assets`
- `allocation.debts`
- `allocation.protocols`
- `allocation.networks`
- `allocation.wallets[]` — per-wallet scoped series (each with its own assets/debts/protocols/networks)

**Important:** Debts are **not** mixed into assets. The UI exposes separate modes (Assets / Debts / Protocols / Networks).

The frontend **only selects** the correct series (`selectAllocationSeries`):

- **All wallets** → global `allocation.*` arrays
- **Selected wallet** → matching entry in `allocation.wallets[walletId]`

No frontend aggregation or percentage recalculation.

---

## DeFi Risk / Health Factor

Health Factor data comes from backend `defiRisk`:

- `defiRisk.healthFactor` — portfolio-level HF
- `defiRisk.positionsHealth[]` — per protocol / network / wallet entries

**Statuses:** `no_debt`, `safe`, `watch`, `warning`, `at_risk`, `liquidation_risk`, plus `none`, `missing`, `stale`, `unknown`

**UI behavior:**

- Displayed in summary cards, protocol strips, and DeFi position groups
- Shows **`updatedAt`** freshness line instead of alarming stale badges where implemented
- Scoped overview HF respects wallet + protocol filters using backend summary fields

The separate **Health Factor Calculator** nav tab is a **placeholder** (“Coming soon”). Live HF monitoring is in the **Portfolio** section today.

---

## PDF Export

| | |
|---|---|
| **Endpoint** | `GET /portfolio/export/pdf` |
| **Auth** | Required (`Bearer` token) |
| **Generation** | **Backend** aggregates portfolio and renders PDF |
| **Frontend** | Downloads bytes via Dio; triggers browser download — **no screenshot or client-side PDF generation** |

Filename parsed from `Content-Disposition` when present.

---

## API Integration

Base URL: `CRYPRICE_BACKEND_BASE_URL` (default `https://api.cryprice.dev`)

### Portfolio

| Method | Path | Auth |
|--------|------|------|
| GET | `/portfolio` | Yes |
| GET | `/portfolio/export/pdf` | Yes |

### Auth

| Method | Path | Auth |
|--------|------|------|
| POST | `/auth/google` | No (ID token body) |
| GET | `/auth/me` | Yes |
| POST | `/auth/refresh` | No (refresh token body) |
| POST | `/auth/logout` | No |
| POST | `/auth/link/telegram` | Yes → returns `telegramDeepLink` |

### Profile & wallets

| Method | Path | Auth |
|--------|------|------|
| GET | `/users/me` | Yes |
| PATCH | `/users/me` | Yes |
| GET | `/wallets` | Yes |
| POST | `/wallets` | Yes |
| PATCH | `/wallets/:id` | Yes |
| DELETE | `/wallets/:id` | Yes |

### Prices (Price Calculator)

| Method | Path | Auth |
|--------|------|------|
| GET | `/prices/current/offchain/{symbol}` | No* |
| GET | `/prices/current/onchain/{symbol}` | No* |

\*Price endpoints are public; the app shell still requires login to access the calculator in the current product flow.

All price fetches go through the CryPrice backend — **no direct Binance / CoinGecko calls** in app code.

---

## Environment Variables

Compile-time **`--dart-define`** values (not committed to source):

| Define | Required | Description |
|--------|----------|-------------|
| `CRYPRICE_BACKEND_BASE_URL` | Optional | API base URL. Default: `https://api.cryprice.dev` |
| `GOOGLE_WEB_CLIENT_ID` | **Yes (Web)** | Google OAuth 2.0 **Web application** client id |
| `GOOGLE_SERVER_CLIENT_ID` | Optional | Android server client id for native ID token exchange |
| `CRYPRICE_TELEGRAM_BOT_URL` | Optional | **Not read by Dart source today.** Telegram linking uses backend `telegramDeepLink` from `POST /auth/link/telegram`. Reserved for future bot URL configuration. |
| `FIREBASE_PROJECT_ID` | Push | Firebase project id |
| `FIREBASE_MESSAGING_SENDER_ID` | Push | FCM sender id |
| `FIREBASE_WEB_API_KEY` / `FIREBASE_WEB_APP_ID` | Push (Web) | Web app Firebase config |
| `FIREBASE_ANDROID_API_KEY` / `FIREBASE_ANDROID_APP_ID` | Push (Android) | Android app Firebase config |
| `FIREBASE_IOS_API_KEY` / `FIREBASE_IOS_APP_ID` | Push (iOS) | iOS app Firebase config |
| `FIREBASE_WEB_VAPID_KEY` | Push (Web) | Web push VAPID key for `getToken(vapidKey: …)` |
| `FIREBASE_IOS_BUNDLE_ID` | Push (iOS) | Optional; default `com.example.apiBinanceApp` |

### Firebase Cloud Messaging (push notifications)

Push uses FCM via `firebase_core` + `firebase_messaging`. Push delivery is optional and depends on backend push support in your deployment; this public API edition does not export the private push contract.

**Native config files (add manually per environment):**

| Platform | File |
|----------|------|
| Android | `android/app/google-services.json` |
| iOS | `ios/Runner/GoogleService-Info.plist` + Push Notifications capability in Xcode |
| Web | `build/web/firebase-messaging-sw.js` — generated by `./scripts/web/build_release.sh` and merged into `flutter_service_worker.js` (not registered separately in `index.html`) |

Web FCM config for the service worker can be supplied via environment variables (`FIREBASE_PROJECT_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_WEB_API_KEY`, `FIREBASE_WEB_APP_ID`) or the same `--dart-define` keys passed to `build_release.sh`.

**Example production Web build with push:**

```bash
./scripts/web/build_release.sh \
  --dart-define=CRYPRICE_BACKEND_BASE_URL=https://api.cryprice.dev \
  --dart-define=GOOGLE_WEB_CLIENT_ID=<google-web-client-id>.apps.googleusercontent.com \
  --dart-define=FIREBASE_PROJECT_ID=<project-id> \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=<sender-id> \
  --dart-define=FIREBASE_WEB_API_KEY=<web-api-key> \
  --dart-define=FIREBASE_WEB_APP_ID=<web-app-id> \
  --dart-define=FIREBASE_WEB_VAPID_KEY=<vapid-key>
```

When Firebase dart-defines/env are omitted, the app starts normally; web push background handler is skipped at build time.

See [DEVELOPMENT.md](DEVELOPMENT.md#web-google-sign-in-oauth-20) for Google Sign-In setup (Authorized JavaScript origins must match your `--web-port`).

### Local run (Web)

```bash
flutter pub get
flutter gen-l10n   # if lib/gen_l10n is out of date after ARB edits

flutter run -d chrome --web-port=51916 \
  --dart-define=CRYPRICE_BACKEND_BASE_URL=http://127.0.0.1:3000 \
  --dart-define=GOOGLE_WEB_CLIENT_ID=<google-web-client-id>.apps.googleusercontent.com
```

Android emulator → host machine backend: use `http://10.0.2.2:3000` instead of `127.0.0.1`.

### Production build (Web)

```bash
flutter build web --release \
  --dart-define=CRYPRICE_BACKEND_BASE_URL=https://api.cryprice.dev \
  --dart-define=GOOGLE_WEB_CLIENT_ID=<google-web-client-id>.apps.googleusercontent.com
```

Deploy the `build/web/` output (e.g. to `app.cryprice.dev`). **Use the same `--dart-define` values at build time** — they are baked into the compiled app.

---

## Localization

- **Languages:** English (`en`), Russian (`ru`)
- **Source:** `lib/l10n/app_en.arb`, `lib/l10n/app_ru.arb`
- **Generated:** `lib/gen_l10n/` via Flutter codegen (`flutter: generate: true`, config in `l10n.yaml`)
- **Regenerate after ARB changes:**

```bash
flutter gen-l10n
```

- **Runtime switching:** `LocaleCubit` + shell command menu

---

## Theme

- **Light / dark** Material 3 themes (`CrypriceTheme`)
- **User toggle** in shell command menu; persisted via `ThemeCubit` + `shared_preferences`

---

## Testing & Quality

```bash
flutter pub get
flutter analyze
flutter test
flutter gen-l10n    # when localization files change
```

The project includes unit and widget tests under `test/` (portfolio parsing, allocation selection, auth, shell navigation, etc.).

---

## Deployment Notes

### Why `version.json` must match `APP_BUILD_ID`

The web app detects stale Flutter bundles by comparing:

- **Remote** `/version.json` → `build` field (served from the server after deploy)
- **Embedded** compile-time `APP_BUILD_ID` (baked into `main.dart.js`)

If both stay `"dev"` in production, update detection never fires and users may keep a cached old bundle (especially Safari). Production builds must inject the **same git short SHA** into both places.

| Source | Field / define | Local dev default | Production |
|--------|----------------|-------------------|------------|
| `web/version.json` | `build` | `dev` (committed) | `git rev-parse --short HEAD` |
| Flutter compile | `--dart-define=APP_BUILD_ID` | `dev` (default) | same short SHA |
| Both | `authFlowVersion` / `AUTH_FLOW_VERSION` | `2` | `2` (bump when auth flows change) |

### Production build (recommended)

Use the release script — it generates `web/version.json` and passes the same build id to Flutter:

```bash
./scripts/web/build_release.sh \
  --dart-define=GOOGLE_WEB_CLIENT_ID=<WEB_CLIENT_ID>.apps.googleusercontent.com \
  --dart-define=CRYPRICE_BACKEND_BASE_URL=https://api.cryprice.dev
```

Or step by step:

```bash
BUILD_ID=$(./scripts/web/generate_version_json.sh)
flutter build web --release \
  --dart-define=APP_BUILD_ID="$BUILD_ID" \
  --dart-define=AUTH_FLOW_VERSION=2 \
  --dart-define=GOOGLE_WEB_CLIENT_ID=<WEB_CLIENT_ID>.apps.googleusercontent.com
```

Use `flutter build web --release` only — do **not** pass `--source-maps` for production deploys.

**Local development:** `flutter run -d chrome` does not need the script; defaults (`build: dev`, `APP_BUILD_ID=dev`) are fine.

### Deploy sequence

1. Run `./scripts/web/build_release.sh` (with production `--dart-define` values).
2. Publish **`build/web/`** to static hosting (e.g. `app.cryprice.dev`). Do not upload `*.map` files unless you intentionally want public source maps.
3. Verify deploy metadata (replace origin as needed):

```bash
curl -s https://app.cryprice.dev/version.json
curl -s "https://app.cryprice.dev/version.json?t=$(date +%s)"
# Expect: "build" equals the git SHA you built, "authFlowVersion": 2
```

4. Optional: sync with delete so removed assets do not linger:
3. **Service worker / browser cache:** After deploy, users may need a hard refresh or cache bust if an old Flutter web bundle is cached (`flutter_service_worker.js`). Use `rsync --delete` so removed assets do not linger on the server:

```bash
CRYPRICE_DEPLOY_HOST=user@your-vps ./scripts/web/rsync_deploy.sh \
  --dart-define=GOOGLE_WEB_CLIENT_ID=... \
  --dart-define=FIREBASE_PROJECT_ID=...
```

`rsync_deploy.sh` runs `build_release.sh`, uploads with `--delete`, and fixes SW file permissions on the server (nginx returns **403** if `flutter_service_worker.js` is mode `600`).

Manual rsync:

```bash
rsync -avz --delete build/web/ user@host:/var/www/cryprice-app/
ssh user@host 'sudo bash /path/to/nginx/scripts/post-deploy-fix-sw-perms.sh'
```

### HTTP cache headers (recommended for Nginx or CDN) Serve app shell and update files with **no long-lived cache** so Safari/PWA clients pick up new bundles after deploy:

| Path | Recommended `Cache-Control` |
|------|---------------------------|
| `/`, `/index.html` | `no-store, no-cache, must-revalidate` |
| `/flutter_bootstrap.js` | `no-store, no-cache, must-revalidate` |
| `/flutter_service_worker.js` | `no-store, no-cache, must-revalidate` |
| `/firebase-messaging-sw.js` | `no-store, no-cache, must-revalidate` |
| `/version.json` | `no-store, no-cache, must-revalidate` |
| `/assets/*` (hashed filenames) | `public, max-age=31536000, immutable` |
| `/icons/*`, fonts | long cache if filenames are versioned |

Example Nginx snippet (adjust root/path):

```nginx
location = /index.html { add_header Cache-Control "no-store, no-cache, must-revalidate"; }
location = /flutter_bootstrap.js { add_header Cache-Control "no-store, no-cache, must-revalidate"; }
location = /flutter_service_worker.js { add_header Cache-Control "no-store, no-cache, must-revalidate"; }
location = /firebase-messaging-sw.js { add_header Cache-Control "no-store, no-cache, must-revalidate"; }
location = /version.json { add_header Cache-Control "no-store, no-cache, must-revalidate"; }
location /assets/ { add_header Cache-Control "public, max-age=31536000, immutable"; }
```

### In-app update & cache reset On startup the web app fetches `/version.json` (cache-busted) and compares it with the embedded `APP_BUILD_ID`. When a deploy is detected it shows a non-blocking reload banner; reload clears only app-shell CacheStorage and service workers (auth tokens and user prefs are preserved). A one-reload-per-build guard prevents infinite loops. Auth redirect failures (`?gis_error=`) offer the same safe reload path. Profile still includes a manual **Reset app cache** action (also clears auth tokens). Logout/re-login remounts the shell with fresh user-bound cubits without clearing static assets.

### Google OAuth origins

Ensure Google Cloud **Authorized JavaScript origins** include your production origin (e.g. `https://app.cryprice.dev` or `https://cryprice.dev`).

---

## Security Notes

- Protected APIs require a valid **access token** (`Authorization: Bearer …`)
- Tokens stored in **flutter_secure_storage** (Web has known limitations; session restore may fail gracefully)
- **PDF export** and portfolio data require authentication
- Frontend does **not** store private keys or backend secrets
- `GOOGLE_WEB_CLIENT_ID` is a public OAuth client id (safe in `--dart-define`); never commit client **secrets**

---

## Roadmap

**Near term**

- Dedicated Health Factor Calculator tab
- Full l10n coverage for Profile UI
- CSV / XLSX export
- Historical portfolio analytics

**Risk Insights (future)**

- LLM-powered Risk Insights (backend-mediated)
- Portfolio risk factor explanation
- Protocol risk summaries
- Incident / news-based DeFi risk analysis

**Protocols & infrastructure**

- Additional protocol integrations: Fluid, Lido, BENQI, Uniswap V3/V4, etc.
- More networks
- Advanced risk alerts
- Telegram / PWA notifications
- Optional `CRYPRICE_TELEGRAM_BOT_URL` dart-define for configurable bot links

**Legacy note:** the project was originally scaffolded as a crypto price tracker (`crypto_tracker_app`). The package has been renamed to `cryprice_frontend`; native bundle IDs were left unchanged for deployment safety.

---

## Related Docs

- [DEVELOPMENT.md](DEVELOPMENT.md) — Google Sign-In on Web (OAuth client id, origins, troubleshooting)
