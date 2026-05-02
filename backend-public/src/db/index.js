// src/db/index.js
import { postgresClient } from "./connection.js";
import { UserRepository } from "./repositories/user.repo.js";
import { NetworkRepository } from "./repositories/network.repo.js";
import { AssetRepository } from "./repositories/asset.repo.js";
import { OnchainPriceRepository } from "./repositories/onchainPrices.repo.js";
import { OffchainPriceRepository } from "./repositories/offchainPrices.repo.js";
import { WalletRepository } from "./repositories/wallet.repo.js";
import { HFRepository } from "./repositories/healthfactor.repo.js";
import { CurrentOnchainPriceRepository } from "./repositories/currentOnchainPrices.repo.js";
import { CurrentOffchainPriceRepository } from "./repositories/currentOffchainPrices.repo.js";
import { AuthIdentityRepository } from "./repositories/authIdentity.repo.js";
import { RefreshTokenRepository } from "./repositories/refreshToken.repo.js";

export const db = {
  users: new UserRepository(postgresClient),
  networks: new NetworkRepository(postgresClient),
  assets: new AssetRepository(postgresClient),
  onchainPrices: new OnchainPriceRepository(postgresClient),
  offchainPrices: new OffchainPriceRepository(postgresClient),
  currentOnchainPrices: new CurrentOnchainPriceRepository(postgresClient),
  currentOffchainPrices: new CurrentOffchainPriceRepository(postgresClient),
  wallets: new WalletRepository(postgresClient),
  hf: new HFRepository(postgresClient),
  authIdentities: new AuthIdentityRepository(postgresClient),
  refreshTokens: new RefreshTokenRepository(postgresClient),
};
