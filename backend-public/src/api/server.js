//src/api/server.js
import express from "express";
import cors from "cors";
import healthRoute from "./routes/health.route.js";
import assetsRoute from "./routes/assets.route.js";
import onchainPricesRoute from "./routes/onchainPrices.route.js";
import offchainPricesRoute from "./routes/offchainPrices.route.js";
import networksRoute from "./routes/network.route.js";
import authRoute from "./routes/auth.route.js";
import apiLimiter from "./middlewares/rateLimit.middleware.js";
import authLimiter from "./middlewares/authRateLimit.middleware.js";
import { errorHandler } from "./middlewares/error.middleware.js";
import { ENV } from "../config/env.js";

export function startServer() {
  const app = express();
  app.set("trust proxy", 1);
  app.use(cors());
  app.use(express.json());

  // middleware rate limiter
  app.use("/health", apiLimiter);
  app.use("/assets", apiLimiter);
  app.use("/prices/current/onchain", apiLimiter);
  app.use("/prices/current/offchain", apiLimiter);
  app.use("/networks", apiLimiter);
  app.use("/auth", authLimiter);

  // **подключаем роуты**
  app.use("/health", healthRoute);
  app.use("/assets", assetsRoute);
  app.use("/prices/current/onchain", onchainPricesRoute);
  app.use("/prices/current/offchain", offchainPricesRoute);
  app.use("/networks", networksRoute);
  app.use("/auth", authRoute);

  app.use(errorHandler);

  app.listen(ENV.PORT_API, () => {
    console.log(`🚀 Backend running on http://localhost:${ENV.PORT_API}`);
  });

  return app;
}
