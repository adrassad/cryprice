// src/api/routes/onchainPrices.route.js
import express from "express";
import { getCurrentOnchainPricesByTicker } from "../../services/price/onchainPrice.service.js";

const router = express.Router();

router.get("/:ticker", async (req, res) => {
  try {
    const symbol = req.params.ticker.toUpperCase();
    const result = await getCurrentOnchainPricesByTicker(symbol);

    const hasAnyPrice = Object.values(result).some((p) => p != null);
    if (!hasAnyPrice) {
      return res.status(404).json({ error: "Price not found" });
    }

    res.json(result);
  } catch (e) {
    console.error(
      "❌ onchain prices API failed:",
      new Date().toISOString(),
      e,
    );
    res.status(500).json({ error: "Internal error" });
  }
});

export default router;
