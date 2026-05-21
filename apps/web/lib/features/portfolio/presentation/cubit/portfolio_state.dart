import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filtered_view.dart';

enum PortfolioStatus {
  initial,
  loading,
  loaded,
  empty,
  refreshing,
  error,
  unauthenticated,
}

class PortfolioState {
  const PortfolioState({
    this.status = PortfolioStatus.initial,
    this.portfolio,
    this.errorMessage,
    this.errorCode,
    this.selectedProtocol = PortfolioFilter.allProtocols,
    this.selectedWalletId = PortfolioFilter.allWallets,
    this.isExportingPdf = false,
    this.exportPdfError,
    this.exportPdfSuccessTick = 0,
  });

  final PortfolioStatus status;
  final Portfolio? portfolio;
  final String? errorMessage;
  final String? errorCode;

  /// True while `exportPdf` is in flight (repository fetch + file download).
  final bool isExportingPdf;

  /// One-shot export failure message for UI snackbars (separate from [errorMessage]).
  final String? exportPdfError;

  /// Incremented on each successful export; UI listens for changes to show success once.
  final int exportPdfSuccessTick;

  /// Level-1 filter: [PortfolioFilter.allProtocols], [PortfolioFilter.walletProtocol],
  /// or a protocol id from the backend (e.g. `aave-v3`).
  final String selectedProtocol;

  /// Level-2 filter: [PortfolioFilter.allWallets] or a specific wallet id.
  final String selectedWalletId;

  PortfolioFilteredView? get filteredView {
    final portfolio = this.portfolio;
    if (portfolio == null) {
      return null;
    }
    return buildFilteredPortfolioView(
      portfolio,
      selectedProtocol,
      selectedWalletId,
    );
  }

  String? get mainNetValueUsd =>
      filteredView?.scopeNetValueUsd ?? portfolio?.mainNetValueUsd;

  bool get hasWalletHoldings => portfolio?.hasWalletHoldings ?? false;

  bool get hasSuppliedPositions => portfolio?.hasSuppliedPositions ?? false;

  bool get hasBorrowedPositions => portfolio?.hasBorrowedPositions ?? false;

  bool get hasDeFiPositions => portfolio?.hasDeFiPositions ?? false;

  bool get hasHealthFactor => portfolio?.hasHealthFactor ?? false;

  bool get hasVisibleWalletHoldings =>
      filteredView?.hasVisibleWalletHoldings ?? false;

  bool get hasVisibleSuppliedPositions =>
      (filteredView?.visibleSuppliedPositions.isNotEmpty ?? false);

  bool get hasVisibleBorrowedPositions =>
      (filteredView?.visibleBorrowedPositions.isNotEmpty ?? false);

  bool get hasVisibleDeFiPositions =>
      filteredView?.hasVisibleDefiPositions ?? false;

  PortfolioState copyWith({
    PortfolioStatus? status,
    Portfolio? portfolio,
    String? errorMessage,
    String? errorCode,
    String? selectedProtocol,
    String? selectedWalletId,
    bool? isExportingPdf,
    String? exportPdfError,
    int? exportPdfSuccessTick,
    bool clearPortfolio = false,
    bool clearError = false,
    bool clearExportPdfError = false,
  }) {
    return PortfolioState(
      status: status ?? this.status,
      portfolio: clearPortfolio ? null : (portfolio ?? this.portfolio),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      selectedProtocol: selectedProtocol ?? this.selectedProtocol,
      selectedWalletId: selectedWalletId ?? this.selectedWalletId,
      isExportingPdf: isExportingPdf ?? this.isExportingPdf,
      exportPdfError:
          clearExportPdfError ? null : (exportPdfError ?? this.exportPdfError),
      exportPdfSuccessTick: exportPdfSuccessTick ?? this.exportPdfSuccessTick,
    );
  }
}
