import 'package:cryprice_frontend/features/portfolio/data/utils/content_disposition_filename_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses quoted filename', () {
    expect(
      parseFilenameFromContentDisposition(
        'attachment; filename="cryprice-portfolio-report-2026-05-21.pdf"',
      ),
      'cryprice-portfolio-report-2026-05-21.pdf',
    );
  });

  test('parses unquoted filename', () {
    expect(
      parseFilenameFromContentDisposition(
        'attachment; filename=cryprice-portfolio-report-2026-05-21.pdf',
      ),
      'cryprice-portfolio-report-2026-05-21.pdf',
    );
  });

  test('returns null for missing header', () {
    expect(parseFilenameFromContentDisposition(null), isNull);
    expect(parseFilenameFromContentDisposition(''), isNull);
  });

  test('returns null for invalid filename with path separators', () {
    expect(
      parseFilenameFromContentDisposition('attachment; filename="../evil.pdf"'),
      isNull,
    );
  });
}
