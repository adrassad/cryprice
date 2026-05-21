/// Sentinel values for local portfolio filtering (no backend calls).
abstract final class PortfolioFilter {
  static const String allProtocols = 'all';
  static const String walletProtocol = 'wallet';
  static const String allWallets = 'all';

  static String normalizeProtocol(String? protocol) {
    if (protocol == null || protocol.trim().isEmpty) {
      return allProtocols;
    }
    return protocol.trim();
  }

  static String normalizeWalletId(String? walletId) {
    if (walletId == null || walletId.trim().isEmpty) {
      return allWallets;
    }
    return walletId.trim();
  }

  static bool isAllProtocols(String? protocol) {
    return normalizeProtocol(protocol) == allProtocols;
  }

  static bool isWalletProtocol(String? protocol) {
    return normalizeProtocol(protocol) == walletProtocol;
  }

  static bool isSpecificProtocol(String? protocol) {
    final normalized = normalizeProtocol(protocol);
    return normalized != allProtocols && normalized != walletProtocol;
  }

  static bool isAllWallets(String? walletId) {
    return normalizeWalletId(walletId) == allWallets;
  }
}
