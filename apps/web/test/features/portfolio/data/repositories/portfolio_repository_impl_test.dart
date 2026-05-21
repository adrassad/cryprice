import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/portfolio/data/datasources/portfolio_remote_datasource.dart';
import 'package:cryprice_frontend/features/portfolio/data/models/portfolio_pdf_export_result_model.dart';
import 'package:cryprice_frontend/features/portfolio/data/repositories/portfolio_repository_impl.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_pdf_export_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPortfolioRemoteDataSource extends Mock
    implements PortfolioRemoteDataSource {}

void main() {
  late MockPortfolioRemoteDataSource remote;
  late PortfolioRepositoryImpl repository;

  setUp(() {
    remote = MockPortfolioRemoteDataSource();
    repository = PortfolioRepositoryImpl(remote: remote);
  });

  test('getPortfolio delegates to remote data source', () async {
    final portfolio = _portfolio();
    when(() => remote.getPortfolio()).thenAnswer((_) async => portfolio);

    final result = await repository.getPortfolio();

    expect(result, same(portfolio));
    verify(() => remote.getPortfolio()).called(1);
  });

  test('getPortfolio propagates remote errors', () async {
    const error = ApiError(
      message: 'Portfolio unavailable',
      code: 'PORTFOLIO_UNAVAILABLE',
      statusCode: 503,
    );
    when(() => remote.getPortfolio()).thenAnswer((_) async {
      throw error;
    });

    expect(
      repository.getPortfolio(),
      throwsA(
        isA<ApiError>()
            .having((e) => e.statusCode, 'statusCode', 503)
            .having((e) => e.code, 'code', 'PORTFOLIO_UNAVAILABLE')
            .having((e) => e.message, 'message', 'Portfolio unavailable'),
      ),
    );
    verify(() => remote.getPortfolio()).called(1);
  });

  test('exportPortfolioPdf delegates to remote and maps to entity', () async {
    const model = PortfolioPdfExportResultModel(
      bytes: <int>[0x25, 0x50, 0x44, 0x46],
      filename: 'cryprice-portfolio-report-2026-05-21.pdf',
    );
    when(() => remote.exportPortfolioPdf()).thenAnswer((_) async => model);

    final result = await repository.exportPortfolioPdf();

    expect(result.bytes, model.bytes);
    expect(result.filename, model.filename);
    expect(result.mimeType, kPortfolioPdfMimeType);
    verify(() => remote.exportPortfolioPdf()).called(1);
  });

  test('exportPortfolioPdf propagates remote errors', () async {
    const error = ApiError(
      message: 'PDF export failed',
      code: 'PORTFOLIO_PDF_EXPORT_FAILED',
      statusCode: 500,
    );
    when(() => remote.exportPortfolioPdf()).thenAnswer((_) async {
      throw error;
    });

    expect(
      repository.exportPortfolioPdf(),
      throwsA(
        isA<ApiError>()
            .having((e) => e.statusCode, 'statusCode', 500)
            .having((e) => e.code, 'code', 'PORTFOLIO_PDF_EXPORT_FAILED')
            .having((e) => e.message, 'message', 'PDF export failed'),
      ),
    );
    verify(() => remote.exportPortfolioPdf()).called(1);
  });
}

Portfolio _portfolio() {
  return const Portfolio(
    summary: PortfolioSummary(
      totalValueUsd: '5240.75',
      walletsCount: 3,
      assetsCount: 5,
      networksCount: 2,
      updatedAt: '2026-05-19T13:30:00.000Z',
    ),
    networks: <PortfolioNetwork>[],
  );
}
