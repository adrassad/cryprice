import Decimal from "decimal.js";
import { HttpError } from "../../api/errors/httpError.js";
import { db } from "../../db/index.js";
import {
  calculateUsdValue,
  formatUsd,
  formatTokenBalance,
  sumRawBalances,
  sumUsdValues,
} from "./portfolio.math.js";
import {
  getHealthFactorStatus,
  getHealthFactorStatusLabel,
  isHealthFactorStale,
  normalizeHealthFactorForApi,
  selectSummaryHealthFactor,
} from "./portfolioHealthFactor.mapper.js";
import { buildPortfolioAllocation } from "./portfolioAllocation.mapper.js";
import { buildPublicUrlForAssetLogo } from "../asset/tokenIcon.service.js";

export const DEFAULT_PRICE_STALE_AFTER_MS = 60 * 60 * 1000;
const HEALTH_FACTOR_PROTOCOL = "aave";

function toRequiredString(value, fieldName) {
  if (value === undefined || value === null || value === "") {
    throw new Error(`${fieldName} is required`);
  }
  return String(value);
}

function toNullableString(value) {
  if (value === undefined || value === null) return null;
  return String(value);
}

function toIntegerValue(value, fieldName) {
  if (typeof value === "number") {
    if (!Number.isInteger(value)) throw new Error(`${fieldName} must be an integer`);
    return value;
  }
  const raw = toRequiredString(value, fieldName);
  if (!/^-?\d+$/.test(raw)) throw new Error(`${fieldName} must be an integer`);
  const parsed = parseInt(raw, 10);
  if (!Number.isSafeInteger(parsed)) {
    throw new Error(`${fieldName} is outside the safe integer range`);
  }
  return parsed;
}

function toIsoOrNull(value) {
  if (value === undefined || value === null) return null;
  if (value instanceof Date) return value.toISOString();
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return null;
  return date.toISOString();
}

function maxIso(a, b) {
  if (!a) return b ?? null;
  if (!b) return a;
  return new Date(a).getTime() >= new Date(b).getTime() ? a : b;
}

function compareIds(a, b) {
  const left = BigInt(String(a));
  const right = BigInt(String(b));
  if (left < right) return -1;
  if (left > right) return 1;
  return 0;
}

function compareAssets(a, b) {
  const aHasValue = a.valueUsd !== null;
  const bHasValue = b.valueUsd !== null;
  if (aHasValue && bHasValue) {
    const byValue = new Decimal(b.valueUsd).cmp(new Decimal(a.valueUsd));
    if (byValue !== 0) return byValue;
  } else if (aHasValue !== bHasValue) {
    return aHasValue ? -1 : 1;
  }

  const bySymbol = String(a.symbol).localeCompare(String(b.symbol));
  if (bySymbol !== 0) return bySymbol;
  return compareIds(a.assetId, b.assetId);
}

function compareProtocolPositions(a, b) {
  const aHasValue = a.valueUsd !== null;
  const bHasValue = b.valueUsd !== null;
  if (aHasValue && bHasValue) {
    const byValue = new Decimal(b.valueUsd).cmp(new Decimal(a.valueUsd));
    if (byValue !== 0) return byValue;
  } else if (aHasValue !== bHasValue) {
    return aHasValue ? -1 : 1;
  }

  const byProtocol = String(a.protocol).localeCompare(String(b.protocol));
  if (byProtocol !== 0) return byProtocol;
  const bySymbol = String(a.underlyingSymbol).localeCompare(
    String(b.underlyingSymbol),
  );
  if (bySymbol !== 0) return bySymbol;
  return String(a.tokenRole).localeCompare(String(b.tokenRole));
}

function addUsdValues(values) {
  let total = new Decimal(0);
  for (const value of values) {
    if (value === null || value === undefined) continue;
    total = total.plus(new Decimal(String(value)));
  }
  return formatUsd(total);
}

function subtractUsd(left, right) {
  return formatUsd(new Decimal(String(left)).minus(new Decimal(String(right))));
}

function protocolApiName(protocol) {
  const normalized = String(protocol ?? "").toLowerCase();
  if (normalized === "aave" || normalized === "aave_v3") return "aave_v3";
  return normalized || null;
}

function protocolDisplayName(protocol) {
  if (protocolApiName(protocol) === "aave_v3") return "Aave V3";
  return protocolApiName(protocol);
}

function networkDisplayName(networkName) {
  if (!networkName) return null;
  return String(networkName).charAt(0).toUpperCase() + String(networkName).slice(1);
}

export function protocolCategory(protocol) {
  if (protocol === "wallet") return "wallet";
  if (protocol === "aave_v3") return "lending";
  return "unknown";
}

export function withWalletAliases(walletEntry) {
  const address = walletEntry.address ?? null;
  const label = walletEntry.label ?? null;
  return {
    ...walletEntry,
    walletAddress: address,
    walletLabel: label,
  };
}

function isZeroAddress(value) {
  return typeof value === "string" && /^0x0{40}$/i.test(value.trim());
}

function debtTypeFromTokenRole(tokenRole) {
  if (tokenRole === "stable_debt_token") return "stable";
  if (tokenRole === "variable_debt_token") return "variable";
  return null;
}

function priceStatus(priceUsd, priceCalculatedAt, nowMs, staleAfterMs) {
  if (priceUsd === null) return "missing";
  const calculatedMs = priceCalculatedAt ? new Date(priceCalculatedAt).getTime() : null;
  if (
    calculatedMs === null ||
    Number.isNaN(calculatedMs) ||
    nowMs - calculatedMs > staleAfterMs
  ) {
    return "stale";
  }
  return "ok";
}

function logoUrlFromAssetMetadata(metadata, chainId) {
  return buildPublicUrlForAssetLogo(
    {
      logo_status: metadata.logoStatus ?? metadata.logo_status ?? null,
      logo_local_path: metadata.logoLocalPath ?? metadata.logo_local_path ?? null,
      logo_content_hash:
        metadata.logoContentHash ?? metadata.logo_content_hash ?? null,
      logo_updated_at:
        metadata.logoUpdatedAt ?? metadata.logo_updated_at ?? null,
    },
    chainId,
  );
}

export function buildPortfolioAggregationFromRows(rows, options = {}) {
  if (!Array.isArray(rows)) {
    throw new Error("rows must be an array");
  }

  const staleAfterMs = options.staleAfterMs ?? DEFAULT_PRICE_STALE_AFTER_MS;
  const nowMs = options.now ? new Date(options.now).getTime() : Date.now();
  const includeWallets = options.includeWallets !== false;

  const walletsSeen = new Set();
  const networksById = new Map();
  const assetsByKey = new Map();
  let updatedAt = null;

  for (const row of rows) {
    const walletId = toRequiredString(row.wallet_id, "wallet_id");
    const networkId = toIntegerValue(row.network_id, "network_id");
    const assetId = toRequiredString(row.asset_id, "asset_id");
    const decimals = toIntegerValue(row.asset_decimals, "asset_decimals");
    const balanceRaw = toRequiredString(row.balance_raw, "balance_raw");
    const balanceSyncedAt = toIsoOrNull(row.balance_synced_at);
    const priceCalculatedAt = toIsoOrNull(row.price_calculated_at);
    const priceUsd = toNullableString(row.price_usd);
    const assetKey = `${networkId}:${assetId}`;
    const chainId = toIntegerValue(row.chain_id, "chain_id");

    walletsSeen.add(walletId);
    updatedAt = maxIso(updatedAt, balanceSyncedAt);
    updatedAt = maxIso(updatedAt, priceCalculatedAt);

    if (!networksById.has(networkId)) {
      networksById.set(networkId, {
        networkId,
        chainId: toIntegerValue(row.chain_id, "chain_id"),
        name: toRequiredString(row.network_name, "network_name"),
        nativeSymbol: toRequiredString(row.native_symbol, "native_symbol"),
        assets: [],
      });
    }

    let assetGroup = assetsByKey.get(assetKey);
    if (!assetGroup) {
      assetGroup = {
        networkId,
        assetId,
        symbol: toRequiredString(row.asset_symbol, "asset_symbol"),
        address: toRequiredString(row.asset_address, "asset_address"),
        decimals,
        logo_url: logoUrlFromAssetMetadata(
          {
            logo_status: row.asset_logo_status,
            logo_local_path: row.asset_logo_local_path,
            logo_content_hash: row.asset_logo_content_hash,
            logo_updated_at: row.asset_logo_updated_at,
          },
          chainId,
        ),
        priceUsd,
        priceCalculatedAt,
        priceStatus: priceStatus(priceUsd, priceCalculatedAt, nowMs, staleAfterMs),
        balanceSyncedAt: null,
        rawValues: [],
        wallets: [],
      };
      assetsByKey.set(assetKey, assetGroup);
      networksById.get(networkId).assets.push(assetGroup);
    }

    assetGroup.rawValues.push(balanceRaw);
    assetGroup.balanceSyncedAt = maxIso(assetGroup.balanceSyncedAt, balanceSyncedAt);

    const walletBalance = formatTokenBalance(balanceRaw, decimals);
    assetGroup.wallets.push({
      walletId,
      address: toRequiredString(row.wallet_address, "wallet_address"),
      label: toNullableString(row.wallet_label),
      balanceRaw,
      balance: walletBalance,
      valueUsd: calculateUsdValue(walletBalance, priceUsd),
      syncedAt: balanceSyncedAt,
      blockNumber: row.block_number ?? null,
    });
  }

  const networks = [...networksById.values()]
    .sort((a, b) => compareIds(a.networkId, b.networkId))
    .map((network) => {
      const assets = network.assets.map((assetGroup) => {
        const balanceRaw = sumRawBalances(assetGroup.rawValues);
        const balance = formatTokenBalance(balanceRaw, assetGroup.decimals);
        const valueUsd = calculateUsdValue(balance, assetGroup.priceUsd);
        const wallets = assetGroup.wallets.sort((a, b) =>
          compareIds(a.walletId, b.walletId),
        );

        return {
          assetId: assetGroup.assetId,
          symbol: assetGroup.symbol,
          address: assetGroup.address,
          decimals: assetGroup.decimals,
          logo_url: assetGroup.logo_url,
          balanceRaw,
          balance,
          priceUsd: assetGroup.priceUsd,
          valueUsd,
          priceStatus: assetGroup.priceStatus,
          priceCalculatedAt: assetGroup.priceCalculatedAt,
          balanceSyncedAt: assetGroup.balanceSyncedAt,
          wallets: includeWallets ? wallets : [],
        };
      });

      assets.sort(compareAssets);
      return {
        networkId: network.networkId,
        chainId: network.chainId,
        name: network.name,
        nativeSymbol: network.nativeSymbol,
        totalValueUsd: sumUsdValues(assets.map((asset) => asset.valueUsd)),
        assets,
      };
    });

  return {
    summary: {
      totalValueUsd: sumUsdValues(networks.map((network) => network.totalValueUsd)),
      walletsCount: walletsSeen.size,
      assetsCount: assetsByKey.size,
      networksCount: networks.length,
      updatedAt,
    },
    networks,
  };
}

export function buildWalletHoldings(networks) {
  return networks.flatMap((network) =>
    network.assets.map((asset) => ({
      kind: "wallet_holding",
      networkId: network.networkId,
      network: network.name,
      networkName: networkDisplayName(network.name),
      chainId: network.chainId,
      assetId: asset.assetId,
      assetSymbol: asset.symbol,
      assetAddress: asset.address,
      symbol: asset.symbol,
      address: asset.address,
      decimals: asset.decimals,
      logo_url: asset.logo_url ?? null,
      balanceRaw: asset.balanceRaw,
      amount: asset.balance,
      priceUsd: asset.priceUsd,
      valueUsd: asset.valueUsd,
      priceStatus: asset.priceStatus,
      priceCalculatedAt: asset.priceCalculatedAt,
      balanceSyncedAt: asset.balanceSyncedAt,
      wallets: asset.wallets.map(withWalletAliases),
    })),
  );
}

function buildNetworkMap(networks) {
  const map = new Map();
  for (const network of networks) {
    map.set(String(network.networkId), network);
  }
  return map;
}

function buildWalletMap(walletsMap) {
  const map = new Map();
  for (const wallet of walletsMap.values()) {
    map.set(String(wallet.address).toLowerCase(), wallet);
  }
  return map;
}

function formatThreshold(value) {
  try {
    return new Decimal(String(value ?? "1.2")).toFixed(2);
  } catch {
    return "1.20";
  }
}

export function buildDefiRisk({ hfRows, walletsMap, networkMap, threshold }) {
  const walletByAddress = buildWalletMap(walletsMap);
  const positionsHealth = hfRows.map((row) => {
    const networkId = toIntegerValue(row.network_id, "network_id");
    const normalized = normalizeHealthFactorForApi(row.healthfactor);
    const updatedAt = toIsoOrNull(row.collected_at);
    const status = getHealthFactorStatus(normalized.value, threshold);
    const wallet = walletByAddress.get(String(row.address).toLowerCase());
    const network = networkMap.get(String(networkId));
    const stale = isHealthFactorStale(row.collected_at);

    return {
      protocol: protocolApiName(row.protocol),
      protocolName: protocolDisplayName(row.protocol),
      networkId,
      network: network?.name ?? null,
      networkName: networkDisplayName(network?.name),
      walletId: wallet?.id != null ? String(wallet.id) : null,
      walletAddress: String(row.address).toLowerCase(),
      walletLabel: wallet?.label != null ? String(wallet.label) : null,
      healthFactor: normalized.value,
      value: normalized.value,
      status,
      statusLabel: getHealthFactorStatusLabel(status),
      threshold: formatThreshold(threshold),
      updatedAt,
      stale,
    };
  });

  const healthFactor = selectSummaryHealthFactor(positionsHealth);

  return {
    healthFactor,
    positionsHealth,
  };
}

export function buildProtocolAggregationFromRows(rows, options = {}) {
  if (!Array.isArray(rows)) {
    throw new Error("rows must be an array");
  }

  const staleAfterMs = options.staleAfterMs ?? DEFAULT_PRICE_STALE_AFTER_MS;
  const nowMs = options.now ? new Date(options.now).getTime() : Date.now();
  const includeWallets = options.includeWallets !== false;
  const groups = new Map();

  for (const row of rows) {
    if (isZeroAddress(row.token_address)) continue;

    const side = toRequiredString(row.position_side, "position_side");
    const networkId = toIntegerValue(row.network_id, "network_id");
    const tokenId = toRequiredString(
      row.protocol_asset_token_id,
      "protocol_asset_token_id",
    );
    const key = `${networkId}:${row.protocol}:${side}:${tokenId}`;
    const decimals = toIntegerValue(row.underlying_decimals, "underlying_decimals");
    const balanceRaw = toRequiredString(row.balance_raw, "balance_raw");
    const priceUsd = toNullableString(row.price_usd);
    const priceCalculatedAt = toIsoOrNull(row.price_calculated_at);
    const balanceSyncedAt = toIsoOrNull(row.balance_synced_at);

    let group = groups.get(key);
    if (!group) {
      group = {
        kind: "protocol_position",
        protocol: toRequiredString(row.protocol, "protocol"),
        networkId,
        network: toRequiredString(row.network_name, "network_name"),
        networkName: networkDisplayName(row.network_name),
        chainId: toIntegerValue(row.chain_id, "chain_id"),
        positionSide: side,
        tokenRole: toRequiredString(row.token_role, "token_role"),
        protocolAssetTokenId: tokenId,
        underlyingAssetId: toRequiredString(
          row.underlying_asset_id,
          "underlying_asset_id",
        ),
        underlyingSymbol: toRequiredString(
          row.underlying_symbol,
          "underlying_symbol",
        ),
        underlyingAddress: toRequiredString(
          row.underlying_address,
          "underlying_address",
        ),
        logo_url: logoUrlFromAssetMetadata(
          {
            logo_status: row.underlying_logo_status,
            logo_local_path: row.underlying_logo_local_path,
            logo_content_hash: row.underlying_logo_content_hash,
            logo_updated_at: row.underlying_logo_updated_at,
          },
          toIntegerValue(row.chain_id, "chain_id"),
        ),
        decimals,
        tokenSymbol: toNullableString(row.token_symbol),
        tokenAddress: toRequiredString(row.token_address, "token_address"),
        priceAssetId: toNullableString(row.price_asset_id),
        priceAssetSymbol: toNullableString(row.price_asset_symbol),
        priceUsd,
        priceCalculatedAt,
        priceStatus: priceStatus(priceUsd, priceCalculatedAt, nowMs, staleAfterMs),
        balanceSyncedAt: null,
        rawValues: [],
        wallets: [],
      };
      groups.set(key, group);
    }

    group.rawValues.push(balanceRaw);
    group.balanceSyncedAt = maxIso(group.balanceSyncedAt, balanceSyncedAt);

    const walletAmount = formatTokenBalance(balanceRaw, decimals);
    group.wallets.push({
      walletId: toRequiredString(row.wallet_id, "wallet_id"),
      address: toRequiredString(row.wallet_address, "wallet_address"),
      label: toNullableString(row.wallet_label),
      balanceRaw,
      amount: walletAmount,
      valueUsd: calculateUsdValue(walletAmount, priceUsd),
      syncedAt: balanceSyncedAt,
      blockNumber: row.block_number ?? null,
    });
  }

  const positions = [...groups.values()].map((group) => {
    const balanceRaw = sumRawBalances(group.rawValues);
    const amount = formatTokenBalance(balanceRaw, group.decimals);
    const valueUsd = calculateUsdValue(amount, group.priceUsd);
    return {
      kind: group.kind,
      protocol: protocolApiName(group.protocol),
      protocolName: protocolDisplayName(group.protocol),
      networkId: group.networkId,
      network: group.network,
      networkName: group.networkName,
      chainId: group.chainId,
      positionSide: group.positionSide,
      tokenRole: group.tokenRole,
      ...(group.positionSide === "borrowed"
        ? { debtType: debtTypeFromTokenRole(group.tokenRole) }
        : {}),
      protocolAssetTokenId: group.protocolAssetTokenId,
      underlyingAssetId: group.underlyingAssetId,
      underlyingSymbol: group.underlyingSymbol,
      underlyingAddress: group.underlyingAddress,
      logo_url: group.logo_url,
      tokenSymbol: group.tokenSymbol,
      tokenAddress: group.tokenAddress,
      decimals: group.decimals,
      balanceRaw,
      amount,
      priceAssetId: group.priceAssetId,
      priceAssetSymbol: group.priceAssetSymbol,
      priceUsd: group.priceUsd,
      valueUsd,
      priceStatus: group.priceStatus,
      priceCalculatedAt: group.priceCalculatedAt,
      balanceSyncedAt: group.balanceSyncedAt,
      wallets: includeWallets
        ? group.wallets
            .sort((a, b) => compareIds(a.walletId, b.walletId))
            .map(withWalletAliases)
        : [],
    };
  });

  positions.sort(compareProtocolPositions);

  return {
    supplied: positions.filter((p) => p.positionSide === "supplied"),
    borrowed: positions.filter((p) => p.positionSide === "borrowed"),
  };
}

function walletIdentityFromNested(nested) {
  return {
    walletId: String(nested.walletId),
    walletAddress: String(
      nested.walletAddress ?? nested.address ?? "",
    ).toLowerCase(),
    walletLabel:
      nested.walletLabel !== undefined
        ? nested.walletLabel
        : nested.label !== undefined
          ? nested.label
          : null,
  };
}

export function buildWalletsSelector(
  userWallets,
  walletHoldings,
  protocolPositions,
  positionsHealth,
) {
  const byWallet = new Map();

  const ensure = (walletId, walletAddress, walletLabel) => {
    const key = String(walletId);
    if (!byWallet.has(key)) {
      byWallet.set(key, {
        walletId: key,
        walletAddress,
        walletLabel,
        walletValues: [],
        suppliedValues: [],
        borrowedValues: [],
      });
    }
    return byWallet.get(key);
  };

  for (const wallet of userWallets ?? []) {
    ensure(
      wallet.id,
      String(wallet.address).toLowerCase(),
      wallet.label != null ? String(wallet.label) : null,
    );
  }

  for (const holding of walletHoldings ?? []) {
    for (const nested of holding.wallets ?? []) {
      const { walletId, walletAddress, walletLabel } =
        walletIdentityFromNested(nested);
      const entry = ensure(walletId, walletAddress, walletLabel);
      if (nested.valueUsd != null) entry.walletValues.push(nested.valueUsd);
    }
  }

  for (const position of protocolPositions?.supplied ?? []) {
    for (const nested of position.wallets ?? []) {
      const { walletId, walletAddress, walletLabel } =
        walletIdentityFromNested(nested);
      const entry = ensure(walletId, walletAddress, walletLabel);
      if (nested.valueUsd != null) entry.suppliedValues.push(nested.valueUsd);
    }
  }

  for (const position of protocolPositions?.borrowed ?? []) {
    for (const nested of position.wallets ?? []) {
      const { walletId, walletAddress, walletLabel } =
        walletIdentityFromNested(nested);
      const entry = ensure(walletId, walletAddress, walletLabel);
      if (nested.valueUsd != null) entry.borrowedValues.push(nested.valueUsd);
    }
  }

  return [...byWallet.values()]
    .map((entry) => {
      const walletValueUsd = addUsdValues(entry.walletValues);
      const suppliedValueUsd = addUsdValues(entry.suppliedValues);
      const borrowedValueUsd = addUsdValues(entry.borrowedValues);
      const grossValueUsd = addUsdValues([walletValueUsd, suppliedValueUsd]);
      const netValueUsd = subtractUsd(grossValueUsd, borrowedValueUsd);
      const walletHf = selectSummaryHealthFactor(
        (positionsHealth ?? []).filter((item) => item.walletId === entry.walletId),
      );

      return {
        walletId: entry.walletId,
        walletAddress: entry.walletAddress,
        walletLabel: entry.walletLabel,
        walletValueUsd,
        suppliedValueUsd,
        borrowedValueUsd,
        grossValueUsd,
        netValueUsd,
        healthFactor: walletHf.value,
        healthFactorStatus: walletHf.status,
        healthFactorStatusLabel: walletHf.statusLabel,
      };
    })
    .sort((a, b) => compareIds(a.walletId, b.walletId));
}

function buildWalletProtocolSummary(walletValueUsd) {
  return {
    protocol: "wallet",
    protocolName: "Wallet",
    category: "wallet",
    walletValueUsd,
    suppliedValueUsd: "0.00",
    borrowedValueUsd: "0.00",
    grossValueUsd: walletValueUsd,
    netValueUsd: walletValueUsd,
    totalValueUsd: walletValueUsd,
    healthFactor: null,
    healthFactorStatus: "none",
    healthFactorStatusLabel: null,
    networks: [],
  };
}

export function buildProtocolSummaries(
  walletValueUsd,
  protocolPositions,
  positionsHealth,
) {
  const summaries = [buildWalletProtocolSummary(walletValueUsd)];
  const protocols = new Set();

  for (const position of [
    ...(protocolPositions?.supplied ?? []),
    ...(protocolPositions?.borrowed ?? []),
  ]) {
    if (position.protocol) protocols.add(position.protocol);
  }

  for (const protocol of [...protocols].sort((a, b) => String(a).localeCompare(String(b)))) {
    const supplied = (protocolPositions?.supplied ?? []).filter(
      (p) => p.protocol === protocol,
    );
    const borrowed = (protocolPositions?.borrowed ?? []).filter(
      (p) => p.protocol === protocol,
    );
    const suppliedValueUsd = addUsdValues(supplied.map((p) => p.valueUsd));
    const borrowedValueUsd = addUsdValues(borrowed.map((p) => p.valueUsd));
    const grossValueUsd = addUsdValues(["0.00", suppliedValueUsd]);
    const netValueUsd = subtractUsd(grossValueUsd, borrowedValueUsd);
    const protocolHf = selectSummaryHealthFactor(
      (positionsHealth ?? []).filter((item) => item.protocol === protocol),
    );

    const networkIds = new Set();
    for (const position of [...supplied, ...borrowed]) {
      networkIds.add(position.networkId);
    }

    const networks = [...networkIds]
      .sort((a, b) => compareIds(a, b))
      .map((networkId) => {
        const networkSupplied = supplied.filter((p) => p.networkId === networkId);
        const networkBorrowed = borrowed.filter((p) => p.networkId === networkId);
        const networkSuppliedUsd = addUsdValues(
          networkSupplied.map((p) => p.valueUsd),
        );
        const networkBorrowedUsd = addUsdValues(
          networkBorrowed.map((p) => p.valueUsd),
        );
        const networkNetUsd = subtractUsd(networkSuppliedUsd, networkBorrowedUsd);
        const reference = networkSupplied[0] ?? networkBorrowed[0];
        const networkHf = selectSummaryHealthFactor(
          (positionsHealth ?? []).filter(
            (item) =>
              item.protocol === protocol && item.networkId === networkId,
          ),
        );

        return {
          networkId,
          network: reference?.network ?? null,
          networkName: reference?.networkName ?? null,
          netValueUsd: networkNetUsd,
          healthFactor: networkHf.value,
          healthFactorStatus: networkHf.status,
          healthFactorStatusLabel: networkHf.statusLabel,
        };
      });

    summaries.push({
      protocol,
      protocolName: protocolDisplayName(protocol) ?? protocol,
      category: protocolCategory(protocol),
      walletValueUsd: "0.00",
      suppliedValueUsd,
      borrowedValueUsd,
      grossValueUsd,
      netValueUsd,
      totalValueUsd: suppliedValueUsd,
      healthFactor: protocolHf.value,
      healthFactorStatus: protocolHf.status,
      healthFactorStatusLabel: protocolHf.statusLabel,
      networks,
    });
  }

  return summaries;
}

export async function getAggregatedUserPortfolio(internalUserId, options = {}) {
  if (internalUserId === undefined || internalUserId === null || internalUserId === "") {
    throw new HttpError(400, "INVALID_REQUEST", "userId is required.");
  }

  const user = await db.users.findByInternalId(internalUserId);
  if (!user) {
    throw new HttpError(404, "USER_NOT_FOUND", "User not found.");
  }

  const wallets = await db.wallets.findByUserId(user.id);
  const walletsMap = new Map(
    wallets.map((wallet) => [String(wallet.address).toLowerCase(), wallet]),
  );
  const walletAddresses = wallets.map((wallet) => wallet.address);
  const [rows, protocolRows, hfRows, allNetworks] = await Promise.all([
    db.portfolioAggregation.findRawRowsByInternalUserId(user.id),
    db.portfolioAggregation.findProtocolRowsByInternalUserId(user.id),
    db.hf.findLatestByAddresses(walletAddresses, {
      protocol: HEALTH_FACTOR_PROTOCOL,
    }),
    db.networks.findAll(),
  ]);
  const walletAggregation = buildPortfolioAggregationFromRows(rows, options);
  const protocolPositions = buildProtocolAggregationFromRows(protocolRows, options);
  const networkMap = buildNetworkMap(walletAggregation.networks);
  for (const network of allNetworks) {
    if (!networkMap.has(String(network.id))) {
      networkMap.set(String(network.id), {
        networkId: toIntegerValue(network.id, "network_id"),
        chainId: toIntegerValue(network.chain_id, "chain_id"),
        name: toRequiredString(network.name, "network_name"),
      });
    }
  }
  for (const p of [...protocolPositions.supplied, ...protocolPositions.borrowed]) {
    if (!networkMap.has(String(p.networkId))) {
      networkMap.set(String(p.networkId), {
        networkId: p.networkId,
        chainId: p.chainId,
        name: p.network,
      });
    }
  }
  const defiRisk = buildDefiRisk({
    hfRows,
    walletsMap,
    networkMap,
    threshold: user.threshold_hf,
  });

  const walletValueUsd = walletAggregation.summary.totalValueUsd;
  const suppliedValueUsd = addUsdValues(
    protocolPositions.supplied.map((p) => p.valueUsd),
  );
  const borrowedValueUsd = addUsdValues(
    protocolPositions.borrowed.map((p) => p.valueUsd),
  );
  const grossValueUsd = addUsdValues([walletValueUsd, suppliedValueUsd]);
  const netValueUsd = subtractUsd(grossValueUsd, borrowedValueUsd);
  const walletHoldings = buildWalletHoldings(walletAggregation.networks);
  const walletsSelector = buildWalletsSelector(
    wallets,
    walletHoldings,
    protocolPositions,
    defiRisk.positionsHealth,
  );
  const protocolSummaries = buildProtocolSummaries(
    walletValueUsd,
    protocolPositions,
    defiRisk.positionsHealth,
  );
  const allocation = buildPortfolioAllocation({
    walletHoldings,
    protocolPositions,
    protocolSummaries,
    wallets: walletsSelector,
  });

  return {
    ...walletAggregation,
    summary: {
      ...walletAggregation.summary,
      walletValueUsd,
      suppliedValueUsd,
      borrowedValueUsd,
      grossValueUsd,
      netValueUsd,
      healthFactor: defiRisk.healthFactor.value,
      healthFactorStatus: defiRisk.healthFactor.status,
      healthFactorStatusLabel: defiRisk.healthFactor.statusLabel,
    },
    walletHoldings,
    protocolPositions,
    defiRisk,
    wallets: walletsSelector,
    protocolSummaries,
    totals: {
      walletValueUsd,
      suppliedValueUsd,
      borrowedValueUsd,
      grossValueUsd,
      netValueUsd,
    },
    allocation,
  };
}
