//
import { Contract, getAddress, isAddress } from "ethers";
import { AaveBaseAdapter } from "../base.protocol.js";
import { getTokenMetadata } from "../../../helpers/tokenMetadata.js";
import { parseHealthFactor } from "../../../helpers/healthFactor.js";

export class AaveAdapter extends AaveBaseAdapter {
  constructor({ provider, config, AbiRegistry, networkName }) {
    super({ provider, config });

    this.AbiRegistry = AbiRegistry;
    this.networkName = networkName;

    if (!config.ADDRESSES_PROVIDER) {
      throw new Error("Aave ADDRESSES_PROVIDER not configured");
    }

    this.addressesProviderAddress = getAddress(config.ADDRESSES_PROVIDER);
  }

  /**
   * lazy init addresses provider
   */
  async getAddressesProvider() {
    if (!this.addressesProvider) {
      const abi = await this.AbiRegistry.get(
        this.networkName,
        this.addressesProviderAddress.toLowerCase(),
        "aave",
      );

      this.addressesProvider = new Contract(
        this.addressesProviderAddress,
        abi,
        this.provider,
      );
    }

    return this.addressesProvider;
  }

  async getPool() {
    if (!this.pool) {
      const provider = await this.getAddressesProvider();

      const poolAddress = await provider.getPoolDataProvider();

      const abi = await this.AbiRegistry.get(
        this.networkName,
        poolAddress.toLowerCase(),
        "aave",
      );

      this.pool = new Contract(poolAddress, abi, this.provider);
    }

    return this.pool;
  }

  async getOracle() {
    if (!this.oracle) {
      const provider = await this.getAddressesProvider();

      const oracleAddress = await provider.getPriceOracle();

      const abi = await this.AbiRegistry.get(
        this.networkName,
        oracleAddress.toLowerCase(),
        "aave",
      );

      this.oracle = new Contract(oracleAddress, abi, this.provider);
    }

    return this.oracle;
  }

  async getDataProvider() {
    if (!this.dataProvider) {
      const provider = await this.getAddressesProvider();

      const address = await provider.getPoolDataProvider();

      const abi = await this.AbiRegistry.get(
        this.networkName,
        address.toLowerCase(),
        "aave",
      );

      this.dataProvider = new Contract(address, abi, this.provider);
    }

    return this.dataProvider;
  }

  async getAssets() {
    const pool = await this.getPool();

    // const reserves = await pool.getReservesList();
    const reserves = await pool.getAllReservesTokens();

    const assets = await Promise.all(
      reserves.map((reserve) =>
        getTokenMetadata(reserve[1], this.provider).catch(() => null),
      ),
    );

    return assets.filter(Boolean);
  }

  async getProtocolAssetTokens() {
    const dataProvider = await this.getDataProvider();

    if (
      typeof dataProvider.getAllReservesTokens !== "function" ||
      typeof dataProvider.getReserveTokensAddresses !== "function"
    ) {
      throw new Error("Aave Data Provider reserve token methods unavailable");
    }

    const reserves = await dataProvider.getAllReservesTokens();
    const rows = await Promise.all(
      reserves.map((reserve) =>
        this.getProtocolAssetTokenMapping(reserve, dataProvider).catch((e) => {
          const underlyingAddress = extractReserveAddress(reserve);
          console.warn(
            "getProtocolAssetTokens reserve failed",
            this.networkName,
            underlyingAddress ?? "unknown",
            e.message,
          );
          return null;
        }),
      ),
    );

    return rows.filter(Boolean);
  }

  async getProtocolAssetTokenMapping(reserve, dataProvider) {
    const underlyingAddress = normalizeAddressLower(extractReserveAddress(reserve));
    if (!underlyingAddress) {
      throw new Error("Aave reserve underlying address missing");
    }

    const [underlying, reserveTokenAddresses] = await Promise.all([
      getTokenMetadata(underlyingAddress, this.provider).catch(() => null),
      dataProvider.getReserveTokensAddresses(underlyingAddress),
    ]);

    const tokenSpecs = [
      {
        tokenRole: "supply_token",
        address: reserveTokenAddresses.aTokenAddress ?? reserveTokenAddresses[0],
      },
      {
        tokenRole: "stable_debt_token",
        address:
          reserveTokenAddresses.stableDebtTokenAddress ?? reserveTokenAddresses[1],
      },
      {
        tokenRole: "variable_debt_token",
        address:
          reserveTokenAddresses.variableDebtTokenAddress ?? reserveTokenAddresses[2],
      },
    ];

    const tokens = await Promise.all(
      tokenSpecs.map((spec) => this.getProtocolTokenMetadata(spec)),
    );

    return {
      protocol: "aave_v3",
      underlying: {
        address: underlyingAddress,
        symbol: underlying?.symbol ?? null,
        decimals: underlying?.decimals ?? null,
      },
      tokens,
      metadata: {
        source: "aave_data_provider",
      },
    };
  }

  async getProtocolTokenMetadata({ tokenRole, address }) {
    const normalizedAddress = normalizeAddressLower(address);
    if (!normalizedAddress) {
      return {
        tokenRole,
        address: null,
        symbol: null,
        decimals: null,
      };
    }

    const metadata = await getTokenMetadata(normalizedAddress, this.provider).catch(
      (e) => {
        console.warn(
          "getProtocolAssetTokens token metadata failed",
          this.networkName,
          tokenRole,
          normalizedAddress,
          e.message,
        );
        return null;
      },
    );

    return {
      tokenRole,
      address: normalizedAddress,
      symbol: metadata?.symbol ?? null,
      decimals: metadata?.decimals ?? null,
    };
  }

  async getPrices(assets) {
    const block = await this.provider.getBlock("latest");
    const collected_at = new Date(block.timestamp * 1000);

    const ORACLE_DECIMALS = 8;

    const oracle = await this.getOracle();

    const prices = {};

    // отфильтровать и нормализовать адреса
    const validAssets = assets.filter((a) => a.address && isAddress(a.address));

    if (!validAssets.length) {
      return prices;
    }

    const addresses = validAssets.map((a) => a.address);

    try {
      // один вызов вместо множества
      const rawPrices = await oracle.getAssetsPrices(addresses);

      rawPrices.forEach((rawPrice, index) => {
        if (!rawPrice || rawPrice === 0n) return;

        const asset = validAssets[index];
        const addressLower = asset.address.toLowerCase();

        prices[addressLower] = {
          address: asset.address,
          symbol: asset.symbol,
          collected_at,
          price: Number(rawPrice) / 10 ** ORACLE_DECIMALS,
        };
      });
    } catch (e) {
      console.error(
        "Batch price fetch failed:",
        new Date().toISOString(),
        e.message,
      );
    }

    return prices;
  }

  async getUserHealthFactor(userAddress) {
    try {
      const block = await this.provider.getBlock("latest");
      const collected_at = new Date(block.timestamp * 1000);
      const provider = await this.getAddressesProvider();
      const proxiPoolAddress = await provider.getPool();

      const abi = [
        "function getUserAccountData(address user) view returns (uint256 totalCollateralBase, uint256 totalDebtBase, uint256 availableBorrowsBase, uint256 currentLiquidationThreshold, uint256 ltv, uint256 healthFactor)",
      ];

      const pool = new Contract(proxiPoolAddress, abi, this.provider);

      const { healthFactor } = await pool.getUserAccountData(userAddress);

      return { healthFactor: parseHealthFactor(healthFactor), collected_at };
    } catch (e) {
      console.warn("getUserHealthFactor failed", e.message);

      return { healthFactor: null, collected_at: null };
    }
  }

  async getUserPositions(userAddress) {
    // console.log("getUserPositions chain:", this.networkName);
    const healthFactor = await this.getUserHealthFactor(userAddress);

    try {
      const uiAddress = getAddress(this.config.DATA_PROVIDER);

      const abi = await this.AbiRegistry.get(
        this.networkName,
        uiAddress.toLowerCase(),
        "aave",
      );

      const ui = new Contract(uiAddress, abi, this.provider);

      let userReserves = [];

      if (typeof ui.getUserReservesData === "function") {
        [userReserves] = await ui.getUserReservesData(
          this.addressesProviderAddress,
          userAddress,
        );
      } else {
        // Some networks may have POOL_DATA_PROVIDER configured instead of UI_POOL_DATA_PROVIDER.
        // Fallback to per-asset reads from PoolDataProvider to keep /positions functional.
        const dataProvider = await this.getDataProvider();
        const reserves = await dataProvider.getAllReservesTokens();

        const rows = await Promise.all(
          reserves.map(async (reserve) => {
            const underlyingAsset = reserve?.tokenAddress ?? reserve?.[1];
            if (!underlyingAsset) return null;

            const raw = await dataProvider.getUserReserveData(
              underlyingAsset,
              userAddress,
            );

            return normalizePoolDataProviderUserReserve(underlyingAsset, raw);
          }),
        );

        userReserves = rows.filter(Boolean);
      }

      const positions = parseUserPositions(userReserves);

      return {
        positions,
        healthFactor,
        error: null,
      };
    } catch (e) {
      return {
        positions: [],
        healthFactor,
        error: e.message,
      };
    }
  }
}

function extractReserveAddress(reserve) {
  return reserve?.tokenAddress ?? reserve?.[1] ?? null;
}

function normalizeAddressLower(address) {
  if (!address || typeof address !== "string" || !isAddress(address)) return null;
  const normalized = address.toLowerCase();
  if (normalized === "0x0000000000000000000000000000000000000000") {
    return null;
  }
  return normalized;
}

function normalizePoolDataProviderUserReserve(underlyingAsset, raw) {
  if (!raw) return null;

  return {
    underlyingAsset,
    scaledATokenBalance: raw.currentATokenBalance ?? raw[0] ?? 0n,
    principalStableDebt: raw.principalStableDebt ?? raw[3] ?? 0n,
    scaledVariableDebt: raw.scaledVariableDebt ?? raw[4] ?? 0n,
    usageAsCollateralEnabledOnUser:
      raw.usageAsCollateralEnabled ?? raw[8] ?? false,
    stableBorrowRate: raw.stableBorrowRate ?? raw[5] ?? 0n,
    stableBorrowLastUpdateTimestamp: raw.stableRateLastUpdated ?? raw[7] ?? 0,
  };
}

export function parseUserPositions(userReserves) {
  // console.log("userReserves: ", userReserves);
  return userReserves
    .filter(
      (r) =>
        r.underlyingAsset !== "0x0000000000000000000000000000000000000000" &&
        (r.scaledATokenBalance > 0n ||
          r.principalStableDebt > 0n ||
          r.scaledVariableDebt > 0n),
    )
    .map((r) => ({
      assetAddress: r?.underlyingAsset ?? null,
      aTokenBalance: toBigIntSafe(r?.scaledATokenBalance),
      stableDebt: toBigIntSafe(r?.principalStableDebt),
      variableDebt: toBigIntSafe(r?.scaledVariableDebt),
      collateral: toBoolSafe(r?.usageAsCollateralEnabledOnUser),
      stableBorrowRate: toBigIntSafe(r?.stableBorrowRate),
      stableBorrowLastUpdateTimestamp: toNumberSafe(
        r?.stableBorrowLastUpdateTimestamp,
      ),
    }));
}

function toBigIntSafe(value) {
  if (value === undefined || value === null) return 0n;

  try {
    return BigInt(value);
  } catch {
    return 0n;
  }
}

function toBoolSafe(value) {
  return Boolean(value);
}

function toNumberSafe(value) {
  if (value === undefined || value === null) return 0;
  return Number(value);
}
