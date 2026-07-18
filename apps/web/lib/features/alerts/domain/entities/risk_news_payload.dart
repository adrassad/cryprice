/// Domain payload for [InboxAlertType.riskNews] notifications.
class RiskNewsPayload {
  const RiskNewsPayload({
    this.targetScope,
    this.eventType,
    this.primarySourceUrl,
    this.primarySourceTitle,
    this.matchedAssets = const <String>[],
    this.matchedProtocols = const <String>[],
    this.matchedChains = const <String>[],
    this.matchConfidence,
    this.affectedAssets = const <String>[],
    this.affectedProtocols = const <String>[],
    this.affectedChains = const <String>[],
    this.globalReason,
    this.matchedMajorEntities = const <String>[],
  });

  final String? targetScope;
  final String? eventType;
  final String? primarySourceUrl;
  final String? primarySourceTitle;
  final List<String> matchedAssets;
  final List<String> matchedProtocols;
  final List<String> matchedChains;
  final String? matchConfidence;
  final List<String> affectedAssets;
  final List<String> affectedProtocols;
  final List<String> affectedChains;
  final String? globalReason;
  final List<String> matchedMajorEntities;

  bool get isGlobalScope => targetScope?.trim().toLowerCase() == 'global';

  bool get isExposureScope => targetScope?.trim().toLowerCase() == 'exposure';
}
