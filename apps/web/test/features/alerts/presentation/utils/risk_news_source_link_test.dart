import 'package:cryprice_frontend/features/alerts/presentation/utils/risk_news_source_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RiskNewsSourceLink.isDisplayableUrl', () {
    test('allows https public URLs', () {
      expect(
        RiskNewsSourceLink.isDisplayableUrl('https://news.example.com/article'),
        isTrue,
      );
    });

    test('blocks localhost and local.test hosts', () {
      expect(RiskNewsSourceLink.isDisplayableUrl('http://localhost/news'), isFalse);
      expect(RiskNewsSourceLink.isDisplayableUrl('https://app.local.test/x'), isFalse);
      expect(RiskNewsSourceLink.isDisplayableUrl('https://service.test/incident'), isFalse);
    });

    test('blocks non-http schemes', () {
      expect(RiskNewsSourceLink.isDisplayableUrl('javascript:alert(1)'), isFalse);
      expect(RiskNewsSourceLink.isDisplayableUrl('file:///tmp/x'), isFalse);
    });
  });
}
