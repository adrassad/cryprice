import { verifyAccessToken, JWT_SUB_TYP_USER_ID } from "../../services/auth/jwt.tokens.js";
import { db } from "../../db/index.js";
import { HttpError } from "../errors/httpError.js";

/**
 * Resolves `req.auth.userId` (internal `users.id` string). Legacy access tokens
 * (no `sub_typ`) treat `sub` as `users.telegram_id` and resolve to `users.id`.
 */
export async function requireAccessToken(req, res, next) {
  const h = req.headers.authorization;
  if (!h?.startsWith("Bearer ")) {
    next(
      new HttpError(
        401,
        "UNAUTHORIZED",
        "Missing or invalid Authorization header.",
      ),
    );
    return;
  }
  try {
    const token = h.slice(7).trim();
    const payload = verifyAccessToken(token);
    if (payload.typ !== "access") {
      next(
        new HttpError(401, "INVALID_TOKEN", "Invalid access token type."),
      );
      return;
    }

    if (payload.sub_typ === JWT_SUB_TYP_USER_ID) {
      req.auth = { userId: String(payload.sub) };
      next();
      return;
    }

    const user = await db.users.findById(payload.sub);
    if (!user) {
      next(
        new HttpError(401, "UNAUTHORIZED", "Invalid or unknown subject."),
      );
      return;
    }
    req.auth = { userId: String(user.id) };
    next();
  } catch (e) {
    next(e);
  }
}
