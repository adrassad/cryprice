import 'package:cryprice_frontend/features/portfolio/data/datasources/portfolio_remote_datasource.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_pdf_export_result.dart';
import 'package:cryprice_frontend/features/portfolio/domain/repositories/portfolio_repository.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  PortfolioRepositoryImpl({required PortfolioRemoteDataSource remote})
      : _remote = remote;

  final PortfolioRemoteDataSource _remote;

  @override
  Future<Portfolio> getPortfolio() => _remote.getPortfolio();

  @override
  Future<PortfolioPdfExportResult> exportPortfolioPdf() async {
    final model = await _remote.exportPortfolioPdf();
    return model.toEntity();
  }
}
