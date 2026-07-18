import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_protocol_path.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('slugFromQuery maps aave_v3 to aave-v3', () {
    expect(
      HealthFactorProtocolPath.slugFromQuery(HealthFactorProtocolPath.aaveV3Query),
      HealthFactorProtocolPath.aaveV3Slug,
    );
  });

  test('queryFromSlug maps aave-v3 to aave_v3', () {
    expect(
      HealthFactorProtocolPath.queryFromSlug(HealthFactorProtocolPath.aaveV3Slug),
      HealthFactorProtocolPath.aaveV3Query,
    );
  });
}
