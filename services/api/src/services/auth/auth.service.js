import { randomBytes } from "node:crypto";
import { db } from "../../db/index.js";
import { setUserToCache } from "../../cache/user.cache.js";
import { verifyGoogleIdToken } from "./google-auth.service.js";
import { signAccessToken } from "./jwt.tokens.js";
import { HttpError } from "../../api/errors/httpError.js";
import { ENV } from "../../config/env.js";

const PROVIDER_GOOGLE = "google";
const PROVIDER_TELEGRAM = "telegram";
const REFRESH_BYTES = 48;
const LINK_TOKEN_BYTES = 32;
const LINK_TOKEN_TTL_MS = 15 * 60 * 1000;

export function toPublicUser(row) {
  if (!row) return null;
  return {
    id: row.id,
    telegram_id: row.telegram_id,
    username: row.username,
    first_name: row.first_name,
    last_name: row.last_name,
    email: row.email,
    email_verified: row.email_verified,
    avatar_url: row.avatar_url,
    threshold_hf: row.threshold_hf,
    language: row.language ?? null,
  };
}

async function issueAccessAndRefresh(user) {
  const accessToken = signAccessToken(user.id);
  const rawRefresh = randomBytes(REFRESH_BYTES).toString("base64url");
  const expiresAt = new Date(
    Date.now() + ENV.JWT_REFRESH_EXPIRES_SEC * 1000,
  );
  await db.refreshTokens.insert(user.id, rawRefresh, expiresAt);
  return { accessToken, refreshToken: rawRefresh, expiresAt };
}

/**
 * @param {string} idToken
 */
export async function loginWithGoogle(idToken) {
  const gp = await verifyGoogleIdToken(idToken);

  if (!gp.email_verified) {
    throw new HttpError(
      403,
      "EMAIL_NOT_VERIFIED",
      "Google account email is not verified.",
    );
  }
  if (!gp.email?.trim()) {
    throw new HttpError(
      400,
      "EMAIL_REQUIRED",
      "Google token did not include a verified email.",
    );
  }

  let identity = await db.authIdentities.findByProviderUserId(
    PROVIDER_GOOGLE,
    gp.sub,
  );
  let user;
  let isNewUser = false;

  if (identity) {
    user = await db.users.findByInternalId(identity.user_id);
    if (!user) {
      throw new HttpError(
        500,
        "USER_ORPHAN",
        "Account data is inconsistent. Contact support.",
      );
    }
    await db.users.updateProfileById(user.id, {
      email: gp.email,
      email_verified: gp.email_verified,
      avatar_url: gp.picture,
      first_name: gp.given_name ?? user.first_name,
      last_name: gp.family_name ?? user.last_name,
      username: user.username ?? gp.email,
    });
    await db.authIdentities.upsertIdentity({
      user_id: user.id,
      provider: PROVIDER_GOOGLE,
      provider_user_id: gp.sub,
      email: gp.email,
      username: user.username ?? gp.email,
    });
    user = await db.users.findByInternalId(identity.user_id);
  } else {
    isNewUser = true;
    user = await db.users.createGoogleUser({
      username: gp.email,
      first_name: gp.given_name,
      last_name: gp.family_name,
      email: gp.email,
      email_verified: gp.email_verified,
      avatar_url: gp.picture,
    });
    if (!user) {
      throw new HttpError(500, "USER_CREATE_FAILED", "Could not create user.");
    }
    try {
      identity = await db.authIdentities.insert({
        user_id: user.id,
        provider: PROVIDER_GOOGLE,
        provider_user_id: gp.sub,
        email: gp.email,
        username: gp.email,
      });
    } catch (e) {
      if (e?.code !== "23505") throw e;
      identity = await db.authIdentities.findByProviderUserId(
        PROVIDER_GOOGLE,
        gp.sub,
      );
      if (!identity) throw e;
      await db.users.delete(user.id);
      user = await db.users.findByInternalId(identity.user_id);
      if (!user) {
        throw new HttpError(
          500,
          "USER_ORPHAN",
          "Account data is inconsistent. Contact support.",
        );
      }
      isNewUser = false;
      await db.users.updateProfileById(user.id, {
        email: gp.email,
        email_verified: gp.email_verified,
        avatar_url: gp.picture,
        first_name: gp.given_name ?? user.first_name,
        last_name: gp.family_name ?? user.last_name,
        username: user.username ?? gp.email,
      });
      await db.authIdentities.upsertIdentity({
        user_id: user.id,
        provider: PROVIDER_GOOGLE,
        provider_user_id: gp.sub,
        email: gp.email,
        username: user.username ?? gp.email,
      });
      user = await db.users.findByInternalId(identity.user_id);
    }
    if (!identity) {
      throw new HttpError(
        500,
        "IDENTITY_CREATE_FAILED",
        "Could not link Google account.",
      );
    }
  }

  await setUserToCache(user.id, user);
  const tokens = await issueAccessAndRefresh(user);

  return {
    accessToken: tokens.accessToken,
    refreshToken: tokens.refreshToken,
    expiresIn: ENV.JWT_ACCESS_EXPIRES_SEC,
    refreshExpiresAt: tokens.expiresAt.toISOString(),
    user: toPublicUser(user),
    isNewUser,
  };
}

/**
 * Rotate refresh token (one-time use) and return new pair.
 * @param {string} rawRefresh
 */
export async function refreshSession(rawRefresh) {
  const rawNew = randomBytes(REFRESH_BYTES).toString("base64url");
  const expiresAt = new Date(
    Date.now() + ENV.JWT_REFRESH_EXPIRES_SEC * 1000,
  );
  const rotated = await db.refreshTokens.rotateRefreshToken(
    rawRefresh,
    rawNew,
    expiresAt,
  );
  if (!rotated) {
    throw new HttpError(
      401,
      "REFRESH_INVALID",
      "Invalid or expired refresh token.",
    );
  }

  let user = null;
  user = await db.users.findByInternalId(rotated.userId);
  if (!user) {
    throw new HttpError(401, "USER_NOT_FOUND", "User no longer exists.");
  }

  const accessToken = signAccessToken(user.id);

  return {
    accessToken,
    refreshToken: rawNew,
    expiresIn: ENV.JWT_ACCESS_EXPIRES_SEC,
    refreshExpiresAt: expiresAt.toISOString(),
    user: toPublicUser(user),
  };
}

/**
 * @param {string} rawRefresh
 */
export async function logout(rawRefresh) {
  if (!rawRefresh) {
    throw new HttpError(400, "INVALID_BODY", "refreshToken is required.");
  }
  await db.refreshTokens.revokeByRawToken(rawRefresh);
  return { ok: true };
}

/**
 * @param {string | bigint} userId internal `users.id`
 */
export async function getMe(userId) {
  const user = await db.users.findByInternalId(userId);
  if (!user) {
    throw new HttpError(404, "USER_NOT_FOUND", "User not found.");
  }
  const identities = await db.authIdentities.findByUserId(user.id);
  return {
    ...toPublicUser(user),
    identities: identities.map((x) => ({
      provider: x.provider,
      provider_user_id: x.provider_user_id,
      email: x.email,
      username: x.username,
    })),
  };
}

export async function createTelegramLinkToken(userId) {
  const user = await db.users.findByInternalId(userId);
  if (!user) {
    throw new HttpError(404, "USER_NOT_FOUND", "User not found.");
  }
  const rawToken = randomBytes(LINK_TOKEN_BYTES).toString("base64url");
  const expiresAt = new Date(Date.now() + LINK_TOKEN_TTL_MS);
  const row = await db.accountLinkTokens.create({
    rawToken,
    userId: user.id,
    provider: PROVIDER_TELEGRAM,
    expiresAt,
  });
  const tokenId = String(row.id);
  const botUsername = process.env.TELEGRAM_BOT_USERNAME;
  if (!botUsername) {
    throw new HttpError(
      500,
      "LINK_NOT_CONFIGURED",
      "TELEGRAM_BOT_USERNAME is required for Telegram linking.",
    );
  }
  return {
    tokenId,
    expiresAt: expiresAt.toISOString(),
    telegramDeepLink: `https://t.me/${botUsername}?start=link_${rawToken}`,
  };
}

export async function consumeTelegramLinkToken(rawToken, tgUser) {
  const link = await db.accountLinkTokens.findValidByRawToken(
    rawToken,
    PROVIDER_TELEGRAM,
  );
  if (!link) {
    throw new HttpError(400, "LINK_TOKEN_INVALID", "Link token is invalid or expired.");
  }

  const existing = await db.authIdentities.findByProviderUserId(
    PROVIDER_TELEGRAM,
    String(tgUser.id),
  );
  if (existing && String(existing.user_id) !== String(link.user_id)) {
    throw new HttpError(
      409,
      "TELEGRAM_ALREADY_LINKED",
      "Telegram account is already linked to another user.",
    );
  }

  await db.authIdentities.upsertIdentity({
    user_id: link.user_id,
    provider: PROVIDER_TELEGRAM,
    provider_user_id: String(tgUser.id),
    username: tgUser.username ?? null,
  });

  await db.users.updateProfileById(link.user_id, {
    telegram_id: tgUser.id,
    username: tgUser.username ?? null,
    first_name: tgUser.first_name ?? null,
    last_name: tgUser.last_name ?? null,
    language: tgUser.language_code ?? null,
  });

  await db.accountLinkTokens.markUsed(link.id);
  return { ok: true };
}
