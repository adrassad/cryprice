import express from "express";
import { requireAccessToken } from "../middlewares/auth.middleware.js";
import { HttpError } from "../errors/httpError.js";
import { getMe, toPublicUser } from "../../services/auth/auth.service.js";
import {
  parseMePatchBody,
  patchMeByUserId,
} from "../../services/user/user.service.js";
import { db } from "../../db/index.js";

const router = express.Router();

function ensureAuthContext(req, next) {
  if (req.auth?.userId == null || req.auth.userId === "") {
    next(
      new HttpError(
        401,
        "UNAUTHORIZED",
        "Authentication context missing.",
      ),
    );
    return false;
  }
  return true;
}

router.get("/me", requireAccessToken, async (req, res, next) => {
  try {
    if (!ensureAuthContext(req, next)) return;
    const user = await getMe(req.auth.userId);
    res.json({ user });
  } catch (e) {
    next(e);
  }
});

router.patch("/me", requireAccessToken, async (req, res, next) => {
  try {
    if (!ensureAuthContext(req, next)) return;

    const row = await db.users.findByInternalId(req.auth.userId);
    if (!row) {
      next(new HttpError(404, "USER_NOT_FOUND", "User not found."));
      return;
    }

    const patch = parseMePatchBody(req.body);
    const updated = await patchMeByUserId(row.id, patch);
    res.json({ user: toPublicUser(updated) });
  } catch (e) {
    next(e);
  }
});

export default router;
