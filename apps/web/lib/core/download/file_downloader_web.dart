import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Web: triggers a browser download via Blob URL and a temporary anchor.
Future<void> downloadFileBytes({
  required List<int> bytes,
  required String filename,
  required String mimeType,
}) async {
  final blobParts = [Uint8List.fromList(bytes).toJS].toJS;
  final blob = web.Blob(blobParts, web.BlobPropertyBag(type: mimeType));
  final objectUrl = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = objectUrl
    ..download = filename
    ..style.display = 'none';

  web.document.body?.append(anchor);
  try {
    anchor.click();
  } finally {
    anchor.remove();
    web.URL.revokeObjectURL(objectUrl);
  }
}
