//src/api/server.js
import express from "express";
import cors from "cors";
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
import apiLimiter from "./middlewares/rateLimit.middleware.js";
import authLimiter from "./middlewares/authRateLimit.middleware.js";
import { errorHandler } from "./middlewares/error.middleware.js";
import { ENV } from "../config/env.js";

export function startServer() {
  const app = express();
  app.set("trust proxy", 1);
  app.use(cors());
  app.use(express.json());

  app.use("/health", apiLimiter);
  app.use("/assets", apiLimiter);
  app.use("/prices/current/onchain", apiLimiter);
  app.use("/prices/current/offchain", apiLimiter);
  app.use("/networks", apiLimiter);
  app.use("/portfolio", apiLimiter);
  app.use("/wallets", apiLimiter);
  app.use("/users", apiLimiter);
  app.use("/auth", authLimiter);
  app.use("/static/token-icons", apiLimiter);

  app.use("/health", healthRoute);
  app.use("/assets", assetsRoute);
  app.use("/prices/current/onchain", onchainPricesRoute);
  app.use("/prices/current/offchain", offchainPricesRoute);
  app.use("/networks", networksRoute);
  app.use("/portfolio", portfolioRoute);
  app.use("/wallets", walletsRoute);
  app.use("/users", usersRoute);
  app.use("/auth", authRoute);
  app.use("/static/token-icons", tokenIconsRoute);

  app.use(errorHandler);

  app.listen(ENV.PORT_API, () => {
    console.log(`🚀 Backend running on http://localhost:${ENV.PORT_API}`);
  });

  return app;
}
