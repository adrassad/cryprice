import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/view_models/portfolio_defi_group_models.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';

/// Groups filtered DeFi positions into protocol → network → wallet buckets.
///
/// Uses nested [PortfolioProtocolPosition.wallets] for wallet scoping.
/// Does not parse financial strings as [double].
List<PortfolioDefiProtocolGroup> buildPortfolioDefiProtocolGroups({
  required List<PortfolioProtocolPosition> supplied,
  required List<PortfolioProtocolPosition> borrowed,
  required List<PortfolioPositionHealth> positionsHealth,
  required String? selectedProtocol,
  required String? selectedWalletId,
  List<PortfolioProtocolSummary> protocolSummaries = const <PortfolioProtocolSummary>[],
}) {
  final protocol = PortfolioFilter.normalizeProtocol(selectedProtocol);
  final walletId = PortfolioFilter.normalizeWalletId(selectedWalletId);

  if (PortfolioFilter.isWalletProtocol(protocol)) {
    return const <PortfolioDefiProtocolGroup>[];
  }

  final filteredSupplied = _filterProtocolPositions(
    supplied,
    protocol: protocol,
    walletId: walletId,
  );
  final filteredBorrowed = _filterProtocolPositions(
    borrowed,
    protocol: protocol,
    walletId: walletId,
  );
  final filteredHealth = _filterPositionsHealth(
    positionsHealth,
    protocol: protocol,
    walletId: walletId,
  );

  if (filteredSupplied.isEmpty && filteredBorrowed.isEmpty) {
    return const <PortfolioDefiProtocolGroup>[];
  }

  final buckets = <String, _NetworkWalletBucket>{};

  for (final position in filteredSupplied) {
    for (final view in _expandPositionViews(position)) {
      _bucketForView(buckets, view).supplied.add(view);
    }
  }

  for (final position in filteredBorrowed) {
    for (final view in _expandPositionViews(position)) {
      _bucketForView(buckets, view).borrowed.add(view);
    }
  }

  final byProtocol = <String, List<PortfolioDefiNetworkWalletGroupView>>{};
  final protocolNames = <String, String>{};

  for (final bucket in buckets.values) {
    final group = bucket.toGroup(filteredHealth);
    byProtocol
        .putIfAbsent(group.protocol, () => <PortfolioDefiNetworkWalletGroupView>[])
        .add(group);
    protocolNames[group.protocol] = group.protocolName;
  }

  for (final groups in byProtocol.values) {
    groups.sort(_compareNetworkWalletGroups);
  }

  final protocolIds = byProtocol.keys.toList(growable: false);
  protocolIds.sort(
    (a, b) => _compareProtocolOrder(
      a,
      b,
      protocolNames: protocolNames,
      protocolSummaries: protocolSummaries,
    ),
  );

  return protocolIds
      .map(
        (protocolId) => _buildProtocolGroup(
          protocolId: protocolId,
          protocolName: protocolNames[protocolId]!,
          groups: byProtocol[protocolId]!,
          protocolSummaries: protocolSummaries,
        ),
      )
      .toList(growable: false);
}

/// Matches [PortfolioPositionHealth] for a network/wallet group.
///
/// Prefers [walletId] when non-empty; otherwise matches [walletAddress]
/// case-insensitively.
PortfolioPositionHealth? matchGroupPositionHealth({
  required List<PortfolioPositionHealth> positionsHealth,
  required String protocol,
  required int networkId,
  required String walletId,
  required String walletAddress,
}) {
  if (walletId.isNotEmpty) {
    for (final health in positionsHealth) {
      if (health.protocol == protocol &&
          health.networkId == networkId &&
          health.walletId == walletId) {
        return health;
      }
    }
    return null;
  }

  final normalizedAddress = walletAddress.trim().toLowerCase();
  if (normalizedAddress.isEmpty) {
    return null;
  }

  for (final health in positionsHealth) {
    if (health.protocol != protocol || health.networkId != networkId) {
      continue;
    }
    if (health.walletAddress.trim().toLowerCase() == normalizedAddress) {
      return health;
    }
  }

  return null;
}

List<PortfolioProtocolPosition> _filterProtocolPositions(
  List<PortfolioProtocolPosition> positions, {
  required String protocol,
  required String walletId,
}) {
  final filtered = <PortfolioProtocolPosition>[];

  for (final position in positions) {
    if (!_matchesProtocolFilter(position.protocol, protocol)) {
      continue;
    }

    if (PortfolioFilter.isAllWallets(walletId)) {
      filtered.add(position);
      continue;
    }

    if (position.wallets.isEmpty) {
      continue;
    }

    final nested = position.wallets
        .where((wallet) => wallet.walletId == walletId)
        .toList(growable: false);
    if (nested.isEmpty) {
      continue;
    }

    filtered.add(_protocolPositionWithNestedWallets(position, nested));
  }

  return filtered;
}

List<PortfolioPositionHealth> _filterPositionsHealth(
  List<PortfolioPositionHealth> positionsHealth, {
  required String protocol,
  required String walletId,
}) {
  return positionsHealth
      .where(
        (entry) =>
            _matchesProtocolFilter(entry.protocol, protocol) &&
            _matchesWalletFilter(entry.walletId, walletId),
      )
      .toList(growable: false);
}

bool _matchesProtocolFilter(String positionProtocol, String selectedProtocol) {
  if (PortfolioFilter.isAllProtocols(selectedProtocol)) {
    return true;
  }
  return positionProtocol == selectedProtocol;
}

bool _matchesWalletFilter(String rowWalletId, String selectedWalletId) {
  if (PortfolioFilter.isAllWallets(selectedWalletId)) {
    return true;
  }
  return rowWalletId == selectedWalletId;
}

PortfolioProtocolPosition _protocolPositionWithNestedWallets(
  PortfolioProtocolPosition position,
  List<PortfolioWalletBreakdown> nested,
) {
  final scopedAmount = _scopedAmountFromNested(nested, position.amount);
  final scopedValueUsd = _scopedValueUsdFromNested(nested, position.valueUsd);

  return PortfolioProtocolPosition(
    kind: position.kind,
    protocol: position.protocol,
    protocolName: position.protocolName,
    networkId: position.networkId,
    network: position.network,
    networkName: position.networkName,
    chainId: position.chainId,
    positionSide: position.positionSide,
    tokenRole: position.tokenRole,
    debtType: position.debtType,
    underlyingSymbol: position.underlyingSymbol,
    underlyingAddress: position.underlyingAddress,
    tokenSymbol: position.tokenSymbol,
    tokenAddress: position.tokenAddress,
    amount: scopedAmount,
    balanceRaw: position.balanceRaw,
    decimals: position.decimals,
    priceUsd: position.priceUsd,
    valueUsd: scopedValueUsd,
    priceStatus: position.priceStatus,
    logoUrl: position.logoUrl,
    wallets: nested,
  );
}

String? _scopedAmountFromNested(
  List<PortfolioWalletBreakdown> nested,
  String? parentAmount,
) {
  if (nested.length == 1) {
    final nestedAmount = nested.first.amount?.trim();
    if (nestedAmount != null && nestedAmount.isNotEmpty) {
      return nested.first.amount;
    }
    final nestedBalance = nested.first.balance.trim();
    if (nestedBalance.isNotEmpty) {
      return nested.first.balance;
    }
  }
  return parentAmount;
}

String? _scopedValueUsdFromNested(
  List<PortfolioWalletBreakdown> nested,
  String? parentValueUsd,
) {
  if (nested.length == 1) {
    final nestedValue = nested.first.valueUsd?.trim();
    if (nestedValue != null && nestedValue.isNotEmpty) {
      return nested.first.valueUsd;
    }
  }
  return parentValueUsd;
}

List<PortfolioProtocolPositionView> _expandPositionViews(
  PortfolioProtocolPosition position,
) {
  if (position.wallets.isEmpty) {
    return [
      _positionView(
        position: position,
        walletId: '',
        walletAddress: '',
        walletLabel: null,
        amount: position.amount,
        valueUsd: _displayValueUsd(position.valueUsd, position.positionSide),
      ),
    ];
  }

  return position.wallets
      .map(
        (wallet) => _positionView(
          position: position,
          walletId: wallet.walletId,
          walletAddress: _walletAddress(wallet),
          walletLabel: _walletLabel(wallet),
          amount: _nestedAmount(wallet, position.amount),
          valueUsd: _displayValueUsd(
            _nestedValueUsd(wallet, position.valueUsd),
            position.positionSide,
          ),
        ),
      )
      .toList(growable: false);
}

PortfolioProtocolPositionView _positionView({
  required PortfolioProtocolPosition position,
  required String walletId,
  required String walletAddress,
  required String? walletLabel,
  required String? amount,
  required String? valueUsd,
}) {
  return PortfolioProtocolPositionView(
    protocol: position.protocol,
    protocolName: _protocolName(position),
    networkId: position.networkId,
    network: position.network,
    networkName: _networkName(position),
    underlyingSymbol: position.underlyingSymbol,
    tokenSymbol: position.tokenSymbol,
    tokenRole: position.tokenRole,
    positionSide: position.positionSide,
    debtType: position.debtType,
    priceUsd: position.priceUsd,
    priceStatus: position.priceStatus,
    walletId: walletId,
    walletAddress: walletAddress,
    walletLabel: walletLabel,
    amount: amount,
    valueUsd: valueUsd,
    logoUrl: position.logoUrl,
  );
}

String? _displayValueUsd(String? valueUsd, PortfolioPositionSide side) {
  if (side != PortfolioPositionSide.borrowed) {
    return valueUsd;
  }
  return positiveFinancialDisplayValue(valueUsd) ?? valueUsd;
}

_NetworkWalletBucket _bucketForView(
  Map<String, _NetworkWalletBucket> buckets,
  PortfolioProtocolPositionView view,
) {
  final key =
      '${view.protocol}|${view.networkId}|${view.walletId}|${view.walletAddress}';
  return buckets.putIfAbsent(
    key,
    () => _NetworkWalletBucket(
      protocol: view.protocol,
      protocolName: view.protocolName,
      networkId: view.networkId,
      network: view.network,
      networkName: view.networkName,
      walletId: view.walletId,
      walletAddress: view.walletAddress,
      walletLabel: view.walletLabel,
    ),
  );
}

PortfolioDefiProtocolGroup _buildProtocolGroup({
  required String protocolId,
  required String protocolName,
  required List<PortfolioDefiNetworkWalletGroupView> groups,
  required List<PortfolioProtocolSummary> protocolSummaries,
}) {
  final summary = _findProtocolSummary(protocolSummaries, protocolId);

  return PortfolioDefiProtocolGroup(
    protocol: protocolId,
    protocolName: summary?.protocolName.trim().isNotEmpty == true
        ? summary!.protocolName
        : protocolName,
    category: summary?.category ?? '',
    totalValueUsd: summary?.totalValueUsd ?? summary?.netValueUsd,
    suppliedValueUsd: summary?.suppliedValueUsd,
    borrowedValueUsd: summary?.borrowedValueUsd,
    netValueUsd: summary?.netValueUsd,
    networkWalletGroups: groups,
  );
}

PortfolioProtocolSummary? _findProtocolSummary(
  List<PortfolioProtocolSummary> summaries,
  String protocolId,
) {
  for (final summary in summaries) {
    if (summary.protocol == protocolId) {
      return summary;
    }
  }
  return null;
}

int _compareProtocolOrder(
  String protocolA,
  String protocolB, {
  required Map<String, String> protocolNames,
  required List<PortfolioProtocolSummary> protocolSummaries,
}) {
  final indexA = _protocolSummaryIndex(protocolSummaries, protocolA);
  final indexB = _protocolSummaryIndex(protocolSummaries, protocolB);

  if (indexA != null && indexB != null && indexA != indexB) {
    return indexA.compareTo(indexB);
  }
  if (indexA != null && indexB == null) {
    return -1;
  }
  if (indexA == null && indexB != null) {
    return 1;
  }

  return _compareProtocolNames(
    protocolNames[protocolA] ?? protocolA,
    protocolNames[protocolB] ?? protocolB,
    protocolA,
    protocolB,
  );
}

int? _protocolSummaryIndex(
  List<PortfolioProtocolSummary> summaries,
  String protocolId,
) {
  for (var i = 0; i < summaries.length; i++) {
    if (summaries[i].protocol == protocolId) {
      return i;
    }
  }
  return null;
}

int _compareNetworkWalletGroups(
  PortfolioDefiNetworkWalletGroupView a,
  PortfolioDefiNetworkWalletGroupView b,
) {
  final networkCompare = a.networkName.compareTo(b.networkName);
  if (networkCompare != 0) {
    return networkCompare;
  }

  final walletLabelA = a.walletLabel?.trim().isNotEmpty == true
      ? a.walletLabel!
      : a.walletAddress;
  final walletLabelB = b.walletLabel?.trim().isNotEmpty == true
      ? b.walletLabel!
      : b.walletAddress;
  return walletLabelA.compareTo(walletLabelB);
}

int _compareProtocolNames(
  String nameA,
  String nameB,
  String protocolA,
  String protocolB,
) {
  final byName = nameA.compareTo(nameB);
  return byName != 0 ? byName : protocolA.compareTo(protocolB);
}

String _protocolName(PortfolioProtocolPosition position) {
  final name = position.protocolName.trim();
  return name.isNotEmpty ? name : position.protocol;
}

String _networkName(PortfolioProtocolPosition position) {
  final name = position.networkName.trim();
  return name.isNotEmpty ? name : position.network;
}

String _walletAddress(PortfolioWalletBreakdown wallet) {
  final address = wallet.walletAddress.trim();
  if (address.isNotEmpty) {
    return address;
  }
  return wallet.address.trim();
}

String? _walletLabel(PortfolioWalletBreakdown wallet) {
  final label = wallet.walletLabel?.trim();
  if (label != null && label.isNotEmpty) {
    return label;
  }
  final fallback = wallet.label?.trim() ?? '';
  return fallback.isNotEmpty ? fallback : null;
}

String? _nestedAmount(PortfolioWalletBreakdown wallet, String? parentAmount) {
  final nestedAmount = wallet.amount?.trim();
  if (nestedAmount != null && nestedAmount.isNotEmpty) {
    return wallet.amount;
  }
  final nestedBalance = wallet.balance.trim();
  if (nestedBalance.isNotEmpty) {
    return wallet.balance;
  }
  return parentAmount;
}

String? _nestedValueUsd(PortfolioWalletBreakdown wallet, String? parentValueUsd) {
  final nestedValue = wallet.valueUsd?.trim();
  if (nestedValue != null && nestedValue.isNotEmpty) {
    return wallet.valueUsd;
  }
  return parentValueUsd;
}

class _NetworkWalletBucket {
  _NetworkWalletBucket({
    required this.protocol,
    required this.protocolName,
    required this.networkId,
    required this.network,
    required this.networkName,
    required this.walletId,
    required this.walletAddress,
    required this.walletLabel,
  });

  final String protocol;
  final String protocolName;
  final int networkId;
  final String network;
  final String networkName;
  final String walletId;
  final String walletAddress;
  final String? walletLabel;
  final List<PortfolioProtocolPositionView> supplied = <PortfolioProtocolPositionView>[];
  final List<PortfolioProtocolPositionView> borrowed = <PortfolioProtocolPositionView>[];

  PortfolioDefiNetworkWalletGroupView toGroup(
    List<PortfolioPositionHealth> positionsHealth,
  ) {
    return PortfolioDefiNetworkWalletGroupView(
      protocol: protocol,
      protocolName: protocolName,
      networkId: networkId,
      network: network,
      networkName: networkName,
      walletId: walletId,
      walletAddress: walletAddress,
      walletLabel: walletLabel,
      healthFactor: matchGroupPositionHealth(
        positionsHealth: positionsHealth,
        protocol: protocol,
        networkId: networkId,
        walletId: walletId,
        walletAddress: walletAddress,
      ),
      supplied: List<PortfolioProtocolPositionView>.unmodifiable(supplied),
      borrowed: List<PortfolioProtocolPositionView>.unmodifiable(borrowed),
    );
  }
}
