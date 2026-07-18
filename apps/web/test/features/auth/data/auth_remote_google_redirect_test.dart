import 'package:cryprice_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cryprice_frontend/features/auth/domain/exceptions/auth_api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late AuthRemoteDataSource ds;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.test.dev'));
    adapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = adapter;
    ds = AuthRemoteDataSource(dio: dio, baseUrl: 'https://api.test.dev');
  });

  test('postAuthGoogle sends JSON idToken unchanged', () async {
    adapter.onPost(
      '/auth/google',
      (server) => server.reply(
        200,
        <String, dynamic>{
          'accessToken': 'at',
          'refreshToken': 'rt',
          'user': <String, dynamic>{'email': 'a@test.dev'},
        },
      ),
      data: <String, dynamic>{'idToken': 'jwt-token'},
    );

    final bundle = await ds.postAuthGoogle('jwt-token');
    expect(bundle.accessToken, 'at');
    expect(bundle.user.email, 'a@test.dev');
  });

  test('postAuthGoogleExchange sends code not tokens in URL', () async {
    adapter.onPost(
      '/auth/google/exchange',
      (server) => server.reply(
        200,
        <String, dynamic>{
          'accessToken': 'at2',
          'refreshToken': 'rt2',
          'user': <String, dynamic>{'email': 'b@test.dev'},
        },
      ),
      data: <String, dynamic>{'code': 'one-time-code'},
    );

    final bundle = await ds.postAuthGoogleExchange('one-time-code');
    expect(bundle.accessToken, 'at2');
    expect(bundle.user.email, 'b@test.dev');
  });

  test('postAuthGoogleExchange maps API errors', () async {
    adapter.onPost(
      '/auth/google/exchange',
      (server) => server.reply(
        401,
        <String, dynamic>{
          'error': <String, dynamic>{'code': 'INVALID_CODE', 'message': 'Expired'},
        },
      ),
      data: <String, dynamic>{'code': 'bad'},
    );

    expect(
      () => ds.postAuthGoogleExchange('bad'),
      throwsA(isA<AuthApiException>()),
    );
  });

  test('prepareGoogleRedirectStart sends return_to query param', () async {
    adapter.onGet(
      '/auth/google/redirect/start',
      (server) => server.reply(200, <String, dynamic>{'ok': true}),
      queryParameters: <String, dynamic>{'return_to': 'https://app.cryprice.dev'},
    );

    await ds.prepareGoogleRedirectStart('https://app.cryprice.dev');
  });

  test('prepareGoogleRedirectStart throws on 400', () async {
    adapter.onGet(
      '/auth/google/redirect/start',
      (server) => server.reply(
        400,
        <String, dynamic>{
          'error': <String, dynamic>{
            'code': 'INVALID_RETURN_TO',
            'message': 'Invalid return_to',
          },
        },
      ),
      queryParameters: <String, dynamic>{'return_to': 'https://app.cryprice.dev'},
    );

    expect(
      () => ds.prepareGoogleRedirectStart('https://app.cryprice.dev'),
      throwsA(isA<AuthApiException>()),
    );
  });
}
