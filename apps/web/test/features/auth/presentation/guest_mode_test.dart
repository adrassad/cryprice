import 'package:cryprice_frontend/core/cubit/locale_cubit.dart';
import 'package:cryprice_frontend/core/di/di.dart';
import 'package:cryprice_frontend/core/navigation/push_navigation_bridge.dart';
import 'package:cryprice_frontend/core/shell/app_shell.dart';
import 'package:cryprice_frontend/core/theme/cryprice_theme.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/get_alert_rules_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/get_alerts_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/mark_alert_read_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/mark_all_alerts_read_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/upsert_global_hf_alert_rule_usecase.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alert_rules_cubit.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_cubit.dart';
import 'package:cryprice_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:cryprice_frontend/features/auth/domain/gateways/google_sign_in_gateway.dart';
import 'package:cryprice_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:cryprice_frontend/features/auth/presentation/app_auth_gate.dart';
import 'package:cryprice_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cryprice_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:cryprice_frontend/features/auth/presentation/widgets/authenticated_feature_gate.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/entities/price_fetch_outcome.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/usecases/get_crypto_price_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_request.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_asset.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_flags.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_market_reserve.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_markets_result.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_network.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_price.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_protocol.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_risk.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/calculate_health_factor_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/get_health_factor_markets_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/get_health_factor_networks_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/get_health_factor_protocols_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_cubit.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_state.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_pdf_export_result.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';
import 'package:cryprice_frontend/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:cryprice_frontend/features/portfolio/domain/usecases/export_portfolio_pdf_usecase.dart';
import 'package:cryprice_frontend/features/portfolio/domain/usecases/get_portfolio_usecase.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:cryprice_frontend/features/crypto_price/presentation/cubit/crypto_cubit.dart';
import 'package:cryprice_frontend/features/profile/domain/repositories/profile_repository.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/add_wallet_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/delete_wallet_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/get_current_user_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/get_wallets_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/update_wallet_label_usecase.dart';
import 'package:cryprice_frontend/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:cryprice_frontend/features/profile/presentation/pages/profile_page.dart';
import 'package:cryprice_frontend/features/push_notifications/data/platforms/push_messaging_stub.dart';
import 'package:cryprice_frontend/features/push_notifications/domain/repositories/push_token_repository.dart';
import 'package:cryprice_frontend/features/push_notifications/presentation/push_notification_coordinator.dart';
import 'package:cryprice_frontend/features/theme/cubit/theme_cubit.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockGoogleSignInGateway extends Mock implements GoogleSignInGateway {}

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

class MockGetAlertsUseCase extends Mock implements GetAlertsUseCase {}

class MockMarkAlertReadUseCase extends Mock implements MarkAlertReadUseCase {}

class MockMarkAllAlertsReadUseCase extends Mock implements MarkAllAlertsReadUseCase {}

class MockGetCryptoPriceUseCase extends Mock implements GetCryptoPriceUseCase {}

class MockGetHealthFactorProtocolsUseCase extends Mock
    implements GetHealthFactorProtocolsUseCase {}

class MockGetHealthFactorNetworksUseCase extends Mock
    implements GetHealthFactorNetworksUseCase {}

class MockGetHealthFactorMarketsUseCase extends Mock
    implements GetHealthFactorMarketsUseCase {}

class MockCalculateHealthFactorUseCase extends Mock
    implements CalculateHealthFactorUseCase {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockGetAlertRulesUseCase extends Mock implements GetAlertRulesUseCase {}

class MockUpsertGlobalHfAlertRuleUseCase extends Mock
    implements UpsertGlobalHfAlertRuleUseCase {}

class MockPushTokenRepository extends Mock implements PushTokenRepository {}

class MockPushMessagingPlatform extends Mock implements PushMessagingPlatform {}

class _GuestModeTestContext {
  _GuestModeTestContext({
    required this.portfolioRepository,
    required this.getAlertsUseCase,
    required this.googleGateway,
    required this.getHealthFactorProtocolsUseCase,
  });

  final MockPortfolioRepository portfolioRepository;
  final MockGetAlertsUseCase getAlertsUseCase;
  final MockGoogleSignInGateway googleGateway;
  final MockGetHealthFactorProtocolsUseCase getHealthFactorProtocolsUseCase;
}

_GuestModeTestContext? _guestContext;

Future<_GuestModeTestContext> _setupGuestModeDi() async {
  await di.reset();

  final portfolioRepository = MockPortfolioRepository();
  when(() => portfolioRepository.getPortfolio()).thenAnswer((_) async => _samplePortfolio());
  when(() => portfolioRepository.exportPortfolioPdf()).thenAnswer(
    (_) async => const PortfolioPdfExportResult(
      bytes: <int>[0x25, 0x50, 0x44, 0x46],
      filename: 'report.pdf',
      mimeType: 'application/pdf',
    ),
  );

  final getAlertsUseCase = MockGetAlertsUseCase();
  when(() => getAlertsUseCase.execute()).thenAnswer((_) async => []);

  final markAlertReadUseCase = MockMarkAlertReadUseCase();
  final markAllAlertsReadUseCase = MockMarkAllAlertsReadUseCase();

  final getCryptoPriceUseCase = MockGetCryptoPriceUseCase();
  when(
    () => getCryptoPriceUseCase.execute(any(), any(), any()),
  ).thenAnswer(
    (_) async => PriceFetchOutcome(
      results: const [],
      debug: PriceFetchDebugSnapshot(
        onchainTrace: BackendPathTrace(path: '/onchain', isOnchainEndpoint: true),
        offchainTrace: BackendPathTrace(path: '/offchain', isOnchainEndpoint: false),
        mergedRowOrigins: const [],
        repositoryTotalRows: 0,
        cexCountAfterGroup: 0,
        dexCountAfterGroup: 0,
      ),
    ),
  );

  final getProtocols = MockGetHealthFactorProtocolsUseCase();
  final getNetworks = MockGetHealthFactorNetworksUseCase();
  final getMarkets = MockGetHealthFactorMarketsUseCase();
  final calculateHf = MockCalculateHealthFactorUseCase();
  _stubHealthFactorCatalog(getProtocols, getNetworks, getMarkets);

  di.registerFactory<GetPortfolioUseCase>(() => GetPortfolioUseCase(portfolioRepository));
  di.registerFactory<ExportPortfolioPdfUseCase>(
    () => ExportPortfolioPdfUseCase(portfolioRepository),
  );
  di.registerFactory<PortfolioCubit>(
    () => PortfolioCubit(
      di<GetPortfolioUseCase>(),
      di<ExportPortfolioPdfUseCase>(),
    ),
  );
  di.registerFactory<AlertsInboxCubit>(
    () => AlertsInboxCubit(
      getAlertsUseCase: getAlertsUseCase,
      markAlertReadUseCase: markAlertReadUseCase,
      markAllAlertsReadUseCase: markAllAlertsReadUseCase,
    ),
  );
  di.registerFactory<TitleCubit>(() => TitleCubit(getCryptoPriceUseCase));
  di.registerFactory<HealthFactorCalculatorCubit>(
    () => HealthFactorCalculatorCubit(
      getProtocolsUseCase: getProtocols,
      getNetworksUseCase: getNetworks,
      getMarketsUseCase: getMarkets,
      calculateHealthFactorUseCase: calculateHf,
    ),
  );

  final pushMessaging = MockPushMessagingPlatform();
  when(() => pushMessaging.configureForegroundPresentation())
      .thenAnswer((_) async {});
  when(() => pushMessaging.getInitialMessage()).thenAnswer((_) async => null);
  when(() => pushMessaging.onMessage)
      .thenAnswer((_) => const Stream<Map<String, String>>.empty());
  when(() => pushMessaging.onMessageOpenedApp)
      .thenAnswer((_) => const Stream<Map<String, String>>.empty());
  when(() => pushMessaging.onTokenRefresh)
      .thenAnswer((_) => const Stream<String>.empty());

  di.registerLazySingleton<PushTokenRepository>(MockPushTokenRepository.new);
  di.registerLazySingleton<PushMessagingPlatform>(() => pushMessaging);
  di.registerLazySingleton(MutablePushNavigationBridge.new);
  di.registerLazySingleton<PushNavigationBridge>(
    () => di<MutablePushNavigationBridge>(),
  );
  di.registerLazySingleton(
    () => PushNotificationCoordinator(
      messagingPlatform: di<PushMessagingPlatform>(),
      tokenRepository: di<PushTokenRepository>(),
      navigationBridge: di<PushNavigationBridge>(),
    ),
  );

  final context = _GuestModeTestContext(
    portfolioRepository: portfolioRepository,
    getAlertsUseCase: getAlertsUseCase,
    googleGateway: MockGoogleSignInGateway(),
    getHealthFactorProtocolsUseCase: getProtocols,
  );
  when(() => context.googleGateway.getIdToken()).thenAnswer((_) async => null);
  when(() => context.googleGateway.signOut()).thenAnswer((_) async {});

  _guestContext = context;
  return context;
}

AuthCubit _guestAuthCubit(_GuestModeTestContext ctx) {
  final authCubit = AuthCubit(MockAuthRepository(), ctx.googleGateway);
  authCubit.emit(const AuthStateUnauthenticated());
  return authCubit;
}

AuthCubit _authenticatedAuthCubit(_GuestModeTestContext ctx) {
  final authCubit = AuthCubit(MockAuthRepository(), ctx.googleGateway);
  authCubit.emit(AuthStateAuthenticated(const AuthUser(email: 'guest@test.dev')));
  return authCubit;
}

Widget _guestApp({
  required AuthCubit authCubit,
  required Widget home,
  double width = 390,
}) {
  final localeCubit = LocaleCubit()..emit(const Locale('en'));
  final themeCubit = ThemeCubit()..emit(ThemeMode.light);

  return MediaQuery(
    data: MediaQueryData(size: Size(width, 900)),
    child: MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<LocaleCubit>.value(value: localeCubit),
        BlocProvider<ThemeCubit>.value(value: themeCubit),
      ],
      child: MaterialApp(
        theme: CrypriceTheme.light(),
        darkTheme: CrypriceTheme.dark(),
        themeMode: ThemeMode.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: home,
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(
      const HealthFactorCalculateRequest(protocol: 'aave_v3', network: 'arbitrum'),
    );
  });

  setUp(() async {
    await _setupGuestModeDi();
  });

  tearDown(() async {
    await di.reset();
    _guestContext = null;
  });

  group('AppAuthGate', () {
    testWidgets('shows loading spinner while auth is restoring', (tester) async {
      final ctx = _guestContext!;
      final authCubit = AuthCubit(MockAuthRepository(), ctx.googleGateway);

      await tester.pumpWidget(_guestApp(authCubit: authCubit, home: const AppAuthGate()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(AppShell), findsNothing);
      expect(find.byType(LoginPage), findsNothing);

      await authCubit.close();
    });

    testWidgets('unauthenticated user opens AppShell instead of LoginPage', (tester) async {
      final ctx = _guestContext!;
      final authCubit = _guestAuthCubit(ctx);

      await tester.pumpWidget(_guestApp(authCubit: authCubit, home: const AppAuthGate()));
      await tester.pumpAndSettle();

      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.text('Get Price'), findsOneWidget);

      await authCubit.close();
    });

    testWidgets('does not auto-start Google sign-in on guest startup', (tester) async {
      final ctx = _guestContext!;
      final authCubit = _guestAuthCubit(ctx);

      await tester.pumpWidget(_guestApp(authCubit: authCubit, home: const AppAuthGate()));
      await tester.pumpAndSettle();

      verifyNever(() => ctx.googleGateway.getIdToken());

      await authCubit.close();
    });
  });

  group('Guest AppShell navigation', () {
    testWidgets('defaults to Price Calculator tab', (tester) async {
      final ctx = _guestContext!;
      final authCubit = _guestAuthCubit(ctx);

      await tester.pumpWidget(
        _guestApp(
          authCubit: authCubit,
          home: AppShell(onProfile: () {}, onLogin: () {}, onLogout: () {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Get Price'), findsOneWidget);
      expect(find.byKey(const Key('account_access_required_panel')), findsNothing);
      verifyNever(() => ctx.getHealthFactorProtocolsUseCase.execute());

      await authCubit.close();
    });

    testWidgets('HF metadata loads once when HF tab is selected', (tester) async {
      final ctx = _guestContext!;
      final authCubit = _guestAuthCubit(ctx);

      await tester.pumpWidget(
        _guestApp(
          authCubit: authCubit,
          home: AppShell(onProfile: () {}, onLogin: () {}, onLogout: () {}),
        ),
      );
      await tester.pumpAndSettle();

      verifyNever(() => ctx.getHealthFactorProtocolsUseCase.execute());

      await tester.tap(find.text('HF Calculator').last);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('hf_calc_form')), findsOneWidget);

      await tester.tap(find.text('Prices').last);
      await tester.pump();
      await tester.tap(find.text('HF Calculator').last);
      await tester.pumpAndSettle();

      verify(() => ctx.getHealthFactorProtocolsUseCase.execute()).called(1);

      await authCubit.close();
    });

    testWidgets('guest can open Health Factor Calculator tab', (tester) async {
      final ctx = _guestContext!;
      final authCubit = _guestAuthCubit(ctx);

      await tester.pumpWidget(
        _guestApp(
          authCubit: authCubit,
          home: AppShell(onProfile: () {}, onLogin: () {}, onLogout: () {}),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('HF Calculator').last);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('hf_calc_form')), findsOneWidget);
      expect(find.byKey(const Key('account_access_required_panel')), findsNothing);

      await authCubit.close();
    });

    testWidgets('guest Portfolio tab shows account access panel without API call', (tester) async {
      final ctx = _guestContext!;
      final authCubit = _guestAuthCubit(ctx);

      await tester.pumpWidget(
        _guestApp(
          authCubit: authCubit,
          home: AppShell(onProfile: () {}, onLogin: () {}, onLogout: () {}),
        ),
      );
      await tester.pumpAndSettle();

      verifyNever(() => ctx.portfolioRepository.getPortfolio());

      await tester.tap(find.text('Portfolio').last);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('account_access_required_panel')), findsOneWidget);
      expect(find.text('Account access required'), findsOneWidget);
      verifyNever(() => ctx.portfolioRepository.getPortfolio());

      await authCubit.close();
    });

    testWidgets('guest Alerts tab shows account access panel without API call', (tester) async {
      final ctx = _guestContext!;
      final authCubit = _guestAuthCubit(ctx);

      await tester.pumpWidget(
        _guestApp(
          authCubit: authCubit,
          home: AppShell(onProfile: () {}, onLogin: () {}, onLogout: () {}),
        ),
      );
      await tester.pumpAndSettle();

      verifyNever(() => ctx.getAlertsUseCase.execute());

      await tester.tap(find.text('Alerts').last);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('account_access_required_panel')), findsOneWidget);
      expect(find.text('Account access required'), findsOneWidget);
      verifyNever(() => ctx.getAlertsUseCase.execute());

      await authCubit.close();
    });

    testWidgets('authenticated user does not load Portfolio until tab selected', (tester) async {
      final ctx = _guestContext!;
      final authCubit = _authenticatedAuthCubit(ctx);

      await tester.pumpWidget(
        _guestApp(
          authCubit: authCubit,
          home: AppShell(onProfile: () {}, onLogin: () {}, onLogout: () {}),
        ),
      );
      await tester.pumpAndSettle();

      verifyNever(() => ctx.portfolioRepository.getPortfolio());

      await authCubit.close();
    });

    testWidgets('authenticated user loads Portfolio normally', (tester) async {
      final ctx = _guestContext!;
      final authCubit = _authenticatedAuthCubit(ctx);

      await tester.pumpWidget(
        _guestApp(
          authCubit: authCubit,
          home: AppShell(onProfile: () {}, onLogin: () {}, onLogout: () {}),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Portfolio').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      verify(() => ctx.portfolioRepository.getPortfolio()).called(1);
      expect(find.text('Net value'), findsWidgets);
      expect(find.byKey(const Key('account_access_required_panel')), findsNothing);

      await authCubit.close();
    });

    testWidgets('authenticated user loads Alerts normally', (tester) async {
      final ctx = _guestContext!;
      final authCubit = _authenticatedAuthCubit(ctx);

      await tester.pumpWidget(
        _guestApp(
          authCubit: authCubit,
          home: AppShell(onProfile: () {}, onLogin: () {}, onLogout: () {}),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alerts').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      verify(() => ctx.getAlertsUseCase.execute()).called(1);
      expect(find.byKey(const Key('alerts_inbox_empty')), findsOneWidget);
      expect(find.byKey(const Key('account_access_required_panel')), findsNothing);

      await authCubit.close();
    });
  });

  group('Profile guest guard', () {
    testWidgets('guest Profile shows account access panel without protected calls', (tester) async {
      final ctx = _guestContext!;
      final authCubit = _guestAuthCubit(ctx);
      final profileRepository = MockProfileRepository();
      final profileCubit = ProfileCubit(
        getCurrentUserUseCase: GetCurrentUserUseCase(profileRepository),
        profileRepository: profileRepository,
        updateProfileUseCase: UpdateProfileUseCase(profileRepository),
        getWalletsUseCase: GetWalletsUseCase(profileRepository),
        addWalletUseCase: AddWalletUseCase(profileRepository),
        updateWalletLabelUseCase: UpdateWalletLabelUseCase(profileRepository),
        deleteWalletUseCase: DeleteWalletUseCase(profileRepository),
      );
      final alertRulesCubit = AlertRulesCubit(
        getAlertRulesUseCase: MockGetAlertRulesUseCase(),
        upsertGlobalHfAlertRuleUseCase: MockUpsertGlobalHfAlertRuleUseCase(),
      );
      addTearDown(profileCubit.close);
      addTearDown(alertRulesCubit.close);

      await tester.pumpWidget(
        _guestApp(
          authCubit: authCubit,
          home: MultiBlocProvider(
            providers: [
              BlocProvider<ProfileCubit>.value(value: profileCubit),
              BlocProvider<AlertRulesCubit>.value(value: alertRulesCubit),
            ],
            child: const ProfilePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('account_access_required_panel')), findsOneWidget);
      expect(find.text('Account access required'), findsOneWidget);
      verifyNever(() => profileRepository.getCurrentUser());
      verifyNever(() => profileRepository.getWallets());

      await authCubit.close();
    });
  });

  group('AuthenticatedFeatureGate', () {
    testWidgets('shows panel for guest and child for authenticated user', (tester) async {
      final ctx = _guestContext!;
      final authCubit = _guestAuthCubit(ctx);
      var authenticatedCallbackCount = 0;

      await tester.pumpWidget(
        _guestApp(
          authCubit: authCubit,
          home: AuthenticatedFeatureGate(
            onAuthenticated: () => authenticatedCallbackCount += 1,
            child: const Text('Protected content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Protected content'), findsNothing);
      expect(find.byKey(const Key('account_access_required_panel')), findsOneWidget);
      expect(authenticatedCallbackCount, 0);

      authCubit.emit(AuthStateAuthenticated(const AuthUser(email: 'user@test.dev')));
      await tester.pumpAndSettle();

      expect(find.text('Protected content'), findsOneWidget);
      expect(authenticatedCallbackCount, 1);

      await authCubit.close();
    });
  });

  group('LoginPage', () {
    testWidgets('does not auto-start Google sign-in when opened', (tester) async {
      final ctx = _guestContext!;
      final authCubit = _guestAuthCubit(ctx);

      await tester.pumpWidget(_guestApp(authCubit: authCubit, home: const LoginPage()));
      await tester.pumpAndSettle();

      verifyNever(() => ctx.googleGateway.getIdToken());

      await authCubit.close();
    });
  });
}

Portfolio _samplePortfolio() {
  return Portfolio(
    summary: const PortfolioSummary(
      totalValueUsd: '1000',
      netValueUsd: '1000',
      walletsCount: 1,
      assetsCount: 1,
      networksCount: 1,
      updatedAt: '2026-06-07T00:00:00.000Z',
    ),
    networks: [
      PortfolioNetwork(
        networkId: 1,
        chainId: 1,
        name: 'Ethereum',
        nativeSymbol: 'ETH',
        totalValueUsd: '1000',
        assets: [
          PortfolioAsset(
            assetId: '10',
            symbol: 'USDC',
            address: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
            decimals: 6,
            balanceRaw: '1000000000',
            balance: '1000',
            priceUsd: '1',
            valueUsd: '1000',
            priceStatus: PortfolioPriceStatus.ok,
            priceCalculatedAt: '2026-06-07T00:00:00.000Z',
            balanceSyncedAt: '2026-06-07T00:00:00.000Z',
            wallets: const <PortfolioWalletBreakdown>[],
          ),
        ],
      ),
    ],
  );
}

void _stubHealthFactorCatalog(
  MockGetHealthFactorProtocolsUseCase getProtocols,
  MockGetHealthFactorNetworksUseCase getNetworks,
  MockGetHealthFactorMarketsUseCase getMarkets,
) {
  when(() => getProtocols.execute()).thenAnswer(
    (_) async => [const HealthFactorProtocol(id: kHealthFactorAaveV3ProtocolId, name: 'Aave V3')],
  );
  when(() => getNetworks.execute(protocol: kHealthFactorAaveV3ProtocolId)).thenAnswer(
    (_) async => [const HealthFactorNetwork(id: '2', name: 'arbitrum', chainId: 42161)],
  );
  when(
    () => getMarkets.execute(
      protocol: any(named: 'protocol'),
      network: any(named: 'network'),
      marketId: any(named: 'marketId'),
      onlyActive: any(named: 'onlyActive'),
      onlySupplyEnabled: any(named: 'onlySupplyEnabled'),
      onlyBorrowEnabled: any(named: 'onlyBorrowEnabled'),
      onlyCollateralEnabled: any(named: 'onlyCollateralEnabled'),
      search: any(named: 'search'),
    ),
  ).thenAnswer(
    (_) async => HealthFactorMarketsResult(
      protocol: kHealthFactorAaveV3ProtocolId,
      network: const HealthFactorNetwork(id: '2', name: 'arbitrum', chainId: 42161),
      reserves: [
        HealthFactorMarketReserve(
          protocol: kHealthFactorAaveV3ProtocolId,
          network: const HealthFactorNetwork(id: '2', name: 'arbitrum', chainId: 42161),
          asset: const HealthFactorAsset(
            id: '10',
            symbol: 'USDC',
            name: 'USD Coin',
            address: '0x10',
            decimals: 6,
          ),
          price: const HealthFactorPrice(usd: '1'),
          risk: const HealthFactorRisk(),
          flags: const HealthFactorFlags(
            supplyEnabled: true,
            borrowEnabled: true,
            collateralEnabled: true,
            isActive: true,
          ),
        ),
      ],
    ),
  );
}
