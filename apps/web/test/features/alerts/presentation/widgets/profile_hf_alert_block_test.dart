import 'package:bloc_test/bloc_test.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alert_rules_cubit.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alert_rules_state.dart';
import 'package:cryprice_frontend/features/alerts/presentation/widgets/profile_hf_alert_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockAlertRulesCubit extends MockCubit<AlertRulesState> implements AlertRulesCubit {}

void main() {
  late MockAlertRulesCubit cubit;

  setUp(() {
    cubit = MockAlertRulesCubit();
    when(() => cubit.state).thenReturn(const AlertRulesState());
    when(() => cubit.stream).thenAnswer((_) => const Stream<AlertRulesState>.empty());
    when(() => cubit.setThresholdInput(any())).thenReturn(null);
    when(() => cubit.setEnabled(any())).thenReturn(null);
    when(() => cubit.save()).thenAnswer((_) async {});
  });

  Widget buildSubject({required AlertRulesState state, bool isTelegramLinked = false}) {
    when(() => cubit.state).thenReturn(state);
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BlocProvider<AlertRulesCubit>.value(
          value: cubit,
          child: ProfileHfAlertBlock(isTelegramLinked: isTelegramLinked),
        ),
      ),
    );
  }

  testWidgets('shows loading indicator while alert rules are loading', (tester) async {
    await tester.pumpWidget(
      buildSubject(state: const AlertRulesState(status: AlertRulesStatus.loading)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('shows threshold controls when loaded', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        state: const AlertRulesState(
          status: AlertRulesStatus.loaded,
          thresholdInput: '1.5',
          enabled: true,
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(SwitchListTile), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('shows optional telegram warning when not linked', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        state: const AlertRulesState(
          status: AlertRulesStatus.loaded,
          thresholdInput: '2',
        ),
        isTelegramLinked: false,
      ),
    );

    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(
      find.textContaining('optional Telegram notifications require linking'),
      findsOneWidget,
    );
  });

  testWidgets('disables save button while saving', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        state: const AlertRulesState(
          status: AlertRulesStatus.saving,
          thresholdInput: '2',
        ),
      ),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });
}
