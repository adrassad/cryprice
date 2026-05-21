# CryPrice — Flutter app (`apps/web`)

Public Flutter client for the CryPrice API. Package name: **`cryprice_frontend`**. In this monorepo the app lives under **`apps/web`**.

## Features

- **Portfolio** — multi-wallet, multi-chain visibility with backend-calculated allocation.
- **Health Factor** — Aave V3 supplied/borrowed positions and risk classification.
- **Profile** — Google Sign-In, authenticated Telegram linking (in-app only; no public bot CTA).
- **PDF reports** — download server-generated portfolio snapshots.
- **Prices** — off-chain and on-chain price lookup; Price Calculator utility.
- English / Russian UI, light and dark themes, Material 3, BLoC/Cubit.

Subscription, upgrade, and payment UI are **not** part of the public edition.

## Configuration (no secrets in the repo)

Runtime API hosts are **not** hardcoded to production URLs. Pass base URLs and OAuth client ids at **compile time** with `--dart-define=...` (see [`.env.example`](.env.example) and [DEVELOPMENT.md](DEVELOPMENT.md)). Defaults point at `http://127.0.0.1:3000` for local development.

## Getting started

```bash
cd apps/web
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run
```

**Web with Google Sign-In (example):**

```bash
flutter run -d chrome --web-port=5000 \
  --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

Point your backend with e.g. `--dart-define=CRYPRICE_BACKEND_BASE_URL=...` and `--dart-define=AUTH_BACKEND_BASE_URL=...` when they differ from the local default.

## License

See [LICENSE](LICENSE).
