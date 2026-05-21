import 'package:cryprice_frontend/core/network/api_error_parser.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/domain/usecases/export_portfolio_pdf_usecase.dart';
import 'package:cryprice_frontend/features/portfolio/domain/usecases/get_portfolio_usecase.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/cubit/portfolio_file_downloader.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/cubit/portfolio_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PortfolioCubit extends Cubit<PortfolioState> {
  PortfolioCubit(
    this._getPortfolioUseCase,
    this._exportPortfolioPdfUseCase, {
    PortfolioFileDownloader? downloadFile,
  })  : _downloadFile = downloadFile ?? downloadPortfolioFile,
        super(const PortfolioState());

  final GetPortfolioUseCase _getPortfolioUseCase;
  final ExportPortfolioPdfUseCase _exportPortfolioPdfUseCase;
  final PortfolioFileDownloader _downloadFile;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: PortfolioStatus.loading,
        clearPortfolio: true,
        clearError: true,
      ),
    );
    await _fetchPortfolio(preserveExisting: false);
  }

  Future<void> refresh() async {
    final hasExistingPortfolio = state.portfolio != null;
    emit(
      state.copyWith(
        status: hasExistingPortfolio ? PortfolioStatus.refreshing : PortfolioStatus.loading,
        clearError: true,
      ),
    );
    await _fetchPortfolio(preserveExisting: hasExistingPortfolio);
  }

  /// Fetches server-generated PDF and triggers a platform file download.
  Future<void> exportPdf() async {
    if (state.isExportingPdf) {
      return;
    }

    emit(
      state.copyWith(
        isExportingPdf: true,
        clearExportPdfError: true,
      ),
    );

    try {
      final result = await _exportPortfolioPdfUseCase.execute();
      await _downloadFile(
        bytes: result.bytes,
        filename: result.filename,
        mimeType: result.mimeType,
      );
      emit(
        state.copyWith(
          isExportingPdf: false,
          exportPdfSuccessTick: state.exportPdfSuccessTick + 1,
        ),
      );
    } on Object catch (e) {
      _emitExportError(e);
    }
  }

  Future<void> _fetchPortfolio({required bool preserveExisting}) async {
    try {
      final portfolio = await _getPortfolioUseCase.execute();
      emit(
        state.copyWith(
          status: _statusForPortfolio(portfolio),
          portfolio: portfolio,
          selectedProtocol: preserveExisting
              ? state.selectedProtocol
              : PortfolioFilter.allProtocols,
          selectedWalletId: preserveExisting
              ? state.selectedWalletId
              : PortfolioFilter.allWallets,
          clearError: true,
        ),
      );
    } on Object catch (e) {
      _emitError(e, preserveExisting: preserveExisting);
    }
  }

  PortfolioStatus _statusForPortfolio(Portfolio portfolio) {
    return portfolio.isEmpty ? PortfolioStatus.empty : PortfolioStatus.loaded;
  }

  void selectProtocol(String? protocol) {
    emit(
      state.copyWith(
        selectedProtocol: PortfolioFilter.normalizeProtocol(protocol),
      ),
    );
  }

  void selectWallet(String? walletId) {
    emit(
      state.copyWith(
        selectedWalletId: PortfolioFilter.normalizeWalletId(walletId),
      ),
    );
  }

  void resetFilters() {
    emit(
      state.copyWith(
        selectedProtocol: PortfolioFilter.allProtocols,
        selectedWalletId: PortfolioFilter.allWallets,
      ),
    );
  }

  void _emitExportError(Object e) {
    final apiError = parseApiError(e);
    final isUnauthenticated =
        apiError.statusCode == 401 || apiError.code == 'UNAUTHENTICATED';
    final hasExistingPortfolio = state.portfolio != null;

    emit(
      state.copyWith(
        isExportingPdf: false,
        exportPdfError: apiError.message,
        status: hasExistingPortfolio
            ? _statusForPortfolio(state.portfolio!)
            : isUnauthenticated
                ? PortfolioStatus.unauthenticated
                : state.status,
        errorCode: isUnauthenticated ? apiError.code : state.errorCode,
      ),
    );
  }

  void _emitError(Object e, {required bool preserveExisting}) {
    final apiError = parseApiError(e);
    final hasExistingPortfolio = preserveExisting && state.portfolio != null;
    final status = apiError.statusCode == 401 || apiError.code == 'UNAUTHENTICATED'
        ? PortfolioStatus.unauthenticated
        : hasExistingPortfolio
            ? _statusForPortfolio(state.portfolio!)
            : PortfolioStatus.error;
    emit(
      state.copyWith(
        status: status,
        errorMessage: apiError.message,
        errorCode: apiError.code,
        clearPortfolio: !hasExistingPortfolio,
      ),
    );
  }
}
