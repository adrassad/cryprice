import 'package:crypto_tracker_app/features/crypto_price/presentation/utils/display_count_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty uses fallback', () {
    expect(parseDisplayCount(''), 1.0);
    expect(parseDisplayCount('   '), 1.0);
  });

  test('decimals with dot and comma', () {
    expect(parseDisplayCount('0.1'), closeTo(0.1, 1e-9));
    expect(parseDisplayCount('2'), 2.0);
    expect(parseDisplayCount('0,1'), closeTo(0.1, 1e-9));
  });

  test('invalid uses fallback', () {
    expect(parseDisplayCount('abc'), 1.0);
    expect(parseDisplayCount('1.2.3'), 1.0);
  });

  test('negative becomes zero', () {
    expect(parseDisplayCount('-1'), 0.0);
  });

  test('zero count', () {
    expect(parseDisplayCount('0'), 0.0);
    expect(parseDisplayCount('0.0'), 0.0);
  });
}
