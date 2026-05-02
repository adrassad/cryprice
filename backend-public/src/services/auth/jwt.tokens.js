import jwt from "jsonwebtoken";
import { ENV } from "../../config/env.js";

/** New access tokens: `sub` is `users.id` (disambiguated from legacy `sub` = telegram_id). */
export const JWT_SUB_TYP_USER_ID = "user_id";

/**
 * Issue API access JWT. `sub` is internal `users.id`.
 * @param {string | bigint} internalUserId
 */
export function signAccessToken(internalUserId) {
  const sub = String(internalUserId);
  return jwt.sign(
    { typ: "access", sub, sub_typ: JWT_SUB_TYP_USER_ID },
    ENV.JWT_ACCESS_SECRET,
    {
      expiresIn: ENV.JWT_ACCESS_EXPIRES_SEC,
      issuer: ENV.JWT_ISSUER,
      audience: ENV.JWT_AUDIENCE,
    },
  );
}

/**
 * @returns {{ sub: string, typ: string, sub_typ?: string, iat: number, exp: number, iss: string, aud: string | string[] }}
 */
export function verifyAccessToken(token) {
  return jwt.verify(token, ENV.JWT_ACCESS_SECRET, {
    issuer: ENV.JWT_ISSUER,
    audience: ENV.JWT_AUDIENCE,
  });
}
