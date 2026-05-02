import express from "express";
import { getCurrentOffchainPricesByTicker } from "../../services/price/offchainPrice.service.js";

const router = express.Router();

router.get("/:ticker", async (req, res) => {
  try {
    const symbol = req.params.ticker.toUpperCase();
    const result = await getCurrentOffchainPricesByTicker(symbol);

    if (!result || Object.keys(result).length === 0) {
      return res.status(404).json({ error: "Price not found" });
    }

    res.json(result);
  } catch (e) {
    console.error(
      "❌ offchain prices API failed:",
      new Date().toISOString(),
      e,
    );
    res.status(500).json({ error: "Internal error" });
  }
});

export default router;
