import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cryprice_frontend/features/auth/data/local/auth_token_store.dart';
import 'package:cryprice_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:cryprice_frontend/features/auth/domain/services/auth_session_service.dart';
import 'package:cryprice_frontend/features/portfolio/data/datasources/portfolio_remote_datasource.dart';
import 'package:cryprice_frontend/features/portfolio/data/utils/portfolio_pdf_export_filename.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_pdf_export_result.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('getPortfolio parses successful response', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: _portfolioResponse(),
            ),
          );
        },
      ),
    );
    final dataSource = PortfolioRemoteDataSource(
      sessionService: _StaticSessionService('access-token'),
      dio: dio,
    );

    final portfolio = await dataSource.getPortfolio();

    expect(portfolio.summary.totalValueUsd, '5240.75');
    expect(portfolio.networks.single.assets.single.symbol, 'USDC');
    expect(
      portfolio.networks.single.assets.single.priceStatus,
      PortfolioPriceStatus.ok,
    );
  });

  test('getPortfolio sends bearer Authorization header', () async {
    RequestOptions? capturedOptions;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedOptions = options;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: _portfolioResponse(),
            ),
          );
        },
      ),
    );
    final dataSource = PortfolioRemoteDataSource(
      sessionService: _StaticSessionService('access-token'),
      dio: dio,
    );

    await dataSource.getPortfolio();

    expect(capturedOptions?.path, '/portfolio');
    expect(capturedOptions?.headers['Authorization'], 'Bearer access-token');
  });

  test('getPortfolio follows AuthSessionService refresh behavior after 401', () async {
    final requestedAuthHeaders = <Object?>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestedAuthHeaders.add(options.headers['Authorization']);
          if (options.headers['Authorization'] == 'Bearer expired-token') {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 401,
                  data: const <String, Object?>{
                    'error': <String, Object?>{
                      'message': 'Unauthorized',
                      'code': 'UNAUTHENTICATED',
                    },
                  },
                ),
              ),
            );
            return;
          }
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: _portfolioResponse(),
            ),
          );
        },
      ),
    );
    final tokenStore = _FakeTokenStore(
      access: 'expired-token',
      refresh: 'refresh-token',
    );
    final authRemote = _FakeAuthRemoteDataSource(
      refreshedAccess: 'fresh-token',
      refreshedRefresh: 'next-refresh-token',
    );
    final sessionService = AuthSessionService(
      tokenStore: tokenStore,
      authRemoteDataSource: authRemote,
    );
    final dataSource = PortfolioRemoteDataSource(
      sessionService: sessionService,
      dio: dio,
    );

    final portfolio = await dataSource.getPortfolio();

    expect(portfolio.summary.totalValueUsd, '5240.75');
    expect(requestedAuthHeaders, ['Bearer expired-token', 'Bearer fresh-token']);
    expect(authRemote.refreshCalls, 1);
    expect(tokenStore.access, 'fresh-token');
    expect(tokenStore.refresh, 'next-refresh-token');
  });

  test('getPortfolio maps API errors with parseApiError', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response<dynamic>(
                requestOptions: options,
                statusCode: 500,
                data: const <String, Object?>{
                  'error': <String, Object?>{
                    'message': 'Portfolio temporarily unavailable',
                    'code': 'PORTFOLIO_UNAVAILABLE',
                  },
                },
              ),
            ),
          );
        },
      ),
    );
    final dataSource = PortfolioRemoteDataSource(
      sessionService: _StaticSessionService('access-token'),
      dio: dio,
    );

    final call = dataSource.getPortfolio();

    await expectLater(
      call,
      throwsA(
        isA<ApiError>()
            .having((error) => error.statusCode, 'statusCode', 500)
            .having((error) => error.code, 'code', 'PORTFOLIO_UNAVAILABLE')
            .having(
              (error) => error.message,
              'message',
              'Portfolio temporarily unavailable',
            ),
      ),
    );
  });

  group('exportPortfolioPdf', () {
    final pdfBytes = <int>[0x25, 0x50, 0x44, 0x46];

    test('calls correct endpoint with ResponseType.bytes and bearer auth', () async {
      RequestOptions? capturedOptions;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedOptions = options;
            final headers = Headers();
            headers.set(
              'content-disposition',
              'attachment; filename="cryprice-portfolio-report-2026-05-21.pdf"',
            );
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: pdfBytes,
                headers: headers,
              ),
            );
          },
        ),
      );
      final dataSource = PortfolioRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );

      final result = await dataSource.exportPortfolioPdf();

      expect(capturedOptions?.path, '/portfolio/export/pdf');
      expect(capturedOptions?.responseType, ResponseType.bytes);
      expect(capturedOptions?.headers['Authorization'], 'Bearer access-token');
      expect(capturedOptions?.headers['Accept'], kPortfolioPdfMimeType);
      expect(result.filename, 'cryprice-portfolio-report-2026-05-21.pdf');
      expect(result.bytes, pdfBytes);
      expect(result.mimeType, kPortfolioPdfMimeType);
    });

    test('uses fallback filename when Content-Disposition is missing', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: pdfBytes,
              ),
            );
          },
        ),
      );
      final dataSource = PortfolioRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );

      final result = await dataSource.exportPortfolioPdf();

      expect(
        result.filename,
        portfolioPdfExportFallbackFilename(reference: DateTime.now().toUtc()),
      );
    });

    test('throws ApiError for empty PDF bytes', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <int>[],
              ),
            );
          },
        ),
      );
      final dataSource = PortfolioRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );

      await expectLater(
        dataSource.exportPortfolioPdf(),
        throwsA(
          isA<ApiError>().having((e) => e.code, 'code', 'EMPTY_PDF_RESPONSE'),
        ),
      );
    });

    test('follows AuthSessionService refresh behavior after 401', () async {
      final requestedAuthHeaders = <Object?>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedAuthHeaders.add(options.headers['Authorization']);
            if (options.headers['Authorization'] == 'Bearer expired-token') {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response<dynamic>(
                    requestOptions: options,
                    statusCode: 401,
                    data: const <String, Object?>{
                      'error': <String, Object?>{
                        'message': 'Unauthorized',
                        'code': 'UNAUTHENTICATED',
                      },
                    },
                  ),
                ),
              );
              return;
            }
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: pdfBytes,
              ),
            );
          },
        ),
      );
      final tokenStore = _FakeTokenStore(
        access: 'expired-token',
        refresh: 'refresh-token',
      );
      final authRemote = _FakeAuthRemoteDataSource(
        refreshedAccess: 'fresh-token',
        refreshedRefresh: 'next-refresh-token',
      );
      final sessionService = AuthSessionService(
        tokenStore: tokenStore,
        authRemoteDataSource: authRemote,
      );
      final dataSource = PortfolioRemoteDataSource(
        sessionService: sessionService,
        dio: dio,
      );

      final result = await dataSource.exportPortfolioPdf();

      expect(result.bytes, pdfBytes);
      expect(requestedAuthHeaders, ['Bearer expired-token', 'Bearer fresh-token']);
      expect(authRemote.refreshCalls, 1);
    });

    test('maps API errors with parseApiError', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 500,
                  data: const <String, Object?>{
                    'error': <String, Object?>{
                      'message': 'PDF export failed',
                      'code': 'PORTFOLIO_PDF_EXPORT_FAILED',
                    },
                  },
                ),
              ),
            );
          },
        ),
      );
      final dataSource = PortfolioRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );

      await expectLater(
        dataSource.exportPortfolioPdf(),
        throwsA(
          isA<ApiError>()
              .having((error) => error.statusCode, 'statusCode', 500)
              .having((error) => error.code, 'code', 'PORTFOLIO_PDF_EXPORT_FAILED')
              .having((error) => error.message, 'message', 'PDF export failed'),
        ),
      );
    });
  });
}

class _StaticSessionService implements AuthSessionService {
  _StaticSessionService(this.accessToken);

  final String accessToken;

  @override
  Future<T> authorized<T>(Future<T> Function(String accessToken) request) {
    return request(accessToken);
  }
}

class _FakeTokenStore extends AuthTokenStore {
  _FakeTokenStore({
    required this.access,
    required this.refresh,
  });

  String? access;
  String? refresh;
  String? refreshExpiresAt;
  var cleared = false;

  @override
  Future<StoredSessionTokens> read() async {
    return StoredSessionTokens(
      access: access,
      refresh: refresh,
      refreshExpiresAt: refreshExpiresAt,
    );
  }

  @override
  Future<void> write({
    required String access,
    required String refresh,
    String? refreshExpiresAt,
  }) async {
    this.access = access;
    this.refresh = refresh;
    this.refreshExpiresAt = refreshExpiresAt;
  }

  @override
  Future<void> clear() async {
    cleared = true;
    access = null;
    refresh = null;
    refreshExpiresAt = null;
  }
}

class _FakeAuthRemoteDataSource extends AuthRemoteDataSource {
  _FakeAuthRemoteDataSource({
    required this.refreshedAccess,
    required this.refreshedRefresh,
  }) : super(dio: Dio(BaseOptions(baseUrl: 'https://auth.test')));

  final String refreshedAccess;
  final String refreshedRefresh;
  var refreshCalls = 0;

  @override
  Future<AuthTokenBundle> postRefresh(String refreshToken) async {
    refreshCalls += 1;
    return AuthTokenBundle(
      accessToken: refreshedAccess,
      refreshToken: refreshedRefresh,
      user: const AuthUser(),
    );
  }
}

Map<String, Object?> _portfolioResponse() {
  return {
    'summary': {
      'totalValueUsd': '5240.75',
      'walletsCount': 3,
      'assetsCount': 5,
      'networksCount': 2,
      'updatedAt': '2026-05-19T13:30:00.000Z',
    },
    'networks': [
      {
        'networkId': 1,
        'chainId': 1,
        'name': 'Ethereum',
        'nativeSymbol': 'ETH',
        'totalValueUsd': '4150.59',
        'assets': [
          {
            'assetId': 10,
            'symbol': 'USDC',
            'address': '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
            'decimals': 6,
            'balanceRaw': '250000000',
            'balance': '250.0',
            'priceUsd': '1.0001',
            'valueUsd': '250.03',
            'priceStatus': 'ok',
            'priceCalculatedAt': '2026-05-19T13:20:00.000Z',
            'balanceSyncedAt': '2026-05-19T13:21:00.000Z',
            'wallets': [
              {
                'walletId': 1,
                'address': '0x111...',
                'label': 'Main wallet',
                'balanceRaw': '100000000',
                'balance': '100.0',
                'valueUsd': '100.01',
                'syncedAt': '2026-05-19T13:21:00.000Z',
                'blockNumber': 22500111,
              },
            ],
          },
        ],
      },
    ],
  };
}
