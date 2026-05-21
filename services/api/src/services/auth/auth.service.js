import { randomBytes } from "node:crypto";
import { db } from "../../db/index.js";
import { setUserToCache } from "../../cache/user.cache.js";
import { verifyGoogleIdToken } from "./google-auth.service.js";
import { signAccessToken } from "./jwt.tokens.js";
import { HttpError } from "../../api/errors/httpError.js";
import { ENV } from "../../config/env.js";

const PROVIDER_GOOGLE = "google";
const REFRESH_BYTES = 48;

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
  };
}

async function issueAccessAndRefresh(user) {
  const accessToken = signAccessToken(user.id);
  const rawRefresh = randomBytes(REFRESH_BYTES).toString("base64url");
  const expiresAt = new Date(
    Date.now() + ENV.JWT_REFRESH_EXPIRES_SEC * 1000,
  );
  await db.refreshTokens.insert(user.telegram_id, rawRefresh, expiresAt);
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
    user = await db.users.findById(identity.user_telegram_id);
    if (!user) {
      throw new HttpError(
        500,
        "USER_ORPHAN",
        "Account data is inconsistent. Contact support.",
      );
    }
    await db.users.updateProfile(user.telegram_id, {
      email: gp.email,
      email_verified: gp.email_verified,
      avatar_url: gp.picture,
      first_name: gp.given_name ?? user.first_name,
      last_name: gp.family_name ?? user.last_name,
      username: user.username ?? gp.email,
    });
    await db.authIdentities.updateProfile(identity.id, {
      email: gp.email,
      email_verified: gp.email_verified,
      avatar_url: gp.picture,
      profile_json: {
        name: gp.name,
        given_name: gp.given_name,
        family_name: gp.family_name,
      },
    });
    user = await db.users.findById(identity.user_telegram_id);
  } else {
    isNewUser = true;
    user = await db.users.createApiUser({
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
        provider: PROVIDER_GOOGLE,
        provider_user_id: gp.sub,
        user_telegram_id: user.telegram_id,
        user_id: user.id,
        email: gp.email,
        email_verified: gp.email_verified,
        avatar_url: gp.picture,
        profile_json: {
          name: gp.name,
          given_name: gp.given_name,
          family_name: gp.family_name,
        },
      });
    } catch (e) {
      if (e?.code !== "23505") throw e;
      const orphanId = user.telegram_id;
      identity = await db.authIdentities.findByProviderUserId(
        PROVIDER_GOOGLE,
        gp.sub,
      );
      if (!identity) throw e;
      await db.users.delete(orphanId);
      user = await db.users.findById(identity.user_telegram_id);
      if (!user) {
        throw new HttpError(
          500,
          "USER_ORPHAN",
          "Account data is inconsistent. Contact support.",
        );
      }
      isNewUser = false;
      await db.users.updateProfile(user.telegram_id, {
        email: gp.email,
        email_verified: gp.email_verified,
        avatar_url: gp.picture,
        first_name: gp.given_name ?? user.first_name,
        last_name: gp.family_name ?? user.last_name,
        username: user.username ?? gp.email,
      });
      await db.authIdentities.updateProfile(identity.id, {
        email: gp.email,
        email_verified: gp.email_verified,
        avatar_url: gp.picture,
        profile_json: {
          name: gp.name,
          given_name: gp.given_name,
          family_name: gp.family_name,
        },
      });
      user = await db.users.findById(identity.user_telegram_id);
    }
    if (!identity) {
      throw new HttpError(
        500,
        "IDENTITY_CREATE_FAILED",
        "Could not link Google account.",
      );
    }
  }

  await setUserToCache(user.telegram_id, user);
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
  if (rotated.userId) {
    user = await db.users.findByInternalId(rotated.userId);
  }
  if (!user && rotated.userTelegramId) {
    user = await db.users.findById(rotated.userTelegramId);
  }
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
  return toPublicUser(user);
}
