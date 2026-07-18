import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('web static assets', () {
    late String sitemap;
    late String robots;
    late String indexHtml;
    late String manifestJson;

    setUp(() {
      sitemap = File('web/sitemap.xml').readAsStringSync();
      robots = File('web/robots.txt').readAsStringSync();
      indexHtml = File('web/index.html').readAsStringSync();
      manifestJson = File('web/manifest.json').readAsStringSync();
    });

    test('sitemap lists app entry points and excludes API URLs', () {
      expect(sitemap, contains('<loc>https://app.cryprice.dev/</loc>'));
      expect(sitemap, contains('<loc>https://app.cryprice.dev/authentication/</loc>'));
      expect(sitemap, isNot(contains('api.cryprice.dev')));
      expect(sitemap, isNot(contains('<loc>https://cryprice.dev/')));
      expect(sitemap, isNot(contains('t.me/')));
    });

    test('robots.txt references app sitemap only', () {
      expect(robots, contains('Sitemap: https://app.cryprice.dev/sitemap.xml'));
      expect(robots, isNot(contains('api.cryprice.dev')));
    });

    test('index.html uses product-first metadata and canonical', () {
      expect(indexHtml, contains('CryPrice — Read-Only DeFi Dashboard'));
      expect(
        indexHtml,
        contains(
          'Read-only DeFi portfolio monitoring and risk intelligence platform for public blockchain addresses.',
        ),
      );
      expect(indexHtml, contains('<link rel="canonical" href="https://app.cryprice.dev/">'));
      expect(indexHtml, isNot(contains('DeFi portfolio tracker')));
      expect(indexHtml, isNot(contains('crypto risk alerts')));
      expect(indexHtml, isNot(contains('Track DeFi positions')));
      expect(indexHtml, isNot(contains('Not a wallet — no transaction execution.')));
    });

    test('index.html shell includes Security Model for crawlers', () {
      expect(indexHtml, isNot(contains('id="cryprice-static-trust"')));
      expect(indexHtml, isNot(contains('CryPrice trust and security context')));

      expect(indexHtml, contains('id="cryprice-app-static-shell"'));
      expect(indexHtml, contains('Official application: app.cryprice.dev'));
      expect(indexHtml, contains('Read-only by design'));
      expect(indexHtml, contains('Security Model'));
      expect(indexHtml, contains('CryPrice is designed as a read-only platform.'));
      expect(indexHtml, contains('recovery phrases (seed phrases)'));
      expect(indexHtml, contains('private keys'));
      expect(indexHtml, contains('wallet signing credentials'));
      expect(
        indexHtml,
        contains(
          'CryPrice does not execute blockchain transactions and does not take custody of user assets.',
        ),
      );
      expect(
        indexHtml,
        contains(
          'Authentication through Google OAuth is used only for CryPrice accounts and is unrelated to',
        ),
      );
      expect(
        indexHtml,
        contains(
          'CryPrice does not require users to connect a wallet in order to monitor public blockchain',
        ),
      );
      expect(indexHtml, contains('security@cryprice.dev'));
      expect(indexHtml, contains('https://cryprice.dev/faq'));

      // semantic footer with legal links and authentication page
      expect(indexHtml, contains('id="cryprice-app-static-footer"'));
      expect(indexHtml, contains('Official Domains'));
      expect(indexHtml, contains('https://cryprice.dev/privacy/'));
      expect(indexHtml, contains('https://cryprice.dev/terms/'));
      expect(indexHtml, contains('https://cryprice.dev/security/'));
      expect(indexHtml, contains('https://cryprice.dev/trust/'));
      expect(indexHtml, contains('https://cryprice.dev/transparency/'));
      expect(indexHtml, contains('https://cryprice.dev/contact/'));
      expect(indexHtml, contains('href="/authentication/"'));

      // noscript product-first fallback must be present
      expect(indexHtml, contains('<noscript>'));
      expect(indexHtml, contains('id="cryprice-noscript-fallback"'));
      expect(indexHtml, contains('<h1>CryPrice — Read-Only DeFi Dashboard</h1>'));
      expect(
        indexHtml,
        contains(
          'Read-only DeFi portfolio monitoring and risk intelligence platform for public blockchain',
        ),
      );
      expect(indexHtml, contains('JavaScript is required'));

      // links to legal/security pages in noscript
      expect(indexHtml, contains('https://cryprice.dev/security'));
      expect(indexHtml, contains('https://cryprice.dev/privacy'));
      expect(indexHtml, contains('https://cryprice.dev/terms'));

      // structured data present
      expect(indexHtml, contains('"@type": "WebApplication"'));
      expect(indexHtml, contains('"@type": "Organization"'));
      expect(indexHtml, contains('"contactType": "security"'));
      expect(indexHtml, contains('https://cryprice.dev/trust/'));

      // shell hidden from users; loading gif until Flutter mounts
      expect(indexHtml, contains('id="cryprice-app-loading"'));
      expect(indexHtml, contains('assets/assets/gifs/loading.gif'));
      expect(indexHtml, contains('#cryprice-app-static-shell'));
      expect(indexHtml, contains('clip: rect(0, 0, 0, 0)'));
      expect(indexHtml, contains('body.cryprice-app-mounted #cryprice-app-loading'));
      expect(indexHtml, isNot(contains('body.cryprice-app-mounted #cryprice-app-static-shell')));
    });

    test('index.html static shell has enough crawler-visible text without JavaScript', () {
      final shellStart = indexHtml.indexOf('id="cryprice-app-static-shell"');
      final shellEnd = indexHtml.indexOf('</main>', shellStart);
      expect(shellStart, greaterThan(-1));
      expect(shellEnd, greaterThan(shellStart));

      final shellHtml = indexHtml.substring(shellStart, shellEnd);
      final visibleText = shellHtml
          .replaceAll(RegExp(r'<[^>]+>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      final wordCount = visibleText.split(' ').where((w) => w.isNotEmpty).length;

      expect(wordCount, greaterThan(180));
      expect(shellHtml, contains('<h1>'));
      expect(shellHtml, contains('<h2>'));
      expect(shellHtml, contains('<footer'));
    });

    test('index.html does not register a separate Firebase messaging service worker', () {
      expect(indexHtml, isNot(contains("register('/firebase-messaging-sw.js')")));
      expect(indexHtml, isNot(contains('register("/firebase-messaging-sw.js")')));
      expect(indexHtml, isNot(contains('firebase-messaging-sw.js')));
    });

    test('index.html keeps controllerchange reload guard for app updates', () {
      expect(indexHtml, contains('controllerchange'));
      expect(indexHtml, contains('window.location.reload()'));
      expect(indexHtml, contains('cryprice_sw_reload_pending'));
    });

    test('manifest.json matches read-only dashboard metadata', () {
      expect(manifestJson, contains('CryPrice — Read-Only DeFi Dashboard'));
      expect(
        manifestJson,
        contains(
          'Read-only dashboard for public address monitoring, portfolio visibility, and DeFi risk context.',
        ),
      );
    });

    test('security.txt uses security contact and canonical landing policy', () {
      final securityTxt = File('web/.well-known/security.txt').readAsStringSync();
      const expected = '''
Contact: mailto:security@cryprice.dev
Contact: https://x.com/AdrasSad
Acknowledgments: https://cryprice.dev/trust/#acknowledgments
Policy: https://cryprice.dev/security
Expires: 2027-01-01T00:00:00.000Z
Preferred-Languages: en, ru
Canonical: https://cryprice.dev/.well-known/security.txt
''';

      expect(securityTxt, expected);
      expect(securityTxt, isNot(contains('http://')));
    });

    test('production lib source has no legacy AaveRadar bot references', () {
      final libDir = Directory('lib');
      expect(libDir.existsSync(), isTrue);

      final matches = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .map((file) => file.readAsStringSync())
          .where(
            (content) =>
                content.contains('AaveRadar') || content.contains('AaveRadar_bot'),
          )
          .toList();

      expect(matches, isEmpty);
    });
  });

  group('web/authentication/index.html', () {
    late String authHtml;

    setUp(() {
      authHtml = File('web/authentication/index.html').readAsStringSync();
    });

    test('authentication page exists with OAuth endpoints and domains', () {
      expect(File('web/authentication/index.html').existsSync(), isTrue);
      expect(authHtml, contains('/auth/google/oauth/start'));
      expect(authHtml, contains('/auth/google/oauth/callback'));
      expect(authHtml, contains('/auth/google/exchange'));
      expect(authHtml, contains('gis_exchange'));
      expect(authHtml, contains('https://cryprice.dev/'));
      expect(authHtml, contains('https://app.cryprice.dev/'));
      expect(authHtml, contains('https://api.cryprice.dev/'));
      expect(authHtml, contains('Google OAuth'));
    });

    test('authentication page links to legal pages and has sufficient content', () {
      expect(authHtml, contains('https://cryprice.dev/privacy/'));
      expect(authHtml, contains('https://cryprice.dev/terms/'));
      expect(authHtml, contains('https://cryprice.dev/security/'));
      expect(authHtml, contains('https://cryprice.dev/trust/'));
      expect(authHtml, contains('https://cryprice.dev/transparency/'));
      expect(authHtml, contains('https://cryprice.dev/contact/'));
      expect(authHtml, contains('security@cryprice.dev'));
      expect(authHtml, contains('CryPrice is designed as a read-only platform.'));
      expect(authHtml, contains('Aave V3'));
      expect(authHtml, isNot(contains('WalletConnect integration')));

      final visibleText = authHtml
          .replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>'), ' ')
          .replaceAll(RegExp(r'<[^>]+>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      final wordCount = visibleText.split(' ').where((w) => w.isNotEmpty).length;
      expect(wordCount, greaterThan(250));
    });
  });

  group('web/404.html', () {
    late String notFoundHtml;

    setUp(() {
      notFoundHtml = File('web/404.html').readAsStringSync();
    });

    test('404 page exists with trust content, SEO, and navigation', () {
      expect(File('web/404.html').existsSync(), isTrue);
      expect(notFoundHtml, contains('noindex'));
      expect(notFoundHtml, contains('404 — Page Not Found'));
      expect(notFoundHtml, contains('rel="canonical"'));
      expect(notFoundHtml, contains('og:title'));
      expect(notFoundHtml, contains('twitter:card'));
      expect(notFoundHtml, contains('"@type": "WebPage"'));
      expect(notFoundHtml, contains('Official Domains'));
      expect(notFoundHtml, contains('api.cryprice.dev'));
      expect(notFoundHtml, contains('Security notice'));
      expect(notFoundHtml, contains('href="/"'));
      expect(notFoundHtml, contains('href="/authentication/"'));
      expect(notFoundHtml, contains('https://cryprice.dev/privacy/'));
      expect(notFoundHtml, contains('https://cryprice.dev/security/'));
      expect(notFoundHtml, contains('https://cryprice.dev/faq/'));
      expect(notFoundHtml, contains('<h1>'));
      expect(notFoundHtml, contains('aria-label="CryPrice pages"'));
      expect(notFoundHtml, contains('Need help?'));
      expect(notFoundHtml, contains('aria-label="Breadcrumb"'));
      expect(notFoundHtml, contains('BreadcrumbList'));
      expect(notFoundHtml, contains('Last updated: 2026'));
      expect(notFoundHtml, contains('cryprice.dev/docs/'));

      final visibleText = notFoundHtml
          .replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>'), ' ')
          .replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>'), ' ')
          .replaceAll(RegExp(r'<[^>]+>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      final wordCount = visibleText.split(' ').where((w) => w.isNotEmpty).length;
      expect(wordCount, greaterThan(120));
    });
  });
}
