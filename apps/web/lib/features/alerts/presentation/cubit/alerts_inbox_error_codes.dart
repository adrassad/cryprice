/// Machine-readable error codes for [AlertsInboxState].
///
/// UI maps these to [AppLocalizations] getters (e.g. [AlertsInboxErrorCodes.unauthenticated]
/// → `loginRequired`).
abstract final class AlertsInboxErrorCodes {
  static const String unauthenticated = 'UNAUTHENTICATED';
  static const String network = 'NETWORK_ERROR';
  static const String unknown = 'UNKNOWN';
}
