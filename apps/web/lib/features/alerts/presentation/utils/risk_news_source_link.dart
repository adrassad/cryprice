/// Safe external link handling for risk news alert cards.
abstract final class RiskNewsSourceLink {
  static bool isDisplayableUrl(String? raw) {
    final uri = _parseHttpUri(raw);
    if (uri == null) {
      return false;
    }
    return !_isBlockedHost(uri.host);
  }

  static Uri? displayableUri(String? raw) {
    if (!isDisplayableUrl(raw)) {
      return null;
    }
    return _parseHttpUri(raw);
  }

  static Uri? _parseHttpUri(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasAuthority) {
      return null;
    }
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      return null;
    }
    return uri;
  }

  static bool _isBlockedHost(String host) {
    final normalized = host.trim().toLowerCase();
    if (normalized.isEmpty) {
      return true;
    }
    if (normalized == 'localhost' || normalized.endsWith('.localhost')) {
      return true;
    }
    if (normalized == '127.0.0.1' || normalized.startsWith('127.')) {
      return true;
    }
    if (normalized == '::1' || normalized == '[::1]') {
      return true;
    }
    if (normalized.endsWith('.local')) {
      return true;
    }
    if (normalized.endsWith('.test')) {
      return true;
    }
    if (normalized.contains('local.test')) {
      return true;
    }
    if (normalized == '0.0.0.0') {
      return true;
    }
    return false;
  }
}
