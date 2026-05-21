class PublicUser {
  const PublicUser({
    this.id,
    this.telegramId,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.emailVerified,
    this.avatarUrl,
    this.thresholdHf,
    this.language,
  });

  final int? id;
  final int? telegramId;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final bool? emailVerified;
  final String? avatarUrl;
  final double? thresholdHf;
  final String? language;

  /// True when the profile has a valid Telegram account id from the backend.
  bool get isTelegramLinked {
    final id = telegramId;
    if (id == null || id == 0) {
      return false;
    }
    return true;
  }

  /// Display handle for linked Telegram (@username), without leading duplication.
  String? get telegramDisplayUsername {
    final raw = username?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return raw.startsWith('@') ? raw : '@$raw';
  }

  factory PublicUser.fromJson(Map<String, Object?> json) {
    int? asInt(Object? value) => value is num ? value.toInt() : int.tryParse('$value');

    double? asDouble(Object? value) => value is num ? value.toDouble() : double.tryParse('$value');

    String? asString(Object? value) {
      if (value == null) {
        return null;
      }
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    return PublicUser(
      id: asInt(json['id']),
      telegramId: asInt(json['telegram_id'] ?? json['telegramId']),
      username: asString(json['username']),
      firstName: asString(json['first_name']),
      lastName: asString(json['last_name']),
      email: asString(json['email']),
      emailVerified: json['email_verified'] as bool?,
      avatarUrl: asString(json['avatar_url']),
      thresholdHf: asDouble(json['threshold_hf']),
      language: asString(json['language']),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'telegram_id': telegramId,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'email_verified': emailVerified,
        'avatar_url': avatarUrl,
        'threshold_hf': thresholdHf,
        'language': language,
      };
}
