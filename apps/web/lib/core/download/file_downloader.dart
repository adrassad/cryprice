/// Platform-specific file download from in-memory bytes.
///
/// Import this library only — do not import [file_downloader_web] or
/// [file_downloader_stub] directly.
library;

export 'file_downloader_stub.dart'
    if (dart.library.html) 'file_downloader_web.dart';
