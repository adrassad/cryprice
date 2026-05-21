import 'package:cryprice_frontend/core/download/file_downloader.dart';

/// Saves exported file bytes on the current platform (web download in browser).
typedef PortfolioFileDownloader = Future<void> Function({
  required List<int> bytes,
  required String filename,
  required String mimeType,
});

/// Default implementation used by [PortfolioCubit].
Future<void> downloadPortfolioFile({
  required List<int> bytes,
  required String filename,
  required String mimeType,
}) {
  return downloadFileBytes(
    bytes: bytes,
    filename: filename,
    mimeType: mimeType,
  );
}
