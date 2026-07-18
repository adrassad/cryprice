import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/core/widgets/token_icon.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_pdf_export_result.dart';
import 'package:cryprice_frontend/features/portfolio/domain/usecases/export_portfolio_pdf_usecase.dart';
import 'package:cryprice_frontend/features/portfolio/domain/usecases/get_portfolio_usecase.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/pages/portfolio_page.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_export_pdf_button.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

void main() {
  late MockPortfolioRepository repository;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    repository = MockPortfolioRepository();
    when(() => repository.exportPortfolioPdf()).thenAnswer(
      (_) async => const PortfolioPdfExportResult(
        bytes: <int>[0x25, 0x50, 0x44, 0x46],
        filename: 'report.pdf',
        mimeType: kPortfolioPdfMimeType,
      ),
    );
  });

  testWidgets('shows summary for loaded portfolio', (tester) async {
    final cubit = await _loadedCubit(repository, _portfolio());

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('Net value'), findsWidgets);
    expect(find.text('\$5240.75'), findsWidgets);
    expect(find.text('Health Factor unavailable'), findsWidgets);
    expect(find.text('Ethereum'), findsOneWidget);
    expect(find.text('USDC'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('shows wallet holdings when present', (tester) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        walletHoldings: [
          _holding(
            symbol: 'DAI',
            networkName: 'Polygon',
            amount: '42.5',
            priceUsd: '1.0000',
            valueUsd: '42.50',
          ),
        ],
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('On-chain holdings'), findsOneWidget);
    expect(find.byType(TokenIcon), findsOneWidget);
    expect(find.text('DAI'), findsWidgets);
    expect(find.text('Polygon'), findsOneWidget);
    expect(find.text('42.5 DAI'), findsOneWidget);
    expect(find.text('Current Price'), findsOneWidget);
    expect(find.text('\$1.00'), findsOneWidget);
    expect(find.text('\$42.50'), findsOneWidget);
    expect(find.text('Ethereum'), findsNothing);

    await cubit.close();
  });

  testWidgets('falls back to legacy networks when wallet holdings are empty', (tester) async {
    final cubit = await _loadedCubit(repository, _portfolio());

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('On-chain holdings'), findsNothing);
    expect(find.text('Ethereum'), findsOneWidget);
    expect(find.text('USDC'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('shows no wallet holdings card when loaded without holdings or legacy assets', (
    tester,
  ) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: const <PortfolioAsset>[],
        protocolPositions: PortfolioProtocolPositions(
          supplied: [_protocolPosition()],
        ),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('No on-chain holdings'), findsOneWidget);
    expect(find.text('DeFi Positions'), findsOneWidget);
    expect(find.text('Supplied'), findsOneWidget);
    expect(find.text('Aave V3'), findsWidgets);
    expect(find.text('Network total'), findsNothing);

    await cubit.close();
  });

  testWidgets('shows supplied defi positions only', (tester) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: const <PortfolioAsset>[],
        protocolPositions: PortfolioProtocolPositions(
          supplied: [
            _protocolPosition(
              amount: '100',
              valueUsd: '100.00',
              priceUsd: '1.00',
            ),
          ],
        ),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('DeFi Positions'), findsOneWidget);
    expect(find.text('Supplied'), findsOneWidget);
    expect(find.text('Borrowed'), findsNothing);
    expect(find.text('Aave V3'), findsWidgets);
    expect(find.text('USDC'), findsOneWidget);
    expect(find.text('100 USDC'), findsOneWidget);
    expect(find.text('Current Price'), findsOneWidget);
    expect(find.text('\$100.00'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('shows borrowed defi positions as positive debt', (tester) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: const <PortfolioAsset>[],
        protocolPositions: PortfolioProtocolPositions(
          borrowed: [
            _protocolPosition(
              positionSide: PortfolioPositionSide.borrowed,
              amount: '50',
              valueUsd: '2500.00',
              priceUsd: '50.00',
              debtType: PortfolioDebtType.variable,
            ),
          ],
        ),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('Borrowed'), findsOneWidget);
    expect(find.text('Debt'), findsOneWidget);
    expect(find.text('Variable debt'), findsOneWidget);
    expect(find.text('50 USDC'), findsOneWidget);
    expect(find.text('\$2500.00'), findsOneWidget);
    expect(find.text('-\$2500.00'), findsNothing);

    await cubit.close();
  });

  testWidgets('shows supplied and borrowed defi sections', (tester) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: const <PortfolioAsset>[],
        protocolPositions: PortfolioProtocolPositions(
          supplied: [_protocolPosition(valueUsd: '10.00')],
          borrowed: [
            _protocolPosition(
              positionSide: PortfolioPositionSide.borrowed,
              valueUsd: '5.00',
              debtType: PortfolioDebtType.stable,
            ),
          ],
        ),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('Supplied'), findsOneWidget);
    expect(find.text('Borrowed'), findsOneWidget);
    expect(find.text('Stable debt'), findsOneWidget);
    expect(find.text('\$10.00'), findsOneWidget);
    expect(find.text('\$5.00'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('shows no defi positions card when protocol positions are empty', (
    tester,
  ) async {
    final cubit = await _loadedCubit(repository, _portfolio());

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('No DeFi positions yet'), findsOneWidget);
    expect(find.text('Supplied'), findsNothing);

    await cubit.close();
  });

  testWidgets('shows unavailable price and value for missing defi price', (
    tester,
  ) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: const <PortfolioAsset>[],
        protocolPositions: PortfolioProtocolPositions(
          supplied: [
            _protocolPosition(
              priceUsd: '0',
              valueUsd: '0',
              priceStatus: PortfolioPriceStatus.missing,
            ),
          ],
        ),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('Price unavailable'), findsWidgets);
    expect(find.text('Value unavailable'), findsWidgets);
    expect(find.text('\$0'), findsNothing);
    expect(find.text('\$0.00'), findsNothing);

    await cubit.close();
  });

  testWidgets('renders defi positions in dark theme', (tester) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: const <PortfolioAsset>[],
        protocolPositions: PortfolioProtocolPositions(
          supplied: [_protocolPosition()],
        ),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit, themeMode: ThemeMode.dark));

    expect(find.text('DeFi Positions'), findsOneWidget);
    expect(find.text('Supplied'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('shows Russian defi localization', (tester) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: const <PortfolioAsset>[],
        protocolPositions: PortfolioProtocolPositions(
          borrowed: [
            _protocolPosition(
              positionSide: PortfolioPositionSide.borrowed,
              debtType: PortfolioDebtType.variable,
            ),
          ],
        ),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit, locale: const Locale('ru')));

    expect(find.text('DeFi-позиции'), findsOneWidget);
    expect(find.text('Заем'), findsOneWidget);
    expect(find.text('Долг'), findsOneWidget);
    expect(find.text('Переменный долг'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('hides risk details when positionsHealth is empty and no borrowed', (
    tester,
  ) async {
    final cubit = await _loadedCubit(repository, _portfolio());

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('Risk Details'), findsNothing);

    await cubit.close();
  });

  testWidgets('shows compact health factor unavailable when borrowed without rows', (
    tester,
  ) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: const <PortfolioAsset>[],
        protocolPositions: PortfolioProtocolPositions(
          borrowed: [
            _protocolPosition(positionSide: PortfolioPositionSide.borrowed),
          ],
        ),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('Risk Details'), findsNothing);
    expect(find.text('Health Factor unavailable'), findsWidgets);

    await cubit.close();
  });

  testWidgets('shows one safe risk details row', (tester) async {
    final healthRows = [
      _positionHealth(
        healthFactor: '2.1400',
        status: PortfolioHealthFactorStatus.safe,
        threshold: '1.5000',
      ),
    ];
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: const <PortfolioAsset>[],
        protocolPositions: _suppliedPositionsBackingHealth(healthRows),
        defiRisk: PortfolioDefiRisk(positionsHealth: healthRows),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('Risk Details'), findsOneWidget);
    expect(find.text('Aave V3'), findsWidgets);
    expect(find.text('Ethereum'), findsWidgets);
    expect(find.text('0x1234...5678'), findsWidgets);
    expect(find.text('2.14'), findsWidgets);
    expect(find.text('Safe'), findsWidgets);
    expect(find.text('Threshold'), findsOneWidget);
    expect(find.text('1.5'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('shows at risk risk details row', (tester) async {
    final healthRows = [
      _positionHealth(
        healthFactor: '1.0500',
        status: PortfolioHealthFactorStatus.atRisk,
      ),
    ];
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: const <PortfolioAsset>[],
        protocolPositions: _suppliedPositionsBackingHealth(healthRows),
        defiRisk: PortfolioDefiRisk(positionsHealth: healthRows),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('1.05'), findsWidgets);
    expect(find.text('At risk'), findsWidgets);

    await cubit.close();
  });

  testWidgets('shows multiple risk details rows for different wallets', (tester) async {
    final healthRows = [
      _positionHealth(
        networkName: 'Ethereum',
        walletAddress: '0x1111111111111111111111111111111111111111',
      ),
      _positionHealth(
        networkId: 137,
        network: 'polygon',
        networkName: 'Polygon',
        walletAddress: '0x2222222222222222222222222222222222222222',
      ),
    ];
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: const <PortfolioAsset>[],
        protocolPositions: _suppliedPositionsBackingHealth(healthRows),
        defiRisk: PortfolioDefiRisk(positionsHealth: healthRows),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('Risk Details'), findsOneWidget);
    expect(find.text('Ethereum'), findsWidgets);
    expect(find.text('Polygon'), findsOneWidget);
    expect(find.text('0x1111...1111'), findsWidgets);
    expect(find.text('0x2222...2222'), findsWidgets);

    await cubit.close();
  });

  testWidgets('shows stale risk details row without hiding value', (tester) async {
    final healthRows = [
      _positionHealth(
        healthFactor: '1.8000',
        status: PortfolioHealthFactorStatus.safe,
        stale: true,
      ),
    ];
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: const <PortfolioAsset>[],
        protocolPositions: _suppliedPositionsBackingHealth(healthRows),
        defiRisk: PortfolioDefiRisk(positionsHealth: healthRows),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('1.8'), findsWidgets);
    expect(find.textContaining('HF updated:'), findsWidgets);
    expect(find.text('Stale data'), findsNothing);

    await cubit.close();
  });

  testWidgets('shows missing health factor in risk details row', (tester) async {
    final healthRows = [
      _positionHealth(
        healthFactor: null,
        status: PortfolioHealthFactorStatus.missing,
      ),
    ];
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: const <PortfolioAsset>[],
        protocolPositions: _suppliedPositionsBackingHealth(healthRows),
        defiRisk: PortfolioDefiRisk(positionsHealth: healthRows),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('Health Factor unavailable'), findsWidgets);

    await cubit.close();
  });

  testWidgets('shows no borrow risk in risk details row', (tester) async {
    final healthRows = [
      _positionHealth(
        healthFactor: null,
        status: PortfolioHealthFactorStatus.noDebt,
      ),
    ];
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: const <PortfolioAsset>[],
        protocolPositions: _suppliedPositionsBackingHealth(healthRows),
        defiRisk: PortfolioDefiRisk(positionsHealth: healthRows),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('No borrow risk'), findsWidgets);

    await cubit.close();
  });

  testWidgets('hides risk details when health exists without protocol positions', (
    tester,
  ) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: const <PortfolioAsset>[],
        defiRisk: PortfolioDefiRisk(
          positionsHealth: [
            _positionHealth(
              healthFactor: null,
              status: PortfolioHealthFactorStatus.noDebt,
            ),
          ],
        ),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('Risk Details'), findsNothing);
    expect(find.text('No borrow risk'), findsNothing);

    await cubit.close();
  });

  testWidgets('renders risk details in dark theme', (tester) async {
    final healthRows = [_positionHealth()];
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: const <PortfolioAsset>[],
        protocolPositions: _suppliedPositionsBackingHealth(healthRows),
        defiRisk: PortfolioDefiRisk(positionsHealth: healthRows),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit, themeMode: ThemeMode.dark));

    expect(find.text('Risk Details'), findsOneWidget);
    expect(find.text('2.14'), findsWidgets);

    await cubit.close();
  });

  testWidgets('shows Russian risk details localization', (tester) async {
    final healthRows = [
      _positionHealth(
        status: PortfolioHealthFactorStatus.atRisk,
        threshold: '1.10',
      ),
    ];
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: const <PortfolioAsset>[],
        protocolPositions: _suppliedPositionsBackingHealth(healthRows),
        defiRisk: PortfolioDefiRisk(positionsHealth: healthRows),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit, locale: const Locale('ru')));

    expect(find.text('Детали риска'), findsOneWidget);
    expect(find.text('Порог'), findsOneWidget);
    expect(find.text('В зоне риска'), findsWidgets);

    await cubit.close();
  });

  testWidgets('shows unavailable price and value for missing holding price', (tester) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        walletHoldings: [
          _holding(
            priceUsd: null,
            valueUsd: null,
            priceStatus: PortfolioPriceStatus.missing,
          ),
        ],
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('Price unavailable'), findsWidgets);
    expect(find.text('Value unavailable'), findsWidgets);
    expect(find.text('\$0'), findsNothing);

    await cubit.close();
  });

  testWidgets('HF badge displays no_debt in summary', (tester) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        defiRisk: const PortfolioDefiRisk(
          healthFactor: PortfolioHealthFactor(
            value: null,
            status: PortfolioHealthFactorStatus.noDebt,
            statusLabel: null,
            protocol: 'aave-v3',
            protocolName: 'Aave V3',
            updatedAt: '2026-05-19T13:30:00.000Z',
            stale: false,
          ),
        ),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('Health Factor'), findsOneWidget);
    expect(find.text('No borrow risk'), findsWidgets);

    await cubit.close();
  });

  testWidgets('renders wallet holdings in dark theme', (tester) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(walletHoldings: [_holding()]),
    );

    await _pumpPortfolio(tester, _app(cubit, themeMode: ThemeMode.dark));

    expect(find.text('On-chain holdings'), findsOneWidget);
    expect(find.text('USDC'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('renders wallet holdings on mobile width', (tester) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(walletHoldings: [_holding()]),
    );

    await _pumpPortfolio(
      tester,
      _app(cubit),
      viewport: const Size(390, 5000),
    );

    expect(find.text('On-chain holdings'), findsOneWidget);
    expect(find.text('USDC'), findsOneWidget);
    expect(find.text('Current Price'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('wallet holdings desktop table shows column headers', (tester) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(walletHoldings: [_holding()]),
    );

    await _pumpPortfolio(
      tester,
      _app(cubit),
      viewport: const Size(900, 700),
    );

    expect(find.text('USD Value'), findsOneWidget);
    expect(find.text('Assets'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('wallet holdings stale price shows stale data chip', (tester) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        walletHoldings: [
          _holding(
            priceUsd: '1.00',
            valueUsd: '10.00',
            priceStatus: PortfolioPriceStatus.stale,
          ),
        ],
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('\$1.00'), findsOneWidget);
    expect(find.text('Stale data'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('shows net value totals and safe health factor', (tester) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        summary: const PortfolioSummary(
          totalValueUsd: '1200.00',
          walletValueUsd: '600.00',
          suppliedValueUsd: '700.00',
          borrowedValueUsd: '100.00',
          grossValueUsd: '1300.00',
          netValueUsd: '1200.00',
          walletsCount: 1,
          assetsCount: 1,
          networksCount: 1,
          updatedAt: '2026-05-19T13:30:00.000Z',
        ),
        defiRisk: const PortfolioDefiRisk(
          healthFactor: PortfolioHealthFactor(
            value: '2.1400',
            status: PortfolioHealthFactorStatus.safe,
            statusLabel: null,
            protocol: 'aave-v3',
            protocolName: 'Aave V3',
            updatedAt: '2026-05-19T13:30:00.000Z',
            stale: false,
          ),
        ),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('Net value'), findsWidgets);
    expect(find.text('\$1200.00'), findsWidgets);
    expect(find.text('On-chain value'), findsWidgets);
    expect(find.text('\$600.00'), findsOneWidget);
    expect(find.text('Supplied value'), findsOneWidget);
    expect(find.text('\$700.00'), findsOneWidget);
    expect(find.text('Borrowed / debt'), findsOneWidget);
    expect(find.text('\$100.00'), findsOneWidget);
    expect(find.text('Gross value'), findsOneWidget);
    expect(find.text('\$1300.00'), findsOneWidget);
    expect(find.text('Health Factor'), findsOneWidget);
    expect(find.text('2.14'), findsWidgets);
    expect(find.text('Safe'), findsWidgets);

    await cubit.close();
  });

  testWidgets('shows no debt health factor label', (tester) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        summary: const PortfolioSummary(
          totalValueUsd: '100.00',
          healthFactorStatus: PortfolioHealthFactorStatus.noDebt,
          walletsCount: 1,
          assetsCount: 1,
          networksCount: 1,
          updatedAt: '2026-05-19T13:30:00.000Z',
        ),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('No borrow risk'), findsWidgets);

    await cubit.close();
  });

  testWidgets('shows at risk health factor label', (tester) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        defiRisk: const PortfolioDefiRisk(
          healthFactor: PortfolioHealthFactor(
            value: '1.05',
            status: PortfolioHealthFactorStatus.atRisk,
            statusLabel: null,
            protocol: 'aave-v3',
            protocolName: 'Aave V3',
            updatedAt: '2026-05-19T13:30:00.000Z',
            stale: false,
          ),
        ),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('1.05'), findsWidgets);
    expect(find.text('At risk'), findsWidgets);

    await cubit.close();
  });

  testWidgets('shows stale health factor without hiding value', (tester) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        defiRisk: const PortfolioDefiRisk(
          healthFactor: PortfolioHealthFactor(
            value: '1.80',
            status: PortfolioHealthFactorStatus.stale,
            statusLabel: null,
            protocol: 'aave-v3',
            protocolName: 'Aave V3',
            updatedAt: '2026-05-19T13:30:00.000Z',
            stale: true,
          ),
        ),
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('1.8'), findsWidgets);
    expect(find.textContaining('HF updated:'), findsOneWidget);
    expect(find.text('Stale data'), findsNothing);

    await cubit.close();
  });

  testWidgets('shows Russian summary localization', (tester) async {
    final cubit = await _loadedCubit(repository, _portfolio());

    await _pumpPortfolio(tester, _app(cubit, locale: const Locale('ru')));

    expect(find.text('Чистая стоимость'), findsWidgets);
    expect(find.text('Health Factor недоступен'), findsWidgets);

    await cubit.close();
  });

  testWidgets('shows missing price label', (tester) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: [
          _asset(
            symbol: 'USDC',
            priceUsd: null,
            valueUsd: null,
            priceStatus: PortfolioPriceStatus.missing,
          ),
        ],
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('Price unavailable'), findsWidgets);

    await cubit.close();
  });

  testWidgets('shows stale price label', (tester) async {
    final cubit = await _loadedCubit(
      repository,
      _portfolio(
        assets: [
          _asset(
            symbol: 'USDC',
            priceStatus: PortfolioPriceStatus.stale,
          ),
        ],
      ),
    );

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('Price stale'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('shows empty state', (tester) async {
    final cubit = await _loadedCubit(repository, _emptyPortfolio());

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('No portfolio assets yet'), findsOneWidget);
    expect(find.text('Pull to refresh'), findsOneWidget);

    await cubit.close();
  });

  group('overview card', () {
    testWidgets('shows portfolio totals for all protocols and wallets', (
      tester,
    ) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolio(
          summary: const PortfolioSummary(
            totalValueUsd: '300.00',
            walletsCount: 2,
            assetsCount: 2,
            networksCount: 1,
            updatedAt: '2026-05-19T13:30:00.000Z',
            netValueUsd: '299.00',
          ),
          totals: const PortfolioTotals(
            netValueUsd: '300.00',
            walletValueUsd: '110.00',
            suppliedValueUsd: '150.00',
            borrowedValueUsd: '40.00',
            grossValueUsd: '260.00',
          ),
          defiRisk: const PortfolioDefiRisk(
            healthFactor: PortfolioHealthFactor(
              value: '2.00',
              status: PortfolioHealthFactorStatus.safe,
              statusLabel: 'Safe',
              protocol: 'aave-v3',
              protocolName: 'Aave V3',
              updatedAt: '2026-05-19T13:30:00.000Z',
              stale: false,
            ),
          ),
          assets: const <PortfolioAsset>[],
          walletHoldings: [_holding()],
          protocolSummaries: const <PortfolioProtocolSummary>[
            PortfolioProtocolSummary(
              protocol: 'aave-v3',
              protocolName: 'Aave V3',
              category: 'lending',
              walletValueUsd: '0',
              suppliedValueUsd: '150.00',
              borrowedValueUsd: '40.00',
              grossValueUsd: '190.00',
              netValueUsd: '200.00',
              totalValueUsd: '200.00',
              healthFactor: '1.80',
              healthFactorStatus: PortfolioHealthFactorStatus.watch,
              healthFactorStatusLabel: 'Watch',
            ),
          ],
        ),
      );

      await _pumpPortfolio(tester, _app(cubit));

      expect(cubit.state.filteredView?.scopeNetValueUsd, '300.00');
      expect(find.text('\$300.00'), findsWidgets);
      expect(find.text('\$110.00'), findsWidgets);
      expect(find.text('Safe'), findsWidgets);

      await cubit.close();
    });

    testWidgets('hides health factor badge for wallet protocol filter', (
      tester,
    ) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolioWithWalletSummaries(),
      );

      await _pumpPortfolio(tester, _app(cubit));
      await tester.tap(find.byKey(const ValueKey<String>('portfolio-protocol-wallet')));
      await tester.pump();

      expect(find.text('Health Factor'), findsNothing);

      await cubit.close();
    });

    testWidgets('shows protocol scoped overview for Aave V3', (tester) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolioWithWalletSummaries(),
      );

      await _pumpPortfolio(tester, _app(cubit));
      await tester.tap(find.byKey(const ValueKey<String>('portfolio-protocol-aave-v3')));
      await tester.pump();

      expect(cubit.state.filteredView?.scopeNetValueUsd, '200.00');
      expect(find.text('\$200.00'), findsWidgets);
      expect(find.text('Watch'), findsWidgets);

      await cubit.close();
    });

    testWidgets('shows wallet scoped overview for selected wallet', (
      tester,
    ) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolioWithWalletSummaries(),
      );

      await _pumpPortfolio(tester, _app(cubit));
      await tester.tap(find.byKey(const ValueKey<String>('portfolio-wallet-1')));
      await tester.pump();

      expect(cubit.state.filteredView?.scopeNetValueUsd, '100.00');
      expect(find.text('\$100.00'), findsWidgets);
      expect(find.text('\$10.00'), findsWidgets);

      await cubit.close();
    });

    testWidgets('renders overview in dark theme', (tester) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolioWithWalletSummaries(),
      );

      await _pumpPortfolio(tester, _app(cubit, themeMode: ThemeMode.dark));

      expect(find.text('Net value'), findsWidgets);
      expect(find.textContaining('Last updated'), findsWidgets);

      await cubit.close();
    });
  });

  group('wallet selector', () {
    testWidgets('hides selector when no wallets are available', (tester) async {
      final cubit = await _loadedCubit(repository, _portfolio());

      await _pumpPortfolio(tester, _app(cubit));

      expect(find.text('All addresses'), findsNothing);
      expect(cubit.state.selectedWalletId, PortfolioFilter.allWallets);

      await cubit.close();
    });

    testWidgets('shows one wallet chip from derived nested wallets', (tester) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolio(
          assets: const <PortfolioAsset>[],
          walletHoldings: [
            _holding(
              wallets: const <PortfolioWalletBreakdown>[
                PortfolioWalletBreakdown(
                  walletId: 'wallet-1',
                  address: '0x1111111111111111111111111111111111111111',
                  label: 'Primary',
                  walletAddress: '0x1111111111111111111111111111111111111111',
                  walletLabel: 'Primary',
                  amount: '1.0',
                  balanceRaw: '0',
                  balance: '1.0',
                  valueUsd: '25.00',
                  syncedAt: null,
                  blockNumber: null,
                ),
              ],
            ),
          ],
        ),
      );

      await _pumpPortfolio(tester, _app(cubit));

      expect(find.text('All addresses'), findsOneWidget);
      expect(find.text('Primary'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('portfolio-wallet-wallet-1')),
          matching: find.text('\$25.00'),
        ),
        findsOneWidget,
      );

      await cubit.close();
    });

    testWidgets('shows multiple wallet chips from wallet summaries', (tester) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolioWithWalletSummaries(),
      );

      await _pumpPortfolio(tester, _app(cubit));

      expect(find.text('All addresses'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('portfolio-wallet-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('portfolio-wallet-2')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('portfolio-wallet-1')),
          matching: find.text('\$100.00'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('portfolio-wallet-2')),
          matching: find.text('\$200.00'),
        ),
        findsOneWidget,
      );

      await cubit.close();
    });

    testWidgets('shows shortened address when wallet label is missing', (tester) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolio(
          assets: const <PortfolioAsset>[],
          walletHoldings: [_holding(symbol: 'ETH')],
          wallets: const <PortfolioWalletSummary>[
            PortfolioWalletSummary(
              walletId: 'wallet-2',
              walletAddress: '0xabcdefabcdefabcdefabcdefabcdefabcdef01',
              walletLabel: null,
              walletValueUsd: '10.00',
              suppliedValueUsd: null,
              borrowedValueUsd: null,
              grossValueUsd: '10.00',
              netValueUsd: '10.00',
              healthFactor: null,
              healthFactorStatus: null,
              healthFactorStatusLabel: null,
            ),
          ],
        ),
      );

      await _pumpPortfolio(tester, _app(cubit));

      expect(
        find.byKey(const ValueKey<String>('portfolio-wallet-wallet-2')),
        findsOneWidget,
      );

      await cubit.close();
    });

    testWidgets('selects specific wallet without reloading', (tester) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolioWithWalletSummaries(),
      );

      await _pumpPortfolio(tester, _app(cubit));
      await tester.tap(find.byKey(const ValueKey<String>('portfolio-wallet-1')));
      await tester.pump();

      expect(cubit.state.selectedWalletId, '1');

      await cubit.close();
    });

    testWidgets('resets wallet filter to all wallets', (tester) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolioWithWalletSummaries(),
      );

      await _pumpPortfolio(tester, _app(cubit));
      await tester.tap(find.byKey(const ValueKey<String>('portfolio-wallet-1')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey<String>('portfolio-wallet-all')));
      await tester.pump();

      expect(cubit.state.selectedWalletId, PortfolioFilter.allWallets);

      await cubit.close();
    });

    testWidgets('combines aave protocol filter with wallet filter', (tester) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolioWithWalletSummaries(),
      );

      await _pumpPortfolio(tester, _app(cubit));
      await tester.tap(find.byKey(const ValueKey<String>('portfolio-protocol-aave-v3')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey<String>('portfolio-wallet-1')));
      await tester.pump();
      await tester.pump();

      expect(cubit.state.selectedProtocol, 'aave-v3');
      expect(cubit.state.selectedWalletId, '1');
      expect(cubit.state.filteredView!.hasVisibleDefiPositions, isTrue);
      expect(cubit.state.filteredView!.visibleSuppliedPositions, hasLength(1));
      expect(cubit.state.filteredView!.visibleBorrowedPositions, hasLength(1));
      expect(find.text('On-chain holdings'), findsNothing);

      await cubit.close();
    });

    testWidgets('filters wallet holdings for wallet protocol and selected wallet', (
      tester,
    ) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolioWithWalletSummaries(),
      );

      await _pumpPortfolio(tester, _app(cubit));
      await tester.tap(find.byKey(const ValueKey<String>('portfolio-protocol-wallet')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey<String>('portfolio-wallet-1')));
      await tester.pump();

      expect(cubit.state.selectedProtocol, PortfolioFilter.walletProtocol);
      expect(cubit.state.selectedWalletId, '1');
      expect(find.text('On-chain holdings'), findsOneWidget);
      expect(find.text('Main scoped USDC'), findsOneWidget);
      expect(find.text('Secondary scoped USDC'), findsNothing);

      await cubit.close();
    });

    testWidgets('renders wallet selector in dark theme on mobile width', (
      tester,
    ) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolioWithWalletSummaries(),
      );
      await _pumpPortfolio(
        tester,
        _app(cubit, themeMode: ThemeMode.dark),
        viewport: const Size(390, 844),
      );
      await tester.pumpAndSettle();

      expect(find.text('All addresses'), findsOneWidget);
      expect(find.text('Main'), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.horizontal,
        ),
        findsWidgets,
      );

      await cubit.close();
    });
  });

  group('protocol summary strip', () {
    testWidgets('shows cards from protocolSummaries', (tester) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolioWithProtocolSummaries(),
      );

      await _pumpPortfolio(tester, _app(cubit));

      expect(find.text('Protocols'), findsOneWidget);
      expect(find.text('All protocols'), findsOneWidget);
      expect(find.text('Address'), findsWidgets);
      expect(find.text('Aave V3'), findsWidgets);
      expect(find.text('\$300.00'), findsWidgets);
      expect(find.text('\$100.00'), findsWidgets);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('portfolio-protocol-aave-v3')),
          matching: find.text('\$200.00'),
        ),
        findsOneWidget,
      );
      expect(find.text('Watch'), findsWidgets);
      expect(cubit.state.selectedProtocol, PortfolioFilter.allProtocols);

      await cubit.close();
    });

    testWidgets('builds fallback strip when protocolSummaries are absent', (
      tester,
    ) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolio(
          assets: const <PortfolioAsset>[],
          walletHoldings: [_holding(symbol: 'ETH')],
          protocolPositions: PortfolioProtocolPositions(
            supplied: [_protocolPosition()],
          ),
        ),
      );

      await _pumpPortfolio(tester, _app(cubit));

      expect(find.text('All protocols'), findsOneWidget);
      expect(find.text('Address'), findsWidgets);
      expect(find.text('Aave V3'), findsWidgets);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('portfolio-protocol-aave-v3')),
          matching: find.text('Value unavailable'),
        ),
        findsOneWidget,
      );

      await cubit.close();
    });

    testWidgets('selects wallet protocol without reloading', (tester) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolioWithProtocolSummaries(),
      );

      await _pumpPortfolio(tester, _app(cubit));
      await tester.tap(find.byKey(const ValueKey<String>('portfolio-protocol-wallet')));
      await tester.pump();

      expect(cubit.state.selectedProtocol, PortfolioFilter.walletProtocol);
      expect(find.text('DeFi Positions'), findsNothing);
      expect(find.text('On-chain holdings'), findsOneWidget);

      await cubit.close();
    });

    testWidgets('selects aave protocol without reloading', (tester) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolioWithProtocolSummaries(),
      );

      await _pumpPortfolio(
        tester,
        _app(cubit),
        viewport: const Size(800, 600),
      );
      await tester.tap(find.byKey(const ValueKey<String>('portfolio-protocol-aave-v3')));
      await tester.pump();

      expect(cubit.state.selectedProtocol, 'aave-v3');
      expect(find.text('On-chain holdings'), findsNothing);
      expect(find.text('DeFi Positions'), findsOneWidget);

      await cubit.close();
    });

    testWidgets('renders strip in dark theme', (tester) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolioWithProtocolSummaries(),
      );

      await _pumpPortfolio(
        tester,
        _app(cubit, themeMode: ThemeMode.dark),
      );

      expect(find.text('Protocols'), findsOneWidget);
      expect(find.text('All protocols'), findsOneWidget);

      await cubit.close();
    });

    testWidgets('uses horizontal scroll on mobile width', (tester) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolioWithProtocolSummaries(),
      );
      await _pumpPortfolio(
        tester,
        _app(cubit),
        viewport: const Size(390, 844),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.horizontal,
        ),
        findsWidgets,
      );

      await cubit.close();
    });

    testWidgets('uses wrap layout on desktop width', (tester) async {
      final cubit = await _loadedCubit(
        repository,
        _portfolioWithProtocolSummaries(),
      );

      await _pumpPortfolio(
        tester,
        _app(cubit),
        viewport: const Size(1280, 800),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Wrap), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.horizontal,
        ),
        findsNothing,
      );

      await cubit.close();
    });
  });

  testWidgets('shows Export PDF button for loaded portfolio', (tester) async {
    final cubit = await _loadedCubit(repository, _portfolio());

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('Export PDF'), findsOneWidget);
    expect(find.byKey(PortfolioExportPdfButton.buttonKey), findsOneWidget);

    await cubit.close();
  });

  testWidgets('tapping Export PDF triggers repository export', (tester) async {
    final cubit = await _loadedCubit(repository, _portfolio());

    await _pumpPortfolio(tester, _app(cubit));
    await tester.tap(find.text('Export PDF'));
    await tester.pumpAndSettle();

    verify(() => repository.exportPortfolioPdf()).called(1);

    await cubit.close();
  });

  testWidgets('shows preparing label and disables export while exporting', (tester) async {
    when(() => repository.exportPortfolioPdf()).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return const PortfolioPdfExportResult(
        bytes: <int>[0x25, 0x50, 0x44, 0x46],
        filename: 'report.pdf',
        mimeType: kPortfolioPdfMimeType,
      );
    });
    final cubit = await _loadedCubit(repository, _portfolio());

    await _pumpPortfolio(tester, _app(cubit));
    await tester.tap(find.text('Export PDF'));
    await tester.pump();

    expect(find.text('Preparing PDF...'), findsOneWidget);
    final button = tester.widget<ButtonStyleButton>(
      find.byKey(PortfolioExportPdfButton.buttonKey),
    );
    expect(button.onPressed, isNull);

    await tester.pumpAndSettle();
    await cubit.close();
  });

  testWidgets('shows login required snackbar when PDF export is unauthenticated', (
    tester,
  ) async {
    when(() => repository.exportPortfolioPdf()).thenThrow(
      const ApiError(
        message: 'Session expired',
        code: 'UNAUTHENTICATED',
        statusCode: 401,
      ),
    );
    final cubit = await _loadedCubit(repository, _portfolio());

    await _pumpPortfolio(tester, _app(cubit));
    await tester.tap(find.text('Export PDF'));
    await tester.pumpAndSettle();

    expect(find.text('Account access required'), findsOneWidget);
    expect(find.text('Export PDF'), findsOneWidget);
    expect(find.text('PDF export failed'), findsNothing);

    await cubit.close();
  });

  testWidgets('shows localized snackbar when PDF export fails', (tester) async {
    when(() => repository.exportPortfolioPdf()).thenThrow(
      const ApiError(
        message: 'Server error',
        code: 'PORTFOLIO_PDF_EXPORT_FAILED',
        statusCode: 500,
      ),
    );
    final cubit = await _loadedCubit(repository, _portfolio());

    await _pumpPortfolio(tester, _app(cubit));
    await tester.tap(find.text('Export PDF'));
    await tester.pumpAndSettle();

    expect(find.text('PDF export failed'), findsOneWidget);
    expect(find.text('Server error'), findsNothing);

    await cubit.close();
  });

  testWidgets('shows success snackbar after PDF export', (tester) async {
    final cubit = await _loadedCubit(repository, _portfolio());

    await _pumpPortfolio(tester, _app(cubit));
    await tester.tap(find.text('Export PDF'));
    await tester.pumpAndSettle();

    expect(find.text('PDF report downloaded'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('shows compact tonal export button on narrow width', (tester) async {
    final cubit = await _loadedCubit(repository, _portfolio());

    await _pumpPortfolio(
      tester,
      _app(cubit),
      viewport: const Size(390, 800),
    );

    expect(find.byKey(PortfolioExportPdfButton.buttonKey), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('Export PDF'), findsNothing);
    expect(find.byIcon(Icons.download_rounded), findsOneWidget);

    await cubit.close();
  });

  testWidgets('compact export button stays visible while exporting', (tester) async {
    when(() => repository.exportPortfolioPdf()).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return const PortfolioPdfExportResult(
        bytes: <int>[0x25, 0x50, 0x44, 0x46],
        filename: 'report.pdf',
        mimeType: kPortfolioPdfMimeType,
      );
    });
    final cubit = await _loadedCubit(repository, _portfolio());

    await _pumpPortfolio(
      tester,
      _app(cubit),
      viewport: const Size(390, 800),
    );
    await tester.tap(find.text('PDF'));
    await tester.pump();

    expect(find.text('Preparing PDF...'), findsOneWidget);
    expect(find.byKey(PortfolioExportPdfButton.buttonKey), findsOneWidget);
    final button = tester.widget<ButtonStyleButton>(
      find.byKey(PortfolioExportPdfButton.buttonKey),
    );
    expect(button.onPressed, isNull);

    await tester.pumpAndSettle();
    await cubit.close();
  });

  testWidgets('shows error retry button', (tester) async {
    when(() => repository.getPortfolio()).thenThrow(
      const ApiError(
        message: 'Failed to load portfolio',
        code: 'PORTFOLIO_UNAVAILABLE',
        statusCode: 503,
      ),
    );
    final cubit = _portfolioCubit(repository);
    await cubit.load();

    await _pumpPortfolio(tester, _app(cubit));

    expect(find.text('Failed to load portfolio'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await cubit.close();
  });
}

Future<void> _pumpPortfolio(
  WidgetTester tester,
  Widget app, {
  Size viewport = const Size(900, 5000),
}) async {
  await tester.binding.setSurfaceSize(viewport);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(app);
}

Future<PortfolioCubit> _loadedCubit(
  MockPortfolioRepository repository,
  Portfolio portfolio,
) async {
  when(() => repository.getPortfolio()).thenAnswer((_) async => portfolio);
  final cubit = _portfolioCubit(repository);
  await cubit.load();
  return cubit;
}

PortfolioCubit _portfolioCubit(MockPortfolioRepository repository) {
  return PortfolioCubit(
    GetPortfolioUseCase(repository),
    ExportPortfolioPdfUseCase(repository),
    downloadFile: ({required bytes, required filename, required mimeType}) async {},
  );
}

Widget _app(
  PortfolioCubit cubit, {
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) {
  return MaterialApp(
    locale: locale,
    theme: ThemeData.light(useMaterial3: true),
    darkTheme: ThemeData.dark(useMaterial3: true),
    themeMode: themeMode,
    supportedLocales: const [Locale('en'), Locale('ru')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      body: BlocProvider<PortfolioCubit>.value(
        value: cubit,
        child: const PortfolioPage(),
      ),
    ),
  );
}

Portfolio _emptyPortfolio() {
  return const Portfolio(
    summary: PortfolioSummary(
      totalValueUsd: '0',
      walletsCount: 0,
      assetsCount: 0,
      networksCount: 0,
      updatedAt: '2026-05-19T13:30:00.000Z',
    ),
    networks: <PortfolioNetwork>[],
  );
}

Portfolio _portfolioWithWalletSummaries() {
  return _portfolio(
    assets: const <PortfolioAsset>[],
    wallets: const <PortfolioWalletSummary>[
      PortfolioWalletSummary(
        walletId: '1',
        walletAddress: '0xwallet1',
        walletLabel: 'Main',
        walletValueUsd: '10.00',
        suppliedValueUsd: '70.00',
        borrowedValueUsd: '20.00',
        grossValueUsd: '80.00',
        netValueUsd: '100.00',
        healthFactor: '1.50',
        healthFactorStatus: PortfolioHealthFactorStatus.safe,
        healthFactorStatusLabel: 'Safe',
      ),
      PortfolioWalletSummary(
        walletId: '2',
        walletAddress: '0xwallet2',
        walletLabel: 'Secondary',
        walletValueUsd: '100.00',
        suppliedValueUsd: '80.00',
        borrowedValueUsd: '20.00',
        grossValueUsd: '180.00',
        netValueUsd: '200.00',
        healthFactor: '2.10',
        healthFactorStatus: PortfolioHealthFactorStatus.safe,
        healthFactorStatusLabel: 'Safe',
      ),
    ],
    walletHoldings: [
      _holding(
        symbol: 'Main scoped USDC',
        wallets: const <PortfolioWalletBreakdown>[
          PortfolioWalletBreakdown(
            walletId: '1',
            address: '0xwallet1',
            label: 'Main',
            walletAddress: '0xwallet1',
            walletLabel: 'Main',
            amount: '10.0',
            balanceRaw: '10000000',
            balance: '10.0',
            valueUsd: '10.00',
            syncedAt: null,
            blockNumber: null,
          ),
        ],
      ),
      _holding(
        symbol: 'Secondary scoped USDC',
        wallets: const <PortfolioWalletBreakdown>[
          PortfolioWalletBreakdown(
            walletId: '2',
            address: '0xwallet2',
            label: 'Secondary',
            walletAddress: '0xwallet2',
            walletLabel: 'Secondary',
            amount: '100.0',
            balanceRaw: '100000000',
            balance: '100.0',
            valueUsd: '100.00',
            syncedAt: null,
            blockNumber: null,
          ),
        ],
      ),
    ],
    protocolPositions: PortfolioProtocolPositions(
      supplied: [
        _protocolPosition(
          valueUsd: '70.00',
          wallets: const <PortfolioWalletBreakdown>[
            PortfolioWalletBreakdown(
              walletId: '1',
              address: '0xwallet1',
              label: 'Main',
              walletAddress: '0xwallet1',
              walletLabel: 'Main',
              amount: '70.0',
              balanceRaw: '0',
              balance: '70.0',
              valueUsd: '70.00',
              syncedAt: null,
              blockNumber: null,
            ),
          ],
        ),
        _protocolPosition(
          valueUsd: '80.00',
          wallets: const <PortfolioWalletBreakdown>[
            PortfolioWalletBreakdown(
              walletId: '2',
              address: '0xwallet2',
              label: 'Secondary',
              walletAddress: '0xwallet2',
              walletLabel: 'Secondary',
              amount: '80.0',
              balanceRaw: '0',
              balance: '80.0',
              valueUsd: '80.00',
              syncedAt: null,
              blockNumber: null,
            ),
          ],
        ),
      ],
      borrowed: [
        _protocolPosition(
          positionSide: PortfolioPositionSide.borrowed,
          debtType: PortfolioDebtType.variable,
          valueUsd: '20.00',
          wallets: const <PortfolioWalletBreakdown>[
            PortfolioWalletBreakdown(
              walletId: '1',
              address: '0xwallet1',
              label: 'Main',
              walletAddress: '0xwallet1',
              walletLabel: 'Main',
              amount: '20.0',
              balanceRaw: '0',
              balance: '20.0',
              valueUsd: '20.00',
              syncedAt: null,
              blockNumber: null,
            ),
          ],
        ),
      ],
    ),
    summary: const PortfolioSummary(
      totalValueUsd: '300.00',
      walletsCount: 2,
      assetsCount: 2,
      networksCount: 1,
      updatedAt: '2026-05-19T13:30:00.000Z',
      netValueUsd: '300.00',
      walletValueUsd: '110.00',
    ),
    protocolSummaries: const <PortfolioProtocolSummary>[
      PortfolioProtocolSummary(
        protocol: 'aave-v3',
        protocolName: 'Aave V3',
        category: 'lending',
        walletValueUsd: '0',
        suppliedValueUsd: '150.00',
        borrowedValueUsd: '20.00',
        grossValueUsd: '170.00',
        netValueUsd: '200.00',
        totalValueUsd: '200.00',
        healthFactor: '1.80',
        healthFactorStatus: PortfolioHealthFactorStatus.watch,
        healthFactorStatusLabel: 'Watch',
      ),
    ],
  );
}

Portfolio _portfolioWithProtocolSummaries() {
  return _portfolio(
    assets: const <PortfolioAsset>[],
    walletHoldings: [_holding(symbol: 'USDC')],
    protocolPositions: PortfolioProtocolPositions(
      supplied: [_protocolPosition(valueUsd: '200.00')],
      borrowed: [
        _protocolPosition(
          positionSide: PortfolioPositionSide.borrowed,
          debtType: PortfolioDebtType.variable,
          valueUsd: '40.00',
        ),
      ],
    ),
    summary: const PortfolioSummary(
      totalValueUsd: '300.00',
      walletsCount: 1,
      assetsCount: 1,
      networksCount: 1,
      updatedAt: '2026-05-19T13:30:00.000Z',
      netValueUsd: '300.00',
      walletValueUsd: '100.00',
    ),
    protocolSummaries: const <PortfolioProtocolSummary>[
      PortfolioProtocolSummary(
        protocol: 'aave-v3',
        protocolName: 'Aave V3',
        category: 'lending',
        walletValueUsd: '0',
        suppliedValueUsd: '200.00',
        borrowedValueUsd: '40.00',
        grossValueUsd: '240.00',
        netValueUsd: '200.00',
        totalValueUsd: '200.00',
        healthFactor: '1.80',
        healthFactorStatus: PortfolioHealthFactorStatus.watch,
        healthFactorStatusLabel: 'Watch',
      ),
    ],
  );
}

Portfolio _portfolio({
  List<PortfolioAsset>? assets,
  List<PortfolioHolding> walletHoldings = const <PortfolioHolding>[],
  PortfolioProtocolPositions protocolPositions = const PortfolioProtocolPositions(),
  PortfolioSummary? summary,
  PortfolioTotals totals = const PortfolioTotals(),
  PortfolioDefiRisk defiRisk = const PortfolioDefiRisk(),
  List<PortfolioProtocolSummary> protocolSummaries = const <PortfolioProtocolSummary>[],
  List<PortfolioWalletSummary> wallets = const <PortfolioWalletSummary>[],
}) {
  return Portfolio(
    summary: summary ??
        const PortfolioSummary(
          totalValueUsd: '5240.75',
          walletsCount: 1,
          assetsCount: 1,
          networksCount: 1,
          updatedAt: '2026-05-19T13:30:00.000Z',
        ),
    totals: totals,
    defiRisk: defiRisk,
    walletHoldings: walletHoldings,
    protocolPositions: protocolPositions,
    protocolSummaries: protocolSummaries,
    wallets: wallets,
    networks: [
      PortfolioNetwork(
        networkId: 1,
        chainId: 1,
        name: 'Ethereum',
        nativeSymbol: 'ETH',
        totalValueUsd: '5240.75',
        assets: assets ?? [_asset(symbol: 'USDC')],
      ),
    ],
  );
}

PortfolioHolding _holding({
  String symbol = 'USDC',
  String networkName = 'Ethereum',
  String? amount = '250.0',
  String? priceUsd = '1.0000',
  String? valueUsd = '250.00',
  PortfolioPriceStatus priceStatus = PortfolioPriceStatus.ok,
  List<PortfolioWalletBreakdown> wallets = const <PortfolioWalletBreakdown>[],
}) {
  return PortfolioHolding(
    kind: 'wallet',
    networkId: 1,
    network: networkName.toLowerCase(),
    networkName: networkName,
    chainId: 1,
    assetId: '10',
    assetSymbol: symbol,
    assetAddress: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
    symbol: symbol,
    address: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
    amount: amount,
    balanceRaw: null,
    decimals: 6,
    priceUsd: priceUsd,
    valueUsd: valueUsd,
    priceStatus: priceStatus,
    wallets: wallets,
  );
}

PortfolioWalletBreakdown _walletBreakdownForHealth(PortfolioPositionHealth health) {
  return PortfolioWalletBreakdown(
    walletId: health.walletId,
    address: health.walletAddress,
    label: health.walletLabel,
    walletAddress: health.walletAddress,
    walletLabel: health.walletLabel,
    amount: '1',
    balanceRaw: '0',
    balance: '1',
    valueUsd: '1.00',
    syncedAt: null,
    blockNumber: null,
  );
}

PortfolioProtocolPositions _suppliedPositionsBackingHealth(
  List<PortfolioPositionHealth> healthRows,
) {
  return PortfolioProtocolPositions(
    supplied: healthRows
        .map(
          (health) => _protocolPosition(
            networkId: health.networkId,
            network: health.network,
            networkName: health.networkName,
            wallets: [_walletBreakdownForHealth(health)],
          ),
        )
        .toList(growable: false),
  );
}

PortfolioPositionHealth _positionHealth({
  String protocol = 'aave-v3',
  String protocolName = 'Aave V3',
  int networkId = 1,
  String network = 'ethereum',
  String networkName = 'Ethereum',
  String walletId = 'wallet-1',
  String walletAddress = '0x1234567890abcdef1234567890abcdef12345678',
  String? walletLabel,
  String? healthFactor = '2.1400',
  PortfolioHealthFactorStatus status = PortfolioHealthFactorStatus.safe,
  String? statusLabel,
  String? threshold,
  String? updatedAt = '2026-05-19T13:30:00.000Z',
  bool stale = false,
}) {
  return PortfolioPositionHealth(
    protocol: protocol,
    protocolName: protocolName,
    networkId: networkId,
    network: network,
    networkName: networkName,
    walletId: walletId,
    walletAddress: walletAddress,
    walletLabel: walletLabel,
    healthFactor: healthFactor,
    status: status,
    statusLabel: statusLabel,
    threshold: threshold,
    updatedAt: updatedAt,
    stale: stale,
  );
}

PortfolioProtocolPosition _protocolPosition({
  PortfolioPositionSide positionSide = PortfolioPositionSide.supplied,
  PortfolioDebtType? debtType,
  String? amount = '1',
  String? priceUsd = '1.00',
  String? valueUsd = '1.00',
  PortfolioPriceStatus priceStatus = PortfolioPriceStatus.ok,
  List<PortfolioWalletBreakdown> wallets = const <PortfolioWalletBreakdown>[],
  int networkId = 1,
  String network = 'ethereum',
  String networkName = 'Ethereum',
}) {
  return PortfolioProtocolPosition(
    kind: 'protocol',
    protocol: 'aave-v3',
    protocolName: 'Aave V3',
    networkId: networkId,
    network: network,
    networkName: networkName,
    chainId: 1,
    positionSide: positionSide,
    tokenRole: positionSide == PortfolioPositionSide.borrowed
        ? 'debt'
        : 'collateral',
    debtType: debtType,
    underlyingSymbol: 'USDC',
    underlyingAddress: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
    tokenSymbol: 'aEthUSDC',
    tokenAddress: '0x98c23e9d8f34fefb1b7bd6a91b7ff122f4e16f5c',
    amount: amount,
    balanceRaw: null,
    decimals: 6,
    priceUsd: priceUsd,
    valueUsd: valueUsd,
    priceStatus: priceStatus,
    wallets: wallets,
  );
}

PortfolioAsset _asset({
  required String symbol,
  String? priceUsd = '1.0001',
  String? valueUsd = '250.03',
  PortfolioPriceStatus priceStatus = PortfolioPriceStatus.ok,
}) {
  return PortfolioAsset(
    assetId: '10',
    symbol: symbol,
    address: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
    decimals: 6,
    balanceRaw: '250000000',
    balance: '250.0',
    priceUsd: priceUsd,
    valueUsd: valueUsd,
    priceStatus: priceStatus,
    priceCalculatedAt: '2026-05-19T13:20:00.000Z',
    balanceSyncedAt: '2026-05-19T13:21:00.000Z',
    wallets: const <PortfolioWalletBreakdown>[],
  );
}
