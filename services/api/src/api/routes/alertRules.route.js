import express from "express";
import { requireAccessToken } from "../middlewares/auth.middleware.js";
import { HttpError } from "../errors/httpError.js";
import { db } from "../../db/index.js";
import {
  createAlertRuleForUser,
  listAlertRulesForUser,
  patchAlertRuleForUser,
} from "../../services/alerts/alertRule.service.js";

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

    const rules = await listAlertRulesForUser(user.id);
    res.json({ rules });
  } catch (e) {
    next(e);
  }
});

router.post("/", requireAccessToken, async (req, res, next) => {
  try {
    if (!ensureAuthContext(req, next)) return;
    const user = await loadUserRow(req.auth.userId, next);
    if (!user) return;

    const rule = await createAlertRuleForUser(user.id, req.body);
    res.status(201).json({ rule });
  } catch (e) {
    next(e);
  }
});

router.patch("/:id", requireAccessToken, async (req, res, next) => {
  try {
    if (!ensureAuthContext(req, next)) return;
    const user = await loadUserRow(req.auth.userId, next);
    if (!user) return;

    const rule = await patchAlertRuleForUser(user.id, req.params.id, req.body);
    res.json({ rule });
  } catch (e) {
    next(e);
  }
});

export default router;
