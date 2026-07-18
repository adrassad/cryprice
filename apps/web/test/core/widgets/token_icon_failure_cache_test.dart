import 'package:cryprice_frontend/core/widgets/token_icon_failure_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(TokenIconFailureCache.clearForTesting);

  test('markFailed and isFailed track URLs for the session', () {
    const url = 'https://api.cryprice.dev/static/token-icons/1/eth.png';

    expect(TokenIconFailureCache.isFailed(url), isFalse);
    TokenIconFailureCache.markFailed(url);
    expect(TokenIconFailureCache.isFailed(url), isTrue);
  });

  test('clearForTesting resets session failures', () {
    TokenIconFailureCache.markFailed('https://example.com/a.png');
    TokenIconFailureCache.clearForTesting();
    expect(TokenIconFailureCache.isFailed('https://example.com/a.png'), isFalse);
  });

  test('markFailed ignores blank URLs', () {
    TokenIconFailureCache.markFailed('   ');
    expect(TokenIconFailureCache.isFailed('   '), isFalse);
  });
}
