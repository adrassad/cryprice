# Локальный сетап

## Требования

- Node.js 20+ (рекомендуется)
- Docker (опционально, для Postgres из `docker-compose.example.yml`)

## Быстрый старт

1. Скопируйте переменные окружения:
   - `./.env.example` → `./.env`
   - `backend-public/.env.example` → `backend-public/.env`

2. При необходимости поднимите инфраструктуру:
   - `cp docker-compose.example.yml docker-compose.yml` и `docker compose up -d`

3. Инициализируйте и запустите backend (команды добавятся в `backend-public` после выбора стека).

4. В монорепо при использовании `pnpm` / `npm` / `yarn` workspaces подключите `packages/*` и `apps/*` в корневой манифест — корневой `package.json` можно добавить отдельно.

## Документация

- [architecture.md](architecture.md) — устройство системы
- [public-api.md](public-api.md) — контракт API
