import '../../data/models/gacha_item_model.dart';
import '../../data/repositories/gacha_repository.dart';
import '../../services/ai_service.dart';

/// ガチャアイテム管理ユースケース
///
/// AI判定からコレクション登録までの一連の処理
class GachaUsecase {
  final GachaRepository _gachaRepository;
  final AIService _aiService;

  GachaUsecase({
    required GachaRepository gachaRepository,
    required AIService aiService,
  })  : _gachaRepository = gachaRepository,
        _aiService = aiService;

  /// 「Aha Moment」フロー：撮影 → AI判定 → 自動登録
  Future<String> registerItemFromImage({
    required String userId,
    required String imagePath,
    required String imageUrl, // Firebase Storage URL
  }) async {
    try {
      // Step 1: AI 判定を実行
      final aiResult = await _aiService.identifyGachaItem(imagePath);

      // Step 2: ガチャアイテムを作成
      final now = DateTime.now();
      final item = GachaItem(
        id: '', // Firestore により自動生成
        userId: userId,
        imageUrl: imageUrl,
        aiResult: aiResult,
        createdAt: now,
        updatedAt: now,
        isManualEdit: false,
        isDuplicate: false,
      );

      // Step 3: Firestore に登録
      final itemId = await _gachaRepository.addItem(userId, item);

      return itemId;
    } catch (e) {
      throw GachaUsecaseException('アイテム登録に失敗しました: $e');
    }
  }

  /// ユーザーのアイテム一覧を取得
  Future<List<GachaItem>> getUserItems(String userId) async {
    try {
      return await _gachaRepository.getUserItems(userId);
    } catch (e) {
      throw GachaUsecaseException('アイテム取得に失敗しました: $e');
    }
  }

  /// シリーズ別にアイテムを取得
  Future<List<GachaItem>> getItemsBySeries(
    String userId,
    String series,
  ) async {
    try {
      return await _gachaRepository.getUserItemsBySeries(userId, series);
    } catch (e) {
      throw GachaUsecaseException('シリーズ別アイテム取得に失敗しました: $e');
    }
  }

  /// レアリティ別にアイテムを取得
  Future<List<GachaItem>> getItemsByRarity(
    String userId,
    String rarity,
  ) async {
    try {
      return await _gachaRepository.getUserItemsByRarity(userId, rarity);
    } catch (e) {
      throw GachaUsecaseException('レアリティ別アイテム取得に失敗しました: $e');
    }
  }

  /// アイテムを更新（手動編集）
  Future<void> updateItem(
    String userId,
    GachaItem item,
  ) async {
    try {
      final updatedItem = item.copyWith(
        updatedAt: DateTime.now(),
        isManualEdit: true,
      );
      await _gachaRepository.updateItem(userId, updatedItem);
    } catch (e) {
      throw GachaUsecaseException('アイテム更新に失敗しました: $e');
    }
  }

  /// アイテムを削除
  Future<void> deleteItem(String userId, String itemId) async {
    try {
      await _gachaRepository.deleteItem(userId, itemId);
    } catch (e) {
      throw GachaUsecaseException('アイテム削除に失敗しました: $e');
    }
  }

  /// アイテムを重複フラグでマーク
  Future<void> markAsDuplicate(
    String userId,
    String itemId,
    bool isDuplicate,
  ) async {
    try {
      await _gachaRepository.markAsDuplicate(userId, itemId, isDuplicate);
    } catch (e) {
      throw GachaUsecaseException('重複マークに失敗しました: $e');
    }
  }

  /// ユーザーの統計を取得
  Future<CollectionStatistics> getUserStatistics(String userId) async {
    try {
      final stats = await _gachaRepository.getUserStatistics(userId);

      return CollectionStatistics(
        totalItems: stats.totalItems,
        duplicateItems: stats.duplicateItems,
        uniqueItems: stats.totalItems - stats.duplicateItems,
        manuallyEditedItems: stats.manuallyEditedItems,
        rarityDistribution: stats.rarityDistribution,
        seriesCount: stats.seriesCount,
        completionRate: stats.seriesCount > 0
            ? (stats.totalItems / (stats.seriesCount * 20)).clamp(0.0, 1.0)
            : 0.0,
      );
    } catch (e) {
      throw GachaUsecaseException('統計取得に失敗しました: $e');
    }
  }

  /// シリーズの進捗を取得
  Future<SeriesProgressData> getSeriesProgress(
    String userId,
    String series,
  ) async {
    try {
      final progress = await _gachaRepository.getSeriesProgress(userId, series);

      return SeriesProgressData(
        series: progress.series,
        totalItems: progress.totalItems,
        collectedCount: progress.collectedCount,
        uniqueCount: progress.uniqueCount,
        duplicateCount: progress.duplicateCount,
        completionRate: progress.completionRate,
      );
    } catch (e) {
      throw GachaUsecaseException('進捗取得に失敗しました: $e');
    }
  }
}

/// コレクション統計
class CollectionStatistics {
  final int totalItems;
  final int duplicateItems;
  final int uniqueItems;
  final int manuallyEditedItems;
  final Map<String, int> rarityDistribution;
  final int seriesCount;
  final double completionRate;

  CollectionStatistics({
    required this.totalItems,
    required this.duplicateItems,
    required this.uniqueItems,
    required this.manuallyEditedItems,
    required this.rarityDistribution,
    required this.seriesCount,
    required this.completionRate,
  });
}

/// シリーズ進捗
class SeriesProgressData {
  final String series;
  final int totalItems;
  final int collectedCount;
  final int uniqueCount;
  final int duplicateCount;
  final double completionRate;

  SeriesProgressData({
    required this.series,
    required this.totalItems,
    required this.collectedCount,
    required this.uniqueCount,
    required this.duplicateCount,
    required this.completionRate,
  });
}

/// GachaUsecase の例外クラス
class GachaUsecaseException implements Exception {
  final String message;
  GachaUsecaseException(this.message);

  @override
  String toString() => 'GachaUsecaseException: $message';
}
