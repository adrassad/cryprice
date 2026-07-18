import 'package:cryprice_frontend/core/auth/auth_flow_guard.dart';
import 'package:cryprice_frontend/core/web/app_update_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(clearAuthFlowGuardForTesting);

  testWidgets('AppUpdateListener does not check for updates during auth flow', (tester) async {
    beginAuthFlow();

    await tester.pumpWidget(
      const MaterialApp(
        home: AppUpdateListener(
          child: SizedBox(),
        ),
      ),
    );
    await tester.pump();

    expect(isAuthFlowInProgress(), isTrue);
    expect(find.byType(SnackBar), findsNothing);
  });
}
