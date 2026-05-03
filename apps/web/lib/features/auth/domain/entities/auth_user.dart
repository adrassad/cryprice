class AuthUser {
  const AuthUser({
    this.telegramId,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.emailVerified,
    this.avatarUrl,
    this.subscriptionLevel,
    this.subscriptionEnd,
    this.thresholdHf,
  });

  final String? telegramId;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final bool? emailVerified;
  final String? avatarUrl;
  final String? subscriptionLevel;
  final String? subscriptionEnd;
  final String? thresholdHf;

  factory AuthUser.fromJson(Map<String, Object?> m) {
    String? asString(Object? v) {
      if (v == null) {
        return null;
      }
      return v.toString();
    }
    return AuthUser(
      telegramId: asString(m['telegram_id']),
      username: asString(m['username']),
      firstName: asString(m['first_name']),
      lastName: asString(m['last_name']),
      email: asString(m['email']),
      emailVerified: m['email_verified'] as bool?,
      avatarUrl: asString(m['avatar_url']),
      subscriptionLevel: asString(m['subscription_level']),
      subscriptionEnd: asString(m['subscription_end']),
      thresholdHf: asString(m['threshold_hf']),
    );
  }
}
