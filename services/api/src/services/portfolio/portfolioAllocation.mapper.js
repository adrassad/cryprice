import Decimal from "decimal.js";
import { formatUsd, sumUsdValues } from "./portfolio.math.js";

export const DEFAULT_ALLOCATION_MAX_ITEMS = 8;
export const DEFAULT_ALLOCATION_MIN_PERCENTAGE = "1.00";

function safeDecimal(value) {
  if (value === null || value === undefined || value === "") return null;
  try {
    const decimal = new Decimal(String(value));
    return decimal.isFinite() ? decimal : null;
  } catch {
    return null;
  }
}

export function formatPercentage(value) {
  const decimal = safeDecimal(value);
  if (decimal === null) return "0.00";
  return decimal.toDecimalPlaces(2, Decimal.ROUND_HALF_UP).toFixed(2);
}

function isPositiveValueUsd(valueUsd) {
  const decimal = safeDecimal(valueUsd);
  return decimal !== null && decimal.gt(0);
}

function formatPositiveValueUsd(valueUsd) {
  return formatUsd(safeDecimal(valueUsd));
}

export function normalizeAllocationLabel(symbol) {
  const raw = symbol === undefined || symbol === null ? "" : String(symbol).trim();
  return raw || "Unknown";
}

function compareByValueUsdDesc(a, b) {
  const left = safeDecimal(a.valueUsd) ?? new Decimal(0);
  const right = safeDecimal(b.valueUsd) ?? new Decimal(0);
  return right.cmp(left);
}

export function calculatePercentages(items, denominatorUsd) {
  const denominator = safeDecimal(denominatorUsd);
  if (!items.length || denominator === null || denominator.lte(0)) {
    return items.map((item) => ({ ...item, percentage: "0.00" }));
  }

  return items.map((item) => {
    const value = safeDecimal(item.valueUsd);
    const percentage =
      value === null || value.lte(0)
        ? "0.00"
        : formatPercentage(value.div(denominator).mul(100));
    return { ...item, percentage };
  });
}

export function groupSmallAllocationItems(items, denominatorUsd, options = {}) {
  const maxItems = options.maxItems ?? DEFAULT_ALLOCATION_MAX_ITEMS;
  const minPercentage = safeDecimal(
    options.minPercentage ?? DEFAULT_ALLOCATION_MIN_PERCENTAGE,
  );

  const positiveItems = items
    .filter((item) => isPositiveValueUsd(item.valueUsd))
    .sort(compareByValueUsdDesc);

  if (!positiveItems.length) return [];

  const denominator = safeDecimal(denominatorUsd);
  if (denominator === null || denominator.lte(0)) {
    return calculatePercentages(positiveItems, "0");
  }

  const withPct = positiveItems.map((item) => {
    const value = safeDecimal(item.valueUsd);
    const pct = value.div(denominator).mul(100);
    return { item, pct };
  });

  const kept = [];
  const grouped = [];

  for (const { item, pct } of withPct) {
    const belowMin = minPercentage !== null && pct.lt(minPercentage);
    const atCapacity = kept.length >= maxItems;

    if (!belowMin && !atCapacity) {
      kept.push(item);
    } else {
      grouped.push(item);
    }
  }

  if (!grouped.length) {
    return calculatePercentages(kept, denominator.toFixed());
  }

  const otherValue = grouped.reduce(
    (sum, item) => sum.plus(safeDecimal(item.valueUsd) ?? 0),
    new Decimal(0),
  );

  const otherItem = {
    key: "other",
    label: "Other",
    valueUsd: formatUsd(otherValue),
    childrenCount: grouped.length,
  };

  return calculatePercentages([...kept, otherItem], denominator.toFixed());
}

function sumPositiveValueUsd(items) {
  const values = items
    .map((item) => item.valueUsd)
    .filter((value) => isPositiveValueUsd(value));
  if (!values.length) return "0.00";
  return sumUsdValues(values);
}

function allocationBaseFields(row) {
  return {
    priceUsd: row.priceUsd ?? null,
    priceStatus: row.priceStatus ?? null,
  };
}

function protocolCategory(protocol) {
  if (protocol === "wallet") return "wallet";
  if (protocol === "aave_v3") return "lending";
  return "unknown";
}

function protocolDisplayName(protocol) {
  if (protocol === "aave_v3") return "Aave V3";
  if (protocol === "wallet") return "Wallet";
  return protocol ?? null;
}

export function findNestedWalletEntry(row, walletId) {
  const targetId = String(walletId);
  return (row.wallets ?? []).find((entry) => String(entry.walletId) === targetId) ?? null;
}

export function getNestedWalletValueUsd(nestedWallet) {
  if (!nestedWallet) return null;
  const valueUsd = nestedWallet.valueUsd;
  if (valueUsd === null || valueUsd === undefined) return null;
  return valueUsd;
}

function subtractUsd(left, right) {
  return formatUsd(new Decimal(String(left)).minus(new Decimal(String(right))));
}

export function buildAssetAllocation(
  walletHoldings = [],
  protocolPositions = {},
  options = {},
) {
  const items = [];

  for (const holding of walletHoldings) {
    if (!isPositiveValueUsd(holding.valueUsd)) continue;
    const label = normalizeAllocationLabel(holding.assetSymbol ?? holding.symbol);
    items.push({
      key: label,
      label,
      valueUsd: formatPositiveValueUsd(holding.valueUsd),
      source: "wallet",
      protocol: "wallet",
      protocolName: "Wallet",
      network: holding.network ?? null,
      networkName: holding.networkName ?? null,
      assetSymbol: label,
      ...allocationBaseFields(holding),
    });
  }

  for (const position of protocolPositions.supplied ?? []) {
    if (!isPositiveValueUsd(position.valueUsd)) continue;
    const label = normalizeAllocationLabel(position.underlyingSymbol);
    items.push({
      key: label,
      label,
      valueUsd: formatPositiveValueUsd(position.valueUsd),
      source: "supplied",
      protocol: position.protocol ?? null,
      protocolName: position.protocolName ?? null,
      network: position.network ?? null,
      networkName: position.networkName ?? null,
      assetSymbol: label,
      ...allocationBaseFields(position),
    });
  }

  const denominator = sumPositiveValueUsd(items);
  return groupSmallAllocationItems(items, denominator, options);
}

export function buildDebtAllocation(protocolPositions = {}, options = {}) {
  const items = [];

  for (const position of protocolPositions.borrowed ?? []) {
    if (!isPositiveValueUsd(position.valueUsd)) continue;
    const label = normalizeAllocationLabel(position.underlyingSymbol);
    const entry = {
      key: label,
      label,
      valueUsd: formatPositiveValueUsd(position.valueUsd),
      source: "borrowed",
      protocol: position.protocol ?? null,
      protocolName: position.protocolName ?? null,
      network: position.network ?? null,
      networkName: position.networkName ?? null,
      assetSymbol: label,
      ...allocationBaseFields(position),
    };
    if (position.debtType) entry.debtType = position.debtType;
    items.push(entry);
  }

  const denominator = sumPositiveValueUsd(items);
  return groupSmallAllocationItems(items, denominator, options).map((item) =>
    item.key === "other" ? { ...item, source: "borrowed" } : item,
  );
}

export function buildProtocolAllocation(protocolSummaries = [], options = {}) {
  const items = [];

  for (const summary of protocolSummaries) {
    if (!isPositiveValueUsd(summary.netValueUsd)) continue;
    items.push({
      key: summary.protocol,
      label: summary.protocolName ?? summary.protocol,
      valueUsd: formatPositiveValueUsd(summary.netValueUsd),
      protocol: summary.protocol,
      protocolName: summary.protocolName ?? null,
      category: summary.category ?? null,
      walletValueUsd: summary.walletValueUsd,
      suppliedValueUsd: summary.suppliedValueUsd,
      borrowedValueUsd: summary.borrowedValueUsd,
      grossValueUsd: summary.grossValueUsd,
      netValueUsd: summary.netValueUsd,
    });
  }

  const denominator = sumPositiveValueUsd(
    items.map((item) => ({ valueUsd: item.netValueUsd })),
  );
  return groupSmallAllocationItems(items, denominator, options);
}

export function buildNetworkAllocation(
  walletHoldings = [],
  protocolPositions = {},
  options = {},
) {
  const byNetwork = new Map();

  const ensure = (networkId, network, networkName) => {
    const key = String(networkId);
    if (!byNetwork.has(key)) {
      byNetwork.set(key, {
        networkId,
        network,
        networkName,
        walletValues: [],
        suppliedValues: [],
        borrowedValues: [],
      });
    }
    return byNetwork.get(key);
  };

  for (const holding of walletHoldings) {
    if (!isPositiveValueUsd(holding.valueUsd)) continue;
    const entry = ensure(
      holding.networkId,
      holding.network,
      holding.networkName,
    );
    entry.walletValues.push(holding.valueUsd);
  }

  for (const position of protocolPositions.supplied ?? []) {
    if (!isPositiveValueUsd(position.valueUsd)) continue;
    const entry = ensure(
      position.networkId,
      position.network,
      position.networkName,
    );
    entry.suppliedValues.push(position.valueUsd);
  }

  for (const position of protocolPositions.borrowed ?? []) {
    if (!isPositiveValueUsd(position.valueUsd)) continue;
    const entry = ensure(
      position.networkId,
      position.network,
      position.networkName,
    );
    entry.borrowedValues.push(position.valueUsd);
  }

  const items = [];

  for (const entry of byNetwork.values()) {
    const walletValueUsd = sumUsdValues(entry.walletValues);
    const suppliedValueUsd = sumUsdValues(entry.suppliedValues);
    const borrowedValueUsd = sumUsdValues(entry.borrowedValues);
    const grossValueUsd = sumUsdValues([walletValueUsd, suppliedValueUsd]);
    const netValueUsd = formatUsd(
      new Decimal(grossValueUsd).minus(new Decimal(borrowedValueUsd)),
    );

    if (!isPositiveValueUsd(netValueUsd)) continue;

    items.push({
      key: entry.network ?? String(entry.networkId),
      label: entry.networkName ?? entry.network ?? String(entry.networkId),
      valueUsd: formatPositiveValueUsd(netValueUsd),
      network: entry.network ?? null,
      networkName: entry.networkName ?? null,
      networkId: entry.networkId,
      walletValueUsd,
      suppliedValueUsd,
      borrowedValueUsd,
      netValueUsd,
    });
  }

  const denominator = sumPositiveValueUsd(items);
  return groupSmallAllocationItems(items, denominator, options);
}

export function buildWalletAssetAllocation(
  walletId,
  walletHoldings = [],
  protocolPositions = {},
  options = {},
) {
  const items = [];

  for (const holding of walletHoldings) {
    const nested = findNestedWalletEntry(holding, walletId);
    const valueUsd = getNestedWalletValueUsd(nested);
    if (!isPositiveValueUsd(valueUsd)) continue;
    const label = normalizeAllocationLabel(holding.assetSymbol ?? holding.symbol);
    items.push({
      key: label,
      label,
      valueUsd: formatPositiveValueUsd(valueUsd),
      source: "wallet",
      protocol: "wallet",
      protocolName: "Wallet",
      network: holding.network ?? null,
      networkName: holding.networkName ?? null,
      assetSymbol: label,
      ...allocationBaseFields(holding),
    });
  }

  for (const position of protocolPositions.supplied ?? []) {
    const nested = findNestedWalletEntry(position, walletId);
    const valueUsd = getNestedWalletValueUsd(nested);
    if (!isPositiveValueUsd(valueUsd)) continue;
    const label = normalizeAllocationLabel(position.underlyingSymbol);
    items.push({
      key: label,
      label,
      valueUsd: formatPositiveValueUsd(valueUsd),
      source: "supplied",
      protocol: position.protocol ?? null,
      protocolName: position.protocolName ?? null,
      network: position.network ?? null,
      networkName: position.networkName ?? null,
      assetSymbol: label,
      ...allocationBaseFields(position),
    });
  }

  const denominator = sumPositiveValueUsd(items);
  return groupSmallAllocationItems(items, denominator, options);
}

export function buildWalletDebtAllocation(
  walletId,
  protocolPositions = {},
  options = {},
) {
  const items = [];

  for (const position of protocolPositions.borrowed ?? []) {
    const nested = findNestedWalletEntry(position, walletId);
    const valueUsd = getNestedWalletValueUsd(nested);
    if (!isPositiveValueUsd(valueUsd)) continue;
    const label = normalizeAllocationLabel(position.underlyingSymbol);
    const entry = {
      key: label,
      label,
      valueUsd: formatPositiveValueUsd(valueUsd),
      source: "borrowed",
      protocol: position.protocol ?? null,
      protocolName: position.protocolName ?? null,
      network: position.network ?? null,
      networkName: position.networkName ?? null,
      assetSymbol: label,
      ...allocationBaseFields(position),
    };
    if (position.debtType) entry.debtType = position.debtType;
    items.push(entry);
  }

  const denominator = sumPositiveValueUsd(items);
  return groupSmallAllocationItems(items, denominator, options).map((item) =>
    item.key === "other" ? { ...item, source: "borrowed" } : item,
  );
}

function collectWalletProtocolIds(walletId, protocolPositions = {}) {
  const protocols = new Set();
  for (const position of [
    ...(protocolPositions.supplied ?? []),
    ...(protocolPositions.borrowed ?? []),
  ]) {
    if (!position.protocol) continue;
    const nested = findNestedWalletEntry(position, walletId);
    if (!isPositiveValueUsd(getNestedWalletValueUsd(nested))) continue;
    protocols.add(position.protocol);
  }
  return protocols;
}

function sumNestedValuesForWallet(positions, walletId, protocol = null) {
  const values = [];
  for (const position of positions) {
    if (protocol !== null && position.protocol !== protocol) continue;
    const nested = findNestedWalletEntry(position, walletId);
    const valueUsd = getNestedWalletValueUsd(nested);
    if (isPositiveValueUsd(valueUsd)) values.push(valueUsd);
  }
  return values;
}

export function buildWalletProtocolAllocation(
  wallet,
  protocolPositions = {},
  options = {},
) {
  const walletId = wallet.walletId;
  const items = [];

  if (isPositiveValueUsd(wallet.walletValueUsd)) {
    const walletValueUsd = formatPositiveValueUsd(wallet.walletValueUsd);
    items.push({
      key: "wallet",
      label: "Wallet",
      valueUsd: walletValueUsd,
      protocol: "wallet",
      protocolName: "Wallet",
      category: "wallet",
      walletValueUsd,
      suppliedValueUsd: "0.00",
      borrowedValueUsd: "0.00",
      grossValueUsd: walletValueUsd,
      netValueUsd: walletValueUsd,
    });
  }

  for (const protocol of [...collectWalletProtocolIds(walletId, protocolPositions)].sort()) {
    const suppliedValueUsd = sumUsdValues(
      sumNestedValuesForWallet(protocolPositions.supplied ?? [], walletId, protocol),
    );
    const borrowedValueUsd = sumUsdValues(
      sumNestedValuesForWallet(protocolPositions.borrowed ?? [], walletId, protocol),
    );
    const grossValueUsd = sumUsdValues(["0.00", suppliedValueUsd]);
    const netValueUsd = subtractUsd(grossValueUsd, borrowedValueUsd);
    if (!isPositiveValueUsd(netValueUsd)) continue;

    items.push({
      key: protocol,
      label: protocolDisplayName(protocol) ?? protocol,
      valueUsd: formatPositiveValueUsd(netValueUsd),
      protocol,
      protocolName: protocolDisplayName(protocol),
      category: protocolCategory(protocol),
      walletValueUsd: "0.00",
      suppliedValueUsd,
      borrowedValueUsd,
      grossValueUsd,
      netValueUsd,
    });
  }

  const denominator = sumPositiveValueUsd(items);
  return groupSmallAllocationItems(items, denominator, options);
}

export function buildWalletNetworkAllocation(
  walletId,
  walletHoldings = [],
  protocolPositions = {},
  options = {},
) {
  const byNetwork = new Map();

  const ensure = (networkId, network, networkName) => {
    const key = String(networkId);
    if (!byNetwork.has(key)) {
      byNetwork.set(key, {
        networkId,
        network,
        networkName,
        walletValues: [],
        suppliedValues: [],
        borrowedValues: [],
      });
    }
    return byNetwork.get(key);
  };

  for (const holding of walletHoldings) {
    const nested = findNestedWalletEntry(holding, walletId);
    const valueUsd = getNestedWalletValueUsd(nested);
    if (!isPositiveValueUsd(valueUsd)) continue;
    const entry = ensure(holding.networkId, holding.network, holding.networkName);
    entry.walletValues.push(valueUsd);
  }

  for (const position of protocolPositions.supplied ?? []) {
    const nested = findNestedWalletEntry(position, walletId);
    const valueUsd = getNestedWalletValueUsd(nested);
    if (!isPositiveValueUsd(valueUsd)) continue;
    const entry = ensure(position.networkId, position.network, position.networkName);
    entry.suppliedValues.push(valueUsd);
  }

  for (const position of protocolPositions.borrowed ?? []) {
    const nested = findNestedWalletEntry(position, walletId);
    const valueUsd = getNestedWalletValueUsd(nested);
    if (!isPositiveValueUsd(valueUsd)) continue;
    const entry = ensure(position.networkId, position.network, position.networkName);
    entry.borrowedValues.push(valueUsd);
  }

  const items = [];

  for (const entry of byNetwork.values()) {
    const walletValueUsd = sumUsdValues(entry.walletValues);
    const suppliedValueUsd = sumUsdValues(entry.suppliedValues);
    const borrowedValueUsd = sumUsdValues(entry.borrowedValues);
    const grossValueUsd = sumUsdValues([walletValueUsd, suppliedValueUsd]);
    const netValueUsd = subtractUsd(grossValueUsd, borrowedValueUsd);
    if (!isPositiveValueUsd(netValueUsd)) continue;

    items.push({
      key: entry.network ?? String(entry.networkId),
      label: entry.networkName ?? entry.network ?? String(entry.networkId),
      valueUsd: formatPositiveValueUsd(netValueUsd),
      network: entry.network ?? null,
      networkName: entry.networkName ?? null,
      networkId: entry.networkId,
      walletValueUsd,
      suppliedValueUsd,
      borrowedValueUsd,
      netValueUsd,
    });
  }

  const denominator = sumPositiveValueUsd(items);
  return groupSmallAllocationItems(items, denominator, options);
}

export function buildWalletAllocations(
  wallets = [],
  walletHoldings = [],
  protocolPositions = {},
  options = {},
) {
  return wallets.map((wallet) => ({
    walletId: String(wallet.walletId),
    walletAddress: wallet.walletAddress ?? null,
    walletLabel: wallet.walletLabel ?? null,
    assets: buildWalletAssetAllocation(
      wallet.walletId,
      walletHoldings,
      protocolPositions,
      options,
    ),
    debts: buildWalletDebtAllocation(wallet.walletId, protocolPositions, options),
    protocols: buildWalletProtocolAllocation(wallet, protocolPositions, options),
    networks: buildWalletNetworkAllocation(
      wallet.walletId,
      walletHoldings,
      protocolPositions,
      options,
    ),
  }));
}

export function buildPortfolioAllocation({
  walletHoldings = [],
  protocolPositions = {},
  protocolSummaries = [],
  wallets = [],
  options = {},
}) {
  const groupingOptions = {
    maxItems: options.maxItems ?? DEFAULT_ALLOCATION_MAX_ITEMS,
    minPercentage: options.minPercentage ?? DEFAULT_ALLOCATION_MIN_PERCENTAGE,
  };

  return {
    assets: buildAssetAllocation(walletHoldings, protocolPositions, groupingOptions),
    debts: buildDebtAllocation(protocolPositions, groupingOptions),
    protocols: buildProtocolAllocation(protocolSummaries, groupingOptions),
    networks: buildNetworkAllocation(
      walletHoldings,
      protocolPositions,
      groupingOptions,
    ),
    wallets: buildWalletAllocations(
      wallets,
      walletHoldings,
      protocolPositions,
      groupingOptions,
    ),
  };
}
