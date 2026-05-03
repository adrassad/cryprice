import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_fetch_outcome.dart';
import 'package:flutter/foundation.dart';

/// Debug-only: `debugPrint` lines for local diagnosis (kDebugMode only; no UI).
void logPriceFetchDebug(PriceFetchDebugSnapshot fetchDebug) {
  if (!kDebugMode) {
    return;
  }
  const on = 'yes';
  const off = 'no';
  final onchain = fetchDebug.onchainTrace;
  final offchain = fetchDebug.offchainTrace;
  final base = onchain.resolvedBaseUrl.isNotEmpty
      ? onchain.resolvedBaseUrl
      : (offchain.resolvedBaseUrl.isNotEmpty
          ? offchain.resolvedBaseUrl
          : '—');

  void line(String s) => debugPrint('[cryprice] $s');

  line('--- cryprice http snapshot ---');
  line('1) backend baseUrl (dio): $base');
  line('2) offchain full URL: ${offchain.fullRequestUrl.isNotEmpty ? offchain.fullRequestUrl : offchain.path}');
  line('3) onchain full URL: ${onchain.fullRequestUrl.isNotEmpty ? onchain.fullRequestUrl : onchain.path}');
  line('4) offchain HTTP: ${offchain.httpAttempted ? on : off}');
  line('5) onchain HTTP: ${onchain.httpAttempted ? on : off}');
  line('6) offchain status: ${offchain.statusCode?.toString() ?? 'n/a'}');
  line('7) onchain status: ${onchain.statusCode?.toString() ?? 'n/a'}');
  line('8) offchain raw type: ${offchain.rawDataRuntimeType}');
  line('9) onchain raw type: ${onchain.rawDataRuntimeType}');
  line('10) offchain err: ${offchain.error ?? '—'}');
  line('11) onchain err: ${onchain.error ?? '—'}');
  line('12) parsed offchain DTOs: ${offchain.parsedDtoCount}');
  line('13) parsed onchain DTOs: ${onchain.parsedDtoCount}');
  line('14) offchain → rows mapped: ${offchain.mappedResultCount}');
  line('15) onchain → rows mapped: ${onchain.mappedResultCount}');
  line('16) repository total rows: ${fetchDebug.repositoryTotalRows}');
  line('17) CEX+offch group (UI): ${fetchDebug.cexCountAfterGroup}');
  line('18) DEX group (UI): ${fetchDebug.dexCountAfterGroup}');
  line('19) row origins (merged): ${fetchDebug.mergedRowOrigins.isEmpty ? '—' : fetchDebug.mergedRowOrigins.join(', ')}');
  line('20) onchain network keys: ${onchain.networkKeys.isEmpty ? '—' : onchain.networkKeys.join(', ')}');
  if (onchain.rawDataPreview.isNotEmpty) {
    line('onchain preview: ${onchain.rawDataPreview}');
  }
  if (offchain.rawDataPreview.isNotEmpty) {
    line('offchain preview: ${offchain.rawDataPreview}');
  }
  line('--- end snapshot ---');
}
