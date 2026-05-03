import 'package:crypto_tracker_app/core/config/cryprice_backend_config.dart';
import 'package:crypto_tracker_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:crypto_tracker_app/features/auth/data/datasources/google_id_token_provider.dart';
import 'package:crypto_tracker_app/features/auth/data/gateways/google_sign_in_gateway_impl.dart';
import 'package:crypto_tracker_app/features/auth/data/local/auth_token_store.dart';
import 'package:crypto_tracker_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:crypto_tracker_app/features/auth/domain/gateways/google_sign_in_gateway.dart';
import 'package:crypto_tracker_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:crypto_tracker_app/features/crypto_price/data/datasources/backend/offchain_onchain_prices_client.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto_tracker_app/features/crypto_price/data/repositories/crypto_repository_impl.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/repositories/crypto_repository.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/usecases/get_crypto_price_usecase.dart';
import 'package:crypto_tracker_app/features/crypto_price/presentation/cubit/crypto_cubit.dart';
import 'package:crypto_tracker_app/features/theme/cubit/theme_cubit.dart';
import 'package:get_it/get_it.dart';

final di = GetIt.instance;

void setupDependencies() {
  final backendBase = crypriceBackendBaseUrl;
  if (kDebugMode) {
    const sample = 'wbtc';
    debugPrint(
      '[Cryprice] baseUrl=$backendBase '
      'offchain=GET $backendBase/prices/current/offchain/$sample '
      'onchain=GET $backendBase/prices/current/onchain/$sample',
    );
  }

  /// Single HTTP entry for aggregated prices. Base URL: [crypriceBackendBaseUrl]
  /// (see `lib/core/config/cryprice_backend_config.dart` and `.env.example` for
  /// `--dart-define=CRYPRICE_BACKEND_BASE_URL=...`).
  /// No direct Binance / Bybit / CoinGecko calls in the app flow.
  di.registerLazySingleton<OffchainOnchainPricesClient>(
    () => OffchainOnchainPricesClient(baseUrl: backendBase),
  );

  di.registerLazySingleton<CryptoRepository>(
    () => CryptoRepositoryImpl(
      backend: di<OffchainOnchainPricesClient>(),
    ),
  );

  di.registerLazySingleton(() => GetCryptoPriceUseCase(di<CryptoRepository>()));
  di.registerFactory(() => TitleCubit(di<GetCryptoPriceUseCase>()));
  di.registerSingleton<ThemeCubit>(ThemeCubit());

  di.registerLazySingleton<AuthTokenStore>(AuthTokenStore.new);
  di.registerLazySingleton<AuthRemoteDataSource>(AuthRemoteDataSource.new);
  di.registerLazySingleton<GoogleIdTokenProvider>(GoogleIdTokenProvider.new);
  di.registerLazySingleton<GoogleSignInGateway>(
    () => GoogleSignInGatewayImpl(di<GoogleIdTokenProvider>()),
  );
  di.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: di<AuthRemoteDataSource>(),
      store: di<AuthTokenStore>(),
      google: di<GoogleSignInGateway>(),
    ),
  );
}
