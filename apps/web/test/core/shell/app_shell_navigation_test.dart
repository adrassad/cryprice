import 'package:cryprice_frontend/core/navigation/app_section.dart';
import 'package:cryprice_frontend/core/shell/cubit/shell_navigation_cubit.dart';
import 'package:cryprice_frontend/core/shell/shell_visuals.dart';
import 'package:cryprice_frontend/core/shell/widgets/shell_alerts_nav_icon.dart';
import 'package:cryprice_frontend/core/shell/widgets/shell_section_nav.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/get_alerts_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/mark_alert_read_usecase.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_cubit.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_state.dart';
import 'package:cryprice_frontend/features/alerts/presentation/pages/alerts_inbox_page.dart';
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

  testWidgets('narrow NavigationBar includes Alerts destination with badge', (tester) async {
    final harness = await _pumpHarness(tester, viewportWidth: 390, unreadCount: 3);

    expect(find.text('Alerts'), findsWidgets);
    expect(find.byKey(const Key('shell_alerts_unread_badge')), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await harness.dispose();
  });

  testWidgets('switching to Alerts tab shows inbox empty state', (tester) async {
    final harness = await _pumpHarness(
      tester,
      viewportWidth: 390,
      unreadCount: 0,
      inboxStatus: AlertsInboxStatus.empty,
    );

    await tester.tap(find.text('Alerts').last);
    await tester.pump();

    expect(find.byKey(const Key('alerts_inbox_empty')), findsOneWidget);
    expect(find.text('No alerts yet'), findsOneWidget);

    await harness.dispose();
  });

  testWidgets('wide layout keeps section nav responsive and switches sections', (tester) async {
    final harness = await _pumpHarness(tester, viewportWidth: 1280, unreadCount: 1);

    expect(find.byType(ShellSectionNav), findsOneWidget);
    expect(find.byKey(const Key('shell_alerts_unread_badge')), findsOneWidget);

    await tester.tap(find.text('Portfolio').first);
    await tester.pump();
    expect(find.text('CryPrice portfolio placeholder'), findsOneWidget);

    await tester.tap(find.text('Alerts').first);
    await tester.pump();
    expect(find.byKey(const Key('alerts_inbox_empty')), findsOneWidget);

    await harness.dispose();
  });
}

Future<_HarnessHandles> _pumpHarness(
  WidgetTester tester, {
  required double viewportWidth,
  required int unreadCount,
  AlertsInboxStatus inboxStatus = AlertsInboxStatus.empty,
}) async {
  final navCubit = ShellNavigationCubit();
  final alertsCubit = _stubAlertsCubit(unreadCount: unreadCount, status: inboxStatus);

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: MediaQuery(
        data: MediaQueryData(size: Size(viewportWidth, 900)),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<ShellNavigationCubit>.value(value: navCubit),
            BlocProvider<AlertsInboxCubit>.value(value: alertsCubit),
          ],
          child: const _ShellNavigationHarness(),
        ),
      ),
    ),
  );
  await tester.pump();

  return _HarnessHandles(
    navCubit: navCubit,
    alertsCubit: alertsCubit,
  );
}

AlertsInboxCubit _stubAlertsCubit({
  required int unreadCount,
  required AlertsInboxStatus status,
}) {
  final getAlertsUseCase = MockGetAlertsUseCase();
  final markAlertReadUseCase = MockMarkAlertReadUseCase();
  when(() => getAlertsUseCase.execute()).thenAnswer((_) async => const []);

  final cubit = AlertsInboxCubit(
    getAlertsUseCase: getAlertsUseCase,
    markAlertReadUseCase: markAlertReadUseCase,
  );
  cubit.emit(AlertsInboxState(status: status, unreadCount: unreadCount));
  return cubit;
}

/// Mirrors [AppShell] narrow/wide nav + [IndexedStack] section wiring for tests.
class _ShellNavigationHarness extends StatelessWidget {
  const _ShellNavigationHarness();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShellNavigationCubit, ShellNavigationState>(
      builder: (BuildContext context, ShellNavigationState navState) {
        final width = MediaQuery.sizeOf(context).width;
        final useWideLayout = width >= ShellVisuals.wideLayoutMinWidth;

        final body = IndexedStack(
          index: _sectionIndex(navState.selectedSection),
          children: const <Widget>[
            Center(child: Text('CryPrice prices placeholder')),
            Center(child: Text('CryPrice portfolio placeholder')),
            AlertsInboxPage(),
            Center(child: Text('CryPrice HF placeholder')),
          ],
        );

        if (useWideLayout) {
          return Row(
            children: [
              Expanded(child: body),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: ShellVisuals.sectionNavMaxWidth,
                  ),
                  child: ShellSectionNav(
                    selectedSection: navState.selectedSection,
                    onSectionSelected: context.read<ShellNavigationCubit>().selectSection,
                  ),
                ),
              ),
            ],
          );
        }

        final loc = AppLocalizations.of(context)!;
        return Column(
          children: [
            Expanded(child: body),
            NavigationBar(
              selectedIndex: _sectionIndex(navState.selectedSection),
              onDestinationSelected: (int index) {
                context.read<ShellNavigationCubit>().selectSection(
                  AppSection.values[index],
                );
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.calculate_outlined),
                  label: loc.navPriceCalculator,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.pie_chart_outline),
                  label: loc.navPortfolio,
                ),
                NavigationDestination(
                  icon: const ShellAlertsNavIcon(),
                  selectedIcon: const ShellAlertsNavIcon(selected: true),
                  label: loc.navAlerts,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.monitor_heart_outlined),
                  label: loc.navHealthFactorCalculator,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

int _sectionIndex(AppSection section) {
  return switch (section) {
    AppSection.priceCalculator => 0,
    AppSection.portfolio => 1,
    AppSection.alerts => 2,
    AppSection.healthFactorCalculator => 3,
  };
}

class _HarnessHandles {
  _HarnessHandles({
    required this.navCubit,
    required this.alertsCubit,
  });

  final ShellNavigationCubit navCubit;
  final AlertsInboxCubit alertsCubit;

  Future<void> dispose() async {
    await navCubit.close();
    await alertsCubit.close();
  }
}
