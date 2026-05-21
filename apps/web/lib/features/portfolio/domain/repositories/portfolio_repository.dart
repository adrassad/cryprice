import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_pdf_export_result.dart';

abstract class PortfolioRepository {
  Future<Portfolio> getPortfolio();

  Future<PortfolioPdfExportResult> exportPortfolioPdf();
}
