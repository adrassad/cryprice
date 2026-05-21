/// Extracts a filename from an HTTP [Content-Disposition] header value.
String? parseFilenameFromContentDisposition(String? header) {
  if (header == null) {
    return null;
  }
  final trimmed = header.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final quoted = RegExp(
    r'filename\s*=\s*"([^"]+)"',
    caseSensitive: false,
  ).firstMatch(trimmed);
  if (quoted != null) {
    final name = quoted.group(1)?.trim();
    if (_isUsableFilename(name)) {
      return name;
    }
  }

  final unquoted = RegExp(
    r'filename\s*=\s*([^;\s]+)',
    caseSensitive: false,
  ).firstMatch(trimmed);
  if (unquoted != null) {
    final name = unquoted.group(1)?.trim();
    if (_isUsableFilename(name)) {
      return name;
    }
  }

  return null;
}

bool _isUsableFilename(String? name) {
  if (name == null || name.isEmpty) {
    return false;
  }
  if (name.contains('/') || name.contains(r'\')) {
    return false;
  }
  return true;
}
