import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_health_factor_display.dart';

/// One position row scoped to a wallet (or unscoped when [wallets] is empty).
class PortfolioDefiPositionEntry {
  const PortfolioDefiPositionEntry({
    required this.position,
    required this.walletId,
    required this.walletAddress,
    required this.walletLabel,
    required this.amount,
    required this.valueUsd,
  });

  final PortfolioProtocolPosition position;
  final String walletId;
  final String walletAddress;
  final String? walletLabel;
  final String? amount;
  final String? valueUsd;
}

/// protocol → network → wallet group for DeFi UI.
class PortfolioDefiNetworkWalletGroup {
  const PortfolioDefiNetworkWalletGroup({
    required this.protocol,
    required this.protocolName,
    required this.networkId,
    required this.networkName,
    required this.walletId,
    required this.walletAddress,
    required this.walletLabel,
    required this.positions,
  });

  final String protocol;
  final String protocolName;
  final int networkId;
  final String networkName;
  final String walletId;
  final String walletAddress;
  final String? walletLabel;
  final List<PortfolioDefiPositionEntry> positions;
}

/// Positions grouped by protocol for [PortfolioProtocolSectionCard].
class PortfolioDefiProtocolSection {
  const PortfolioDefiProtocolSection({
    required this.protocol,
    required this.protocolName,
    required this.groups,
  });

  final String protocol;
  final String protocolName;
  final List<PortfolioDefiNetworkWalletGroup> groups;
}

List<PortfolioDefiProtocolSection> groupDefiPositionsByProtocol(
  List<PortfolioProtocolPosition> positions,
) {
  final groups = _buildNetworkWalletGroups(positions);
  final byProtocol = <String, List<PortfolioDefiNetworkWalletGroup>>{};
  final protocolNames = <String, String>{};

  for (final group in groups) {
    byProtocol.putIfAbsent(group.protocol, () => <PortfolioDefiNetworkWalletGroup>[]).add(group);
    protocolNames[group.protocol] = group.protocolName;
  }

  final protocols = byProtocol.keys.toList(growable: false)
    ..sort((a, b) => _compareProtocolNames(protocolNames[a]!, protocolNames[b]!, a, b));

  return protocols
      .map(
        (protocol) => PortfolioDefiProtocolSection(
          protocol: protocol,
          protocolName: protocolNames[protocol]!,
          groups: byProtocol[protocol]!,
        ),
      )
      .toList(growable: false);
}

List<PortfolioDefiNetworkWalletGroup> _buildNetworkWalletGroups(
  List<PortfolioProtocolPosition> positions,
) {
  final grouped = <String, List<PortfolioDefiPositionEntry>>{};
  final metadata = <String, _GroupMeta>{};

  for (final position in positions) {
    for (final entry in _expandPositionEntries(position)) {
      final key = '${entry.position.protocol}|${entry.position.networkId}|${entry.walletId}|${entry.walletAddress}';
      grouped.putIfAbsent(key, () => <PortfolioDefiPositionEntry>[]).add(entry);
      metadata[key] = _GroupMeta(
        protocol: entry.position.protocol,
        protocolName: _protocolName(entry.position),
        networkId: entry.position.networkId,
        networkName: _networkName(entry.position),
        walletId: entry.walletId,
        walletAddress: entry.walletAddress,
        walletLabel: entry.walletLabel,
      );
    }
  }

  final keys = grouped.keys.toList(growable: false)
    ..sort((a, b) {
      final metaA = metadata[a]!;
      final metaB = metadata[b]!;
      final protocolCompare = _compareProtocolNames(
        metaA.protocolName,
        metaB.protocolName,
        metaA.protocol,
        metaB.protocol,
      );
      if (protocolCompare != 0) {
        return protocolCompare;
      }
      final networkCompare = metaA.networkName.compareTo(metaB.networkName);
      if (networkCompare != 0) {
        return networkCompare;
      }
      final walletLabelA = metaA.walletLabel ?? metaA.walletAddress;
      final walletLabelB = metaB.walletLabel ?? metaB.walletAddress;
      return walletLabelA.compareTo(walletLabelB);
    });

  return keys
      .map(
        (key) => PortfolioDefiNetworkWalletGroup(
          protocol: metadata[key]!.protocol,
          protocolName: metadata[key]!.protocolName,
          networkId: metadata[key]!.networkId,
          networkName: metadata[key]!.networkName,
          walletId: metadata[key]!.walletId,
          walletAddress: metadata[key]!.walletAddress,
          walletLabel: metadata[key]!.walletLabel,
          positions: grouped[key]!,
        ),
      )
      .toList(growable: false);
}

List<PortfolioDefiPositionEntry> _expandPositionEntries(
  PortfolioProtocolPosition position,
) {
  if (position.wallets.isEmpty) {
    return [
      PortfolioDefiPositionEntry(
        position: position,
        walletId: '',
        walletAddress: '',
        walletLabel: null,
        amount: position.amount,
        valueUsd: position.valueUsd,
      ),
    ];
  }

  return position.wallets
      .map(
        (wallet) => PortfolioDefiPositionEntry(
          position: position,
          walletId: wallet.walletId,
          walletAddress: _walletAddress(wallet),
          walletLabel: _walletLabel(wallet),
          amount: _nestedAmount(wallet, position.amount),
          valueUsd: _nestedValueUsd(wallet, position.valueUsd),
        ),
      )
      .toList(growable: false);
}

/// Matches [defiRisk.positionsHealth] by protocol, network, and wallet identity.
PortfolioPositionHealth? matchPositionHealth({
  required List<PortfolioPositionHealth> positionsHealth,
  required String protocol,
  required int networkId,
  required String walletId,
  required String walletAddress,
}) {
  PortfolioPositionHealth? addressFallback;

  for (final health in positionsHealth) {
    if (health.protocol != protocol || health.networkId != networkId) {
      continue;
    }
    if (walletId.isNotEmpty && health.walletId == walletId) {
      return health;
    }
    if (walletAddress.isNotEmpty && health.walletAddress == walletAddress) {
      addressFallback = health;
    }
  }

  return addressFallback;
}

PortfolioHealthFactorDisplay buildGroupHealthFactorDisplay({
  required List<PortfolioPositionHealth> positionsHealth,
  required PortfolioDefiNetworkWalletGroup group,
}) {
  final matched = matchPositionHealth(
    positionsHealth: positionsHealth,
    protocol: group.protocol,
    networkId: group.networkId,
    walletId: group.walletId,
    walletAddress: group.walletAddress,
  );

  if (matched != null) {
    return PortfolioHealthFactorDisplay.fromPositionHealth(matched);
  }

  return const PortfolioHealthFactorDisplay(
    value: null,
    status: PortfolioHealthFactorStatus.missing,
    statusLabel: null,
    stale: false,
  );
}

class _GroupMeta {
  const _GroupMeta({
    required this.protocol,
    required this.protocolName,
    required this.networkId,
    required this.networkName,
    required this.walletId,
    required this.walletAddress,
    required this.walletLabel,
  });

  final String protocol;
  final String protocolName;
  final int networkId;
  final String networkName;
  final String walletId;
  final String walletAddress;
  final String? walletLabel;
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
