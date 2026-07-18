enum GoogleAuthUxMode {
  popup,
  redirect,
}

GoogleAuthUxMode? _debugUxModeOverride;

/// LEGACY helper: Web login routing no longer branches on browser policy.
/// [AuthCubit.signInWithGoogle] always uses backend OAuth on [kIsWeb].
///
/// True when backend OAuth redirect (same-tab) should be used instead of GIS popup.
bool shouldUseGoogleRedirectAuth() {
  return preferredGoogleAuthUxMode() == GoogleAuthUxMode.redirect;
}

/// All Flutter Web browsers use backend OAuth redirect for production login.
GoogleAuthUxMode preferredGoogleAuthUxMode() {
  if (_debugUxModeOverride != null) {
    return _debugUxModeOverride!;
  }
  return GoogleAuthUxMode.redirect;
}

/// Tests only.
void debugSetGoogleAuthUxMode(GoogleAuthUxMode? mode) {
  _debugUxModeOverride = mode;
}
