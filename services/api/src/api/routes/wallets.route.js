import express from "express";
import { requireAccessToken } from "../middlewares/auth.middleware.js";
import { HttpError } from "../errors/httpError.js";
import { db } from "../../db/index.js";
import {
  addUserWallet,
  listWalletsForUser,
  updateUserWalletLabel,
  removeUserWalletByPk,
  serializeWalletForApi,
} from "../../services/wallet/wallet.service.js";
import { assertWalletOwnedByInternalUser } from "../../services/portfolio/portfolio.service.js";

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

function mapWalletServiceError(err, next) {
  const code = err?.message;
  if (code === "INVALID_ADDRESS") {
    next(new HttpError(400, "INVALID_REQUEST", "Invalid wallet address."));
    return true;
  }
  if (code === "WALLET_ALREADY_EXISTS") {
    next(new HttpError(400, "INVALID_REQUEST", "Wallet already exists."));
    return true;
  }
  if (code === "WALLET_NOT_FOUND") {
    next(new HttpError(404, "WALLET_NOT_FOUND", "Wallet not found."));
    return true;
  }
  if (code === "WALLET_LIMIT_REACHED") {
    next(
      new HttpError(
        403,
        "FORBIDDEN",
        "Wallet limit reached for this account.",
      ),
    );
    return true;
  }
  return false;
}

router.get("/", requireAccessToken, async (req, res, next) => {
  try {
    if (!ensureAuthContext(req, next)) return;
    const user = await loadUserRow(req.auth.userId, next);
    if (!user) return;
    const wallets = await listWalletsForUser(user.id);
    res.json({ wallets });
  } catch (e) {
    next(e);
  }
});

router.post("/", requireAccessToken, async (req, res, next) => {
  try {
    if (!ensureAuthContext(req, next)) return;
    const user = await loadUserRow(req.auth.userId, next);
    if (!user) return;

    const address = req.body?.address;
    if (address == null || typeof address !== "string" || !address.trim()) {
      next(new HttpError(400, "INVALID_BODY", "address is required."));
      return;
    }

    let label = null;
    if (req.body != null && Object.prototype.hasOwnProperty.call(req.body, "label")) {
      const l = req.body.label;
      if (l !== null && typeof l !== "string") {
        next(new HttpError(400, "INVALID_BODY", "label must be a string or null."));
        return;
      }
      label = l === null ? null : l.trim() || null;
    }

    const wallet = await addUserWallet(user.id, address.trim(), label);
    res.status(201).json({ wallet: serializeWalletForApi(wallet) });
  } catch (e) {
    if (mapWalletServiceError(e, next)) return;
    next(e);
  }
});

router.patch("/:walletId", requireAccessToken, async (req, res, next) => {
  try {
    if (!ensureAuthContext(req, next)) return;

    const walletId = req.params.walletId;
    await assertWalletOwnedByInternalUser(req.auth.userId, walletId);

    const user = await loadUserRow(req.auth.userId, next);
    if (!user) return;

    const body = req.body;
    if (body == null || typeof body !== "object" || Array.isArray(body)) {
      next(new HttpError(400, "INVALID_BODY", "JSON object body is required."));
      return;
    }
    if (!Object.prototype.hasOwnProperty.call(body, "label")) {
      next(new HttpError(400, "INVALID_BODY", "label is required."));
      return;
    }

    const l = body.label;
    if (l !== null && typeof l !== "string") {
      next(new HttpError(400, "INVALID_BODY", "label must be a string or null."));
      return;
    }
    const label = l === null ? null : l.trim() || null;

    try {
      const wallet = await updateUserWalletLabel(
        user.id,
        walletId,
        label,
      );
      res.json({ wallet });
    } catch (e) {
      if (mapWalletServiceError(e, next)) return;
      throw e;
    }
  } catch (e) {
    next(e);
  }
});

router.delete("/:walletId", requireAccessToken, async (req, res, next) => {
  try {
    if (!ensureAuthContext(req, next)) return;

    const walletId = req.params.walletId;
    await assertWalletOwnedByInternalUser(req.auth.userId, walletId);

    const user = await loadUserRow(req.auth.userId, next);
    if (!user) return;

    try {
      await removeUserWalletByPk(user.id, walletId);
      res.json({ ok: true });
    } catch (e) {
      if (mapWalletServiceError(e, next)) return;
      throw e;
    }
  } catch (e) {
    next(e);
  }
});

export default router;
