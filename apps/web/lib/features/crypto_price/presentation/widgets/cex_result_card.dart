import 'package:crypto_tracker_app/features/crypto_price/domain/conversion/price_row_display_enricher.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/conversion/user_pair_conversion_result.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_result.dart';
import 'package:crypto_tracker_app/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

String _shortPriceTypeLabel(PriceType t, AppLocalizations l10n) {
  return switch (t) {
    PriceType.cex => l10n.priceTypeCex,
    PriceType.aggregated => l10n.priceTypeAggregated,
    PriceType.offchain => l10n.priceTypeOffchain,
    PriceType.onchain => l10n.priceTypeOnchain,
  };
}

String _timeLabel(DateTime t) {
  return t.toLocal().toString().split('.').first;
}

String _cexProviderLabel(PriceResult e) {
  const prefix = 'CRYPRICE · ';
  if (e.source.startsWith(prefix)) {
    return e.source.substring(prefix.length).trim();
  }
  if (e.source == 'CRYPRICE (off-chain)' &&
      (e.network != null && e.network!.trim().isNotEmpty)) {
    return e.network!.trim();
  }
  if (e.source == 'CRYPRICE' || e.source == 'CRYPRICE (off-chain)') {
    return e.network?.trim() ?? e.source;
  }
  return e.source;
}

String _titleCaseProvider(String s) {
  if (s.isEmpty) {
    return s;
  }
  return s
      .split(RegExp(r'[\s/]+'))
      .map(
        (w) => w.isEmpty
            ? w
            : '${w[0].toUpperCase()}${w.length > 1 ? w.substring(1).toLowerCase() : ''}',
      )
      .join(' ');
}

String _formatCopyCexPrice(double p) {
  var s = p.toStringAsFixed(8);
  if (s.contains('.')) {
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
  }
  return s;
}

String _cexClipboardText(
  PriceResult e,
  AppLocalizations l10n,
  String Function(String? code) localizeError,
  UserPairConversionResult conversion,
) {
  final providerName = _cexProviderLabel(e);
  final titleProvider = _titleCaseProvider(providerName);
  if (!e.hasValue || e.price == null) {
    return l10n.resultsCexErrorLine(
      providerName.toUpperCase(),
      localizeError(e.errorCode),
    );
  }
  final pairText = (e.symbol != null && e.symbol!.trim().isNotEmpty)
      ? '${e.symbol!.toUpperCase()} / ${e.quoteCurrency.toUpperCase()}'
      : e.quoteCurrency.toUpperCase();
  final lines = <String>[
    titleProvider,
    '${l10n.labelPair}: $pairText',
    if (e.updatedAt != null)
      '${l10n.labelUpdated}: ${_timeLabel(e.updatedAt!)}',
    '${l10n.labelPrice}: ${_formatCopyCexPrice(conversion.amount)} ${conversion.currencyLabel}',
  ];
  return lines.join('\n');
}

Future<void> _copyPriceCardToClipboard(
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

class CexResultCard extends StatelessWidget {
  const CexResultCard({
    super.key,
    required this.l10n,
    required this.vm,
    required this.localizeError,
    this.embeddedInPanel = false,
  });

  final AppLocalizations l10n;
  final PriceRowViewModel vm;
  final String Function(String? code) localizeError;
  final bool embeddedInPanel;

  @override
  Widget build(BuildContext context) {
    final e = vm.row;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onVar = scheme.onSurfaceVariant;
    final providerName = _cexProviderLabel(e);
    var priceStr = '';
    final scaled = vm.userConversion;
    if (scaled != null) {
      priceStr = scaled.amount.toStringAsFixed(8);
    }
    final currencySuffix = scaled?.currencyLabel ?? e.quoteCurrency.toUpperCase();
    var integerPart = '';
    var fractionalPart = '';
    if (priceStr.isNotEmpty) {
      final parts = priceStr.split('.');
      integerPart = parts[0];
      fractionalPart = parts.length > 1 ? parts[1] : '';
    }

    final pairText = (e.symbol != null && e.symbol!.trim().isNotEmpty)
        ? '${e.symbol!.toUpperCase()} / ${e.quoteCurrency.toUpperCase()}'
        : e.quoteCurrency.toUpperCase();

    return Card(
      margin: EdgeInsets.zero,
      elevation: embeddedInPanel ? 0 : 1,
      color: embeddedInPanel ? scheme.surface : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: embeddedInPanel
            ? BorderSide(
                color: scheme.outline.withValues(alpha: 0.4),
                width: 1,
              )
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: priceStr.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _titleCaseProvider(providerName),
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: scheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        tooltip: MaterialLocalizations.of(context).copyButtonLabel,
                        onPressed: () => _copyPriceCardToClipboard(
                          context,
                          l10n,
                          _cexClipboardText(
                            e,
                            l10n,
                            localizeError,
                            scaled!,
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
                  const SizedBox(height: 2),
                  Text(
                    pairText,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: onVar,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (e.priceType != PriceType.offchain)
                        Chip(
                          label: Text(
                            _shortPriceTypeLabel(e.priceType, l10n),
                            style: GoogleFonts.montserrat(fontSize: 11),
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                          backgroundColor: scheme.secondaryContainer,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                        ),
                      if (e.updatedAt != null)
                        Text(
                          '${l10n.labelUpdated}: ${_timeLabel(e.updatedAt!)}',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: onVar,
                          ),
                        ),
                      if (e.status == PriceStatus.fallback)
                        Text(
                          l10n.statusFallback,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: theme.colorScheme.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (e.status == PriceStatus.stale)
                        Text(
                          l10n.statusStale,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: theme.colorScheme.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          integerPart,
                          style: GoogleFonts.montserrat(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        if (fractionalPart.isNotEmpty)
                          Text(
                            '.${fractionalPart.toLowerCase()}',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: onVar,
                            ),
                          ),
                        const SizedBox(width: 8),
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
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      l10n.resultsCexErrorLine(
                        providerName.toUpperCase(),
                        localizeError(e.errorCode),
                      ),
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: scheme.error,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(context).copyButtonLabel,
                    onPressed: () => _copyPriceCardToClipboard(
                      context,
                      l10n,
                      l10n.resultsCexErrorLine(
                        providerName.toUpperCase(),
                        localizeError(e.errorCode),
                      ),
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
}
