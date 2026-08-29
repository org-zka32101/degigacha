import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/gacha_series_model.dart';
import '../models/gacha_item_model.dart';

/// ガチャシリーズのFirestoreリポジトリ
///
/// ガチャシリーズのCRUD操作とFirestoreへのデータ永続化を担当します
class SeriesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  static const String _seriesCollection = 'gacha_series';
  static const String _usersCollection = 'users';
  static const String _itemsCollection = 'gacha_items';

  /// すべてのアクティブなシリーズを取得
  Future<List<GachaSeries>> getAllActiveSeries() async {
    try {
      _logger.i('アクティブなシリーズ一覧取得開始');
      final snapshot = await _firestore
          .collection(_seriesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final series = snapshot.docs
          .map((doc) => GachaSeries.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      _logger.i('アクティブなシリーズ一覧取得成功: ${series.length}件');
      return series;
    } catch (e) {
      _logger.e('アクティブなシリーズ一覧取得エラー: $e');
      throw SeriesRepositoryException('シリーズ取得に失敗しました: $e');
    }
  }

  /// ユーザーがコレクションしたシリーズを取得
  Future<List<GachaSeries>> getUserCollectedSeries(String userId) async {
    try {
      _logger.i('ユーザーのコレクションシリーズ取得開始: $userId');

      // ユーザーが持っているすべてのアイテムを取得
      final itemsSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_itemsCollection)
          .get();

      // シリーズ名を集計
      final seriesNames = <String>{};
      for (var doc in itemsSnapshot.docs) {
        final data = doc.data();
        if (data['aiResult'] != null && data['aiResult']['series'] != null) {
          seriesNames.add(data['aiResult']['series'] as String);
        }
      }

      // 各シリーズの情報を取得
      final series = <GachaSeries>[];
      for (var seriesName in seriesNames) {
        try {
          final seriesSnapshot = await _firestore
              .collection(_seriesCollection)
              .where('name', isEqualTo: seriesName)
              .limit(1)
              .get();

          if (seriesSnapshot.docs.isNotEmpty) {
            final doc = seriesSnapshot.docs.first;
            final gachaSeries = GachaSeries.fromJson({...doc.data(), 'id': doc.id});

            // ユーザーが持っているこのシリーズのアイテム数を計算
            final collectedCount = itemsSnapshot.docs
                .where((item) => item['aiResult']?['series'] == seriesName)
                .length;

            series.add(gachaSeries.copyWith(collectedItems: collectedCount));
          }
        } catch (e) {
          _logger.w('シリーズ情報取得エラー: $seriesName - $e');
        }
      }

      _logger.i('ユーザーのコレクションシリーズ取得成功: ${series.length}件');
      return series;
    } catch (e) {
      _logger.e('ユーザーのコレクションシリーズ取得エラー: $e');
      throw SeriesRepositoryException('シリーズ取得に失敗しました: $e');
    }
  }

  /// シリーズIDで取得
  Future<GachaSeries> getSeriesById(String seriesId) async {
    try {
      _logger.i('シリーズ取得開始: $seriesId');
      final doc = await _firestore
          .collection(_seriesCollection)
          .doc(seriesId)
          .get();

      if (!doc.exists) {
        throw SeriesRepositoryException('シリーズが見つかりません: $seriesId');
      }

      final series =
          GachaSeries.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});

      _logger.i('シリーズ取得成功: $seriesId');
      return series;
    } catch (e) {
      _logger.e('シリーズ取得エラー: $e');
      throw SeriesRepositoryException('シリーズ取得に失敗しました: $e');
    }
  }

  /// シリーズ名で取得
  Future<GachaSeries> getSeriesByName(String name) async {
    try {
      _logger.i('シリーズ取得開始（名前で検索）: $name');
      final snapshot = await _firestore
          .collection(_seriesCollection)
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw SeriesRepositoryException('シリーズが見つかりません: $name');
      }

      final doc = snapshot.docs.first;
      final series =
          GachaSeries.fromJson({...doc.data(), 'id': doc.id});

      _logger.i('シリーズ取得成功: $name');
      return series;
    } catch (e) {
      _logger.e('シリーズ取得エラー: $e');
      throw SeriesRepositoryException('シリーズ取得に失敗しました: $e');
    }
  }

  /// シリーズを追加
  Future<String> addSeries(GachaSeries series) async {
    try {
      _logger.i('シリーズ追加開始: ${series.name}');

      final dto = GachaSeriesDTO.fromGachaSeries(series);
      final docRef =
          await _firestore.collection(_seriesCollection).add(dto.toJson());

      _logger.i('シリーズ追加成功: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      _logger.e('シリーズ追加エラー: $e');
      throw SeriesRepositoryException('シリーズ追加に失敗しました: $e');
    }
  }

  /// シリーズを更新
  Future<void> updateSeries(GachaSeries series) async {
    try {
      _logger.i('シリーズ更新開始: ${series.id}');

      final dto = GachaSeriesDTO.fromGachaSeries(series);
      await _firestore
          .collection(_seriesCollection)
          .doc(series.id)
          .update(dto.toJson());

      _logger.i('シリーズ更新成功: ${series.id}');
    } catch (e) {
      _logger.e('シリーズ更新エラー: $e');
      throw SeriesRepositoryException('シリーズ更新に失敗しました: $e');
    }
  }

  /// シリーズを削除
  Future<void> deleteSeries(String seriesId) async {
    try {
      _logger.i('シリーズ削除開始: $seriesId');

      await _firestore
          .collection(_seriesCollection)
          .doc(seriesId)
          .delete();

      _logger.i('シリーズ削除成功: $seriesId');
    } catch (e) {
      _logger.e('シリーズ削除エラー: $e');
      throw SeriesRepositoryException('シリーズ削除に失敗しました: $e');
    }
  }
}

/// SeriesRepository の例外クラス
class SeriesRepositoryException implements Exception {
  final String message;
  SeriesRepositoryException(this.message);

  @override
  String toString() => 'SeriesRepositoryException: $message';
}
