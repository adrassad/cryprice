import express from "express";
import {
  loginWithGoogle,
  refreshSession,
  logout,
  getMe,
} from "../../services/auth/auth.service.js";
import { requireAccessToken } from "../middlewares/auth.middleware.js";

const router = express.Router();

router.post("/google", async (req, res, next) => {
  try {
    const idToken = req.body?.idToken ?? req.body?.credential;
    if (!idToken || typeof idToken !== "string") {
      res.status(400).json({
        error: {
          code: "INVALID_BODY",
          message:
            "idToken or credential (Google ID token JWT string) is required.",
        },
      });
      return;
    }
    const out = await loginWithGoogle(idToken.trim());
    res.json(out);
  } catch (e) {
    next(e);
  }
});

router.post("/refresh", async (req, res, next) => {
  try {
    const raw = req.body?.refreshToken;
    if (!raw || typeof raw !== "string") {
      res.status(400).json({
        error: {
          code: "INVALID_BODY",
          message: "refreshToken is required.",
        },
      });
      return;
    }
    const out = await refreshSession(raw.trim());
    res.json(out);
  } catch (e) {
    next(e);
  }
});

router.post("/logout", async (req, res, next) => {
  try {
    const raw = req.body?.refreshToken;
    if (!raw || typeof raw !== "string") {
      res.status(400).json({
        error: {
          code: "INVALID_BODY",
          message: "refreshToken is required.",
        },
      });
      return;
    }
    const out = await logout(raw.trim());
    res.json(out);
  } catch (e) {
    next(e);
  }
});

router.get("/me", requireAccessToken, async (req, res, next) => {
  try {
    const user = await getMe(req.auth.userId);
    res.json({ user });
  } catch (e) {
    next(e);
  }
});

export default router;
