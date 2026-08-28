import 'package:freezed_annotation/freezed_annotation.dart';

part 'gacha_item_model.freezed.dart';
part 'gacha_item_model.g.dart';

/// ガチャアイテムのレアリティ
enum Rarity {
  @JsonValue('N')
  n('N'),
  @JsonValue('R')
  r('R'),
  @JsonValue('SR')
  sr('SR'),
  @JsonValue('SSR')
  ssr('SSR');

  final String value;
  const Rarity(this.value);
}

/// AI判定結果
@freezed
class AIResult with _$AIResult {
  const factory AIResult({
    required String name,
    required String series,
    required Rarity rarity,
    required double confidence,
    String? notes,
  }) = _AIResult;

  factory AIResult.fromJson(Map<String, dynamic> json) =>
      _$AIResultFromJson(json);
}

/// ガチャアイテム（ユーザーが所持するアイテム）
@freezed
class GachaItem with _$GachaItem {
  const factory GachaItem({
    required String id,
    required String userId,
    required String imageUrl,
    required AIResult aiResult,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isManualEdit,
    @Default(false) bool isDuplicate,
  }) = _GachaItem;

  factory GachaItem.fromJson(Map<String, dynamic> json) =>
      _$GachaItemFromJson(json);
}

/// Firestore用ガチャアイテムDTO
@freezed
class GachaItemDTO with _$GachaItemDTO {
  const factory GachaItemDTO({
    required String id,
    required String userId,
    required String imageUrl,
    required Map<String, dynamic> aiResult,
    required int createdAtMillis,
    required int updatedAtMillis,
    @Default(false) bool isManualEdit,
    @Default(false) bool isDuplicate,
  }) = _GachaItemDTO;

  factory GachaItemDTO.fromJson(Map<String, dynamic> json) =>
      _$GachaItemDTOFromJson(json);

  factory GachaItemDTO.fromGachaItem(GachaItem item) {
    return GachaItemDTO(
      id: item.id,
      userId: item.userId,
      imageUrl: item.imageUrl,
      aiResult: _aiResultToJson(item.aiResult),
      createdAtMillis: item.createdAt.millisecondsSinceEpoch,
      updatedAtMillis: item.updatedAt.millisecondsSinceEpoch,
      isManualEdit: item.isManualEdit,
      isDuplicate: item.isDuplicate,
    );
  }

  GachaItem toGachaItem() {
    return GachaItem(
      id: id,
      userId: userId,
      imageUrl: imageUrl,
      aiResult: AIResult.fromJson(aiResult),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMillis),
      isManualEdit: isManualEdit,
      isDuplicate: isDuplicate,
    );
  }
}

Map<String, dynamic> _aiResultToJson(AIResult aiResult) {
  return {
    'name': aiResult.name,
    'series': aiResult.series,
    'rarity': aiResult.rarity.value,
    'confidence': aiResult.confidence,
    if (aiResult.notes != null) 'notes': aiResult.notes,
  };
}
