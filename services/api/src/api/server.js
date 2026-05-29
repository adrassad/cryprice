//src/api/server.js
import express from "express";
import helmet from "helmet";
import healthRoute from "./routes/health.route.js";
import assetsRoute from "./routes/assets.route.js";
import onchainPricesRoute from "./routes/onchainPrices.route.js";
import offchainPricesRoute from "./routes/offchainPrices.route.js";
import networksRoute from "./routes/network.route.js";
import authRoute from "./routes/auth.route.js";
import portfolioRoute from "./routes/portfolio.route.js";
import walletsRoute from "./routes/wallets.route.js";
import usersRoute from "./routes/users.route.js";
import tokenIconsRoute from "./routes/tokenIcons.route.js";
import alertsRoute from "./routes/alerts.route.js";
import alertRulesRoute from "./routes/alertRules.route.js";
import apiLimiter from "./middlewares/rateLimit.middleware.js";
import authLimiter from "./middlewares/authRateLimit.middleware.js";
import { requireAccessToken } from "./middlewares/auth.middleware.js";
import { errorHandler } from "./middlewares/error.middleware.js";
import { ENV } from "../config/env.js";
import { createCorsMiddleware } from "../config/cors.js";

export function createApp() {
  const app = express();
  app.set("trust proxy", 1);
  app.disable("x-powered-by");
  app.use(
    helmet({
      contentSecurityPolicy: false,
      crossOriginResourcePolicy: { policy: "cross-origin" },
    }),
  );
  app.use(createCorsMiddleware());
  app.use(express.json({ limit: "100kb" }));

  app.use("/health", apiLimiter);
  app.use("/assets", apiLimiter);
  app.use("/prices/current/onchain", apiLimiter);
  app.use("/prices/current/offchain", apiLimiter);
  app.use("/networks", apiLimiter);
  app.use("/portfolio", apiLimiter);
  app.use("/wallets", apiLimiter);
  app.use("/users", apiLimiter);
  app.use("/alerts", apiLimiter);
  app.use("/alert-rules", apiLimiter);
  app.use("/auth", authLimiter);
  app.use("/static/token-icons", apiLimiter);

  app.use("/health", healthRoute);
  app.use("/assets", assetsRoute);
  app.use("/prices/current/onchain", onchainPricesRoute);
  app.use("/prices/current/offchain", offchainPricesRoute);
  app.use("/networks", networksRoute);
  app.use("/portfolio", requireAccessToken, portfolioRoute);
  app.use("/wallets", requireAccessToken, walletsRoute);
  app.use("/users", requireAccessToken, usersRoute);
  app.use("/alerts", requireAccessToken, alertsRoute);
  app.use("/alert-rules", requireAccessToken, alertRulesRoute);
  app.use("/auth", authRoute);
  app.use("/static/token-icons", tokenIconsRoute);

  app.use(errorHandler);

  return app;
}

export function startServer() {
  const app = createApp();

  app.listen(ENV.PORT_API, () => {
    console.log(`🚀 Backend running on http://localhost:${ENV.PORT_API}`);
  });

  return app;
}
