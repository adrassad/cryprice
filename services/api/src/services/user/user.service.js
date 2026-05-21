// src/services/user.service.js
import { db } from "../../db/index.js";
import { HttpError } from "../../api/errors/httpError.js";
import { setUserToCache, getUserCache } from "../../cache/user.cache.js";

/**
 * Создать пользователя, если его нет
 */
export async function getOrCreateUserByTelegramProfile(tg) {
  const telegramId = String(tg.id);
  let identity = await db.authIdentities.findByProviderUserId("telegram", telegramId);
  let user = null;

  if (identity) {
    user = await db.users.findByInternalId(identity.user_id);
  }

  if (!user) {
    user = await db.users.createTelegramUser({
      telegram_id: tg.id,
      username: tg.username ?? null,
      first_name: tg.first_name ?? null,
      last_name: tg.last_name ?? null,
      language: tg.language_code ?? null,
    });
    identity = await db.authIdentities.upsertIdentity({
      user_id: user.id,
      provider: "telegram",
      provider_user_id: telegramId,
      username: tg.username ?? null,
    });
  } else {
    user = await db.users.updateProfileById(user.id, {
      telegram_id: tg.id,
      username: tg.username ?? user.username ?? null,
      first_name: tg.first_name ?? user.first_name ?? null,
      last_name: tg.last_name ?? user.last_name ?? null,
      language: tg.language_code ?? user.language ?? null,
    });
    await db.authIdentities.upsertIdentity({
      user_id: user.id,
      provider: "telegram",
      provider_user_id: telegramId,
      username: tg.username ?? null,
    });
  }

  await setUserToCache(user.id, user);
  return user;
}

export async function getUserByTelegramId(telegramId) {
  const identity = await db.authIdentities.findByProviderUserId(
    "telegram",
    String(telegramId),
  );
  if (!identity) return null;
  return db.users.findByInternalId(identity.user_id);
}

export async function findUserByTelegramId(telegramId) {
  const normalized = Number(telegramId);
  if (!Number.isFinite(normalized)) return null;
  const user = await db.users.findByTelegramId(normalized);
  if (!user) return null;
  await setUserToCache(user.id, user);
  return user;
}

export async function getUserByInternalId(userId) {
  let user = await getUserCache(userId);
  if (!user) {
    user = await db.users.findByInternalId(userId);
    if (!user) return null;
    await setUserToCache(user.id, user);
  }
  return user;
}

export async function getUserProfile(userId) {
  const user = await getUserByInternalId(userId);
  if (!user) return null;

  return {
    id: user.id,
    telegram_id: user.telegram_id,
    username: user.username,
    threshold_hf: user.threshold_hf,
    first_name: user.first_name,
    last_name: user.last_name,
  };
}

export async function loadUsersToCache() {
  const users = await db.users.findAll();
  for (const user of users) {
    await setUserToCache(user.id, user);
  }
}

const THRESHOLD_HF_MIN = 0.01;
const THRESHOLD_HF_MAX = 9999.99;
const LANGUAGE_MAX_LEN = 32;
const NAME_MAX_LEN = 255;

/**
 * Validate body for PATCH /users/me (whitelist only). Throws HttpError on invalid input.
 */
export function parseMePatchBody(body) {
  if (body == null || typeof body !== "object" || Array.isArray(body)) {
    throw new HttpError(400, "INVALID_BODY", "JSON object body is required.");
  }

  const out = {};

  if (Object.prototype.hasOwnProperty.call(body, "threshold_hf")) {
    const v = body.threshold_hf;
    if (v === null || v === undefined) {
      throw new HttpError(
        400,
        "INVALID_REQUEST",
        "threshold_hf must be a positive number.",
      );
    }
    const n = Number(v);
    if (
      !Number.isFinite(n) ||
      n <= 0 ||
      n < THRESHOLD_HF_MIN ||
      n > THRESHOLD_HF_MAX
    ) {
      throw new HttpError(
        400,
        "INVALID_REQUEST",
        `threshold_hf must be between ${THRESHOLD_HF_MIN} and ${THRESHOLD_HF_MAX}.`,
      );
    }
    out.threshold_hf = n;
  }

  if (Object.prototype.hasOwnProperty.call(body, "language")) {
    const v = body.language;
    if (v !== null && typeof v !== "string") {
      throw new HttpError(
        400,
        "INVALID_REQUEST",
        "language must be a string or null.",
      );
    }
    if (v === null || v === undefined) {
      out.language = null;
    } else {
      const t = v.trim();
      if (t.length > LANGUAGE_MAX_LEN) {
        throw new HttpError(
          400,
          "INVALID_REQUEST",
          `language must be at most ${LANGUAGE_MAX_LEN} characters.`,
        );
      }
      out.language = t || null;
    }
  }

  for (const key of ["username", "first_name", "last_name"]) {
    if (!Object.prototype.hasOwnProperty.call(body, key)) continue;
    const v = body[key];
    if (v !== null && typeof v !== "string") {
      throw new HttpError(
        400,
        "INVALID_REQUEST",
        `${key} must be a string or null.`,
      );
    }
    if (v === null || v === undefined) {
      out[key] = null;
    } else {
      const t = v.trim().slice(0, NAME_MAX_LEN);
      out[key] = t || null;
    }
  }

  if (Object.keys(out).length === 0) {
    throw new HttpError(
      400,
      "INVALID_BODY",
      "No supported fields to update.",
    );
  }

  return out;
}

export async function patchMeByUserId(userId, fields) {
  const user = await db.users.updateMeFields(userId, fields);
  if (!user) {
    throw new HttpError(404, "USER_NOT_FOUND", "User not found.");
  }
  await setUserToCache(user.id, user);
  return user;
}
