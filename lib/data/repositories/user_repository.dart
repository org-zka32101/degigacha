import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

/// ユーザープロフィールのFirestore リポジトリ
///
/// ユーザー情報をFirestore に永続化・管理します
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  static const String _usersCollection = 'users';

  /// ユーザープロフィールを作成
  Future<void> createUser({
    required String userId,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      _logger.i('ユーザープロフィール作成開始: $userId');

      final userData = {
        'uid': userId,
        'email': email,
        'displayName': displayName ?? '',
        'photoUrl': photoUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastSignInAt': FieldValue.serverTimestamp(),
        'preferences': {
          'language': 'ja',
          'theme': 'system', // system, light, dark
          'notifications': true,
        },
        'statistics': {
          'totalItems': 0,
          'completedSeries': 0,
          'tradesCompleted': 0,
        },
      };

      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .set(userData);

      _logger.i('ユーザープロフィール作成成功: $userId');
    } catch (e) {
      _logger.e('ユーザープロフィール作成エラー: $e');
      throw UserRepositoryException('プロフィール作成に失敗しました: $e');
    }
  }

  /// ユーザープロフィールを取得
  Future<UserProfile?> getUser(String userId) async {
    try {
      _logger.i('ユーザープロフィール取得開始: $userId');

      final doc =
          await _firestore.collection(_usersCollection).doc(userId).get();

      if (!doc.exists) {
        _logger.w('ユーザーが見つかりません: $userId');
        return null;
      }

      final profile = UserProfile.fromJson({...doc.data()!, 'id': doc.id});
      _logger.i('ユーザープロフィール取得成功: $userId');
      return profile;
    } catch (e) {
      _logger.e('ユーザープロフィール取得エラー: $e');
      throw UserRepositoryException('プロフィール取得に失敗しました: $e');
    }
  }

  /// ユーザープロフィール を更新
  Future<void> updateUser(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      _logger.i('ユーザープロフィール更新開始: $userId');

      final updateData = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update(updateData);

      _logger.i('ユーザープロフィール更新成功: $userId');
    } catch (e) {
      _logger.e('ユーザープロフィール更新エラー: $e');
      throw UserRepositoryException('プロフィール更新に失敗しました: $e');
    }
  }

  /// ユーザー設定を更新
  Future<void> updatePreferences(
    String userId,
    UserPreferences preferences,
  ) async {
    try {
      _logger.i('ユーザー設定更新開始: $userId');

      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'preferences': preferences.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _logger.i('ユーザー設定更新成功: $userId');
    } catch (e) {
      _logger.e('ユーザー設定更新エラー: $e');
      throw UserRepositoryException('設定更新に失敗しました: $e');
    }
  }

  /// ユーザーの統計情報を更新
  Future<void> updateStatistics(
    String userId,
    Map<String, dynamic> statistics,
  ) async {
    try {
      _logger.i('ユーザー統計更新開始: $userId');

      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'statistics': statistics,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _logger.i('ユーザー統計更新成功: $userId');
    } catch (e) {
      _logger.e('ユーザー統計更新エラー: $e');
      throw UserRepositoryException('統計更新に失敗しました: $e');
    }
  }

  /// 最終ログイン時刻を更新
  Future<void> updateLastSignIn(String userId) async {
    try {
      _logger.i('最終ログイン時刻更新開始: $userId');

      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'lastSignInAt': FieldValue.serverTimestamp(),
      });

      _logger.i('最終ログイン時刻更新成功: $userId');
    } catch (e) {
      _logger.e('最終ログイン時刻更新エラー: $e');
      throw UserRepositoryException('ログイン時刻更新に失敗しました: $e');
    }
  }

  /// ユーザーを削除
  Future<void> deleteUser(String userId) async {
    try {
      _logger.i('ユーザー削除開始: $userId');

      // TODO: Delete associated data (gacha_items, trades, etc.)
      await _firestore.collection(_usersCollection).doc(userId).delete();

      _logger.i('ユーザー削除成功: $userId');
    } catch (e) {
      _logger.e('ユーザー削除エラー: $e');
      throw UserRepositoryException('ユーザー削除に失敗しました: $e');
    }
  }
}

/// ユーザープロフィール
class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastSignInAt;
  final UserPreferences preferences;
  final UserStatistics statistics;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.lastSignInAt,
    required this.preferences,
    required this.statistics,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSignInAt:
          (json['lastSignInAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      preferences: UserPreferences.fromJson(
        json['preferences'] as Map<String, dynamic>? ?? {},
      ),
      statistics: UserStatistics.fromJson(
        json['statistics'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastSignInAt': lastSignInAt,
      'preferences': preferences.toJson(),
      'statistics': statistics.toJson(),
    };
  }
}

/// ユーザー設定
class UserPreferences {
  final String language;
  final String theme;
  final bool notifications;

  UserPreferences({
    required this.language,
    required this.theme,
    required this.notifications,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      language: json['language'] ?? 'ja',
      theme: json['theme'] ?? 'system',
      notifications: json['notifications'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'theme': theme,
      'notifications': notifications,
    };
  }
}

/// ユーザー統計
class UserStatistics {
  final int totalItems;
  final int completedSeries;
  final int tradesCompleted;

  UserStatistics({
    required this.totalItems,
    required this.completedSeries,
    required this.tradesCompleted,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalItems: json['totalItems'] ?? 0,
      completedSeries: json['completedSeries'] ?? 0,
      tradesCompleted: json['tradesCompleted'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'completedSeries': completedSeries,
      'tradesCompleted': tradesCompleted,
    };
  }
}

/// UserRepository の例外クラス
class UserRepositoryException implements Exception {
  final String message;
  UserRepositoryException(this.message);

  @override
  String toString() => 'UserRepositoryException: $message';
}
