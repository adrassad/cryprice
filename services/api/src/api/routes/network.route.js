//src/api/routes/assets.route.js
import express from "express";
import { getEnabledNetworks } from "../../services/network/network.service.js";

const router = express.Router();

router.get("/", async (req, res) => {
  console.log("networks");
  try {
    const networks = await getEnabledNetworks(); // ждём результат
    res.json(networks);
  } catch (e) {
    console.error("❌ Failed to get networks:", new Date().toISOString(), e);
    res.status(500).json({ error: "Failed to get networks" });
  }
});

export default router;
