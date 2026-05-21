import 'package:cryprice_frontend/core/config/cryprice_backend_config.dart';
import 'package:cryprice_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cryprice_frontend/features/auth/data/datasources/google_id_token_provider.dart';
import 'package:cryprice_frontend/features/auth/data/gateways/google_sign_in_gateway_impl.dart';
import 'package:cryprice_frontend/features/auth/data/local/auth_token_store.dart';
import 'package:cryprice_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cryprice_frontend/features/auth/domain/gateways/google_sign_in_gateway.dart';
import 'package:cryprice_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:cryprice_frontend/features/auth/domain/services/auth_session_service.dart';
import 'package:cryprice_frontend/features/portfolio/data/datasources/portfolio_remote_datasource.dart';
import 'package:cryprice_frontend/features/portfolio/data/repositories/portfolio_repository_impl.dart';
import 'package:cryprice_frontend/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:cryprice_frontend/features/portfolio/domain/usecases/export_portfolio_pdf_usecase.dart';
import 'package:cryprice_frontend/features/portfolio/domain/usecases/get_portfolio_usecase.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:cryprice_frontend/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:cryprice_frontend/features/profile/data/datasources/wallets_remote_datasource.dart';
import 'package:cryprice_frontend/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:cryprice_frontend/features/profile/domain/repositories/profile_repository.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/add_wallet_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/delete_wallet_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/get_current_user_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/get_wallets_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/update_wallet_label_usecase.dart';
import 'package:cryprice_frontend/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:cryprice_frontend/features/crypto_price/data/datasources/backend/offchain_onchain_prices_client.dart';
import 'package:flutter/foundation.dart';
import 'package:cryprice_frontend/features/crypto_price/data/repositories/crypto_repository_impl.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/repositories/crypto_repository.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/usecases/get_crypto_price_usecase.dart';
import 'package:cryprice_frontend/features/crypto_price/presentation/cubit/crypto_cubit.dart';
import 'package:cryprice_frontend/features/theme/cubit/theme_cubit.dart';
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
  /// (default `https://api.cryprice.dev`; local: `--dart-define=CRYPRICE_BACKEND_BASE_URL=...`).
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
  di.registerLazySingleton<AuthSessionService>(
    () => AuthSessionService(
      tokenStore: di<AuthTokenStore>(),
      authRemoteDataSource: di<AuthRemoteDataSource>(),
    ),
  );
  di.registerLazySingleton<PortfolioRemoteDataSource>(
    () => PortfolioRemoteDataSource(sessionService: di<AuthSessionService>()),
  );
  di.registerLazySingleton<PortfolioRepository>(
    () => PortfolioRepositoryImpl(remote: di<PortfolioRemoteDataSource>()),
  );
  di.registerLazySingleton(() => GetPortfolioUseCase(di<PortfolioRepository>()));
  di.registerLazySingleton(
    () => ExportPortfolioPdfUseCase(di<PortfolioRepository>()),
  );
  di.registerFactory(
    () => PortfolioCubit(
      di<GetPortfolioUseCase>(),
      di<ExportPortfolioPdfUseCase>(),
    ),
  );
  di.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(sessionService: di<AuthSessionService>()),
  );
  di.registerLazySingleton<WalletsRemoteDataSource>(
    () => WalletsRemoteDataSource(sessionService: di<AuthSessionService>()),
  );
  di.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      profileRemote: di<ProfileRemoteDataSource>(),
      walletsRemote: di<WalletsRemoteDataSource>(),
    ),
  );
  di.registerLazySingleton(() => GetCurrentUserUseCase(di<ProfileRepository>()));
  di.registerLazySingleton(() => UpdateProfileUseCase(di<ProfileRepository>()));
  di.registerLazySingleton(() => GetWalletsUseCase(di<ProfileRepository>()));
  di.registerLazySingleton(() => AddWalletUseCase(di<ProfileRepository>()));
  di.registerLazySingleton(() => UpdateWalletLabelUseCase(di<ProfileRepository>()));
  di.registerLazySingleton(() => DeleteWalletUseCase(di<ProfileRepository>()));
  di.registerFactory(
    () => ProfileCubit(
      getCurrentUserUseCase: di<GetCurrentUserUseCase>(),
      profileRepository: di<ProfileRepository>(),
      updateProfileUseCase: di<UpdateProfileUseCase>(),
      getWalletsUseCase: di<GetWalletsUseCase>(),
      addWalletUseCase: di<AddWalletUseCase>(),
      updateWalletLabelUseCase: di<UpdateWalletLabelUseCase>(),
      deleteWalletUseCase: di<DeleteWalletUseCase>(),
    ),
  );
}
