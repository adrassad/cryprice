import 'dart:convert';

import 'package:cryprice_frontend/core/config/cryprice_backend_config.dart';
import 'package:cryprice_frontend/core/network/api_error_parser.dart';
import 'package:cryprice_frontend/features/auth/domain/services/auth_session_service.dart';
import 'package:cryprice_frontend/features/portfolio/data/models/portfolio_pdf_export_result_model.dart';
import 'package:cryprice_frontend/features/portfolio/data/models/portfolio_response_model.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_pdf_export_result.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

class PortfolioRemoteDataSource {
  PortfolioRemoteDataSource({
    required AuthSessionService sessionService,
    Dio? dio,
    String? baseUrl,
  })  : _sessionService = sessionService,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? crypriceBackendBaseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: const <String, Object?>{
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            );

  final AuthSessionService _sessionService;
  final Dio _dio;

  Future<Portfolio> getPortfolio() async {
    try {
      final response = await _sessionService.authorized(
        (token) => _dio.get<dynamic>(
          '/portfolio',
          options: Options(headers: <String, Object?>{'Authorization': 'Bearer $token'}),
        ),
      );
      final data = response.data;
      _logPortfolioApiResponse(response);
      _logTokenIconApiSample(data);

      final Portfolio portfolio;
      if (data is Map<String, Object?>) {
        portfolio = PortfolioResponseModel.fromJson(data).portfolio;
      } else if (data is Map) {
        portfolio = PortfolioResponseModel.fromJson(data.cast<String, Object?>()).portfolio;
      } else {
        portfolio = const Portfolio(
        summary: PortfolioSummary(
          totalValueUsd: '',
          walletsCount: 0,
          assetsCount: 0,
          networksCount: 0,
          updatedAt: '',
        ),
        networks: <PortfolioNetwork>[],
        );
      }

      _logParsedPortfolio(portfolio);
      return portfolio;
    } on Object catch (e) {
      if (kDebugMode) {
        debugPrint('[Portfolio][API] GET /portfolio failed: $e');
      }
      throw parseApiError(e);
    }
  }

  /// `GET /portfolio/export/pdf` — server-generated PDF bytes.
  Future<PortfolioPdfExportResultModel> exportPortfolioPdf() async {
    try {
      final response = await _sessionService.authorized(
        (token) => _dio.get<dynamic>(
          '/portfolio/export/pdf',
          options: Options(
            responseType: ResponseType.bytes,
            headers: <String, Object?>{
              'Authorization': 'Bearer $token',
              'Accept': kPortfolioPdfMimeType,
            },
          ),
        ),
      );
      return PortfolioPdfExportResultModel.fromResponse(response);
    } on Object catch (e) {
      if (kDebugMode) {
        debugPrint('[Portfolio][API] GET /portfolio/export/pdf failed: $e');
      }
      throw parseApiError(e);
    }
  }
}

void _logPortfolioApiResponse(Response<dynamic> response) {
  if (!kDebugMode) {
    return;
  }

  final data = response.data;
  debugPrint(
    '[Portfolio][API] GET /portfolio status=${response.statusCode} '
    'type=${data.runtimeType}',
  );
  debugPrint('[Portfolio][API] raw body: ${_previewPortfolioJson(data)}');

  if (data is Map) {
    final summaries = data['protocolSummaries'];
    if (summaries != null) {
      debugPrint('[Portfolio][API] protocolSummaries: $summaries');
    }
  }
}

void _logParsedPortfolio(Portfolio portfolio) {
  if (!kDebugMode) {
    return;
  }

  final summary = portfolio.summary;
  final protocolIds = portfolio.protocolSummaries
      .map((entry) => entry.protocol)
      .join(', ');
  debugPrint(
    '[Portfolio][API] parsed summary: net=${summary.netValueUsd} '
    'wallet=${summary.walletValueUsd} supplied=${summary.suppliedValueUsd} '
    'borrowed=${summary.borrowedValueUsd} updatedAt=${summary.updatedAt}',
  );
  debugPrint(
    '[Portfolio][API] parsed counts: protocols=${portfolio.protocolSummaries.length} '
    'wallets=${portfolio.wallets.length} holdings=${portfolio.walletHoldings.length} '
    'networks=${portfolio.networks.length}',
  );
  debugPrint('[Portfolio][API] parsed protocolIds: $protocolIds');
}

void _logTokenIconApiSample(Object? data) {
  if (!kDebugMode || data is! Map) {
    return;
  }

  final holdings = data['walletHoldings'];
  if (holdings is List && holdings.isNotEmpty) {
    final first = holdings.first;
    if (first is Map) {
      final holding = first.cast<String, Object?>();
      final symbol =
          holding['symbol'] ?? holding['assetSymbol'] ?? '?';
      debugPrint(
        '[TokenIcon][API] holding=$symbol '
        'rawLogoUrl=${holding['logo_url']} '
        'rawLogoURLCamel=${holding['logoUrl']}',
      );
    }
  }

  final protocolPositions = data['protocolPositions'];
  if (protocolPositions is! Map) {
    return;
  }

  for (final side in const ['supplied', 'borrowed']) {
    final rows = protocolPositions[side];
    if (rows is! List || rows.isEmpty) {
      continue;
    }
    final first = rows.first;
    if (first is! Map) {
      continue;
    }
    final position = first.cast<String, Object?>();
    final symbol =
        position['underlyingSymbol'] ??
        position['tokenSymbol'] ??
        '?';
    debugPrint(
      '[TokenIcon][API] defi=$symbol side=$side '
      'rawLogoUrl=${position['logo_url']} '
      'rawLogoURLCamel=${position['logoUrl']}',
    );
    break;
  }
}

String _previewPortfolioJson(Object? value, {int maxChars = 12000}) {
  if (value == null) {
    return '(null)';
  }
  try {
    final encoded = const JsonEncoder.withIndent('  ').convert(value);
    if (encoded.length <= maxChars) {
      return encoded;
    }
    return '${encoded.substring(0, maxChars)}… [truncated, ${encoded.length} chars total]';
  } on Object catch (e) {
    return '${value.toString()} (json encode failed: $e)';
  }
}
