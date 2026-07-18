import 'package:cryprice_frontend/core/network/api_error_parser.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_request.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_markets_result.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_network.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_protocol.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/calculate_health_factor_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/get_health_factor_markets_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/get_health_factor_networks_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/get_health_factor_protocols_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HealthFactorCalculatorCubit extends Cubit<HealthFactorCalculatorState> {
  HealthFactorCalculatorCubit({
    required GetHealthFactorProtocolsUseCase getProtocolsUseCase,
    required GetHealthFactorNetworksUseCase getNetworksUseCase,
    required GetHealthFactorMarketsUseCase getMarketsUseCase,
    required CalculateHealthFactorUseCase calculateHealthFactorUseCase,
  })  : _getProtocolsUseCase = getProtocolsUseCase,
        _getNetworksUseCase = getNetworksUseCase,
        _getMarketsUseCase = getMarketsUseCase,
        _calculateHealthFactorUseCase = calculateHealthFactorUseCase,
        super(const HealthFactorCalculatorState());

  final GetHealthFactorProtocolsUseCase _getProtocolsUseCase;
  final GetHealthFactorNetworksUseCase _getNetworksUseCase;
  final GetHealthFactorMarketsUseCase _getMarketsUseCase;
  final CalculateHealthFactorUseCase _calculateHealthFactorUseCase;

  int _requestGen = 0;
  int _rowSeq = 0;

  bool _isStale(int requestId) => requestId != _requestGen;

  bool get _isMetadataInitializing =>
      state.status == HealthFactorCalculatorStatus.loadingProtocols ||
      state.status == HealthFactorCalculatorStatus.loadingNetworks ||
      state.status == HealthFactorCalculatorStatus.loadingMarkets;

  bool get _isMetadataLoaded =>
      state.protocols.isNotEmpty &&
      state.market != null &&
      (state.status == HealthFactorCalculatorStatus.ready ||
          state.status == HealthFactorCalculatorStatus.result ||
          state.status == HealthFactorCalculatorStatus.calculating);

  Future<void> initialize() async {
    if (_isMetadataInitializing || _isMetadataLoaded) {
      return;
    }

    final requestId = ++_requestGen;
    emit(
      state.copyWith(
        status: HealthFactorCalculatorStatus.loadingProtocols,
        clearError: true,
        clearResult: true,
        requestGeneration: requestId,
      ),
    );
    try {
      final protocols = await _getProtocolsUseCase.execute();
      if (_isStale(requestId)) {
        return;
      }

      final selectedProtocol = _pickDefaultProtocol(protocols);
      if (selectedProtocol == null) {
        emit(
          state.copyWith(
            status: HealthFactorCalculatorStatus.ready,
            protocols: protocols,
            requestGeneration: requestId,
            supplies: _defaultSupplyRows(),
            borrows: _defaultBorrowRows(),
          ),
        );
        return;
      }

      await _loadCatalogForProtocol(
        requestId: requestId,
        protocols: protocols,
        protocol: selectedProtocol,
      );
    } on Object catch (e) {
      if (_isStale(requestId)) {
        return;
      }
      _emitApiFailure(e, requestId: requestId);
    }
  }

  Future<void> selectProtocol(HealthFactorProtocol protocol) async {
    final requestId = ++_requestGen;
    emit(
      state.copyWith(
        status: HealthFactorCalculatorStatus.loadingNetworks,
        selectedProtocol: protocol,
        clearSelectedNetwork: true,
        clearMarket: true,
        networks: const <HealthFactorNetwork>[],
        supplies: const <HealthFactorSupplyDraft>[],
        borrows: const <HealthFactorBorrowDraft>[],
        clearResult: true,
        clearError: true,
        requestGeneration: requestId,
      ),
    );
    try {
      await _loadCatalogForProtocol(
        requestId: requestId,
        protocols: state.protocols,
        protocol: protocol,
      );
    } on Object catch (e) {
      if (_isStale(requestId)) {
        return;
      }
      _emitApiFailure(e, requestId: requestId);
    }
  }

  Future<void> selectNetwork(HealthFactorNetwork network) async {
    final requestId = ++_requestGen;
    final protocol = state.selectedProtocol;
    if (protocol == null) {
      return;
    }

    emit(
      state.copyWith(
        status: HealthFactorCalculatorStatus.loadingMarkets,
        selectedNetwork: network,
        clearMarket: true,
        supplies: const <HealthFactorSupplyDraft>[],
        borrows: const <HealthFactorBorrowDraft>[],
        clearResult: true,
        clearError: true,
        requestGeneration: requestId,
      ),
    );
    try {
      await _loadMarketsForSelection(
        requestId: requestId,
        protocol: protocol,
        network: network,
      );
    } on Object catch (e) {
      if (_isStale(requestId)) {
        return;
      }
      _emitApiFailure(e, requestId: requestId);
    }
  }

  Future<void> refreshMarkets() async {
    final requestId = ++_requestGen;
    final protocol = state.selectedProtocol;
    final network = state.selectedNetwork;
    if (protocol == null || network == null) {
      return;
    }

    emit(
      state.copyWith(
        status: HealthFactorCalculatorStatus.loadingMarkets,
        clearError: true,
        requestGeneration: requestId,
      ),
    );
    try {
      final market = await _getMarketsUseCase.execute(
        protocol: protocol.id,
        network: network.name,
        marketId: state.market?.marketId,
      );
      if (_isStale(requestId)) {
        return;
      }

      emit(
        state.copyWith(
          status: HealthFactorCalculatorStatus.ready,
          market: market,
          supplies: _sanitizeSupplyRows(state.supplies, market),
          borrows: _sanitizeBorrowRows(state.borrows, market),
          requestGeneration: requestId,
        ),
      );
    } on Object catch (e) {
      if (_isStale(requestId)) {
        return;
      }
      _emitApiFailure(e, requestId: requestId, preserveCatalog: true);
    }
  }

  void addSupplyRow() {
    emit(
      state.copyWith(
        supplies: [...state.supplies, _emptySupplyRow()],
        clearResult: true,
      ),
    );
  }

  void removeSupplyRow(String rowId) {
    emit(
      state.copyWith(
        supplies: state.supplies.where((row) => row.id != rowId).toList(growable: false),
        clearResult: true,
      ),
    );
  }

  void updateSupplyAsset(String rowId, String? assetId) {
    _updateSupplyRow(rowId, (row) => row.copyWith(
          assetId: assetId,
          clearAssetId: assetId == null,
          resetCustomPrice: true,
        ));
  }

  void updateSupplyAmount(String rowId, String amount) {
    _updateSupplyRow(rowId, (row) => row.copyWith(amount: amount));
  }

  void updateSupplyUseAsCollateral(String rowId, bool value) {
    _updateSupplyRow(rowId, (row) => row.copyWith(useAsCollateral: value));
  }

  void updateSupplyUseMarketPrice(String rowId, bool value) {
    _updateSupplyRow(
      rowId,
      (row) => row.copyWith(
        useMarketPrice: value,
        customPriceUsd: value ? '' : row.customPriceUsd,
      ),
    );
  }

  void updateSupplyCustomPrice(String rowId, String value) {
    _updateSupplyRow(rowId, (row) => row.copyWith(customPriceUsd: value));
  }

  void addBorrowRow() {
    emit(
      state.copyWith(
        borrows: [...state.borrows, _emptyBorrowRow()],
        clearResult: true,
      ),
    );
  }

  void removeBorrowRow(String rowId) {
    emit(
      state.copyWith(
        borrows: state.borrows.where((row) => row.id != rowId).toList(growable: false),
        clearResult: true,
      ),
    );
  }

  void updateBorrowAsset(String rowId, String? assetId) {
    _updateBorrowRow(rowId, (row) => row.copyWith(
          assetId: assetId,
          clearAssetId: assetId == null,
          resetCustomPrice: true,
        ));
  }

  void updateBorrowAmount(String rowId, String amount) {
    _updateBorrowRow(rowId, (row) => row.copyWith(amount: amount));
  }

  void updateBorrowUseMarketPrice(String rowId, bool value) {
    _updateBorrowRow(
      rowId,
      (row) => row.copyWith(
        useMarketPrice: value,
        customPriceUsd: value ? '' : row.customPriceUsd,
      ),
    );
  }

  void updateBorrowCustomPrice(String rowId, String value) {
    _updateBorrowRow(rowId, (row) => row.copyWith(customPriceUsd: value));
  }

  void clearResult() {
    if (state.result == null) {
      return;
    }
    emit(
      state.copyWith(
        clearResult: true,
        status: state.market != null
            ? HealthFactorCalculatorStatus.ready
            : state.status,
      ),
    );
  }

  void clearError() {
    if (state.errorCode == null && state.errorMessage == null) {
      return;
    }
    emit(
      state.copyWith(
        clearError: true,
        status: state.result != null
            ? HealthFactorCalculatorStatus.result
            : state.market != null
                ? HealthFactorCalculatorStatus.ready
                : state.status,
      ),
    );
  }

  Future<void> calculate() async {
    if (!state.canCalculate) {
      emit(
        state.copyWith(
          status: HealthFactorCalculatorStatus.error,
          errorCode: kHealthFactorCalculatorInvalidFormCode,
          errorMessage: 'At least one supply or borrow row with asset and amount is required.',
        ),
      );
      return;
    }

    if (_hasMissingCustomPrice(state)) {
      emit(
        state.copyWith(
          status: HealthFactorCalculatorStatus.error,
          errorCode: kHealthFactorCalculatorInvalidFormCustomPriceCode,
          errorMessage: 'Enter a custom price for each row using custom price mode.',
        ),
      );
      return;
    }

    final requestId = ++_requestGen;
    final network = state.selectedNetwork!;
    emit(
      state.copyWith(
        status: HealthFactorCalculatorStatus.calculating,
        clearError: true,
        requestGeneration: requestId,
      ),
    );

    try {
      final result = await _calculateHealthFactorUseCase.execute(
        request: _buildCalculateRequest(network),
      );
      if (_isStale(requestId)) {
        return;
      }
      emit(
        state.copyWith(
          status: HealthFactorCalculatorStatus.result,
          result: result,
          requestGeneration: requestId,
        ),
      );
    } on Object catch (e) {
      if (_isStale(requestId)) {
        return;
      }
      _emitApiFailure(e, requestId: requestId, preserveCatalog: true);
    }
  }

  Future<void> _loadCatalogForProtocol({
    required int requestId,
    required List<HealthFactorProtocol> protocols,
    required HealthFactorProtocol protocol,
  }) async {
    emit(
      state.copyWith(
        status: HealthFactorCalculatorStatus.loadingNetworks,
        protocols: protocols,
        selectedProtocol: protocol,
        requestGeneration: requestId,
      ),
    );

    final networks = await _getNetworksUseCase.execute(protocol: protocol.id);
    if (_isStale(requestId)) {
      return;
    }

    final selectedNetwork = networks.isNotEmpty ? networks.first : null;
    if (selectedNetwork == null) {
      emit(
        state.copyWith(
          status: HealthFactorCalculatorStatus.ready,
          protocols: protocols,
          selectedProtocol: protocol,
          networks: networks,
          supplies: _defaultSupplyRows(),
          borrows: _defaultBorrowRows(),
          requestGeneration: requestId,
        ),
      );
      return;
    }

    await _loadMarketsForSelection(
      requestId: requestId,
      protocol: protocol,
      network: selectedNetwork,
      protocols: protocols,
      networks: networks,
    );
  }

  Future<void> _loadMarketsForSelection({
    required int requestId,
    required HealthFactorProtocol protocol,
    required HealthFactorNetwork network,
    List<HealthFactorProtocol>? protocols,
    List<HealthFactorNetwork>? networks,
  }) async {
    emit(
      state.copyWith(
        status: HealthFactorCalculatorStatus.loadingMarkets,
        requestGeneration: requestId,
      ),
    );

    final market = await _getMarketsUseCase.execute(
      protocol: protocol.id,
      network: network.name,
    );
    if (_isStale(requestId)) {
      return;
    }

    final supplies = state.supplies.isEmpty ? _defaultSupplyRows() : state.supplies;
    final borrows = state.borrows.isEmpty ? _defaultBorrowRows() : state.borrows;

    emit(
      state.copyWith(
        status: HealthFactorCalculatorStatus.ready,
        protocols: protocols ?? state.protocols,
        selectedProtocol: protocol,
        networks: networks ?? state.networks,
        selectedNetwork: network,
        market: market,
        supplies: supplies,
        borrows: borrows,
        requestGeneration: requestId,
      ),
    );
  }

  HealthFactorCalculateRequest _buildCalculateRequest(HealthFactorNetwork network) {
    return HealthFactorCalculateRequest(
      protocol: state.selectedProtocol!.id,
      network: network.name,
      marketId: state.market?.marketId,
      supplies: state.validSupplyRows
          .map(
            (row) => HealthFactorSupplyInput(
              assetId: row.assetId!.trim(),
              amount: row.amount.trim(),
              useAsCollateral: row.useAsCollateral,
              customPriceUsd: _customPriceUsdForDraft(row.useMarketPrice, row.customPriceUsd),
            ),
          )
          .toList(growable: false),
      borrows: state.validBorrowRows
          .map(
            (row) => HealthFactorBorrowInput(
              assetId: row.assetId!.trim(),
              amount: row.amount.trim(),
              customPriceUsd: _customPriceUsdForDraft(row.useMarketPrice, row.customPriceUsd),
            ),
          )
          .toList(growable: false),
    );
  }

  static bool _hasMissingCustomPrice(HealthFactorCalculatorState state) {
    for (final row in state.validSupplyRows) {
      if (!row.useMarketPrice && row.customPriceUsd.trim().isEmpty) {
        return true;
      }
    }
    for (final row in state.validBorrowRows) {
      if (!row.useMarketPrice && row.customPriceUsd.trim().isEmpty) {
        return true;
      }
    }
    return false;
  }

  static String? _customPriceUsdForDraft(bool useMarketPrice, String customPriceUsd) {
    if (useMarketPrice) {
      return null;
    }
    final trimmed = customPriceUsd.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  HealthFactorProtocol? _pickDefaultProtocol(List<HealthFactorProtocol> protocols) {
    for (final protocol in protocols) {
      if (protocol.id == kHealthFactorAaveV3ProtocolId) {
        return protocol;
      }
    }
    return protocols.isEmpty ? null : protocols.first;
  }

  List<HealthFactorSupplyDraft> _defaultSupplyRows() => [_emptySupplyRow()];

  List<HealthFactorBorrowDraft> _defaultBorrowRows() => [_emptyBorrowRow()];

  HealthFactorSupplyDraft _emptySupplyRow() =>
      HealthFactorSupplyDraft(id: 'supply-${++_rowSeq}');

  HealthFactorBorrowDraft _emptyBorrowRow() =>
      HealthFactorBorrowDraft(id: 'borrow-${++_rowSeq}');

  void _updateSupplyRow(
    String rowId,
    HealthFactorSupplyDraft Function(HealthFactorSupplyDraft row) transform,
  ) {
    emit(
      state.copyWith(
        supplies: state.supplies
            .map((row) => row.id == rowId ? transform(row) : row)
            .toList(growable: false),
        clearResult: true,
      ),
    );
  }

  void _updateBorrowRow(
    String rowId,
    HealthFactorBorrowDraft Function(HealthFactorBorrowDraft row) transform,
  ) {
    emit(
      state.copyWith(
        borrows: state.borrows
            .map((row) => row.id == rowId ? transform(row) : row)
            .toList(growable: false),
        clearResult: true,
      ),
    );
  }

  List<HealthFactorSupplyDraft> _sanitizeSupplyRows(
    List<HealthFactorSupplyDraft> rows,
    HealthFactorMarketsResult market,
  ) {
    final validAssetIds = market.reserves.map((r) => r.asset.id).toSet();
    return rows
        .map((row) {
          final assetId = row.assetId?.trim();
          if (assetId == null ||
              assetId.isEmpty ||
              validAssetIds.contains(assetId)) {
            return row;
          }
          return row.copyWith(clearAssetId: true, resetCustomPrice: true);
        })
        .toList(growable: false);
  }

  List<HealthFactorBorrowDraft> _sanitizeBorrowRows(
    List<HealthFactorBorrowDraft> rows,
    HealthFactorMarketsResult market,
  ) {
    final validAssetIds = market.reserves.map((r) => r.asset.id).toSet();
    return rows
        .map((row) {
          final assetId = row.assetId?.trim();
          if (assetId == null ||
              assetId.isEmpty ||
              validAssetIds.contains(assetId)) {
            return row;
          }
          return row.copyWith(clearAssetId: true, resetCustomPrice: true);
        })
        .toList(growable: false);
  }

  void _emitApiFailure(
    Object error, {
    required int requestId,
    bool preserveCatalog = false,
  }) {
    final apiError = parseApiError(error);
    final isUnauthenticated =
        apiError.statusCode == 401 || apiError.code == 'UNAUTHENTICATED';

    if (isUnauthenticated) {
      emit(
        state.copyWith(
          status: HealthFactorCalculatorStatus.unauthenticated,
          errorCode: apiError.code ?? 'UNAUTHENTICATED',
          errorMessage: apiError.message,
          requestGeneration: requestId,
        ),
      );
      return;
    }

    final status = preserveCatalog && state.market != null
        ? HealthFactorCalculatorStatus.ready
        : HealthFactorCalculatorStatus.error;

    emit(
      state.copyWith(
        status: status,
        errorCode: apiError.code,
        errorMessage: apiError.message,
        requestGeneration: requestId,
      ),
    );
  }
}
