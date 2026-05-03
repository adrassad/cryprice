import 'package:crypto_tracker_app/features/crypto_price/domain/conversion/price_row_display_enricher.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_result.dart';
import 'package:crypto_tracker_app/features/crypto_price/presentation/widgets/cex_result_card.dart';
import 'package:crypto_tracker_app/features/crypto_price/presentation/widgets/cryprice_dex_result_section.dart';
import 'package:crypto_tracker_app/features/crypto_price/presentation/widgets/result_sections.dart';
import 'package:crypto_tracker_app/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

bool _cexRowShouldList(PriceRowViewModel vm) {
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
  });

  final List<PriceRowViewModel> rows;
  final AppLocalizations l10n;
  final double countMultiplier;
  final String userTicker1;
  final String userTicker2;
  final String Function(String? code) localizeError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (rows.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              localizeError(null),
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final cexBlock = rows
        .where(
          (vm) =>
              vm.row.origin == PriceResultOrigin.cex ||
              vm.row.origin == PriceResultOrigin.crypriceOffchain,
        )
        .where(_cexRowShouldList)
        .toList();
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

        final cexP = cexBlock.isNotEmpty
            ? _CexSectionColumn(
                l10n: l10n,
                items: cexBlock,
                localizeError: localizeError,
              )
            : null;
        final dexP = _DexSectionColumn(
          l10n: l10n,
          items: dexBlock,
          hadRowsBeforeFilter: dexBlockAll.isNotEmpty,
          countMultiplier: countMultiplier,
          userTicker1: userTicker1,
          userTicker2: userTicker2,
          localizeError: localizeError,
        );

        final bool twoCol = bp.isDesktop && cexP != null;

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
              if (cexP != null) cexP,
              if (cexP != null) SizedBox(height: betweenSections),
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

class _CexSectionColumn extends StatelessWidget {
  const _CexSectionColumn({
    required this.l10n,
    required this.items,
    required this.localizeError,
  });

  final AppLocalizations l10n;
  final List<PriceRowViewModel> items;
  final String Function(String? code) localizeError;

  @override
  Widget build(BuildContext context) {
    return SectionPanel(
      kind: PanelKind.cex,
      title: l10n.resultsSectionCexTitle,
      subtitle: l10n.resultsSectionCexSubtitle,
      children: items
          .map(
            (vm) => CexResultCard(
              key: ValueKey(
                'cex_${vm.row.origin.name}_${vm.row.priceType.name}_${vm.row.source}_'
                '${vm.row.network}_${vm.row.symbol}_${vm.row.quoteCurrency}_'
                '${vm.row.tokenAddress ?? ''}',
              ),
              l10n: l10n,
              vm: vm,
              localizeError: localizeError,
              embeddedInPanel: true,
            ),
          )
          .toList(),
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

