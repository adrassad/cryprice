import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';

// Display-only formatters: backend financial strings are never parsed as double.

String formatPortfolioUsd(String? value, {required String unavailableLabel}) {
  if (value == null || value.trim().isEmpty) {
    return unavailableLabel;
  }
  return '\$${value.trim()}';
}

String formatPortfolioUsdForPriceStatus({
  required String? valueUsd,
  required PortfolioPriceStatus priceStatus,
  required String unavailableLabel,
}) {
  if (priceStatus == PortfolioPriceStatus.missing) {
    return unavailableLabel;
  }
  return formatPortfolioUsd(valueUsd, unavailableLabel: unavailableLabel);
}

/// USD value for a holding/position row; independent of [priceStatus].
String formatPortfolioHoldingValueUsd(
  String? valueUsd, {
  required String unavailableLabel,
}) {
  return formatPortfolioUsd(valueUsd, unavailableLabel: unavailableLabel);
}

/// DeFi position USD value: unavailable when price is missing; debt stays positive.
String formatPortfolioPositionValueUsd({
  required String? valueUsd,
  required PortfolioPriceStatus priceStatus,
  required String unavailableLabel,
  bool ensurePositive = false,
}) {
  if (priceStatus == PortfolioPriceStatus.missing) {
    return unavailableLabel;
  }
  final normalized = ensurePositive
      ? positiveFinancialDisplayValue(valueUsd)
      : valueUsd;
  return formatPortfolioHoldingValueUsd(
    normalized,
    unavailableLabel: unavailableLabel,
  );
}

/// Keeps borrowed/debt positive for display without numeric parsing.
String? positiveFinancialDisplayValue(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  if (trimmed.startsWith('-')) {
    return trimmed.substring(1);
  }
  return value;
}

String? compactPortfolioDecimalValue(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  if (!trimmed.contains('.')) {
    return trimmed;
  }
  var compact = trimmed;
  while (compact.endsWith('0')) {
    compact = compact.substring(0, compact.length - 1);
  }
  if (compact.endsWith('.')) {
    compact = compact.substring(0, compact.length - 1);
  }
  return compact;
}

String formatPortfolioBalance({
  required String balance,
  required String symbol,
}) {
  final compactBalance = compactPortfolioDecimalValue(balance) ?? balance.trim();
  final trimmedSymbol = symbol.trim();
  if (trimmedSymbol.isEmpty) {
    return compactBalance;
  }
  return '$compactBalance $trimmedSymbol';
}

String formatPortfolioAmount(
  String? amount, {
  required String unavailableLabel,
}) {
  final trimmed = amount?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return unavailableLabel;
  }
  return compactPortfolioDecimalValue(trimmed) ?? trimmed;
}

String formatPortfolioUpdatedAt(
  String value, {
  required String updatedNeverLabel,
}) {
  if (value.trim().isEmpty) {
    return updatedNeverLabel;
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return value;
  }
  final local = parsed.toLocal();
  final date = _twoDigits(local.day);
  final month = _twoDigits(local.month);
  final year = local.year.toString();
  final hour = _twoDigits(local.hour);
  final minute = _twoDigits(local.minute);
  return '$date.$month.$year $hour:$minute';
}

String shortenPortfolioAddress(String address) {
  if (address.length <= 12) {
    return address;
  }
  return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String formatPortfolioAllocationPercentage(String? percentage) {
  final trimmed = percentage?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return '—';
  }
  if (trimmed.endsWith('%')) {
    return trimmed;
  }
  return '$trimmed%';
}
