import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/alerts/presentation/utils/health_factor_alert_formatters.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations loc;

  setUp(() async {
    loc = lookupAppLocalizations(const Locale('en'));
  });

  group('resolveHealthFactorNumber', () {
    test('parses numeric strings', () {
      expect(resolveHealthFactorNumber('1.62'), 1.62);
      expect(resolveHealthFactorNumber('2'), 2);
    });

    test('handles null, empty, and infinity', () {
      expect(resolveHealthFactorNumber(null), isNull);
      expect(resolveHealthFactorNumber(''), isNull);
      expect(resolveHealthFactorNumber('Infinity'), double.infinity);
    });
  });

  group('resolveHealthFactorSemanticState', () {
    test('maps HF zones to semantic states', () {
      expect(
        resolveHealthFactorSemanticState(
          currentHfRaw: '0.98',
          alertType: InboxAlertType.healthFactorBreach,
        ),
        HealthFactorSemanticState.liquidation,
      );
      expect(
        resolveHealthFactorSemanticState(
          currentHfRaw: '1.08',
          alertType: InboxAlertType.healthFactorBreach,
        ),
        HealthFactorSemanticState.critical,
      );
      expect(
        resolveHealthFactorSemanticState(
          currentHfRaw: '1.66',
          alertType: InboxAlertType.healthFactorBreach,
        ),
        HealthFactorSemanticState.warning,
      );
      expect(
        resolveHealthFactorSemanticState(
          currentHfRaw: '2.30',
          alertType: InboxAlertType.healthFactorRecovery,
        ),
        HealthFactorSemanticState.recovery,
      );
    });
  });

  group('resolveHealthFactorAlertDisplayCopy', () {
    test('uses liquidation copy for HF <= 1.00', () {
      final copy = resolveHealthFactorAlertDisplayCopy(
        currentHfRaw: '0.98',
        alertType: InboxAlertType.healthFactorBreach,
        loc: loc,
      );

      expect(copy.headline, loc.alertsHfLiquidationHeadline);
      expect(copy.explanation, loc.alertsHfLiquidationExplanation);
      expect(copy.severityLabel, contains('Liquidation'));
    });
  });

  group('getHealthFactorIcon', () {
    test('returns expected icons by range', () {
      expect(getHealthFactorIcon(null), '');
      expect(getHealthFactorIcon('Infinity'), '♾️');
      expect(getHealthFactorIcon('2.01'), '💚');
      expect(getHealthFactorIcon('1.75'), '💛');
      expect(getHealthFactorIcon('1.30'), '🧡');
      expect(getHealthFactorIcon('1.05'), '❤️');
      expect(getHealthFactorIcon('0.95'), '💔');
    });
  });

  group('formatHealthFactor', () {
    test('formats with two decimals', () {
      expect(formatHealthFactor('1.62', loc), '1.62');
      expect(formatHealthFactor('2', loc), '2.00');
    });

    test('returns unavailable fallback when missing', () {
      expect(formatHealthFactor(null, loc), loc.portfolioHealthFactorUnavailable);
    });
  });

  group('formatHealthFactorSeverityLabel', () {
    test('adds emoji prefixes', () {
      expect(formatHealthFactorSeverityLabel(loc, 'warning'), contains('Warning'));
      expect(formatHealthFactorSeverityLabel(loc, 'warning'), startsWith('⚠️'));
      expect(formatHealthFactorSeverityLabel(loc, 'critical'), startsWith('🚨'));
    });
  });

  group('formatWalletAddress', () {
    test('shortens long addresses', () {
      expect(
        formatWalletAddress('0x1234567890abcdef1234567890abcdef12345678'),
        '0x1234...5678',
      );
    });
  });

  group('formatProtocolName', () {
    test('maps known protocol slugs', () {
      expect(formatProtocolName('aave'), 'Aave V3');
      expect(formatProtocolName('aave-v3'), 'Aave V3');
    });
  });

  group('formatNetworkName', () {
    test('maps slug and numeric chain ids', () {
      expect(formatNetworkName('arbitrum'), 'Arbitrum');
      expect(formatNetworkName('ethereum'), 'Ethereum');
      expect(formatNetworkName('42161'), 'Arbitrum');
    });
  });

  group('formatNetworkProtocolLine', () {
    test('combines network and protocol', () {
      expect(
        formatNetworkProtocolLine('arbitrum', 'aave'),
        'Arbitrum · Aave V3',
      );
    });
  });

  group('getHealthFactorMovement', () {
    test('detects improved movement', () {
      final movement = getHealthFactorMovement(
        previousRaw: '1.51',
        currentRaw: '1.52',
        loc: loc,
      );

      expect(movement.kind, HealthFactorMovementKind.improved);
      expect(movement.trendIcon, '📈');
      expect(movement.showArrowLine, isTrue);
      expect(formatHealthFactorMovementLine(movement), contains('→'));
    });

    test('detects decreased movement', () {
      final movement = getHealthFactorMovement(
        previousRaw: '1.63',
        currentRaw: '1.62',
        loc: loc,
      );

      expect(movement.kind, HealthFactorMovementKind.decreased);
      expect(movement.trendIcon, '📉');
    });

    test('detects unchanged movement', () {
      final movement = getHealthFactorMovement(
        previousRaw: '1.52',
        currentRaw: '1.52',
        loc: loc,
      );

      expect(movement.kind, HealthFactorMovementKind.unchanged);
      expect(movement.trendIcon, '➖');
    });

    test('returns current only when previous is missing', () {
      final movement = getHealthFactorMovement(
        previousRaw: null,
        currentRaw: '1.52',
        loc: loc,
      );

      expect(movement.kind, HealthFactorMovementKind.currentOnly);
      expect(movement.showArrowLine, isFalse);
    });
  });

  group('healthFactorMovementLabel', () {
    test('uses changed label for breach improvements', () {
      expect(
        healthFactorMovementLabel(
          loc,
          kind: HealthFactorMovementKind.improved,
          isRecovery: false,
        ),
        loc.alertsHfMovementChanged,
      );
    });

    test('uses improved label for recovery improvements', () {
      expect(
        healthFactorMovementLabel(
          loc,
          kind: HealthFactorMovementKind.improved,
          isRecovery: true,
        ),
        loc.alertsHfMovementImproved,
      );
    });
  });

  group('getSeverityVisualStyle', () {
    test('returns severity-aware colors', () {
      const colors = ColorScheme.light();
      final warning = getSeverityVisualStyle('warning', colors);
      final critical = getSeverityVisualStyle('critical', colors);

      expect(warning.borderColor, isNot(equals(critical.borderColor)));
      expect(warning.cardSurfaceColor, isNot(equals(critical.cardSurfaceColor)));
    });
  });
}
