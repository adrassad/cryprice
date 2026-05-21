import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatPortfolioUsd', () {
    test('prefixes backend value with dollar sign', () {
      expect(
        formatPortfolioUsd('1234.50', unavailableLabel: 'n/a'),
        '\$1234.50',
      );
    });

    test('returns unavailable label for null or blank', () {
      expect(formatPortfolioUsd(null, unavailableLabel: 'n/a'), 'n/a');
      expect(formatPortfolioUsd('  ', unavailableLabel: 'n/a'), 'n/a');
    });
  });

  group('formatPortfolioPositionValueUsd', () {
    test('returns unavailable when price status is missing', () {
      expect(
        formatPortfolioPositionValueUsd(
          valueUsd: '10.00',
          priceStatus: PortfolioPriceStatus.missing,
          unavailableLabel: 'Value unavailable',
        ),
        'Value unavailable',
      );
    });

    test('strips leading minus for borrowed rows', () {
      expect(
        formatPortfolioPositionValueUsd(
          valueUsd: '-25.00',
          priceStatus: PortfolioPriceStatus.ok,
          unavailableLabel: 'Value unavailable',
          ensurePositive: true,
        ),
        '\$25.00',
      );
    });
  });

  group('formatPortfolioHoldingValueUsd', () {
    test('returns unavailable for null value regardless of price status', () {
      expect(
        formatPortfolioHoldingValueUsd(null, unavailableLabel: 'Value unavailable'),
        'Value unavailable',
      );
    });

    test('formats value when present', () {
      expect(
        formatPortfolioHoldingValueUsd('42.50', unavailableLabel: 'Value unavailable'),
        '\$42.50',
      );
    });
  });

  group('formatPortfolioUsdForPriceStatus', () {
    test('returns unavailable when price status is missing even if value is zero', () {
      expect(
        formatPortfolioUsdForPriceStatus(
          valueUsd: '0',
          priceStatus: PortfolioPriceStatus.missing,
          unavailableLabel: 'Price unavailable',
        ),
        'Price unavailable',
      );
    });

    test('formats available values with dollar sign', () {
      expect(
        formatPortfolioUsdForPriceStatus(
          valueUsd: '1.00',
          priceStatus: PortfolioPriceStatus.ok,
          unavailableLabel: 'Price unavailable',
        ),
        '\$1.00',
      );
    });
  });

  group('compactPortfolioDecimalValue', () {
    test('trims trailing zeros after decimal', () {
      expect(compactPortfolioDecimalValue('2.1400'), '2.14');
      expect(compactPortfolioDecimalValue('250.0'), '250');
    });

    test('returns null for empty input', () {
      expect(compactPortfolioDecimalValue(null), isNull);
      expect(compactPortfolioDecimalValue(''), isNull);
    });
  });

  group('formatPortfolioBalance', () {
    test('compacts balance and appends symbol', () {
      expect(
        formatPortfolioBalance(balance: '100.0000', symbol: 'USDC'),
        '100 USDC',
      );
    });
  });

  group('formatPortfolioAmount', () {
    test('returns unavailable for empty amount', () {
      expect(
        formatPortfolioAmount(null, unavailableLabel: 'Value unavailable'),
        'Value unavailable',
      );
    });

    test('compacts non-empty amount', () {
      expect(
        formatPortfolioAmount('50.0000', unavailableLabel: 'Value unavailable'),
        '50',
      );
    });

    test('preserves significant digits without parsing as double', () {
      expect(
        formatPortfolioAmount('0.000000100', unavailableLabel: 'n/a'),
        '0.0000001',
      );
    });
  });

  group('positiveFinancialDisplayValue', () {
    test('strips leading minus without parsing', () {
      expect(positiveFinancialDisplayValue('-40.00'), '40.00');
      expect(positiveFinancialDisplayValue('40.00'), '40.00');
    });
  });

  group('shortenPortfolioAddress', () {
    test('shortens long addresses to first6...last4', () {
      expect(
        shortenPortfolioAddress('0xabcdef1234567890abcdef1234567890abcd'),
        '0xabcd...abcd',
      );
    });

    test('returns short addresses unchanged', () {
      expect(shortenPortfolioAddress('0x1234'), '0x1234');
    });
  });

  group('formatPortfolioUpdatedAt', () {
    test('formats ISO timestamp as dd.MM.yyyy HH:mm', () {
      expect(
        formatPortfolioUpdatedAt(
          '2026-05-19T13:30:00.000Z',
          updatedNeverLabel: 'Never',
        ),
        matches(RegExp(r'^\d{2}\.\d{2}\.\d{4} \d{2}:\d{2}$')),
      );
    });

    test('returns never label for blank input', () {
      expect(
        formatPortfolioUpdatedAt('  ', updatedNeverLabel: 'Never updated'),
        'Never updated',
      );
    });
  });
}
