import 'package:cryprice_frontend/features/profile/domain/entities/public_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PublicUser fromJson parses nullable and numeric fields', () {
    final user = PublicUser.fromJson(<String, Object?>{
      'id': 123,
      'telegram_id': -1000000001,
      'username': 'john',
      'first_name': 'John',
      'last_name': 'Doe',
      'email': 'john@example.com',
      'email_verified': true,
      'avatar_url': 'https://avatar',
      'threshold_hf': 1.2,
      'language': 'en',
    });

    expect(user.id, 123);
    expect(user.telegramId, -1000000001);
    expect(user.username, 'john');
    expect(user.thresholdHf, 1.2);
    expect(user.language, 'en');
    expect(user.isTelegramLinked, isTrue);
    expect(user.telegramDisplayUsername, '@john');
  });

  test('isTelegramLinked is false when telegram_id is null or zero', () {
    expect(
      PublicUser.fromJson(<String, Object?>{'telegram_id': null}).isTelegramLinked,
      isFalse,
    );
    expect(
      PublicUser.fromJson(<String, Object?>{'telegram_id': 0}).isTelegramLinked,
      isFalse,
    );
  });

  test('parses telegramId camelCase alias', () {
    final user = PublicUser.fromJson(<String, Object?>{'telegramId': 42});
    expect(user.telegramId, 42);
    expect(user.isTelegramLinked, isTrue);
  });

  test('telegramDisplayUsername adds @ prefix when missing', () {
    final user = PublicUser.fromJson(<String, Object?>{
      'telegram_id': 1,
      'username': 'adrassad',
    });
    expect(user.telegramDisplayUsername, '@adrassad');
  });
}
