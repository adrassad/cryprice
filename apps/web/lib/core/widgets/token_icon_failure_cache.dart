/// In-memory session cache of token icon URLs that failed to load.
///
/// Prevents repeated [Image.network] attempts for the same URL on rebuilds
/// (e.g. Safari resume, list scroll, Bloc updates). Successful loads rely on
/// browser HTTP cache and backend `Cache-Control` headers — no byte caching here.
abstract final class TokenIconFailureCache {
  static final Set<String> _failedUrls = <String>{};

  static bool isFailed(String url) => _failedUrls.contains(url);

  static void markFailed(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _failedUrls.add(trimmed);
  }

  /// Clears session failure state (tests only).
  static void clearForTesting() => _failedUrls.clear();
}
