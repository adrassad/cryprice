/// Starts GIS redirect sign-in. Non-web: unsupported.
int debugStartGoogleRedirectSignInCalls = 0;

Future<void> startGoogleRedirectSignIn() async {
  debugStartGoogleRedirectSignInCalls++;
  throw UnsupportedError('Google redirect sign-in is web-only');
}

/// Tests only.
void resetGoogleRedirectSignInTestHooks() {
  debugStartGoogleRedirectSignInCalls = 0;
}
