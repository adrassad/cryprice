import express from "express";
import { requireAccessToken } from "../middlewares/auth.middleware.js";
import { HttpError } from "../errors/httpError.js";
import { db } from "../../db/index.js";
import {
  listAlertsForUser,
  markAlertReadForUser,
} from "../../services/alerts/alert.service.js";

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

async function loadUserRow(internalUserId, next) {
  const user = await db.users.findByInternalId(internalUserId);
  if (!user) {
    next(new HttpError(404, "USER_NOT_FOUND", "User not found."));
    return null;
  }
  return user;
}

router.get("/", requireAccessToken, async (req, res, next) => {
  try {
    if (!ensureAuthContext(req, next)) return;
    const user = await loadUserRow(req.auth.userId, next);
    if (!user) return;

    const alerts = await listAlertsForUser(user.id, req.query);
    res.json({ alerts });
  } catch (e) {
    next(e);
  }
});

router.patch("/:id/read", requireAccessToken, async (req, res, next) => {
  try {
    if (!ensureAuthContext(req, next)) return;
    const user = await loadUserRow(req.auth.userId, next);
    if (!user) return;

    const alert = await markAlertReadForUser(user.id, req.params.id);
    res.json({ alert });
  } catch (e) {
    next(e);
  }
});

export default router;
