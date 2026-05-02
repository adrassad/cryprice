# API authentication (Google Sign-In + JWT)

## Overview

- The client obtains a **Google ID token** (JWT) from Google Sign-In (One Tap, `gsi`, or mobile SDK).
- The backend verifies that token with Google, upserts `users` + `auth_identities`, and returns:
  - **accessToken** — short-lived JWT for `Authorization: Bearer …`
  - **refreshToken** — opaque random string stored hashed in PostgreSQL (`refresh_tokens`); rotated on each `POST /auth/refresh`
- Telegram bot users keep **positive** `users.telegram_id` (real Telegram id). Google-only users get **negative** surrogate ids from `users_api_telegram_id_seq` so existing FKs (`wallets.user_id`, etc.) stay valid.

## Environment variables

| Variable | Required for auth | Description |
|----------|-------------------|-------------|
| `GOOGLE_CLIENT_ID` | Yes | Comma-separated OAuth 2.0 client IDs (must include the client that minted the ID token). |
| `JWT_ACCESS_SECRET` | Yes | Secret for signing access JWT (HS256). **Production:** use ≥32 random characters. |
| `JWT_ACCESS_EXPIRES_SEC` | No | Access TTL in seconds (default `900`). |
| `JWT_REFRESH_EXPIRES_SEC` | No | Refresh TTL in seconds (default `604800` = 7d). |
| `JWT_ISSUER` | No | JWT `iss` (default `cryprice-api`). |
| `JWT_AUDIENCE` | No | JWT `aud` (default `cryprice-clients`). |

If `GOOGLE_CLIENT_ID` or `JWT_ACCESS_SECRET` is missing, `POST /auth/google` returns **503** `AUTH_NOT_CONFIGURED`.

## Endpoints

### `POST /auth/google`

**Body (JSON):**

```json
{
  "idToken": "<Google ID token JWT>"
}
```

Alias: `credential` (same string) for compatibility with Google’s frontend field name.

**Success (200):**

```json
{
  "accessToken": "...",
  "refreshToken": "...",
  "expiresIn": 900,
  "refreshExpiresAt": "2026-04-28T12:00:00.000Z",
  "user": {
    "id": 42,
    "telegram_id": "-1000000001",
    "username": "user@example.com",
    "first_name": "Jane",
    "last_name": "Doe",
    "email": "user@example.com",
    "email_verified": true,
    "avatar_url": "https://...",
    "threshold_hf": "1.20"
  },
  "isNewUser": true
}
```

**Errors:** `400 INVALID_BODY`, `401 GOOGLE_TOKEN_INVALID`, `403 EMAIL_NOT_VERIFIED`, `503 AUTH_NOT_CONFIGURED`, etc.

### `GET /auth/me`

Header: `Authorization: Bearer <accessToken>`

**Success (200):** `{ "user": { ... } }`

### `POST /auth/refresh`

```json
{ "refreshToken": "<opaque refresh string>" }
```

Returns a **new** access + refresh pair; the previous refresh token is **revoked** (one-time use).

### `POST /auth/logout`

```json
{ "refreshToken": "<opaque refresh string>" }
```

Revokes that refresh token. Access JWTs may still be valid until they expire.

## Frontend / mobile flow

1. Integrate Google Sign-In and read the **ID token** (not the OAuth2 authorization code for this flow).
2. `POST /auth/google` with `idToken`.
3. Store `accessToken` and `refreshToken` securely (mobile: Keychain / Keystore).
4. Call API with `Authorization: Bearer <accessToken>`.
5. On 401, call `POST /auth/refresh` with the stored refresh token; replace both tokens with the response.

## Security notes

- **No email-based account linking** to existing Telegram rows: identity is keyed by `(provider, provider_user_id)` (Google `sub`). Merging accounts would need an explicit, audited flow to avoid takeover.
- Google accounts with **`email_verified: false`** are rejected.
- Refresh tokens are stored as **SHA-256** hashes; raw tokens are only returned once to the client.
- In **production**, `JWT_ACCESS_SECRET` must be at least **32** characters (enforced when verifying Google tokens).

## Schema

- `users`: added `email`, `email_verified`, `avatar_url` (nullable; Telegram users may stay null).
- `auth_identities`: provider row per external account.
- `refresh_tokens`: hashed refresh tokens with expiry and optional revocation.

Idempotent DDL is applied from `src/db/migrateUserAuthSchema.js` during `initDb`.

## Limitations / follow-ups

- `auth_identities.provider` is currently constrained to `'google'` in SQL; adding Apple etc. requires a small migration to widen the check constraint.
- Extremely rare race on first Google login could briefly create a discarded surrogate user row; concurrent requests resolve via unique constraint and orphan cleanup.
