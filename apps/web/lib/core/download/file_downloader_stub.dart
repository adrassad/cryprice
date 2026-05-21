/// Non-web platforms: file download via browser APIs is unavailable.
Future<void> downloadFileBytes({
  required List<int> bytes,
  required String filename,
  required String mimeType,
}) async {
  throw UnsupportedError(
    'downloadFileBytes is only supported on web. '
    'filename=$filename, mimeType=$mimeType, bytes=${bytes.length}',
  );
}
