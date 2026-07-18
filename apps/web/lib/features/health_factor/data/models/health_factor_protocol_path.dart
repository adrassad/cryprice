/// Maps Health Factor API protocol ids between query form and URL path slug.
///
/// Backend convention:
/// - query / JSON: `aave_v3`
/// - path segment: `aave-v3`
abstract final class HealthFactorProtocolPath {
  static const String aaveV3Query = 'aave_v3';
  static const String aaveV3Slug = 'aave-v3';

  /// `aave_v3` → `aave-v3` for `/health-factor/{slug}/...` paths.
  static String slugFromQuery(String protocol) {
    final normalized = protocol.trim();
    if (normalized == aaveV3Query) {
      return aaveV3Slug;
    }
    return normalized.replaceAll('_', '-');
  }

  /// `aave-v3` → `aave_v3` for `?protocol=` query params.
  static String queryFromSlug(String slug) {
    final normalized = slug.trim();
    if (normalized == aaveV3Slug) {
      return aaveV3Query;
    }
    return normalized.replaceAll('-', '_');
  }
}
