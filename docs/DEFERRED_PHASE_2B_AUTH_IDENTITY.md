# Deferred Phase 2B — Auth / User Identity

This document tracks **known auth and user-identity issues intentionally deferred from Phase 2A**.

Phase 2A focused on public-repository hygiene, documentation accuracy, and safe API hardening **without** changing database identity architecture or implementing auth migration.

Phase 2B requires a **focused identity-model audit and migration** with integration tests. Do not apply ad hoc fixes without that plan.

---

## Why this is deferred

The codebase is in a **partial Phase 1 migration** state:

- Internal `users.id` was added alongside legacy `users.telegram_id` (still the primary key for several foreign keys).
- New JWT access tokens use `users.id` as `sub`.
- Many repositories and services still assume `telegram_id` semantics for wallets, refresh tokens, and auth identities.

Fixing this touches schema, repositories, services, bot flows, and tests. It is **out of scope for Phase 2A**.

---

## Known issues (not fixed in Phase 2A)

### Missing repository methods

Services call methods that are **not implemented** (or named differently) in public repositories:

| Called method | Used in | Repo status |
|---------------|---------|-------------|
| `createGoogleUser` | `auth.service.js` | Repo has `createApiUser` only |
| `createTelegramUser` | `user.service.js` | Repo has `create()` only |
| `updateProfileById` | `auth.service.js`, `user.service.js` | Repo has `updateProfile(telegramId)` and `updateMeFields(userId)` |
| `findByTelegramId` | `auth.middleware.js`, `user.service.js` | Not defined on `UserRepository` |
| `upsertIdentity` | `auth.service.js`, `user.service.js` | `AuthIdentityRepository` has `insert` / `updateProfile` only |
| `findByUserId` | `auth.service.js` (`getMe`) | Not defined on `AuthIdentityRepository` |

### Identifier mismatches

| Area | Issue |
|------|--------|
| `wallets.user_id` | FK references `users(telegram_id)`, but routes/services often pass internal `users.id` |
| Refresh tokens | `issueAccessAndRefresh` calls `insert(user.id, …)` but repository looks up by `users.telegram_id` |
| Wallet ownership | `assertWalletOwnedByInternalUser` compares `walletRow.user_id` to `user.id` — inconsistent if `wallets.user_id` stores `telegram_id` |
| Portfolio aggregation | Queries use internal `users.id` as `wallets.user_id` filter |
| `db.users.delete(user.id)` | `UserRepository` primary key column is `telegram_id`; delete by internal id targets the wrong column |

### Schema constraints

| Constraint | Issue |
|------------|--------|
| `auth_identities.provider` CHECK | SQL allows only `'google'`; code inserts `'telegram'` |
| Synthetic negative `telegram_id` | Google-only users use negative surrogate ids; Telegram linking overwrites `telegram_id` — edge cases need explicit design |

---

## Recommended Phase 2B follow-up

1. **Read-only identity model audit** — map every call site that uses `users.id` vs `users.telegram_id` vs `user_telegram_id`.
2. **Choose strategy:**
   - **Compatibility shim** — alias missing repo methods and translate ids at boundaries (short-term), or
   - **Full migration** — repoint FKs to `users.id`, widen provider CHECK, migrate JWT/refresh/wallet paths consistently.
3. **Add integration tests** — Google sign-in, refresh rotation, wallet CRUD, portfolio fetch, Telegram link consume (against real Postgres in CI or testcontainers).
4. **Update `services/api/docs/AUTH.md`** after behavior is verified.

---

## Phase 2A boundary

Phase 2A **did not**:

- Implement missing repository methods
- Change wallet or auth FK semantics
- Widen `auth_identities.provider` CHECK
- Rewrite JWT or refresh token format

See [`docs/SECURITY_MODEL.md`](SECURITY_MODEL.md) and [`services/api/docs/AUTH.md`](../services/api/docs/AUTH.md) for current documented behavior.
