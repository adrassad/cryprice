import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:cryprice_frontend/features/portfolio/domain/usecases/get_portfolio_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

void main() {
  late MockPortfolioRepository repository;
  late GetPortfolioUseCase useCase;

  setUp(() {
    repository = MockPortfolioRepository();
    useCase = GetPortfolioUseCase(repository);
  });

  test('execute delegates to repository', () async {
    final portfolio = _portfolio();
    when(() => repository.getPortfolio()).thenAnswer((_) async => portfolio);

    final result = await useCase.execute();

    expect(result, same(portfolio));
    verify(() => repository.getPortfolio()).called(1);
  });

  test('execute propagates repository errors', () async {
    const error = ApiError(
      message: 'Portfolio unavailable',
      code: 'PORTFOLIO_UNAVAILABLE',
      statusCode: 503,
    );
    when(() => repository.getPortfolio()).thenAnswer((_) async {
      throw error;
    });

    expect(
      useCase.execute(),
      throwsA(
        isA<ApiError>()
            .having((e) => e.statusCode, 'statusCode', 503)
            .having((e) => e.code, 'code', 'PORTFOLIO_UNAVAILABLE')
            .having((e) => e.message, 'message', 'Portfolio unavailable'),
      ),
    );
    verify(() => repository.getPortfolio()).called(1);
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
