import express from "express";
import {
  getUserPortfolio,
  getWalletPortfolioForAuth,
  syncUserPortfolios,
} from "../../services/portfolio/portfolio.service.js";
import { getAggregatedUserPortfolio } from "../../services/portfolio/portfolioAggregation.service.js";
import { generatePortfolioPdf } from "../../services/portfolio/portfolioPdfExport.service.js";
import { portfolioReportFilename } from "../../services/portfolio/portfolioPdfFormat.js";
import { requireAccessToken } from "../middlewares/auth.middleware.js";
import { HttpError } from "../errors/httpError.js";

const router = express.Router();

function ensureAuth(req, next) {
  if (req.auth?.userId == null || req.auth.userId === "") {
    next(new HttpError(401, "UNAUTHORIZED", "Authentication context missing."));
    return false;
  }
  return true;
}

function portfolioMeta(snapshot) {
  const syncedAt = snapshot?.syncedAt ?? null;
  return {
    synced_at: syncedAt,
    stale: syncedAt == null,
  };
}

function parseIncludeWallets(queryValue) {
  if (queryValue === undefined) return true;
  if (queryValue === "false") return false;
  return true;
}

router.get("/", requireAccessToken, async (req, res, next) => {
  try {
    if (!ensureAuth(req, next)) return;

    const portfolio = await getAggregatedUserPortfolio(req.auth.userId, {
      includeWallets: parseIncludeWallets(req.query.includeWallets),
    });

    res.json(portfolio);
  } catch (e) {
    next(e);
  }
});

router.get("/export/pdf", requireAccessToken, async (req, res, next) => {
  try {
    if (!ensureAuth(req, next)) return;

    const portfolio = await getAggregatedUserPortfolio(req.auth.userId, {
      includeWallets: true,
    });
    const pdfBuffer = await generatePortfolioPdf(portfolio);
    const filename = portfolioReportFilename();

    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", `attachment; filename="${filename}"`);
    res.send(pdfBuffer);
  } catch (e) {
    next(e);
  }
});

router.get("/me", requireAccessToken, async (req, res, next) => {
  try {
    if (!ensureAuth(req, next)) return;

    const data = await getUserPortfolio(req.auth.userId);

    console.log("User portfolio data:", data); // Debug log

    const wallets = data.wallets.map(
      ({ walletId, address, label, portfolio }) => ({
        wallet_id: walletId,
        address,
        label,
        meta: portfolioMeta(portfolio),
        portfolio,
      }),
    );

    const syncedTimes = wallets
      .map((w) => w.meta.synced_at)
      .filter(Boolean)
      .sort()
      .reverse();

    res.json({
      meta: {
        synced_at: syncedTimes[0] ?? null,
        stale: wallets.length === 0 || wallets.some((w) => w.meta.stale),
      },
      user_id: data.userId,
      wallets,
    });
  } catch (e) {
    next(e);
  }
});

router.get("/wallet/:walletId", requireAccessToken, async (req, res, next) => {
  try {
    if (!ensureAuth(req, next)) return;

    const walletId = req.params.walletId;
    const portfolio = await getWalletPortfolioForAuth(
      req.auth.userId,
      walletId,
    );

    res.json({
      meta: portfolioMeta(portfolio),
      wallet_id: walletId,
      portfolio,
    });
  } catch (e) {
    next(e);
  }
});

router.post("/sync", requireAccessToken, async (req, res, next) => {
  try {
    if (!ensureAuth(req, next)) return;

    const raw = req.body?.walletId ?? req.body?.wallet_id;
    const walletId =
      raw === undefined || raw === null || raw === "" ? null : raw;

    const out = await syncUserPortfolios(req.auth.userId, walletId);
    res.json(out);
  } catch (e) {
    next(e);
  }
});

export default router;
