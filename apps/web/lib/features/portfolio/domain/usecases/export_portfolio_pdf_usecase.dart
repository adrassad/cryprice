import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_pdf_export_result.dart';
import 'package:cryprice_frontend/features/portfolio/domain/repositories/portfolio_repository.dart';

class ExportPortfolioPdfUseCase {
  ExportPortfolioPdfUseCase(this._repository);

  final PortfolioRepository _repository;

  Future<PortfolioPdfExportResult> execute() => _repository.exportPortfolioPdf();
}
