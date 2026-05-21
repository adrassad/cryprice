import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_defi_positions_section.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap({
    required PortfolioDefiPositionsSection Function({
      required bool useTableLayout,
      required bool useStackedGroupHeader,
    })
        sectionBuilder,
    required Size size,
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return MaterialApp(
      themeMode: themeMode,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return SingleChildScrollView(
                child: sectionBuilder(
                  useTableLayout: width >= 600,
                  useStackedGroupHeader: width < 520,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PortfolioDefiPositionsSection section({
    List<PortfolioProtocolPosition> supplied = const [],
    List<PortfolioProtocolPosition> borrowed = const [],
    List<PortfolioPositionHealth> positionsHealth = const [],
    List<PortfolioProtocolSummary> protocolSummaries = const [],
    String selectedProtocol = PortfolioFilter.allProtocols,
    String selectedWalletId = PortfolioFilter.allWallets,
    required bool useTableLayout,
    required bool useStackedGroupHeader,
  }) {
    return PortfolioDefiPositionsSection(
      supplied: supplied,
      borrowed: borrowed,
      positionsHealth: positionsHealth,
      protocolSummaries: protocolSummaries,
      selectedProtocol: selectedProtocol,
      selectedWalletId: selectedWalletId,
      useTableLayout: useTableLayout,
      useStackedGroupHeader: useStackedGroupHeader,
    );
  }

  testWidgets('renders protocol card with supplied and borrowed under same wallet group', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        size: const Size(900, 900),
        sectionBuilder: ({
          required useTableLayout,
          required useStackedGroupHeader,
        }) =>
            section(
          supplied: [_position()],
          borrowed: [
            _position(
              positionSide: PortfolioPositionSide.borrowed,
              debtType: PortfolioDebtType.variable,
              amount: '5',
              valueUsd: '5.00',
            ),
          ],
          protocolSummaries: const [
            PortfolioProtocolSummary(
              protocol: 'aave-v3',
              protocolName: 'Aave V3',
              category: 'lending',
              walletValueUsd: null,
              suppliedValueUsd: '100.00',
              borrowedValueUsd: '5.00',
              grossValueUsd: '100.00',
              netValueUsd: '95.00',
              totalValueUsd: '95.00',
              healthFactor: null,
              healthFactorStatus: null,
              healthFactorStatusLabel: null,
            ),
          ],
          positionsHealth: const [
            PortfolioPositionHealth(
              protocol: 'aave-v3',
              protocolName: 'Aave V3',
              networkId: 1,
              network: 'ethereum',
              networkName: 'Ethereum',
              walletId: '1',
              walletAddress: '0xwallet1',
              walletLabel: 'Main',
              healthFactor: '1.50',
              status: PortfolioHealthFactorStatus.safe,
              statusLabel: 'Safe',
              threshold: '1.0',
              updatedAt: null,
              stale: false,
            ),
          ],
          useTableLayout: useTableLayout,
          useStackedGroupHeader: useStackedGroupHeader,
        ),
      ),
    );

    expect(find.text('DeFi Positions'), findsOneWidget);
    expect(find.text('Aave V3'), findsOneWidget);
    expect(find.text('Lending'), findsOneWidget);
    expect(find.text('\$95.00'), findsOneWidget);
    expect(find.text('Ethereum · Main'), findsOneWidget);
    expect(find.text('Supplied'), findsOneWidget);
    expect(find.text('Borrowed'), findsOneWidget);
    expect(find.text('Health Factor'), findsOneWidget);
    expect(find.textContaining('1.5'), findsOneWidget);
    expect(find.text('Current Price'), findsWidgets);
    expect(find.text('\$1.00'), findsWidgets);
    expect(find.text('Debt'), findsOneWidget);
    expect(find.text('Variable debt'), findsOneWidget);
    expect(find.text('-\$5.00'), findsNothing);
  });

  testWidgets('multiple network wallet groups render separately', (tester) async {
    await tester.pumpWidget(
      wrap(
        size: const Size(900, 900),
        sectionBuilder: ({
          required useTableLayout,
          required useStackedGroupHeader,
        }) =>
            section(
          supplied: [
            _position(
              networkId: 42161,
              network: 'arbitrum',
              networkName: 'Arbitrum',
              wallets: const [
                PortfolioWalletBreakdown(
                  walletId: '1',
                  address: '0xwallet1',
                  label: 'TW wallet',
                  walletAddress: '0xwallet1',
                  walletLabel: 'TW wallet',
                  amount: '10',
                  balanceRaw: '0',
                  balance: '10',
                  valueUsd: '10.00',
                  syncedAt: null,
                  blockNumber: null,
                ),
              ],
            ),
            _position(
              networkId: 8453,
              network: 'base',
              networkName: 'Base',
              wallets: const [
                PortfolioWalletBreakdown(
                  walletId: '1',
                  address: '0xwallet1',
                  label: 'TW wallet',
                  walletAddress: '0xwallet1',
                  walletLabel: 'TW wallet',
                  amount: '20',
                  balanceRaw: '0',
                  balance: '20',
                  valueUsd: '20.00',
                  syncedAt: null,
                  blockNumber: null,
                ),
              ],
            ),
          ],
          useTableLayout: useTableLayout,
          useStackedGroupHeader: useStackedGroupHeader,
        ),
      ),
    );

    expect(find.text('Arbitrum · TW wallet'), findsOneWidget);
    expect(find.text('Base · TW wallet'), findsOneWidget);
  });

  testWidgets('selected wallet filter shows only matching group', (tester) async {
    await tester.pumpWidget(
      wrap(
        size: const Size(900, 900),
        sectionBuilder: ({
          required useTableLayout,
          required useStackedGroupHeader,
        }) =>
            section(
          supplied: [
            _position(
              wallets: const [
                PortfolioWalletBreakdown(
                  walletId: 'w1',
                  address: '0x1',
                  label: 'Main',
                  walletAddress: '0x1',
                  walletLabel: 'Main',
                  amount: '10',
                  balanceRaw: '0',
                  balance: '10',
                  valueUsd: '10.00',
                  syncedAt: null,
                  blockNumber: null,
                ),
                PortfolioWalletBreakdown(
                  walletId: 'w2',
                  address: '0x2',
                  label: 'Secondary',
                  walletAddress: '0x2',
                  walletLabel: 'Secondary',
                  amount: '20',
                  balanceRaw: '0',
                  balance: '20',
                  valueUsd: '20.00',
                  syncedAt: null,
                  blockNumber: null,
                ),
              ],
            ),
          ],
          selectedWalletId: 'w2',
          useTableLayout: useTableLayout,
          useStackedGroupHeader: useStackedGroupHeader,
        ),
      ),
    );

    expect(find.text('Ethereum · Secondary'), findsOneWidget);
    expect(find.text('Ethereum · Main'), findsNothing);
  });

  testWidgets('wallet protocol filter hides DeFi section content', (tester) async {
    await tester.pumpWidget(
      wrap(
        size: const Size(900, 600),
        sectionBuilder: ({
          required useTableLayout,
          required useStackedGroupHeader,
        }) =>
            section(
          supplied: [_position()],
          selectedProtocol: PortfolioFilter.walletProtocol,
          useTableLayout: useTableLayout,
          useStackedGroupHeader: useStackedGroupHeader,
        ),
      ),
    );

    expect(find.text('DeFi Positions'), findsNothing);
  });

  testWidgets('missing price shows unavailable for price and value', (tester) async {
    await tester.pumpWidget(
      wrap(
        size: const Size(900, 600),
        sectionBuilder: ({
          required useTableLayout,
          required useStackedGroupHeader,
        }) =>
            section(
          supplied: [
            _position(
              priceUsd: '0',
              valueUsd: '0',
              priceStatus: PortfolioPriceStatus.missing,
            ),
          ],
          useTableLayout: useTableLayout,
          useStackedGroupHeader: useStackedGroupHeader,
        ),
      ),
    );

    expect(find.text('Price unavailable'), findsOneWidget);
    expect(find.text('Value unavailable'), findsOneWidget);
    expect(find.text('\$0'), findsNothing);
  });

  testWidgets('stale price shows stale data chip', (tester) async {
    await tester.pumpWidget(
      wrap(
        size: const Size(900, 600),
        sectionBuilder: ({
          required useTableLayout,
          required useStackedGroupHeader,
        }) =>
            section(
          supplied: [
            _position(
              priceStatus: PortfolioPriceStatus.stale,
            ),
          ],
          useTableLayout: useTableLayout,
          useStackedGroupHeader: useStackedGroupHeader,
        ),
      ),
    );

    expect(find.text('Stale data'), findsOneWidget);
    expect(find.text('\$1.00'), findsOneWidget);
  });

  testWidgets('no_debt health factor shows no borrow risk', (tester) async {
    await tester.pumpWidget(
      wrap(
        size: const Size(900, 600),
        sectionBuilder: ({
          required useTableLayout,
          required useStackedGroupHeader,
        }) =>
            section(
          supplied: [_position()],
          positionsHealth: const [
            PortfolioPositionHealth(
              protocol: 'aave-v3',
              protocolName: 'Aave V3',
              networkId: 1,
              network: 'ethereum',
              networkName: 'Ethereum',
              walletId: '1',
              walletAddress: '0xwallet1',
              walletLabel: null,
              healthFactor: null,
              status: PortfolioHealthFactorStatus.noDebt,
              statusLabel: null,
              threshold: null,
              updatedAt: null,
              stale: false,
            ),
          ],
          useTableLayout: useTableLayout,
          useStackedGroupHeader: useStackedGroupHeader,
        ),
      ),
    );

    expect(find.text('No borrow risk'), findsOneWidget);
  });

  testWidgets('missing health factor shows unavailable', (tester) async {
    await tester.pumpWidget(
      wrap(
        size: const Size(900, 600),
        sectionBuilder: ({
          required useTableLayout,
          required useStackedGroupHeader,
        }) =>
            section(
          supplied: [_position()],
          positionsHealth: const [],
          useTableLayout: useTableLayout,
          useStackedGroupHeader: useStackedGroupHeader,
        ),
      ),
    );

    expect(find.text('Health Factor unavailable'), findsOneWidget);
  });

  testWidgets('stale health factor shows updated timestamp', (tester) async {
    await tester.pumpWidget(
      wrap(
        size: const Size(900, 600),
        sectionBuilder: ({
          required useTableLayout,
          required useStackedGroupHeader,
        }) =>
            section(
          supplied: [_position()],
          positionsHealth: const [
            PortfolioPositionHealth(
              protocol: 'aave-v3',
              protocolName: 'Aave V3',
              networkId: 1,
              network: 'ethereum',
              networkName: 'Ethereum',
              walletId: '1',
              walletAddress: '0xwallet1',
              walletLabel: 'Main',
              healthFactor: '1.61',
              status: PortfolioHealthFactorStatus.atRisk,
              statusLabel: 'At risk',
              threshold: '1.0',
              updatedAt: '2026-05-19T13:30:00.000Z',
              stale: true,
            ),
          ],
          useTableLayout: useTableLayout,
          useStackedGroupHeader: useStackedGroupHeader,
        ),
      ),
    );

    expect(find.textContaining('1.61'), findsOneWidget);
    expect(find.text('At risk'), findsOneWidget);
    expect(find.textContaining('HF updated:'), findsOneWidget);
    expect(find.text('Stale data'), findsNothing);
  });

  testWidgets('mobile layout shows per-row current price label', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      wrap(
        size: const Size(390, 844),
        sectionBuilder: ({
          required useTableLayout,
          required useStackedGroupHeader,
        }) =>
            section(
          supplied: [_position()],
          useTableLayout: useTableLayout,
          useStackedGroupHeader: useStackedGroupHeader,
        ),
      ),
    );

    expect(find.text('Current Price'), findsOneWidget);
    expect(find.text('Assets'), findsNothing);
  });

  testWidgets('renders in dark theme', (tester) async {
    await tester.pumpWidget(
      wrap(
        size: const Size(900, 1200),
        themeMode: ThemeMode.dark,
        sectionBuilder: ({
          required useTableLayout,
          required useStackedGroupHeader,
        }) =>
            section(
          supplied: [_position()],
          useTableLayout: useTableLayout,
          useStackedGroupHeader: useStackedGroupHeader,
        ),
      ),
    );

    expect(find.text('DeFi Positions'), findsOneWidget);
  });
}

PortfolioProtocolPosition _position({
  PortfolioPositionSide positionSide = PortfolioPositionSide.supplied,
  PortfolioDebtType? debtType,
  int networkId = 1,
  String network = 'ethereum',
  String networkName = 'Ethereum',
  String amount = '100',
  String? priceUsd = '1.00',
  String? valueUsd = '100.00',
  PortfolioPriceStatus priceStatus = PortfolioPriceStatus.ok,
  List<PortfolioWalletBreakdown>? wallets,
}) {
  return PortfolioProtocolPosition(
    kind: 'protocol',
    protocol: 'aave-v3',
    protocolName: 'Aave V3',
    networkId: networkId,
    network: network,
    networkName: networkName,
    chainId: networkId,
    positionSide: positionSide,
    tokenRole: positionSide == PortfolioPositionSide.borrowed ? 'debt' : 'collateral',
    debtType: debtType,
    underlyingSymbol: 'USDC',
    underlyingAddress: '0xusdc',
    tokenSymbol: 'aUSDC',
    tokenAddress: '0xausdc',
    amount: amount,
    balanceRaw: null,
    decimals: 6,
    priceUsd: priceUsd,
    valueUsd: valueUsd,
    priceStatus: priceStatus,
    wallets: wallets ??
        const [
          PortfolioWalletBreakdown(
            walletId: '1',
            address: '0xwallet1',
            label: 'Main',
            walletAddress: '0xwallet1',
            walletLabel: 'Main',
            amount: '100',
            balanceRaw: '0',
            balance: '100',
            valueUsd: '100.00',
            syncedAt: null,
            blockNumber: null,
          ),
        ],
  );
}
