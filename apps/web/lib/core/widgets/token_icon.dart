import 'package:cryprice_frontend/core/config/cryprice_backend_config.dart';
import 'package:cryprice_frontend/core/widgets/token_icon_failure_cache.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';

/// Reusable token icon with backend-provided [logoUrl] and symbol-based fallback.
///
/// Uses [Image.network] only — no hardcoded token logos and no symbol lookup.
/// Failed URLs are remembered for the current app session so rebuilds do not
/// re-fetch icons that returned 404, 429, or other errors.
class TokenIcon extends StatelessWidget {
  const TokenIcon({
    super.key,
    this.logoUrl,
    required this.symbol,
    required this.size,
  });

  final String? logoUrl;
  final String symbol;
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = resolveTokenIconNetworkUrl(logoUrl);
    final loadable =
        resolvedUrl != null && isLoadableTokenIconUrl(resolvedUrl);
    _logTokenIconBuildOnce(
      symbol: symbol,
      original: logoUrl,
      resolved: resolvedUrl,
      loadable: loadable,
    );
    final semanticsLabel = _tokenIconSemanticsLabel(symbol);

    return Semantics(
      label: semanticsLabel,
      child: SizedBox(
        width: size,
        height: size,
        child: _TokenIconBody(
          resolvedUrl: loadable ? resolvedUrl : null,
          symbol: symbol,
          size: size,
        ),
      ),
    );
  }
}

class _TokenIconBody extends StatelessWidget {
  const _TokenIconBody({
    required this.resolvedUrl,
    required this.symbol,
    required this.size,
  });

  final String? resolvedUrl;
  final String symbol;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = resolvedUrl;
    if (url == null || TokenIconFailureCache.isFailed(url)) {
      return TokenIconFallback(symbol: symbol, size: size);
    }

    return ClipOval(
      child: Image.network(
        url,
        key: ValueKey<String>(url),
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) {
          TokenIconFailureCache.markFailed(url);
          _logTokenIconNetworkErrorOnce(
            symbol: symbol,
            url: url,
            error: error,
          );
          return TokenIconFallback(symbol: symbol, size: size);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return TokenIconFallback(symbol: symbol, size: size);
        },
      ),
    );
  }
}

/// Circular initials avatar used when [logoUrl] is missing or fails to load.
class TokenIconFallback extends StatelessWidget {
  const TokenIconFallback({
    super.key,
    required this.symbol,
    required this.size,
  });

  final String symbol;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final initials = tokenIconInitials(symbol);
    final fontSize = (size * 0.34).clamp(10.0, 18.0);

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        child: Center(
          child: ExcludeSemantics(
            child: Text(
              initials,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final Set<String> _tokenIconBuildLogKeys = <String>{};
final Set<String> _tokenIconErrorLogKeys = <String>{};

void _logTokenIconBuildOnce({
  required String symbol,
  required String? original,
  required String? resolved,
  required bool loadable,
}) {
  if (!kDebugMode) {
    return;
  }
  final key = '$symbol|${original ?? ''}|${resolved ?? ''}|$loadable';
  if (_tokenIconBuildLogKeys.contains(key) || _tokenIconBuildLogKeys.length >= 20) {
    return;
  }
  _tokenIconBuildLogKeys.add(key);
  debugPrint(
    '[TokenIcon][Widget] symbol=$symbol '
    'original=${original ?? '(null)'} '
    'resolved=${resolved ?? '(null)'} '
    'loadable=$loadable',
  );
}

void _logTokenIconNetworkErrorOnce({
  required String symbol,
  required String url,
  required Object error,
}) {
  if (!kDebugMode) {
    return;
  }
  final key = '$symbol|$url|${error.runtimeType}';
  if (_tokenIconErrorLogKeys.contains(key)) {
    return;
  }
  _tokenIconErrorLogKeys.add(key);
  debugPrint(
    '[TokenIcon][Error] symbol=$symbol url=$url error=$error',
  );
}

/// Resolves backend-provided [logoUrl] to an absolute http(s) URL for [Image.network].
///
/// Root-relative paths (`/static/token-icons/...`) are prefixed with
/// [backendBaseUrl] or [crypriceBackendBaseUrl] (`CRYPRICE_BACKEND_BASE_URL`).
/// Query strings (e.g. `?v={hash}`) are preserved.
/// Returns null when [logoUrl] is blank or cannot be resolved safely.
String? resolveTokenIconNetworkUrl(
  String? logoUrl, {
  String? backendBaseUrl,
}) {
  final trimmed = logoUrl?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  final base = backendBaseUrl ?? crypriceBackendBaseUrl;
  final String candidate;
  if (trimmed.startsWith('/')) {
    candidate = '${_stripTrailingSlash(base)}$trimmed';
  } else {
    candidate = trimmed;
  }

  return isLoadableTokenIconUrl(candidate) ? candidate : null;
}

String _stripTrailingSlash(String value) {
  if (value.length <= 1) {
    return value;
  }
  var result = value;
  while (result.endsWith('/')) {
    result = result.substring(0, result.length - 1);
  }
  return result;
}

/// True when [url] is safe to pass to [Image.network] (http/https with a host).
bool isLoadableTokenIconUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
    return false;
  }
  if (uri.host.isEmpty) {
    return false;
  }
  final scheme = uri.scheme.toLowerCase();
  return scheme == 'http' || scheme == 'https';
}

String _tokenIconSemanticsLabel(String symbol) {
  final trimmed = symbol.trim();
  if (trimmed.isEmpty) {
    return tokenIconInitials(symbol);
  }
  return trimmed;
}

/// Uppercase initials (1–3 chars) for token symbol fallback display.
String tokenIconInitials(String symbol) {
  final trimmed = symbol.trim();
  if (trimmed.isEmpty) {
    return '?';
  }
  if (trimmed.length <= 3) {
    return trimmed.toUpperCase();
  }
  return trimmed.substring(0, 3).toUpperCase();
}
