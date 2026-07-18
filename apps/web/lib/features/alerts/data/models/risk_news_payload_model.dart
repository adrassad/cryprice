import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_payload.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/risk_news_payload.dart';

class RiskNewsPayloadModel {
  const RiskNewsPayloadModel({
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

  factory RiskNewsPayloadModel.fromJson(Map<String, Object?> json) {
    String? asNullableString(Object? value) {
      if (value == null) {
        return null;
      }
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    return RiskNewsPayloadModel(
      targetScope: asNullableString(json['target_scope'] ?? json['targetScope']),
      eventType: asNullableString(json['event_type'] ?? json['eventType']),
      primarySourceUrl: asNullableString(
        json['primary_source_url'] ?? json['primarySourceUrl'],
      ),
      primarySourceTitle: asNullableString(
        json['primary_source_title'] ?? json['primarySourceTitle'],
      ),
      matchedAssets: _parseStringList(json['matched_assets'] ?? json['matchedAssets']),
      matchedProtocols: _parseStringList(
        json['matched_protocols'] ?? json['matchedProtocols'],
      ),
      matchedChains: _parseStringList(json['matched_chains'] ?? json['matchedChains']),
      matchConfidence: asNullableString(
        json['match_confidence'] ?? json['matchConfidence'],
      ),
      affectedAssets: _parseStringList(json['affected_assets'] ?? json['affectedAssets']),
      affectedProtocols: _parseStringList(
        json['affected_protocols'] ?? json['affectedProtocols'],
      ),
      affectedChains: _parseStringList(json['affected_chains'] ?? json['affectedChains']),
      globalReason: asNullableString(json['global_reason'] ?? json['globalReason']),
      matchedMajorEntities: _parseStringList(
        json['matched_major_entities'] ?? json['matchedMajorEntities'],
      ),
    );
  }

  RiskNewsPayload toEntity() {
    return RiskNewsPayload(
      targetScope: targetScope,
      eventType: eventType,
      primarySourceUrl: primarySourceUrl,
      primarySourceTitle: primarySourceTitle,
      matchedAssets: matchedAssets,
      matchedProtocols: matchedProtocols,
      matchedChains: matchedChains,
      matchConfidence: matchConfidence,
      affectedAssets: affectedAssets,
      affectedProtocols: affectedProtocols,
      affectedChains: affectedChains,
      globalReason: globalReason,
      matchedMajorEntities: matchedMajorEntities,
    );
  }

  InboxAlertRiskNewsPayload toInboxPayload() {
    return InboxAlertRiskNewsPayload(toEntity());
  }

  static List<String> _parseStringList(Object? raw) {
    if (raw is! List) {
      return const <String>[];
    }
    return raw
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}
