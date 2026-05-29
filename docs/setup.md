# Local Setup

## Requirements

- **Node.js 20+** (recommended)
- **Flutter SDK** (stable channel, for `apps/web`)
- **Docker** (optional, for PostgreSQL via `docker-compose.example.yml`)
- **PostgreSQL** and **Redis** (required for the API service)

---

## Quick start

### 1. Environment files

Copy example environment files and fill in placeholder values locally. Never commit real secrets.

```bash
cp .env.example .env
cp services/api/.env.example services/api/.env
cp apps/web/.env.example apps/web/.env        # optional reference
cp apps/marketing/.env.example apps/marketing/.env  # optional, for custom URLs
```

Edit `services/api/.env` with your local `DATABASE_URL`, `BOT_TOKEN`, Redis settings, and RPC provider variables. See [`services/api/.env.example`](../services/api/.env.example).

**Optional — Health Factor alerts v2:** set `ALERTS_V2_ENABLED=true` to enable persisted HF alert rules (`/alert-rules`), the in-app inbox (`/alerts`), and Telegram HF delivery when the account is linked. When disabled (default), HF sync uses legacy inline Telegram summaries instead.

### 2. Infrastructure (optional)

```bash
cp docker-compose.example.yml docker-compose.yml
docker compose up -d
```

This starts PostgreSQL on port 5432 with default credentials from the example file.

### 3. API service

```bash
cd services/api
npm install
npm test
npm start
```

The API starts on `PORT_API` (default **3000**). It connects to PostgreSQL and Redis, applies schema initialization, starts cron jobs, and serves REST endpoints.

### 4. Web app

```bash
cd apps/web
flutter pub get
flutter run
```

Point the app at your local API:

```bash
flutter run --dart-define=CRYPRICE_BACKEND_BASE_URL=http://127.0.0.1:3000
```

For Google Sign-In on web, supply your OAuth client ID at compile time:

```bash
flutter run -d chrome \
  --dart-define=CRYPRICE_BACKEND_BASE_URL=http://127.0.0.1:3000 \
  --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

### 5. Marketing site

```bash
cd apps/marketing
npm ci
npm run dev
```

---

## Packages

TypeScript packages under `packages/` are managed via npm workspaces from the repository root:

```bash
npm install
npm run typecheck -w @cryprice/shared
npm run typecheck -w @cryprice/api-client
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [`architecture.md`](architecture.md) | System architecture |
| [`public-api.md`](public-api.md) | API contract overview |
| [`SECURITY_MODEL.md`](SECURITY_MODEL.md) | Security and public edition scope |
| [`../services/api/README.md`](../services/api/README.md) | API service documentation |
| [`../services/api/docs/AUTH.md`](../services/api/docs/AUTH.md) | Authentication flow |
| [`../apps/web/DEVELOPMENT.md`](../apps/web/DEVELOPMENT.md) | Flutter development notes |
