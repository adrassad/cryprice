import 'package:cryprice_frontend/core/download/file_downloader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('downloadFileBytes throws UnsupportedError on non-web test VM', () async {
    expect(
      downloadFileBytes(
        bytes: <int>[0x25, 0x50, 0x44, 0x46],
        filename: 'report.pdf',
        mimeType: 'application/pdf',
      ),
      throwsA(
        isA<UnsupportedError>().having(
          (error) => error.message,
          'message',
          contains('only supported on web'),
        ),
      ),
    );
  });
}
