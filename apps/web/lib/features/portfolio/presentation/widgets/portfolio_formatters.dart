import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';

// Display-only formatters: backend financial strings are never parsed as double.

String formatPortfolioUsd(
  String? value, {
  required String unavailableLabel,
  int? fractionDigits,
}) {
  if (value == null || value.trim().isEmpty) {
    return unavailableLabel;
  }
  final trimmed = value.trim();
  final display = fractionDigits == null
      ? trimmed
      : roundFinancialDisplayToDecimalPlaces(trimmed, fractionDigits) ??
            trimmed;
  return '\$$display';
}

String formatPortfolioUsdForPriceStatus({
  required String? valueUsd,
  required PortfolioPriceStatus priceStatus,
  required String unavailableLabel,
  int? fractionDigits,
}) {
  if (priceStatus == PortfolioPriceStatus.missing) {
    return unavailableLabel;
  }
  return formatPortfolioUsd(
    valueUsd,
    unavailableLabel: unavailableLabel,
    fractionDigits: fractionDigits,
  );
}

/// Rounds a backend financial string to [fractionDigits] (half-up) without [double].
String? roundFinancialDisplayToDecimalPlaces(
  String? value,
  int fractionDigits,
) {
  if (fractionDigits < 0) {
    throw ArgumentError.value(fractionDigits, 'fractionDigits');
  }
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  var negative = false;
  var unsigned = trimmed;
  if (unsigned.startsWith('-')) {
    negative = true;
    unsigned = unsigned.substring(1);
  }
  if (unsigned.isEmpty) {
    return null;
  }

  final parts = unsigned.split('.');
  final intPart = parts[0].isEmpty ? '0' : parts[0];
  final fracPart = parts.length > 1 ? parts[1] : '';

  final padded = fracPart.padRight(fractionDigits + 1, '0');
  final keep = padded.substring(0, fractionDigits);
  final roundDigit = padded[fractionDigits];

  var fracBig = BigInt.parse(keep.isEmpty ? '0' : keep);
  if (roundDigit.codeUnitAt(0) >= 0x35) {
    fracBig += BigInt.one;
  }
  final scale = BigInt.from(10).pow(fractionDigits);
  var intBig = BigInt.parse(intPart);
  if (fracBig >= scale) {
    fracBig -= scale;
    intBig += BigInt.one;
  }

  final fracStr = fracBig.toString().padLeft(fractionDigits, '0');
  final result = '$intBig.$fracStr';
  return negative ? '-$result' : result;
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
