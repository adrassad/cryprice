import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/repositories/portfolio_repository.dart';

class GetPortfolioUseCase {
  GetPortfolioUseCase(this._repository);

  final PortfolioRepository _repository;

  Future<Portfolio> execute() => _repository.getPortfolio();
}
