import 'package:cryprice_frontend/features/crypto_price/domain/conversion/price_row_display_enricher.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/entities/offchain_convert_result.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/entities/price_result.dart';
import 'package:cryprice_frontend/features/crypto_price/presentation/widgets/cex_convert_card.dart';
import 'package:cryprice_frontend/features/crypto_price/presentation/widgets/cryprice_dex_result_section.dart';
import 'package:cryprice_frontend/features/crypto_price/presentation/widgets/result_sections.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

bool _dexRowShouldList(PriceRowViewModel vm) {
  final r = vm.row;
  if (!r.hasValue && r.status == PriceStatus.error) {
    return true;
  }
  if (r.hasValue && r.price != null && vm.userConversion == null) {
    return false;
  }
  if (vm.userConversion != null) {
    return true;
  }
  return !r.hasValue;
}



class ResultPriceList extends StatelessWidget {
  const ResultPriceList({
    super.key,
    required this.rows,
    required this.l10n,
    required this.countMultiplier,
    required this.userTicker1,
    required this.userTicker2,
    required this.localizeError,
    required this.offchainConvert,
  });

  final List<PriceRowViewModel> rows;
  final AppLocalizations l10n;
  final double countMultiplier;
  final String userTicker1;
  final String userTicker2;
  final String Function(String? code) localizeError;
  final OffchainConvertResult offchainConvert;

  @override
  Widget build(BuildContext context) {
    final cexP = _CexConvertSectionColumn(
      l10n: l10n,
      convert: offchainConvert,
      localizeError: localizeError,
    );
    final dexBlockAll = rows
        .where((vm) => vm.row.origin == PriceResultOrigin.crypriceOnchain)
        .toList();
    final dexBlock = dexBlockAll.where(_dexRowShouldList).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = MediaQuery.sizeOf(context).width;
        final bp = ResultBreakpoints(w);
        final hPad = bp.isMobile ? 4.0 : 10.0;
        final betweenSections = bp.isMobile ? 20.0 : 24.0;

        final dexP = _DexSectionColumn(
          l10n: l10n,
          items: dexBlock,
          hadRowsBeforeFilter: dexBlockAll.isNotEmpty,
          countMultiplier: countMultiplier,
          userTicker1: userTicker1,
          userTicker2: userTicker2,
          localizeError: localizeError,
        );

        final bool twoCol = bp.isDesktop;

        Widget content;
        if (twoCol) {
          content = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cexP),
              SizedBox(width: w < 1200 ? 16 : 24),
              Expanded(child: dexP),
            ],
          );
        } else {
          // Mobile + tablet: stacked, CEX first; DEX section always shown (may be empty).
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              cexP,
              SizedBox(height: betweenSections),
              dexP,
            ],
          );
        }

        // Single page scroll: one SingleChildScrollView, no nested column scrolls
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              content,
            ],
          ),
        );
      },
    );
  }
}

class _CexConvertSectionColumn extends StatelessWidget {
  const _CexConvertSectionColumn({
    required this.l10n,
    required this.convert,
    required this.localizeError,
  });

  final AppLocalizations l10n;
  final OffchainConvertResult convert;
  final String Function(String? code) localizeError;

  @override
  Widget build(BuildContext context) {
    return SectionPanel(
      kind: PanelKind.cex,
      title: l10n.resultsSectionCexTitle,
      subtitle: l10n.resultsSectionCexSubtitle,
      children: [
        CexConvertCard(
          key: const ValueKey('cex_convert_binance'),
          l10n: l10n,
          venue: 'binance',
          coin1: convert.coin1,
          coin2: convert.coin2,
          count: convert.count,
          venueResult: convert.binance,
          localizeError: localizeError,
          embeddedInPanel: true,
        ),
        CexConvertCard(
          key: const ValueKey('cex_convert_bybit'),
          l10n: l10n,
          venue: 'bybit',
          coin1: convert.coin1,
          coin2: convert.coin2,
          count: convert.count,
          venueResult: convert.bybit,
          localizeError: localizeError,
          embeddedInPanel: true,
        ),
      ],
    );
  }
}

class _DexSectionColumn extends StatelessWidget {
  const _DexSectionColumn({
    required this.l10n,
    required this.items,
    required this.hadRowsBeforeFilter,
    required this.countMultiplier,
    required this.userTicker1,
    required this.userTicker2,
    required this.localizeError,
  });

  final AppLocalizations l10n;
  final List<PriceRowViewModel> items;
  final bool hadRowsBeforeFilter;
  final double countMultiplier;
  final String userTicker1;
  final String userTicker2;
  final String Function(String? code) localizeError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emptyMessage = Text(
      l10n.resultsSectionDexEmpty,
      textAlign: TextAlign.center,
      style: GoogleFonts.montserrat(
        fontSize: 14,
        height: 1.4,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
    final children = !hadRowsBeforeFilter || items.isEmpty
        ? <Widget>[emptyMessage]
        : items
              .asMap()
              .entries
              .map(
                (e) => CrypriceNetworkCard(
                  key: ValueKey(
                    'dex_onchain_${e.value.row.network}_${e.value.row.symbol}_'
                    '${e.value.row.tokenAddress ?? ''}_${e.key}',
                  ),
                  l10n: l10n,
                  vm: e.value,
                  countMultiplier: countMultiplier,
                  userTicker1: userTicker1,
                  userTicker2: userTicker2,
                  localizeError: localizeError,
                  embeddedInPanel: true,
                ),
              )
              .toList();
    return SectionPanel(
      kind: PanelKind.dex,
      title: l10n.resultsSectionDexTitle,
      subtitle: l10n.resultsSectionDexSubtitle,
      children: children,
    );
  }
}

