enum GoogleAuthUxMode {
  popup,
  redirect,
}

GoogleAuthUxMode? _debugUxModeOverride;

/// True when GIS redirect (same-tab) should be used instead of popup.
bool shouldUseGoogleRedirectAuth() {
  return preferredGoogleAuthUxMode() == GoogleAuthUxMode.redirect;
}

GoogleAuthUxMode preferredGoogleAuthUxMode() {
  return _debugUxModeOverride ?? GoogleAuthUxMode.redirect;
}

/// Tests only.
void debugSetGoogleAuthUxMode(GoogleAuthUxMode? mode) {
  _debugUxModeOverride = mode;
}
