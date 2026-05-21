/// Server-generated portfolio PDF ready for client download.
class PortfolioPdfExportResult {
  const PortfolioPdfExportResult({
    required this.bytes,
    required this.filename,
    required this.mimeType,
  });

  final List<int> bytes;
  final String filename;
  final String mimeType;
}

/// MIME type for portfolio PDF exports from the backend.
const kPortfolioPdfMimeType = 'application/pdf';
