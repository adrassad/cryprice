import 'package:crypto_tracker_app/features/crypto_price/domain/conversion/price_row_display_enricher.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/conversion/user_pair_conversion_result.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_result.dart';
import 'package:crypto_tracker_app/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

String _timeLabel(DateTime t) {
  return t.toLocal().toString().split('.').first;
}

String _shortenAddress(String a) {
  if (a.length <= 12) {
    return a;
  }
  if (a.startsWith('0x') && a.length > 10) {
    return '${a.substring(0, 6)}…${a.substring(a.length - 4)}';
  }
  return '${a.substring(0, 4)}…${a.substring(a.length - 3)}';
}

String _networkTitleCase(String raw, AppLocalizations l10n) {
  if (raw.trim().isEmpty) {
    return l10n.unknownNetwork;
  }
  return raw
      .split('_')
      .map(
        (p) => p.isEmpty
            ? p
            : '${p[0].toUpperCase()}${p.length > 1 ? p.substring(1).toLowerCase() : ''}',
      )
      .join(' ');
}

String _formatDexUsdAmount(double p) {
  if (p >= 1) {
    return p.toStringAsFixed(2);
  }
  if (p == 0) {
    return '0';
  }
  return p.toStringAsFixed(6);
}

String _dexClipboardText(
  PriceResult result,
  AppLocalizations l10n,
  String Function(String? code) localizeError,
  UserPairConversionResult conversion,
) {
  final networkLabel = _networkTitleCase(
    (result.network != null && result.network!.trim().isNotEmpty)
        ? result.network!
        : '',
    l10n,
  );
  if (!result.hasValue && result.status == PriceStatus.error) {
    return '$networkLabel\n${localizeError(result.errorCode)}';
  }
  final sym = (result.symbol != null && result.symbol!.trim().isNotEmpty)
      ? result.symbol!
      : l10n.emDash;
  final addr = result.tokenAddress;
  final lines = <String>[
    sym,
    l10n.resultsNetworkLine(networkLabel),
    if (addr != null && addr.isNotEmpty) '${l10n.labelTokenAddress}: $addr',
    if (result.updatedAt != null)
      '${l10n.labelCollected}: ${_timeLabel(result.updatedAt!)}',
    '${l10n.labelPrice}: ${_formatDexUsdAmount(conversion.amount)} ${conversion.currencyLabel}',
  ];
  return lines.join('\n');
}

Future<void> _copyDexCardToClipboard(
  BuildContext context,
  AppLocalizations l10n,
  String text,
) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(l10n.copiedToClipboard),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

class CrypriceNetworkCard extends StatelessWidget {
  const CrypriceNetworkCard({
    super.key,
    required this.l10n,
    required this.vm,
    required this.countMultiplier,
    required this.userTicker1,
    required this.userTicker2,
    required this.localizeError,
    this.embeddedInPanel = false,
  });

  final AppLocalizations l10n;
  final PriceRowViewModel vm;
  final double countMultiplier;
  final String userTicker1;
  final String userTicker2;
  final String Function(String? code) localizeError;
  final bool embeddedInPanel;

  @override
  Widget build(BuildContext context) {
    final result = vm.row;
    final scaled = vm.userConversion;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onVar = scheme.onSurfaceVariant;
    // [PriceResult.network] = top-level on-chain JSON key only
    final networkLabel = _networkTitleCase(
      (result.network != null && result.network!.trim().isNotEmpty)
          ? result.network!
          : '',
      l10n,
    );
    final addr = result.tokenAddress;
    final sym = (result.symbol != null && result.symbol!.trim().isNotEmpty)
        ? result.symbol!
        : l10n.emDash;

    if (!result.hasValue && result.status == PriceStatus.error) {
      return Card(
        margin: EdgeInsets.zero,
        elevation: embeddedInPanel ? 0 : 1,
        color: embeddedInPanel ? scheme.surface : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: scheme.error.withValues(alpha: 0.5),
            width: embeddedInPanel ? 1 : 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '$networkLabel\n${localizeError(result.errorCode)}',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: scheme.error,
                    height: 1.35,
                  ),
                ),
              ),
              IconButton(
                tooltip: MaterialLocalizations.of(context).copyButtonLabel,
                onPressed: () => _copyDexCardToClipboard(
                  context,
                  l10n,
                  '$networkLabel\n${localizeError(result.errorCode)}',
                ),
                icon: Icon(Icons.copy_outlined, size: 20, color: scheme.error),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      );
    }

    final price = result.price;
    if (price == null || scaled == null) {
      return const SizedBox.shrink();
    }
    final priceStr = _formatDexUsdAmount(scaled.amount);
    final currencySuffix = scaled.currencyLabel;
    final priceParts = priceStr.split('.');
    final intPart = priceParts[0];
    final fracPart = priceParts.length > 1 ? priceParts[1] : '';

    final warn = scheme.tertiary;

    return Card(
      margin: EdgeInsets.zero,
      elevation: embeddedInPanel ? 0 : 1,
      color: embeddedInPanel ? scheme.surface : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: scheme.outline.withValues(alpha: embeddedInPanel ? 0.45 : 0.3),
          width: embeddedInPanel ? 1 : 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: DefaultTextStyle.merge(
          style: GoogleFonts.montserrat(
            color: scheme.onSurface,
            fontSize: 12.5,
            height: 1.35,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      sym,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: scheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(context).copyButtonLabel,
                    onPressed: () => _copyDexCardToClipboard(
                      context,
                      l10n,
                      _dexClipboardText(
                        result,
                        l10n,
                        localizeError,
                        scaled,
                      ),
                    ),
                    icon: Icon(Icons.copy_outlined, size: 20, color: onVar),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (result.status == PriceStatus.fallback)
                    Text(
                      l10n.statusFallback,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: warn,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (result.status == PriceStatus.stale)
                    Text(
                      l10n.statusStale,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: warn,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.resultsNetworkLine(networkLabel),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (addr != null && addr.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.labelTokenAddress,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: onVar,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SelectableText(
                  _shortenAddress(addr),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: onVar,
                  ),
                ),
              ],
              if (result.updatedAt != null) ...[
                const SizedBox(height: 6),
                Text(
                  '${l10n.labelCollected}: ${_timeLabel(result.updatedAt!)}',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: onVar,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      intPart,
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    if (fracPart.isNotEmpty)
                      Text(
                        '.${fracPart.toLowerCase()}',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: onVar,
                        ),
                      ),
                    const SizedBox(width: 6),
                    Text(
                      currencySuffix,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: onVar,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
