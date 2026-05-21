import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_wallet_holdings_section.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap({
    required Widget child,
    required Size size,
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('desktop layout shows table headers and current price column', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 600));
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      wrap(
        size: const Size(900, 600),
        child: PortfolioWalletHoldingsSection(
          holdings: [_holding(priceUsd: '2500.00', valueUsd: '5000.00')],
          useTableLayout: true,
        ),
      ),
    );

    expect(find.text('Current Price'), findsOneWidget);
    expect(find.text('USD Value'), findsOneWidget);
    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('\$2500.00'), findsOneWidget);
    expect(find.text('\$5000.00'), findsOneWidget);
  });

  testWidgets('mobile layout labels balance and current price per row', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      wrap(
        size: const Size(390, 844),
        child: PortfolioWalletHoldingsSection(
          holdings: [_holding(priceUsd: '1.00', valueUsd: '10.00')],
          useTableLayout: false,
        ),
      ),
    );

    expect(find.text('Current Price'), findsOneWidget);
    expect(find.text('USD Value'), findsOneWidget);
    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('Assets'), findsNothing);
  });

  testWidgets('missing price shows unavailable and does not show dollar zero', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        size: const Size(900, 600),
        child: PortfolioWalletHoldingsSection(
          holdings: [
            _holding(
              priceUsd: '0',
              valueUsd: null,
              priceStatus: PortfolioPriceStatus.missing,
            ),
          ],
          useTableLayout: true,
        ),
      ),
    );

    expect(find.text('Price unavailable'), findsOneWidget);
    expect(find.text('\$0'), findsNothing);
    expect(find.text('Value unavailable'), findsOneWidget);
  });

  testWidgets('stale price shows value with stale indicator', (tester) async {
    await tester.pumpWidget(
      wrap(
        size: const Size(900, 600),
        child: PortfolioWalletHoldingsSection(
          holdings: [
            _holding(
              priceUsd: '1.50',
              valueUsd: '15.00',
              priceStatus: PortfolioPriceStatus.stale,
            ),
          ],
          useTableLayout: true,
        ),
      ),
    );

    expect(find.text('\$1.50'), findsOneWidget);
    expect(find.text('\$15.00'), findsOneWidget);
    expect(find.text('Stale data'), findsOneWidget);
    expect(find.text('Price unavailable'), findsNothing);
  });

  testWidgets('value unavailable when valueUsd is null but price is ok', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        size: const Size(900, 600),
        child: PortfolioWalletHoldingsSection(
          holdings: [
            _holding(
              priceUsd: '2.00',
              valueUsd: null,
              priceStatus: PortfolioPriceStatus.ok,
            ),
          ],
          useTableLayout: true,
        ),
      ),
    );

    expect(find.text('\$2.00'), findsOneWidget);
    expect(find.text('Value unavailable'), findsOneWidget);
  });
}

PortfolioHolding _holding({
  String symbol = 'ETH',
  String? priceUsd = '2500.00',
  String? valueUsd = '5000.00',
  String amount = '2.0',
  PortfolioPriceStatus priceStatus = PortfolioPriceStatus.ok,
}) {
  return PortfolioHolding(
    kind: 'wallet',
    networkId: 1,
    network: 'ethereum',
    networkName: 'Ethereum',
    chainId: 1,
    assetId: 'eth',
    assetSymbol: symbol,
    assetAddress: '0x0',
    symbol: symbol,
    address: '0x0',
    amount: amount,
    balanceRaw: '0',
    decimals: 18,
    priceUsd: priceUsd,
    valueUsd: valueUsd,
    priceStatus: priceStatus,
  );
}
