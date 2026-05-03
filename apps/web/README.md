# CryPrice — Flutter app (`apps/web`)

Public, open-source Flutter client for the CryPrice API. In this monorepo it lives under **`apps/web`**.

## Features

- Look up current prices (off-chain venues and on-chain) against the configured backend.
- English / Russian UI, light and dark themes.
- Google Sign-In on web and mobile (optional; requires your OAuth client ids at build time).
- `Bloc` / `Cubit` features, Material 3, Google Fonts.

## Configuration (no secrets in the repo)

Runtime API hosts are **not** hardcoded to any production URL. At **compile time** pass base URLs and OAuth client ids with `--dart-define=...` (see [`.env.example`](.env.example) and [DEVELOPMENT.md](DEVELOPMENT.md)). Defaults point at `http://127.0.0.1:3000` for local development.

## Getting started

```bash
cd apps/web
flutter pub get
flutter gen-l10n
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
