import 'package:freezed_annotation/freezed_annotation.dart';

part 'gacha_series_model.freezed.dart';
part 'gacha_series_model.g.dart';

/// ガチャシリーズ
@freezed
class GachaSeries with _$GachaSeries {
  const factory GachaSeries({
    required String id,
    required String name,
    required String imageUrl,
    required String description,
    @Default(0) int totalItems,
    @Default(0) int collectedItems,
    required DateTime createdAt,
    @Default(false) bool isActive,
  }) = _GachaSeries;

  factory GachaSeries.fromJson(Map<String, dynamic> json) =>
      _$GachaSeriesFromJson(json);
}

/// Firestore用ガチャシリーズDTO
@freezed
class GachaSeriesDTO with _$GachaSeriesDTO {
  const factory GachaSeriesDTO({
    required String id,
    required String name,
    required String imageUrl,
    required String description,
    @Default(0) int totalItems,
    required int createdAtMillis,
    @Default(true) bool isActive,
  }) = _GachaSeriesDTO;

  factory GachaSeriesDTO.fromJson(Map<String, dynamic> json) =>
      _$GachaSeriesDTOFromJson(json);

  factory GachaSeriesDTO.fromGachaSeries(GachaSeries series) {
    return GachaSeriesDTO(
      id: series.id,
      name: series.name,
      imageUrl: series.imageUrl,
      description: series.description,
      totalItems: series.totalItems,
      createdAtMillis: series.createdAt.millisecondsSinceEpoch,
      isActive: series.isActive,
    );
  }

  GachaSeries toGachaSeries({int collectedItems = 0}) {
    return GachaSeries(
      id: id,
      name: name,
      imageUrl: imageUrl,
      description: description,
      totalItems: totalItems,
      collectedItems: collectedItems,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
      isActive: isActive,
    );
  }
}
