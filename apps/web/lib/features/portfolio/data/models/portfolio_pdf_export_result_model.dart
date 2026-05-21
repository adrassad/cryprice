import 'dart:typed_data';

import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/portfolio/data/utils/content_disposition_filename_parser.dart';
import 'package:cryprice_frontend/features/portfolio/data/utils/portfolio_pdf_export_filename.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_pdf_export_result.dart';
import 'package:dio/dio.dart';

/// Backend PDF export payload from `GET /portfolio/export/pdf`.
class PortfolioPdfExportResultModel {
  const PortfolioPdfExportResultModel({
    required this.bytes,
    required this.filename,
    this.mimeType = kPortfolioPdfMimeType,
  });

  final List<int> bytes;
  final String filename;
  final String mimeType;

  PortfolioPdfExportResult toEntity() {
    return PortfolioPdfExportResult(
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
    );
  }

  static PortfolioPdfExportResultModel fromResponse(
    Response<dynamic> response, {
    DateTime? filenameFallbackReference,
  }) {
    final bytes = _readResponseBytes(response.data);
    if (bytes.isEmpty) {
      throw const ApiError(
        message: 'Portfolio PDF export returned an empty file.',
        code: 'EMPTY_PDF_RESPONSE',
        statusCode: 200,
      );
    }

    final disposition = response.headers.value('content-disposition');
    final filename = parseFilenameFromContentDisposition(disposition) ??
        portfolioPdfExportFallbackFilename(reference: filenameFallbackReference);

    return PortfolioPdfExportResultModel(
      bytes: bytes,
      filename: filename,
    );
  }
}

List<int> _readResponseBytes(Object? data) {
  if (data == null) {
    throw const ApiError(
      message: 'Portfolio PDF export returned no data.',
      code: 'INVALID_PDF_RESPONSE',
    );
  }
  if (data is Uint8List) {
    return data;
  }
  if (data is List<int>) {
    return data;
  }
  throw ApiError(
    message: 'Portfolio PDF export returned unexpected data type: ${data.runtimeType}.',
    code: 'INVALID_PDF_RESPONSE',
  );
}
