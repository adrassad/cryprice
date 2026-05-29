# Alert Rules & Alerts API — Frontend Handoff

Инструкция для реализации настроек HF-алертов (v2) и in-app уведомлений в клиенте CryPrice.

---

## Контекст

Backend поддерживает **два режима** HF → Telegram:

| Режим | Env на backend | Источник порога | API правил |
|-------|----------------|-----------------|------------|
| Legacy | `ALERTS_V2_ENABLED=false` | `users.threshold_hf` (`PATCH /users/me`, бот) | **не используется** |
| **v2 (текущий целевой)** | `ALERTS_V2_ENABLED=true` | **`alert_rules`** | **`/alert-rules`** |

При v2 поле `users.threshold_hf` **не участвует** в создании алертов. Frontend должен управлять **`alert_rules`**.

Оценка алертов идёт на backend по cron (~каждые 5 мин): переход HF через порог → запись в `alerts` → доставка в Telegram (если есть `telegram_id`) и in-app.

---

## Аутентификация

Все эндпоинты ниже требуют:

```http
Authorization: Bearer <accessToken>
```

Получение токена: `POST /auth/google`, обновление: `POST /auth/refresh`.  
См. [docs/AUTH.md](./AUTH.md).

Формат ошибок:

```json
{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "Human-readable message."
  }
}
```

---

## Эндпоинты alert rules

| Method | Path | Описание |
|--------|------|----------|
| `GET` | `/alert-rules` | Список правил текущего пользователя |
| `POST` | `/alert-rules` | Создать правило |
| `PATCH` | `/alert-rules/:id` | Обновить правило |

**DELETE не реализован.** Отключение — `PATCH` с `"enabled": false`.

Rate limit: общий API limiter (как у `/wallets`, `/portfolio`).

---

## Модель `alert_rule`

### Поля ответа

Все числовые id в JSON — **строки** (BigInt-safe).

```json
{
  "id": "1",
  "user_id": "42",
  "type": "health_factor_threshold",
  "protocol": "aave",
  "wallet_id": null,
  "network_id": null,
  "threshold_hf": "2.0000",
  "direction": "below",
  "enabled": true,
  "cooldown_minutes": 30,
  "last_triggered_at": "2026-05-22T10:00:00.000Z",
  "created_at": "2026-05-20T08:00:00.000Z",
  "updated_at": "2026-05-22T09:00:00.000Z"
}
```

| Поле | Тип | Описание |
|------|-----|----------|
| `type` | string | Сейчас только `health_factor_threshold` |
| `protocol` | string | По умолчанию `aave` |
| `direction` | string | Только `below` |
| `threshold_hf` | string | Порог HF (decimal string) |
| `wallet_id` | string \| null | `null` = все кошельки пользователя |
| `network_id` | string \| null | `null` = все сети с HF |
| `enabled` | boolean | Включено ли правило |
| `cooldown_minutes` | number | Пауза между **повторными breach** (recovery не блокируется) |
| `last_triggered_at` | ISO \| null | Последнее срабатывание (backend) |

### Валидация при создании/обновлении

| Поле | Create | Patch | Ограничения |
|------|--------|-------|-------------|
| `threshold_hf` | **обязательно** | опционально | `0.01` … `9999.99`, > 0 |
| `cooldown_minutes` | опционально (default `30`) | опционально | целое `1` … `10080` |
| `enabled` | опционально (default `true`) | опционально | boolean |
| `wallet_id` | опционально (`null`) | опционально | id кошелька **этого** пользователя |
| `network_id` | опционально (`null`) | опционально | id из `GET /networks` |
| `type` | опционально | — | только `health_factor_threshold` |
| `direction` | опционально | — | только `below` |
| `protocol` | опционально | — | строка, default `aave` |

---

## Примеры запросов

### Минимальное правило (все кошельки, все сети)

```http
POST /alert-rules
Content-Type: application/json

{
  "threshold_hf": 2.0
}
```

**Ответ `201`:**

```json
{
  "rule": {
    "id": "3",
    "user_id": "42",
    "type": "health_factor_threshold",
    "protocol": "aave",
    "wallet_id": null,
    "network_id": null,
    "threshold_hf": "2.0000",
    "direction": "below",
    "enabled": true,
    "cooldown_minutes": 30,
    "last_triggered_at": null,
    "created_at": "...",
    "updated_at": "..."
  }
}
```

### Правило на один кошелёк и сеть

```json
{
  "threshold_hf": 1.5,
  "wallet_id": "12",
  "network_id": "2",
  "cooldown_minutes": 60
}
```

### Список правил

```http
GET /alert-rules
```

```json
{
  "rules": [ { "...": "..." } ]
}
```

### Обновление порога / отключение

```http
PATCH /alert-rules/3
Content-Type: application/json

{
  "threshold_hf": 1.8
}
```

```json
{ "enabled": false }
```

---

## Коды ошибок (alert rules)

| HTTP | code | Когда |
|------|------|-------|
| 401 | `UNAUTHORIZED` | Нет / невалидный Bearer |
| 404 | `ALERT_RULE_NOT_FOUND` | Чужое или несуществующее правило |
| 404 | `NETWORK_NOT_FOUND` | Неверный `network_id` |
| 404 | `USER_NOT_FOUND` | — |
| 400 | `INVALID_BODY` | Не JSON / пустой patch |
| 400 | `INVALID_REQUEST` | Невалидный порог, cooldown, wallet_id и т.д. |

При `wallet_id` не принадлежащем пользователю — ошибка валидации владения (через portfolio service).

---

## In-app алерты (результаты срабатывания правил)

| Method | Path | Описание |
|--------|------|----------|
| `GET` | `/alerts` | Список алертов пользователя |
| `PATCH` | `/alerts/:id/read` | Отметить прочитанным |

### Query `GET /alerts`

| Param | Default | Описание |
|-------|---------|----------|
| `unread` | `false` | `true` — только непрочитанные |
| `limit` | `50` | max `100` |
| `offset` | `0` | пагинация |

```http
GET /alerts?unread=true&limit=20&offset=0
```

### Формат алерта

```json
{
  "id": "101",
  "user_id": "42",
  "rule_id": "3",
  "wallet_id": "12",
  "wallet_address": "0xabc...",
  "network_id": "2",
  "protocol": "aave",
  "type": "health_factor_breach",
  "severity": "critical",
  "title": "Health Factor below threshold",
  "message": "Aave aave HF dropped from 2.10 to 1.05 (threshold 2.00).",
  "previous_hf": "2.10",
  "current_hf": "1.05",
  "payload": {
    "threshold_hf": 2,
    "transition": "breach"
  },
  "read_at": null,
  "created_at": "2026-05-22T10:05:00.000Z"
}
```

### Типы и severity

| `type` | Значение |
|--------|----------|
| `health_factor_breach` | HF пересёк порог **вниз** (был ≥ порога, стал < порога) |
| `health_factor_recovery` | HF **восстановился** (был < порога, стал ≥ порога) |

| `severity` | Условие |
|------------|---------|
| `critical` | `current_hf < 1.2` при breach |
| `warning` | breach, HF ≥ 1.2 |
| `info` | recovery |

**Важно для UX:** алерт не создаётся, если HF «просто ниже порога» без **перехода** между двумя замерами (cron ~5 мин). Пользователю можно показать подсказку: «Уведомление придёт при пересечении порога».

### Прочитать алерт

```http
PATCH /alerts/101/read
```

```json
{
  "alert": {
    "id": "101",
    "read_at": "2026-05-22T10:10:00.000Z",
    "...": "..."
  }
}
```

---

## Связанные эндпоинты для UI

### Профиль (legacy-порог, не заменяет v2)

```http
GET /users/me
PATCH /users/me
```

`PATCH /users/me` принимает `threshold_hf` (`0.01` … `9999.99`).  
**При v2** это поле можно оставить для отображения в профиле / совместимости с ботом, но **алерты идут только из `alert_rules`**.

Рекомендация: при сохранении порога в UI **синхронизировать оба** (см. сценарии ниже).

### Справочники для селекторов

| Endpoint | Auth | Для чего |
|----------|------|----------|
| `GET /networks` | нет | Список сетей → `network_id` |
| `GET /wallets` | Bearer | Кошельки пользователя → `wallet_id` |

---

## Рекомендуемые UX-сценарии

### 1. Первый вход / onboarding (v2)

```
1. GET /users/me          → взять threshold_hf как дефолт для UI (например "2.0")
2. GET /alert-rules       → если rules.length === 0:
3. POST /alert-rules      → { "threshold_hf": <из шага 1 или UI> }
```

Не полагаться на то, что backend создаст правило автоматически.

### 2. Экран «Порог HF» (простой режим)

Один глобальный порог для всех кошельков и сетей:

```
1. GET /alert-rules
2. Если есть enabled-правило с wallet_id=null и network_id=null:
     PATCH /alert-rules/:id  { "threshold_hf": newValue }
   Иначе:
     POST /alert-rules       { "threshold_hf": newValue }
3. (Опционально) PATCH /users/me { "threshold_hf": newValue }
   — чтобы совпадало с Telegram-ботом и legacy-полем профиля
```

### 3. Расширенный режим (несколько правил)

Backend **разрешает несколько** правил на пользователя. UI может:

- одно **глобальное** (`wallet_id` + `network_id` = null);
- отдельные правила на кошелёк/сеть с другим порогом или `enabled: false`.

При сохранении не создавайте дубликаты с одинаковой областью — лучше `PATCH` существующего.

### 4. Экран «Уведомления»

```
1. GET /alerts?unread=true&limit=50
2. Показать title, message, severity, created_at, wallet_address, network (resolve по network_id)
3. По tap → PATCH /alerts/:id/read
4. Badge unread = count где read_at === null (или отдельный запрос с unread=true)
```

### 5. Telegram

Привязка Telegram — **не через alert_rules**. Алерт в Telegram создаётся backend'ом, если у user есть `telegram_id`.  
Frontend может показыать статус: «Telegram подключён / не подключён» (поле из профиля / link flow бота — вне scope alert_rules).

---

## Логика срабатывания (для текста в UI)

Правило `direction: below` + `threshold_hf: T`:

| Событие | Условие (упрощённо) |
|---------|---------------------|
| **Breach** | Предыдущий HF ≥ T, текущий HF < T |
| **Recovery** | Предыдущий HF < T, текущий HF ≥ T |
| **Нет алерта** | HF стабильно ниже/выше порога без пересечения |

Cooldown (`cooldown_minutes`) подавляет **повторные breach** до истечения интервала. Recovery не блокируется cooldown.

---

## Чеклист реализации frontend

- [ ] Экран/секция «Порог Health Factor» → CRUD через `/alert-rules`
- [ ] Onboarding: auto-create default rule если список пуст
- [ ] Sync `threshold_hf` с `PATCH /users/me` (опционально, для бота)
- [ ] Список in-app алертов `GET /alerts` + mark read
- [ ] Подсказка: алерт при **пересечении** порога, не при статичном низком HF
- [ ] Селекторы `wallet_id` / `network_id` для advanced mode
- [ ] Обработка `401` → refresh token → retry
- [ ] Парсинг `threshold_hf` как string → number для UI

---

## Ограничения и out of scope

| Тема | Статус |
|------|--------|
| DELETE `/alert-rules/:id` | Нет — используйте `enabled: false` |
| Push (`/push-tokens`) | Отдельная интеграция FCM |
| Live HF на экране настроек | Берите из `GET /portfolio` → `defiRisk`, не из alert_rules |
| Автосоздание rules из `threshold_hf` | **Нет на backend** — зона frontend |
| `type` кроме `health_factor_threshold` | Пока не поддерживается API |

---

## Пример конфигурации для QA

Backend:

```env
ALERTS_V2_ENABLED=true
```

Клиент после логина:

```bash
# 1. Создать правило
curl -X POST "$API/alert-rules" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"threshold_hf": 2.0}'

# 2. Проверить список
curl "$API/alert-rules" -H "Authorization: Bearer $TOKEN"

# 3. Алерты (после срабатывания на backend)
curl "$API/alerts?unread=true" -H "Authorization: Bearer $TOKEN"
```

---

## Контакты по коду backend

| Файл | Назначение |
|------|------------|
| `src/api/routes/alertRules.route.js` | HTTP routes |
| `src/services/alerts/alertRule.service.js` | Валидация + сериализация |
| `src/services/alerts/alert.service.js` | `/alerts` |
| `src/services/alerts/healthFactorAlert.service.js` | Оценка правил (cron) |

При изменениях API сверяйтесь с regression-тестами: `test/regression/api-alerts-mount.test.mjs`.
