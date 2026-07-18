import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';

bool isRateLimitedApiError({String? code, int? statusCode, String? message}) {
  if (statusCode == 429 || code == kApiErrorCodeRateLimited) {
    return true;
  }
  final normalized = message?.trim().toLowerCase() ?? '';
  return normalized.contains('too many requests') ||
      normalized.contains('слишком много запросов');
}

/// Maps [ApiError] / API failure fields to a user-facing localized string.
String localizeApiError(
  AppLocalizations loc, {
  String? code,
  String? message,
  int? statusCode,
}) {
  if (isRateLimitedApiError(code: code, statusCode: statusCode, message: message)) {
    return loc.error_rate_limited;
  }
  final trimmed = message?.trim();
  if (trimmed != null && trimmed.isNotEmpty) {
    return trimmed;
  }
  return loc.error_unknown;
}
