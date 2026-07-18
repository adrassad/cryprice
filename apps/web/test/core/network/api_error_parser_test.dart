import 'package:cryprice_frontend/core/network/api_error_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses object error format', () {
    final dioError = DioException(
      requestOptions: RequestOptions(path: '/users/me'),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/users/me'),
        statusCode: 400,
        data: <String, Object?>{
          'error': <String, Object?>{
            'code': 'INVALID_REQUEST',
            'message': 'Validation failed',
          },
        },
      ),
    );
    final parsed = parseApiError(dioError);
    expect(parsed.code, 'INVALID_REQUEST');
    expect(parsed.message, 'Validation failed');
    expect(parsed.statusCode, 400);
  });

  test('parses string error format', () {
    final dioError = DioException(
      requestOptions: RequestOptions(path: '/prices/current/onchain/eth'),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/prices/current/onchain/eth'),
        statusCode: 404,
        data: <String, Object?>{'error': 'Price not found'},
      ),
    );
    final parsed = parseApiError(dioError);
    expect(parsed.message, 'Price not found');
    expect(parsed.statusCode, 404);
  });

  test('parses normalized RATE_LIMITED object format', () {
    final dioError = DioException(
      requestOptions: RequestOptions(path: '/users/me'),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/users/me'),
        statusCode: 429,
        data: <String, Object?>{
          'error': <String, Object?>{
            'code': 'RATE_LIMITED',
            'message': 'Too many requests, please try again later.',
          },
        },
      ),
    );
    final parsed = parseApiError(dioError);
    expect(parsed.code, 'RATE_LIMITED');
    expect(parsed.statusCode, 429);
    expect(parsed.message, contains('Too many requests'));
  });

  test('parses legacy 429 string error format', () {
    final dioError = DioException(
      requestOptions: RequestOptions(path: '/users/me'),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/users/me'),
        statusCode: 429,
        data: <String, Object?>{
          'error': 'Too many requests, please try again later.',
        },
      ),
    );
    final parsed = parseApiError(dioError);
    expect(parsed.code, 'RATE_LIMITED');
    expect(parsed.statusCode, 429);
    expect(parsed.message, contains('Too many requests'));
  });
}
