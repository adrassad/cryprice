import 'package:bloc_test/bloc_test.dart';
import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_pdf_export_result.dart';
import 'package:cryprice_frontend/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:cryprice_frontend/features/portfolio/domain/usecases/export_portfolio_pdf_usecase.dart';
import 'package:cryprice_frontend/features/portfolio/domain/usecases/get_portfolio_usecase.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/cubit/portfolio_file_downloader.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/cubit/portfolio_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

const _pdfExportResult = PortfolioPdfExportResult(
  bytes: <int>[0x25, 0x50, 0x44, 0x46],
  filename: 'cryprice-portfolio-report-2026-05-21.pdf',
  mimeType: kPortfolioPdfMimeType,
);

PortfolioCubit _buildCubit(
  PortfolioRepository repository, {
  PortfolioFileDownloader? downloadFile,
}) {
  return PortfolioCubit(
    GetPortfolioUseCase(repository),
    ExportPortfolioPdfUseCase(repository),
    downloadFile: downloadFile,
  );
}

void main() {
  late MockPortfolioRepository repository;

  setUp(() {
    repository = MockPortfolioRepository();
  });

  blocTest<PortfolioCubit, PortfolioState>(
    'load emits loading then loaded for legacy portfolio with networks',
    build: () {
      when(() => repository.getPortfolio()).thenAnswer((_) async => _portfolio());
      return _buildCubit(repository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<PortfolioState>()
          .having((state) => state.status, 'status', PortfolioStatus.loading)
          .having((state) => state.portfolio, 'portfolio', isNull),
      isA<PortfolioState>()
          .having((state) => state.status, 'status', PortfolioStatus.loaded)
          .having((state) => state.portfolio, 'portfolio', isNotNull),
    ],
    verify: (_) {
      verify(() => repository.getPortfolio()).called(1);
    },
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'load emits loaded for portfolio with wallet holdings only',
    build: () {
      when(() => repository.getPortfolio()).thenAnswer(
        (_) async => _portfolioWithWalletHoldingsOnly(),
      );
      return _buildCubit(repository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<PortfolioState>().having(
        (state) => state.status,
        'status',
        PortfolioStatus.loading,
      ),
      isA<PortfolioState>()
          .having((state) => state.status, 'status', PortfolioStatus.loaded)
          .having((state) => state.hasWalletHoldings, 'hasWalletHoldings', isTrue)
          .having((state) => state.mainNetValueUsd, 'mainNetValueUsd', '100.00'),
    ],
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'load emits loaded for portfolio with supplied positions only',
    build: () {
      when(() => repository.getPortfolio()).thenAnswer(
        (_) async => _portfolioWithSuppliedPositionsOnly(),
      );
      return _buildCubit(repository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<PortfolioState>().having(
        (state) => state.status,
        'status',
        PortfolioStatus.loading,
      ),
      isA<PortfolioState>()
          .having((state) => state.status, 'status', PortfolioStatus.loaded)
          .having((state) => state.hasSuppliedPositions, 'hasSuppliedPositions', isTrue)
          .having((state) => state.hasDeFiPositions, 'hasDeFiPositions', isTrue),
    ],
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'load emits loaded for portfolio with borrowed positions only',
    build: () {
      when(() => repository.getPortfolio()).thenAnswer(
        (_) async => _portfolioWithBorrowedPositionsOnly(),
      );
      return _buildCubit(repository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<PortfolioState>().having(
        (state) => state.status,
        'status',
        PortfolioStatus.loading,
      ),
      isA<PortfolioState>()
          .having((state) => state.status, 'status', PortfolioStatus.loaded)
          .having((state) => state.hasBorrowedPositions, 'hasBorrowedPositions', isTrue)
          .having((state) => state.hasDeFiPositions, 'hasDeFiPositions', isTrue),
    ],
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'load emits empty for portfolio without holdings positions or legacy assets',
    build: () {
      when(() => repository.getPortfolio()).thenAnswer((_) async => _emptyPortfolio());
      return _buildCubit(repository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<PortfolioState>().having(
        (state) => state.status,
        'status',
        PortfolioStatus.loading,
      ),
      isA<PortfolioState>()
          .having((state) => state.status, 'status', PortfolioStatus.empty)
          .having((state) => state.portfolio, 'portfolio', isNotNull),
    ],
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'load emits error for initial load failure',
    build: () {
      when(() => repository.getPortfolio()).thenThrow(
        const ApiError(
          message: 'Portfolio unavailable',
          code: 'PORTFOLIO_UNAVAILABLE',
          statusCode: 503,
        ),
      );
      return _buildCubit(repository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<PortfolioState>().having(
        (state) => state.status,
        'status',
        PortfolioStatus.loading,
      ),
      isA<PortfolioState>()
          .having((state) => state.status, 'status', PortfolioStatus.error)
          .having((state) => state.errorCode, 'errorCode', 'PORTFOLIO_UNAVAILABLE')
          .having((state) => state.portfolio, 'portfolio', isNull),
    ],
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'refresh preserves old portfolio while refreshing and replaces it on success',
    build: () {
      when(() => repository.getPortfolio()).thenAnswer(
        (_) async => _portfolio(totalValueUsd: '100.00', assetId: '1'),
      );
      return _buildCubit(repository);
    },
    seed: () => PortfolioState(
      status: PortfolioStatus.loaded,
      portfolio: _portfolio(totalValueUsd: '50.00', assetId: '0'),
    ),
    act: (cubit) => cubit.refresh(),
    expect: () => [
      isA<PortfolioState>()
          .having((state) => state.status, 'status', PortfolioStatus.refreshing)
          .having(
            (state) => state.portfolio?.summary.totalValueUsd,
            'old totalValueUsd',
            '50.00',
          ),
      isA<PortfolioState>()
          .having((state) => state.status, 'status', PortfolioStatus.loaded)
          .having(
            (state) => state.portfolio?.summary.totalValueUsd,
            'new totalValueUsd',
            '100.00',
          )
          .having(
            (state) => state.portfolio?.networks.single.assets.single.assetId,
            'new assetId',
            '1',
          ),
    ],
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'refresh failure preserves old portfolio and reports error',
    build: () {
      when(() => repository.getPortfolio()).thenThrow(
        const ApiError(
          message: 'Network error',
          code: 'NETWORK_ERROR',
          statusCode: 500,
        ),
      );
      return _buildCubit(repository);
    },
    seed: () => PortfolioState(
      status: PortfolioStatus.loaded,
      portfolio: _portfolio(totalValueUsd: '50.00', assetId: '0'),
    ),
    act: (cubit) => cubit.refresh(),
    expect: () => [
      isA<PortfolioState>().having(
        (state) => state.status,
        'status',
        PortfolioStatus.refreshing,
      ),
      isA<PortfolioState>()
          .having((state) => state.status, 'status', PortfolioStatus.loaded)
          .having(
            (state) => state.portfolio?.summary.totalValueUsd,
            'preserved totalValueUsd',
            '50.00',
          )
          .having((state) => state.errorCode, 'errorCode', 'NETWORK_ERROR'),
    ],
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'initial state uses default filters',
    build: () => _buildCubit(repository),
    verify: (cubit) {
      expect(cubit.state.selectedProtocol, PortfolioFilter.allProtocols);
      expect(cubit.state.selectedWalletId, PortfolioFilter.allWallets);
    },
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'selectProtocol and selectWallet update local state without reloading',
    build: () {
      when(() => repository.getPortfolio()).thenAnswer(
        (_) async => _portfolioWithFilters(),
      );
      return _buildCubit(repository);
    },
    seed: () => PortfolioState(
      status: PortfolioStatus.loaded,
      portfolio: _portfolioWithFilters(),
    ),
    act: (cubit) {
      cubit.selectProtocol(PortfolioFilter.walletProtocol);
      cubit.selectWallet('1');
      cubit.selectProtocol('aave-v3');
    },
    expect: () => [
      isA<PortfolioState>().having(
        (state) => state.selectedProtocol,
        'selectedProtocol',
        PortfolioFilter.walletProtocol,
      ),
      isA<PortfolioState>().having(
        (state) => state.selectedWalletId,
        'selectedWalletId',
        '1',
      ),
      isA<PortfolioState>().having(
        (state) => state.selectedProtocol,
        'selectedProtocol',
        'aave-v3',
      ),
    ],
    verify: (_) {
      verifyNever(() => repository.getPortfolio());
    },
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'resetFilters restores default filter state',
    build: () => _buildCubit(repository),
    seed: () => PortfolioState(
      status: PortfolioStatus.loaded,
      portfolio: _portfolioWithFilters(),
      selectedProtocol: 'aave-v3',
      selectedWalletId: '1',
    ),
    act: (cubit) => cubit.resetFilters(),
    expect: () => [
      isA<PortfolioState>()
          .having(
            (state) => state.selectedProtocol,
            'selectedProtocol',
            PortfolioFilter.allProtocols,
          )
          .having(
            (state) => state.selectedWalletId,
            'selectedWalletId',
            PortfolioFilter.allWallets,
          ),
    ],
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'protocol and wallet filter scopes defi positions with positive borrowed',
    build: () => _buildCubit(repository),
    seed: () => PortfolioState(
      status: PortfolioStatus.loaded,
      portfolio: _portfolioWithFilters(),
      selectedProtocol: 'aave-v3',
      selectedWalletId: '1',
    ),
    verify: (cubit) {
      final view = cubit.state.filteredView!;
      expect(view.visibleSuppliedPositions, hasLength(1));
      expect(view.visibleBorrowedPositions, hasLength(1));
      final borrowed = view.visibleBorrowedPositions.single.valueUsd;
      expect(borrowed, '20.00');
      expect(borrowed, isNot(startsWith('-')));
    },
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'loaded portfolio exposes filtered wallet holdings for wallet filter',
    build: () {
      when(() => repository.getPortfolio()).thenAnswer(
        (_) async => _portfolioWithFilters(),
      );
      return _buildCubit(repository);
    },
    seed: () => PortfolioState(
      status: PortfolioStatus.loaded,
      portfolio: _portfolioWithFilters(),
      selectedProtocol: PortfolioFilter.walletProtocol,
      selectedWalletId: '1',
    ),
    verify: (cubit) {
      final view = cubit.state.filteredView;
      expect(view, isNotNull);
      expect(view!.visibleWalletHoldings, hasLength(1));
      expect(view.visibleSuppliedPositions, isEmpty);
      expect(view.visibleWalletHoldings.single.wallets.single.walletId, '1');
    },
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'load resets filters and refresh preserves them',
    build: () {
      when(() => repository.getPortfolio()).thenAnswer(
        (_) async => _portfolioWithFilters(),
      );
      return _buildCubit(repository);
    },
    act: (cubit) async {
      await cubit.load();
      cubit.selectProtocol('aave-v3');
      cubit.selectWallet('2');
      await cubit.refresh();
    },
    expect: () => [
      isA<PortfolioState>().having(
        (state) => state.status,
        'status',
        PortfolioStatus.loading,
      ),
      isA<PortfolioState>()
          .having(
            (state) => state.selectedProtocol,
            'selectedProtocol after load',
            PortfolioFilter.allProtocols,
          )
          .having(
            (state) => state.selectedWalletId,
            'selectedWalletId after load',
            PortfolioFilter.allWallets,
          ),
      isA<PortfolioState>().having(
        (state) => state.selectedProtocol,
        'selectedProtocol after select',
        'aave-v3',
      ),
      isA<PortfolioState>().having(
        (state) => state.selectedWalletId,
        'selectedWalletId after select',
        '2',
      ),
      isA<PortfolioState>().having(
        (state) => state.status,
        'status',
        PortfolioStatus.refreshing,
      ),
      isA<PortfolioState>()
          .having(
            (state) => state.selectedProtocol,
            'selectedProtocol after refresh',
            'aave-v3',
          )
          .having(
            (state) => state.selectedWalletId,
            'selectedWalletId after refresh',
            '2',
          ),
    ],
    verify: (_) {
      verify(() => repository.getPortfolio()).called(2);
    },
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'load emits unauthenticated for auth failure',
    build: () {
      when(() => repository.getPortfolio()).thenThrow(
        const ApiError(
          message: 'Session expired',
          code: 'UNAUTHENTICATED',
          statusCode: 401,
        ),
      );
      return _buildCubit(repository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<PortfolioState>().having(
        (state) => state.status,
        'status',
        PortfolioStatus.loading,
      ),
      isA<PortfolioState>()
          .having((state) => state.status, 'status', PortfolioStatus.unauthenticated)
          .having((state) => state.errorCode, 'errorCode', 'UNAUTHENTICATED'),
    ],
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'exportPdf sets isExportingPdf then clears it on success',
    build: () {
      when(() => repository.exportPortfolioPdf()).thenAnswer((_) async => _pdfExportResult);
      return _buildCubit(
        repository,
        downloadFile: ({required bytes, required filename, required mimeType}) async {},
      );
    },
    seed: () => PortfolioState(
      status: PortfolioStatus.loaded,
      portfolio: _portfolio(),
    ),
    act: (cubit) => cubit.exportPdf(),
    expect: () => [
      isA<PortfolioState>().having((s) => s.isExportingPdf, 'isExportingPdf', isTrue),
      isA<PortfolioState>()
          .having((s) => s.isExportingPdf, 'isExportingPdf', isFalse)
          .having((s) => s.exportPdfSuccessTick, 'exportPdfSuccessTick', 1),
    ],
    verify: (_) {
      verify(() => repository.exportPortfolioPdf()).called(1);
      verifyNever(() => repository.getPortfolio());
    },
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'exportPdf invokes download helper with repository result',
    build: () {
      when(() => repository.exportPortfolioPdf()).thenAnswer((_) async => _pdfExportResult);
      return _buildCubit(
        repository,
        downloadFile: ({required bytes, required filename, required mimeType}) async {
          expect(bytes, _pdfExportResult.bytes);
          expect(filename, _pdfExportResult.filename);
          expect(mimeType, kPortfolioPdfMimeType);
        },
      );
    },
    seed: () => PortfolioState(
      status: PortfolioStatus.loaded,
      portfolio: _portfolio(),
    ),
    act: (cubit) => cubit.exportPdf(),
    expect: () => [
      isA<PortfolioState>().having((s) => s.isExportingPdf, 'isExportingPdf', isTrue),
      isA<PortfolioState>().having((s) => s.isExportingPdf, 'isExportingPdf', isFalse),
    ],
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'exportPdf failure keeps portfolio and loaded status',
    build: () {
      when(() => repository.exportPortfolioPdf()).thenThrow(
        const ApiError(
          message: 'PDF export failed',
          code: 'PORTFOLIO_PDF_EXPORT_FAILED',
          statusCode: 500,
        ),
      );
      return _buildCubit(repository);
    },
    seed: () => PortfolioState(
      status: PortfolioStatus.loaded,
      portfolio: _portfolio(totalValueUsd: '99.00'),
    ),
    act: (cubit) => cubit.exportPdf(),
    expect: () => [
      isA<PortfolioState>().having((s) => s.isExportingPdf, 'isExportingPdf', isTrue),
      isA<PortfolioState>()
          .having((s) => s.isExportingPdf, 'isExportingPdf', isFalse)
          .having((s) => s.status, 'status', PortfolioStatus.loaded)
          .having(
            (s) => s.portfolio?.summary.totalValueUsd,
            'totalValueUsd',
            '99.00',
          )
          .having((s) => s.exportPdfError, 'exportPdfError', 'PDF export failed')
          .having((s) => s.errorMessage, 'errorMessage', isNull),
    ],
    verify: (_) {
      verifyNever(() => repository.getPortfolio());
    },
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'exportPdf unauthenticated keeps loaded view and portfolio data',
    build: () {
      when(() => repository.exportPortfolioPdf()).thenThrow(
        const ApiError(
          message: 'Session expired',
          code: 'UNAUTHENTICATED',
          statusCode: 401,
        ),
      );
      return _buildCubit(repository);
    },
    seed: () => PortfolioState(
      status: PortfolioStatus.loaded,
      portfolio: _portfolio(),
    ),
    act: (cubit) => cubit.exportPdf(),
    expect: () => [
      isA<PortfolioState>().having((s) => s.isExportingPdf, 'isExportingPdf', isTrue),
      isA<PortfolioState>()
          .having((s) => s.status, 'status', PortfolioStatus.loaded)
          .having((s) => s.portfolio, 'portfolio', isNotNull)
          .having((s) => s.exportPdfError, 'exportPdfError', 'Session expired')
          .having((s) => s.errorCode, 'errorCode', 'UNAUTHENTICATED'),
    ],
  );

  blocTest<PortfolioCubit, PortfolioState>(
    'exportPdf ignores repeated click while exporting',
    build: () {
      when(() => repository.exportPortfolioPdf()).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return _pdfExportResult;
      });
      return _buildCubit(
        repository,
        downloadFile: ({required bytes, required filename, required mimeType}) async {},
      );
    },
    seed: () => PortfolioState(
      status: PortfolioStatus.loaded,
      portfolio: _portfolio(),
    ),
    act: (cubit) async {
      final first = cubit.exportPdf();
      await cubit.exportPdf();
      await first;
    },
    verify: (_) {
      verify(() => repository.exportPortfolioPdf()).called(1);
    },
  );
}

PortfolioSummary _summary({
  String totalValueUsd = '0',
  String? netValueUsd,
}) {
  return PortfolioSummary(
    totalValueUsd: totalValueUsd,
    walletsCount: 0,
    assetsCount: 0,
    networksCount: 0,
    updatedAt: '2026-05-19T13:30:00.000Z',
    netValueUsd: netValueUsd,
  );
}

Portfolio _emptyPortfolio() {
  return Portfolio(
    summary: _summary(),
    networks: <PortfolioNetwork>[],
  );
}

Portfolio _portfolioWithWalletHoldingsOnly() {
  return Portfolio(
    summary: _summary(
      totalValueUsd: '110.00',
      netValueUsd: '100.00',
    ),
    networks: const <PortfolioNetwork>[],
    walletHoldings: const <PortfolioHolding>[
      PortfolioHolding(
        kind: 'wallet',
        networkId: 1,
        network: 'ethereum',
        networkName: 'Ethereum',
        chainId: 1,
        assetId: '10',
        assetSymbol: 'USDC',
        assetAddress: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
        symbol: 'USDC',
        address: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
        amount: '100.0',
        balanceRaw: '100000000',
        decimals: 6,
        priceUsd: '1.00',
        valueUsd: '100.00',
        priceStatus: PortfolioPriceStatus.ok,
      ),
    ],
  );
}

Portfolio _portfolioWithSuppliedPositionsOnly() {
  return Portfolio(
    summary: _summary(totalValueUsd: '50.00'),
    networks: const <PortfolioNetwork>[],
    protocolPositions: PortfolioProtocolPositions(
      supplied: <PortfolioProtocolPosition>[
        _protocolPosition(
          positionSide: PortfolioPositionSide.supplied,
          tokenRole: 'collateral',
          valueUsd: '50.00',
        ),
      ],
    ),
  );
}

Portfolio _portfolioWithBorrowedPositionsOnly() {
  return Portfolio(
    summary: _summary(totalValueUsd: '25.00'),
    networks: const <PortfolioNetwork>[],
    protocolPositions: PortfolioProtocolPositions(
      borrowed: <PortfolioProtocolPosition>[
        _protocolPosition(
          positionSide: PortfolioPositionSide.borrowed,
          tokenRole: 'debt',
          debtType: PortfolioDebtType.variable,
          valueUsd: '25.00',
        ),
      ],
    ),
  );
}

Portfolio _portfolio({
  String totalValueUsd = '5240.75',
  String assetId = '10',
}) {
  return Portfolio(
    summary: PortfolioSummary(
      totalValueUsd: totalValueUsd,
      walletsCount: 1,
      assetsCount: 1,
      networksCount: 1,
      updatedAt: '2026-05-19T13:30:00.000Z',
    ),
    networks: <PortfolioNetwork>[
      PortfolioNetwork(
        networkId: 1,
        chainId: 1,
        name: 'Ethereum',
        nativeSymbol: 'ETH',
        totalValueUsd: totalValueUsd,
        assets: <PortfolioAsset>[
          PortfolioAsset(
            assetId: assetId,
            symbol: 'USDC',
            address: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
            decimals: 6,
            balanceRaw: '250000000',
            balance: '250.0',
            priceUsd: '1.0001',
            valueUsd: totalValueUsd,
            priceStatus: PortfolioPriceStatus.ok,
            priceCalculatedAt: '2026-05-19T13:20:00.000Z',
            balanceSyncedAt: '2026-05-19T13:21:00.000Z',
            wallets: const <PortfolioWalletBreakdown>[],
          ),
        ],
      ),
    ],
  );
}

Portfolio _portfolioWithFilters() {
  return Portfolio(
    summary: PortfolioSummary(
      totalValueUsd: '100.00',
      walletsCount: 1,
      assetsCount: 1,
      networksCount: 1,
      updatedAt: '2026-05-19T13:30:00.000Z',
      netValueUsd: '100.00',
    ),
    networks: const <PortfolioNetwork>[],
    wallets: const <PortfolioWalletSummary>[
      PortfolioWalletSummary(
        walletId: '1',
        walletAddress: '0xwallet1',
        walletLabel: 'Main',
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
    walletHoldings: const <PortfolioHolding>[
      PortfolioHolding(
        kind: 'wallet',
        networkId: 1,
        network: 'ethereum',
        networkName: 'Ethereum',
        chainId: 1,
        assetId: '10',
        assetSymbol: 'USDC',
        assetAddress: '0xusdc',
        symbol: 'USDC',
        address: '0xusdc',
        amount: '10.0',
        balanceRaw: '10000000',
        decimals: 6,
        priceUsd: '1.00',
        valueUsd: '10.00',
        priceStatus: PortfolioPriceStatus.ok,
        wallets: <PortfolioWalletBreakdown>[
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
    ],
    protocolPositions: PortfolioProtocolPositions(
      supplied: <PortfolioProtocolPosition>[
        _protocolPosition(
          positionSide: PortfolioPositionSide.supplied,
          tokenRole: 'collateral',
          valueUsd: '50.00',
          wallets: const <PortfolioWalletBreakdown>[
            PortfolioWalletBreakdown(
              walletId: '1',
              address: '0xwallet1',
              label: 'Main',
              walletAddress: '0xwallet1',
              walletLabel: 'Main',
              amount: '50.0',
              balanceRaw: '0',
              balance: '50.0',
              valueUsd: '50.00',
              syncedAt: null,
              blockNumber: null,
            ),
          ],
        ),
      ],
      borrowed: <PortfolioProtocolPosition>[
        _protocolPosition(
          positionSide: PortfolioPositionSide.borrowed,
          tokenRole: 'debt',
          valueUsd: '20.00',
          debtType: PortfolioDebtType.variable,
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
  );
}

PortfolioProtocolPosition _protocolPosition({
  required PortfolioPositionSide positionSide,
  required String tokenRole,
  required String valueUsd,
  PortfolioDebtType? debtType,
  List<PortfolioWalletBreakdown> wallets = const <PortfolioWalletBreakdown>[],
}) {
  return PortfolioProtocolPosition(
    kind: 'protocol',
    protocol: 'aave-v3',
    protocolName: 'Aave V3',
    networkId: 1,
    network: 'ethereum',
    networkName: 'Ethereum',
    chainId: 1,
    positionSide: positionSide,
    tokenRole: tokenRole,
    debtType: debtType,
    underlyingSymbol: 'USDC',
    underlyingAddress: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
    tokenSymbol: 'aEthUSDC',
    tokenAddress: '0x98c23e9d8f34fefb1b7bd6a91b7ff122f4e16f5c',
    amount: valueUsd,
    balanceRaw: null,
    decimals: 6,
    priceUsd: '1.00',
    valueUsd: valueUsd,
    priceStatus: PortfolioPriceStatus.ok,
    wallets: wallets,
  );
}
