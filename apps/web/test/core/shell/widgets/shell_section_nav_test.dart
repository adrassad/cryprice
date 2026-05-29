import 'package:cryprice_frontend/core/navigation/app_section.dart';
import 'package:cryprice_frontend/core/shell/cubit/shell_navigation_cubit.dart';
import 'package:cryprice_frontend/core/shell/shell_visuals.dart';
import 'package:cryprice_frontend/core/shell/widgets/shell_section_nav.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/get_alerts_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/mark_alert_read_usecase.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_cubit.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_state.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAlertsUseCase extends Mock implements GetAlertsUseCase {}

class MockMarkAlertReadUseCase extends Mock implements MarkAlertReadUseCase {}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('includes Alerts nav item with localized label', (tester) async {
    final alertsCubit = _alertsCubitWithUnread(count: 0);
    addTearDown(alertsCubit.close);

    await tester.pumpWidget(
      _shellHarness(
        alertsCubit: alertsCubit,
        child: ShellSectionNav(
          selectedSection: AppSection.priceCalculator,
          onSectionSelected: (_) {},
        ),
      ),
    );

    expect(find.text('Alerts'), findsOneWidget);
    expect(find.byKey(const Key('shell_alerts_unread_badge')), findsNothing);
  });

  testWidgets('renders unread badge when unreadCount is positive', (tester) async {
    final alertsCubit = _alertsCubitWithUnread(count: 4);
    addTearDown(alertsCubit.close);

    await tester.pumpWidget(
      _shellHarness(
        alertsCubit: alertsCubit,
        child: ShellSectionNav(
          selectedSection: AppSection.alerts,
          onSectionSelected: (_) {},
          compactLabels: true,
        ),
      ),
    );

    expect(find.byKey(const Key('shell_alerts_unread_badge')), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('compact layout still shows badge and supports section switch', (tester) async {
    final navCubit = ShellNavigationCubit();
    addTearDown(navCubit.close);

    final alertsCubit = _alertsCubitWithUnread(count: 2);
    addTearDown(alertsCubit.close);

    AppSection? selected = AppSection.priceCalculator;

    await tester.pumpWidget(
      _shellHarness(
        alertsCubit: alertsCubit,
        navCubit: navCubit,
        viewportWidth: 360,
        child: ShellSectionNav(
          compactLabels: true,
          selectedSection: selected,
          onSectionSelected: (section) {
            selected = section;
            navCubit.selectSection(section);
          },
        ),
      ),
    );

    expect(find.byKey(const Key('shell_alerts_unread_badge')), findsOneWidget);

    await tester.tap(find.byTooltip('Alerts'));
    await tester.pump();

    expect(selected, AppSection.alerts);
    expect(navCubit.state.selectedSection, AppSection.alerts);
  });
}

AlertsInboxCubit _alertsCubitWithUnread({required int count}) {
  final getAlertsUseCase = MockGetAlertsUseCase();
  final markAlertReadUseCase = MockMarkAlertReadUseCase();
  final alerts = List<InboxAlert>.generate(
    count,
    (index) => InboxAlert(
      id: 'alert-$index',
      type: InboxAlertType.healthFactorBreach,
      severity: 'high',
      title: 'Alert $index',
      message: 'Message $index',
      createdAt: '2026-05-20T10:00:00.000Z',
    ),
  );

  when(() => getAlertsUseCase.execute()).thenAnswer((_) async => alerts);

  final cubit = AlertsInboxCubit(
    getAlertsUseCase: getAlertsUseCase,
    markAlertReadUseCase: markAlertReadUseCase,
  );
  cubit.emit(
    AlertsInboxState(
      status: AlertsInboxStatus.loaded,
      alerts: alerts,
      unreadCount: count,
    ),
  );
  return cubit;
}

Widget _shellHarness({
  required AlertsInboxCubit alertsCubit,
  required Widget child,
  ShellNavigationCubit? navCubit,
  double viewportWidth = 1200,
}) {
  final navigationCubit = navCubit ?? ShellNavigationCubit();

  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: MediaQuery(
      data: MediaQueryData(size: Size(viewportWidth, 800)),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ShellNavigationCubit>.value(value: navigationCubit),
          BlocProvider<AlertsInboxCubit>.value(value: alertsCubit),
        ],
        child: Scaffold(
          body: Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              width: ShellVisuals.sectionNavMaxWidth,
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}
