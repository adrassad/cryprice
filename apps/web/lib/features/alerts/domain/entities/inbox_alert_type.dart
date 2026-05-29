/// Supported inbox notification types from `GET /alerts`.
abstract final class InboxAlertType {
  static const String healthFactorBreach = 'health_factor_breach';
  static const String healthFactorRecovery = 'health_factor_recovery';

  static const Set<String> supported = {
    healthFactorBreach,
    healthFactorRecovery,
  };

  static bool isSupported(String type) => supported.contains(type.trim());
}
