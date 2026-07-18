import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_market_reserve.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_network.dart';

class HealthFactorMarketsResult {
  const HealthFactorMarketsResult({
    required this.protocol,
    required this.network,
    this.marketId,
    this.reserves = const <HealthFactorMarketReserve>[],
  });

  final String protocol;
  final HealthFactorNetwork network;
  final String? marketId;
  final List<HealthFactorMarketReserve> reserves;
}
