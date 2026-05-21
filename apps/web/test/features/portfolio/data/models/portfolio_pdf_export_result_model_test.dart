import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/portfolio/data/models/portfolio_pdf_export_result_model.dart';
import 'package:cryprice_frontend/features/portfolio/data/utils/portfolio_pdf_export_filename.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_pdf_export_result.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final reference = DateTime.utc(2026, 5, 21);
  final pdfBytes = <int>[0x25, 0x50, 0x44, 0x46];

  test('fromResponse parses quoted Content-Disposition filename', () {
    final headers = Headers();
    headers.set(
      'content-disposition',
      'attachment; filename="cryprice-portfolio-report-2026-05-21.pdf"',
    );

    final model = PortfolioPdfExportResultModel.fromResponse(
      Response<dynamic>(
        requestOptions: RequestOptions(path: '/portfolio/export/pdf'),
        statusCode: 200,
        data: pdfBytes,
        headers: headers,
      ),
      filenameFallbackReference: reference,
    );

    expect(model.filename, 'cryprice-portfolio-report-2026-05-21.pdf');
    expect(model.bytes, pdfBytes);
    expect(model.mimeType, kPortfolioPdfMimeType);
  });

  test('fromResponse uses fallback filename when header is missing', () {
    final model = PortfolioPdfExportResultModel.fromResponse(
      Response<dynamic>(
        requestOptions: RequestOptions(path: '/portfolio/export/pdf'),
        statusCode: 200,
        data: pdfBytes,
      ),
      filenameFallbackReference: reference,
    );

    expect(
      model.filename,
      portfolioPdfExportFallbackFilename(reference: reference),
    );
  });

  test('fromResponse throws ApiError for empty bytes', () {
    expect(
      () => PortfolioPdfExportResultModel.fromResponse(
        Response<dynamic>(
          requestOptions: RequestOptions(path: '/portfolio/export/pdf'),
          statusCode: 200,
          data: <int>[],
        ),
      ),
      throwsA(
        isA<ApiError>().having((e) => e.code, 'code', 'EMPTY_PDF_RESPONSE'),
      ),
    );
  });

  test('fromResponse throws ApiError for invalid response type', () {
    expect(
      () => PortfolioPdfExportResultModel.fromResponse(
        Response<dynamic>(
          requestOptions: RequestOptions(path: '/portfolio/export/pdf'),
          statusCode: 200,
          data: const <String, Object?>{'error': 'not pdf'},
        ),
      ),
      throwsA(
        isA<ApiError>().having((e) => e.code, 'code', 'INVALID_PDF_RESPONSE'),
      ),
    );
  });

  test('toEntity maps fields', () {
    final model = PortfolioPdfExportResultModel(
      bytes: pdfBytes,
      filename: 'report.pdf',
    );

    final entity = model.toEntity();

    expect(entity.bytes, pdfBytes);
    expect(entity.filename, 'report.pdf');
    expect(entity.mimeType, kPortfolioPdfMimeType);
  });
}
