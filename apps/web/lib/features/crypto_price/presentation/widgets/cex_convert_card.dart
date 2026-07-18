import 'package:cryprice_frontend/features/crypto_price/domain/entities/offchain_convert_result.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

String _timeLabel(DateTime t) {
  return t.toLocal().toString().split('.').first;
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

String _formatCount(double value) {
  var s = value.toStringAsFixed(8);
  if (s.contains('.')) {
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
  }
  return s;
}

String _formatSum(double value) {
  var s = value.toStringAsFixed(8);
  if (s.contains('.')) {
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
  }
  return s;
}

Future<void> _copyToClipboard(
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

class CexConvertCard extends StatelessWidget {
  const CexConvertCard({
    super.key,
    required this.l10n,
    required this.venue,
    required this.coin1,
    required this.coin2,
    required this.count,
    required this.venueResult,
    required this.localizeError,
    this.embeddedInPanel = false,
  });

  final AppLocalizations l10n;
  final String venue;
  final String coin1;
  final String coin2;
  final double count;
  final OffchainVenueConvert? venueResult;
  final String Function(String? code) localizeError;
  final bool embeddedInPanel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onVar = scheme.onSurfaceVariant;
    final providerName = _titleCaseProvider(venue);
    final pairText = '${coin1.toUpperCase()} / ${coin2.toUpperCase()}';
    final convertHint = l10n.resultsCexConvertHint(
      _formatCount(count),
      coin1.toUpperCase(),
      coin2.toUpperCase(),
    );

    if (venueResult == null) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                convertHint,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: onVar,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.resultsCexErrorLine(
                  venue.toUpperCase(),
                  localizeError(null),
                ),
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: scheme.error,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sumStr = _formatSum(venueResult!.sum);
    final parts = sumStr.split('.');
    final integerPart = parts[0];
    final fractionalPart = parts.length > 1 ? parts[1] : '';
    final collected = venueResult!.collected;
    final copyText = [
      providerName,
      convertHint,
      '${l10n.labelPair}: $pairText',
      if (collected != null)
        '${l10n.labelUpdated}: ${_timeLabel(collected)}',
      '${l10n.labelPrice}: $sumStr ${coin2.toUpperCase()}',
    ].join('\n');

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    providerName,
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
                  onPressed: () => _copyToClipboard(context, l10n, copyText),
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
              convertHint,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: onVar,
              ),
            ),
            const SizedBox(height: 4),
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
            if (collected != null)
              Text(
                '${l10n.labelUpdated}: ${_timeLabel(collected)}',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: onVar,
                ),
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
                    coin2.toUpperCase(),
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
    );
  }
}
