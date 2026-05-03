import 'package:crypto_tracker_app/features/crypto_price/domain/conversion/price_row_display_enricher.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_fetch_outcome.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/exceptions/crypto_exception.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/usecases/get_crypto_price_usecase.dart';
import 'package:crypto_tracker_app/features/crypto_price/presentation/utils/display_count_parser.dart';
import 'package:crypto_tracker_app/features/crypto_price/presentation/widgets/price_fetch_debug_panel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TitleState {}

class TitleInitial extends TitleState {}

class TitleLoading extends TitleState {}

class TitleLoaded extends TitleState {
  /// Enriched rows: [PriceRowViewModel.userConversion] is computed in the domain layer.
  final List<PriceRowViewModel> rows;
  final PriceFetchDebugSnapshot fetchDebug;
  /// Multiplier applied in the UI: displayed quote amount = unit price × this.
  final double countMultiplier;
  /// User-entered tickers (trimmed), used for direct vs inverse conversion.
  final String userTicker1;
  final String userTicker2;
  TitleLoaded(
    this.rows, {
    required this.fetchDebug,
    required this.countMultiplier,
    required this.userTicker1,
    required this.userTicker2,
  });
}

class TitleError extends TitleState {
  //final String message;
  //TitleError(this.message);
  final String errorCode;
  TitleError(this.errorCode);
}

class TitleCubit extends Cubit<TitleState> {
  final GetCryptoPriceUseCase useCase;
  TitleCubit(this.useCase) : super(TitleInitial());

  int _requestGen = 0;

  Future<void> getPrice(String ticker1, String ticker2, String count) async {
    final id = ++_requestGen;
    if (ticker1.isEmpty || ticker2.isEmpty) {
      emit(TitleInitial());
      return;
    }
    emit(TitleLoading());
    try {
      final outcome = await useCase.execute(ticker1, ticker2, count);
      if (id != _requestGen) {
        return;
      }
      logPriceFetchDebug(outcome.debug);
      final multiplier = parseDisplayCount(count);
      final rows = PriceRowDisplayEnricher.build(
        results: outcome.results,
        userTicker1: ticker1.trim(),
        userTicker2: ticker2.trim(),
        countMultiplier: multiplier,
      );
      emit(
        TitleLoaded(
          rows,
          fetchDebug: outcome.debug,
          countMultiplier: multiplier,
          userTicker1: ticker1.trim(),
          userTicker2: ticker2.trim(),
        ),
      );
    } on CryptoException catch (e) {
      if (id != _requestGen) {
        return;
      }
      emit(TitleError(_mapErrorCode(e.code)));
    } catch (_) {
      if (id != _requestGen) {
        return;
      }
      emit(TitleError('error_unknown'));
    }
  }

  String _mapErrorCode(CryptoErrorCode code) {
    switch (code) {
      case CryptoErrorCode.noInternet:
        return 'error_no_internet';
      case CryptoErrorCode.fetchFailed:
        return 'error_fetch_failed';
      default:
        return 'error_unknown';
    }
  }
}
