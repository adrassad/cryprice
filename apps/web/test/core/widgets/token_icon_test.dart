import 'package:cryprice_frontend/core/widgets/token_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tokenIconInitials', () {
    test('returns up to three uppercase letters', () {
      expect(tokenIconInitials('eth'), 'ETH');
      expect(tokenIconInitials('weth'), 'WET');
      expect(tokenIconInitials('USD₮0'), 'USD');
      expect(tokenIconInitials('  eth  '), 'ETH');
    });

    test('returns question mark for empty symbol', () {
      expect(tokenIconInitials(''), '?');
      expect(tokenIconInitials('   '), '?');
    });
  });

  group('isLoadableTokenIconUrl', () {
    test('accepts http and https URLs with a host', () {
      expect(
        isLoadableTokenIconUrl('https://api.example.com/icons/eth.png'),
        isTrue,
      );
      expect(
        isLoadableTokenIconUrl('http://localhost:8080/logo.svg'),
        isTrue,
      );
    });

    test('rejects malformed and non-http schemes', () {
      expect(isLoadableTokenIconUrl('not-a-url'), isFalse);
      expect(isLoadableTokenIconUrl('javascript:alert(1)'), isFalse);
      expect(isLoadableTokenIconUrl('ftp://example.com/logo.png'), isFalse);
      expect(isLoadableTokenIconUrl('https://'), isFalse);
      expect(isLoadableTokenIconUrl(''), isFalse);
    });
  });

  group('resolveTokenIconNetworkUrl', () {
    const baseUrl = 'https://api.cryprice.dev';

    test('returns null for null blank and invalid URLs', () {
      expect(resolveTokenIconNetworkUrl(null), isNull);
      expect(resolveTokenIconNetworkUrl('   '), isNull);
      expect(
        resolveTokenIconNetworkUrl('not-a-url', backendBaseUrl: baseUrl),
        isNull,
      );
      expect(
        resolveTokenIconNetworkUrl('javascript:alert(1)', backendBaseUrl: baseUrl),
        isNull,
      );
    });

    test('keeps absolute https URL unchanged including query param', () {
      const url =
          'https://api.cryprice.dev/static/token-icons/1/0xabc.png?v=hash1';
      expect(
        resolveTokenIconNetworkUrl(url, backendBaseUrl: baseUrl),
        url,
      );
    });

    test('prefixes root-relative backend static path with backend base URL', () {
      expect(
        resolveTokenIconNetworkUrl(
          '/static/token-icons/1/0xabc.png?v=hash1',
          backendBaseUrl: baseUrl,
        ),
        'https://api.cryprice.dev/static/token-icons/1/0xabc.png?v=hash1',
      );
    });

    test('handles backend base URL with trailing slash', () {
      expect(
        resolveTokenIconNetworkUrl(
          '/static/token-icons/1/0xabc.png',
          backendBaseUrl: '$baseUrl/',
        ),
        'https://api.cryprice.dev/static/token-icons/1/0xabc.png',
      );
    });

    test('resolves backend-relative icon path with chainId and version hash', () {
      const path =
          '/static/token-icons/42161/0xaf88d065e77c8cc2239327c5edb3a432268e5831.png?v=d2cc';
      expect(
        resolveTokenIconNetworkUrl(path, backendBaseUrl: baseUrl),
        'https://api.cryprice.dev$path',
      );
    });

    test('uses custom backend base URL from build config', () {
      const path = '/static/token-icons/1/0xabc.png?v=123';
      expect(
        resolveTokenIconNetworkUrl(
          path,
          backendBaseUrl: 'http://127.0.0.1:3000',
        ),
        'http://127.0.0.1:3000$path',
      );
    });
  });

  group('TokenIcon', () {
    testWidgets('attempts network load for root-relative backend logo URL',
        (tester) async {
      const path = '/static/token-icons/1/0xabc.png?v=hash1';
      final expectedUrl = resolveTokenIconNetworkUrl(path)!;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TokenIcon(
              logoUrl: path,
              symbol: 'ETH',
              size: 36,
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      final networkImage = image.image as NetworkImage;
      expect(networkImage.url, expectedUrl);
      expect(image.key, ValueKey(expectedUrl));
    });

    testWidgets('shows fallback when logoUrl is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TokenIcon(
              symbol: 'ETH',
              size: 36,
            ),
          ),
        ),
      );

      expect(find.text('ETH'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('shows fallback when logoUrl is blank', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TokenIcon(
              logoUrl: '   ',
              symbol: 'ETH',
              size: 36,
            ),
          ),
        ),
      );

      expect(find.text('ETH'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('shows fallback for invalid URL without attempting network load',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TokenIcon(
              logoUrl: 'not-a-valid-url',
              symbol: 'ETH',
              size: 36,
            ),
          ),
        ),
      );

      expect(find.text('ETH'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(find.byType(TokenIconFallback), findsOneWidget);
    });

    testWidgets('shows fallback for non-http URL scheme', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TokenIcon(
              logoUrl: 'javascript:alert(1)',
              symbol: 'ETH',
              size: 36,
            ),
          ),
        ),
      );

      expect(find.text('ETH'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('shows question mark for empty symbol', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TokenIcon(
              symbol: '   ',
              size: 36,
            ),
          ),
        ),
      );

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('truncates long symbol to three letters in fallback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TokenIcon(
              symbol: 'SUPERLONG',
              size: 36,
            ),
          ),
        ),
      );

      expect(find.text('SUP'), findsOneWidget);
      expect(find.text('SUPERLONG'), findsNothing);
    });

    testWidgets('keeps fixed size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TokenIcon(
              symbol: 'BTC',
              size: 40,
            ),
          ),
        ),
      );

      final box = tester.getSize(find.byType(TokenIcon));
      expect(box.width, 40);
      expect(box.height, 40);

      final fallbackBox = tester.getSize(find.byType(TokenIconFallback));
      expect(fallbackBox.width, 40);
      expect(fallbackBox.height, 40);
    });

    testWidgets('falls back when network image fails', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TokenIcon(
              logoUrl: 'https://invalid.example.test/token.png',
              symbol: 'ETH',
              size: 36,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('ETH'), findsOneWidget);
      expect(find.byType(TokenIconFallback), findsOneWidget);
    });

    testWidgets('renders fallback in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(useMaterial3: true),
          home: const Scaffold(
            body: TokenIcon(
              symbol: 'ETH',
              size: 36,
            ),
          ),
        ),
      );

      expect(find.byType(TokenIconFallback), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
