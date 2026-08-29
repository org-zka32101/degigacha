import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';

/// Firebase Storage を使用したファイルアップロードサービス
class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final Logger _logger = Logger();

  static const String _gachaItemsPath = 'gacha_items';
  static const int _maxRetries = 3;

  /// ガチャアイテムの画像をアップロード
  ///
  /// [userId]: ユーザーID
  /// [imagePath]: ローカル画像ファイルパス
  /// [itemId]: アイテムID（オプション、生成される場合がある）
  ///
  /// Returns: Firebase Storage のダウンロード URL
  /// Throws: StorageServiceException
  Future<String> uploadGachaItemImage({
    required String userId,
    required String imagePath,
    String? itemId,
  }) async {
    try {
      _logger.i('画像アップロード開始: $userId, $imagePath');

      final file = File(imagePath);
      if (!file.existsSync()) {
        throw StorageServiceException('ファイルが見つかりません: $imagePath');
      }

      // アイテムID が提供されていない場合は生成
      final id = itemId ?? _generateItemId();

      // ファイル拡張子を取得
      final extension = imagePath.split('.').last.toLowerCase();

      // Firebase Storage パス: gacha_items/{userId}/{itemId}.{ext}
      final storagePath = '$_gachaItemsPath/$userId/$id.$extension';
      final storageRef = _firebaseStorage.ref(storagePath);

      // ファイルをアップロード（リトライあり）
      String downloadUrl = '';
      for (int attempt = 0; attempt < _maxRetries; attempt++) {
        try {
          await storageRef.putFile(file);
          downloadUrl = await storageRef.getDownloadURL();
          _logger.i('画像アップロード成功: $storagePath');
          break;
        } catch (e) {
          _logger.w('アップロードリトライ ${attempt + 1}/$_maxRetries: $e');
          if (attempt == _maxRetries - 1) rethrow;
          await Future.delayed(Duration(seconds: (attempt + 1) * 2));
        }
      }

      return downloadUrl;
    } catch (e) {
      _logger.e('画像アップロードエラー: $e');
      throw StorageServiceException('画像アップロードに失敗しました: $e');
    }
  }

  /// 複数の画像をバッチアップロード
  Future<List<String>> uploadMultipleGachaImages({
    required String userId,
    required List<String> imagePaths,
  }) async {
    try {
      _logger.i('バッチアップロード開始: ${imagePaths.length} 枚');

      final urls = <String>[];
      for (final imagePath in imagePaths) {
        final url = await uploadGachaItemImage(
          userId: userId,
          imagePath: imagePath,
        );
        urls.add(url);
      }

      _logger.i('バッチアップロード完了: ${urls.length} 枚');
      return urls;
    } catch (e) {
      _logger.e('バッチアップロードエラー: $e');
      throw StorageServiceException('バッチアップロードに失敗しました: $e');
    }
  }

  /// 画像を削除
  Future<void> deleteGachaItemImage({
    required String userId,
    required String itemId,
    required String fileExtension,
  }) async {
    try {
      _logger.i('画像削除開始: $userId, $itemId');

      final storagePath =
          '$_gachaItemsPath/$userId/$itemId.$fileExtension';
      final storageRef = _firebaseStorage.ref(storagePath);

      await storageRef.delete();
      _logger.i('画像削除成功: $storagePath');
    } catch (e) {
      _logger.e('画像削除エラー: $e');
      throw StorageServiceException('画像削除に失敗しました: $e');
    }
  }

  /// ユーザーの全画像を削除（アカウント削除時）
  Future<void> deleteUserGachaImages(String userId) async {
    try {
      _logger.i('ユーザー画像削除開始: $userId');

      final userPath = '$_gachaItemsPath/$userId';
      final listResult = await _firebaseStorage.ref(userPath).listAll();

      for (final file in listResult.items) {
        await file.delete();
      }

      _logger.i('ユーザー画像削除完了: ${listResult.items.length} ファイル');
    } catch (e) {
      _logger.e('ユーザー画像削除エラー: $e');
      throw StorageServiceException('ユーザー画像削除に失敗しました: $e');
    }
  }

  /// アイテムID を生成（タイムスタンプベース）
  String _generateItemId() {
    return 'item_${DateTime.now().millisecondsSinceEpoch}';
  }
}

/// StorageService の例外クラス
class StorageServiceException implements Exception {
  final String message;
  StorageServiceException(this.message);

  @override
  String toString() => 'StorageServiceException: $message';
}
