import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/gacha_item_model.dart';

/// ガチャアイテムのFirestore リポジトリ
///
/// ガチャアイテムのCRUD操作とFirestore へのデータ永続化を担当します
class GachaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  static const String _collectionName = 'gacha_items';
  static const String _usersCollection = 'users';

  /// ユーザーのすべてのガチャアイテムを取得
  Future<List<GachaItem>> getUserItems(String userId) async {
    try {
      _logger.i('ユーザーのアイテム取得開始: $userId');
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      final items = snapshot.docs
          .map((doc) => GachaItem.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      _logger.i('ユーザーのアイテム取得成功: ${items.length}件');
      return items;
    } catch (e) {
      _logger.e('ユーザーのアイテム取得エラー: $e');
      throw GachaRepositoryException('アイテム取得に失敗しました: $e');
    }
  }

  /// シリーズ別にアイテムを取得
  Future<List<GachaItem>> getUserItemsBySeries(
    String userId,
    String series,
  ) async {
    try {
      _logger.i('シリーズ別アイテム取得開始: $userId, $series');
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_collectionName)
          .where('aiResult.series', isEqualTo: series)
          .orderBy('createdAt', descending: true)
          .get();

      final items = snapshot.docs
          .map((doc) => GachaItem.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      _logger.i('シリーズ別アイテム取得成功: ${items.length}件');
      return items;
    } catch (e) {
      _logger.e('シリーズ別アイテム取得エラー: $e');
      throw GachaRepositoryException('アイテム取得に失敗しました: $e');
    }
  }

  /// レアリティ別にアイテムを取得
  Future<List<GachaItem>> getUserItemsByRarity(
    String userId,
    String rarity,
  ) async {
    try {
      _logger.i('レアリティ別アイテム取得開始: $userId, $rarity');
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_collectionName)
          .where('aiResult.rarity', isEqualTo: rarity)
          .orderBy('createdAt', descending: true)
          .get();

      final items = snapshot.docs
          .map((doc) => GachaItem.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      _logger.i('レアリティ別アイテム取得成功: ${items.length}件');
      return items;
    } catch (e) {
      _logger.e('レアリティ別アイテム取得エラー: $e');
      throw GachaRepositoryException('アイテム取得に失敗しました: $e');
    }
  }

  /// アイテムを追加
  Future<String> addItem(String userId, GachaItem item) async {
    try {
      _logger.i('アイテム追加開始: $userId');

      final dto = GachaItemDTO.fromGachaItem(item);
      final docRef = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_collectionName)
          .add(dto.toJson());

      _logger.i('アイテム追加成功: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      _logger.e('アイテム追加エラー: $e');
      throw GachaRepositoryException('アイテム追加に失敗しました: $e');
    }
  }

  /// アイテムを更新
  Future<void> updateItem(String userId, GachaItem item) async {
    try {
      _logger.i('アイテム更新開始: ${item.id}');

      final dto = GachaItemDTO.fromGachaItem(item);
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_collectionName)
          .doc(item.id)
          .update(dto.toJson());

      _logger.i('アイテム更新成功: ${item.id}');
    } catch (e) {
      _logger.e('アイテム更新エラー: $e');
      throw GachaRepositoryException('アイテム更新に失敗しました: $e');
    }
  }

  /// アイテムを削除
  Future<void> deleteItem(String userId, String itemId) async {
    try {
      _logger.i('アイテム削除開始: $itemId');

      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_collectionName)
          .doc(itemId)
          .delete();

      _logger.i('アイテム削除成功: $itemId');
    } catch (e) {
      _logger.e('アイテム削除エラー: $e');
      throw GachaRepositoryException('アイテム削除に失敗しました: $e');
    }
  }

  /// 重複アイテムをマーク
  Future<void> markAsDuplicate(
    String userId,
    String itemId,
    bool isDuplicate,
  ) async {
    try {
      _logger.i('重複マーク開始: $itemId, $isDuplicate');

      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_collectionName)
          .doc(itemId)
          .update({'isDuplicate': isDuplicate});

      _logger.i('重複マーク成功: $itemId');
    } catch (e) {
      _logger.e('重複マークエラー: $e');
      throw GachaRepositoryException('重複マークに失敗しました: $e');
    }
  }

  /// 手動編集をマーク
  Future<void> markAsManualEdit(
    String userId,
    String itemId,
    bool isManualEdit,
  ) async {
    try {
      _logger.i('手動編集マーク開始: $itemId, $isManualEdit');

      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_collectionName)
          .doc(itemId)
          .update({'isManualEdit': isManualEdit});

      _logger.i('手動編集マーク成功: $itemId');
    } catch (e) {
      _logger.e('手動編集マークエラー: $e');
      throw GachaRepositoryException('手動編集マークに失敗しました: $e');
    }
  }

  /// ユーザーのアイテム統計を取得
  Future<ItemStatistics> getUserStatistics(String userId) async {
    try {
      _logger.i('ユーザー統計取得開始: $userId');

      final items = await getUserItems(userId);

      final totalCount = items.length;
      final duplicateCount = items.where((item) => item.isDuplicate).length;
      final manualEditCount =
          items.where((item) => item.isManualEdit).length;

      final rarityMap = <String, int>{};
      for (var item in items) {
        final rarity = item.aiResult.rarity.value;
        rarityMap[rarity] = (rarityMap[rarity] ?? 0) + 1;
      }

      final seriesMap = <String, int>{};
      for (var item in items) {
        final series = item.aiResult.series;
        seriesMap[series] = (seriesMap[series] ?? 0) + 1;
      }

      final stats = ItemStatistics(
        totalItems: totalCount,
        duplicateItems: duplicateCount,
        manuallyEditedItems: manualEditCount,
        rarityDistribution: rarityMap,
        seriesCount: seriesMap.length,
        uniqueSeriesMap: seriesMap,
      );

      _logger.i('ユーザー統計取得成功');
      return stats;
    } catch (e) {
      _logger.e('ユーザー統計取得エラー: $e');
      throw GachaRepositoryException('統計取得に失敗しました: $e');
    }
  }

  /// シリーズの進捗度を取得
  Future<SeriesProgress> getSeriesProgress(
    String userId,
    String series,
  ) async {
    try {
      _logger.i('シリーズ進捗取得開始: $userId, $series');

      final items = await getUserItemsBySeries(userId, series);

      // TODO: この情報はサーバーから取得する必要があります
      // 一時的にスタックサイズを仮定します
      const totalInSeries = 20; // Placeholder

      final collectedCount = items.length;
      final duplicateCount = items.where((item) => item.isDuplicate).length;
      final uniqueCount = collectedCount - duplicateCount;
      final completionRate = (uniqueCount / totalInSeries).clamp(0.0, 1.0);

      final progress = SeriesProgress(
        series: series,
        totalItems: totalInSeries,
        collectedCount: collectedCount,
        uniqueCount: uniqueCount,
        duplicateCount: duplicateCount,
        completionRate: completionRate,
      );

      _logger.i('シリーズ進捗取得成功');
      return progress;
    } catch (e) {
      _logger.e('シリーズ進捗取得エラー: $e');
      throw GachaRepositoryException('進捗取得に失敗しました: $e');
    }
  }
}

/// ガチャアイテムの統計情報
class ItemStatistics {
  final int totalItems;
  final int duplicateItems;
  final int manuallyEditedItems;
  final Map<String, int> rarityDistribution;
  final int seriesCount;
  final Map<String, int> uniqueSeriesMap;

  ItemStatistics({
    required this.totalItems,
    required this.duplicateItems,
    required this.manuallyEditedItems,
    required this.rarityDistribution,
    required this.seriesCount,
    required this.uniqueSeriesMap,
  });
}

/// シリーズの進捗情報
class SeriesProgress {
  final String series;
  final int totalItems;
  final int collectedCount;
  final int uniqueCount;
  final int duplicateCount;
  final double completionRate;

  SeriesProgress({
    required this.series,
    required this.totalItems,
    required this.collectedCount,
    required this.uniqueCount,
    required this.duplicateCount,
    required this.completionRate,
  });
}

/// GachaRepository の例外クラス
class GachaRepositoryException implements Exception {
  final String message;
  GachaRepositoryException(this.message);

  @override
  String toString() => 'GachaRepositoryException: $message';
}
