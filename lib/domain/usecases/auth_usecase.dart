import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/user_repository.dart';
import '../../services/auth_service.dart';

/// 認証ユースケース
///
/// ビジネスロジック層でのユーザー認証と管理
class AuthUsecase {
  final AuthService _authService;
  final UserRepository _userRepository;

  AuthUsecase({
    required AuthService authService,
    required UserRepository userRepository,
  })  : _authService = authService,
        _userRepository = userRepository;

  /// メール/パスワードでサインアップ
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Firebase Auth でユーザー作成
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthUsecaseException('ユーザー作成に失敗しました');
      }

      // プロフィール更新
      if (displayName != null && displayName.isNotEmpty) {
        await _authService.updateUserProfile(displayName: displayName);
      }

      // Firestore にユーザープロフィール作成
      // （Cloud Functions の onUserCreate トリガーで自動作成されるが、念のため）
      await _userRepository.createUser(
        userId: user.uid,
        email: user.email!,
        displayName: displayName,
      );

      return user;
    } catch (e) {
      throw AuthUsecaseException('サインアップに失敗しました: $e');
    }
  }

  /// メール/パスワードでサインイン
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Firebase Auth でサインイン
      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthUsecaseException('サインインに失敗しました');
      }

      // Firestore のユーザープロフィール更新
      await _userRepository.updateLastSignIn(user.uid);

      return user;
    } catch (e) {
      throw AuthUsecaseException('サインインに失敗しました: $e');
    }
  }

  /// Google Sign-In
  Future<User> signInWithGoogle() async {
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null || credential.user == null) {
        throw AuthUsecaseException('Google Sign-Inに失敗しました');
      }

      final user = credential.user!;
      await _userRepository.updateLastSignIn(user.uid);
      return user;
    } catch (e) {
      throw AuthUsecaseException('Google Sign-Inに失敗しました: $e');
    }
  }

  /// Apple Sign-In (iOS)
  Future<User> signInWithApple() async {
    try {
      final credential = await _authService.signInWithApple();
      if (credential == null || credential.user == null) {
        throw AuthUsecaseException('Apple Sign-Inに失敗しました');
      }

      final user = credential.user!;
      await _userRepository.updateLastSignIn(user.uid);
      return user;
    } catch (e) {
      throw AuthUsecaseException('Apple Sign-Inに失敗しました: $e');
    }
  }

  /// サインアウト
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw AuthUsecaseException('サインアウトに失敗しました: $e');
    }
  }

  /// パスワードリセット
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      throw AuthUsecaseException('パスワードリセットに失敗しました: $e');
    }
  }

  /// ユーザープロフィール取得
  Future<UserProfileData> getUserProfile(String userId) async {
    try {
      final profile = await _userRepository.getUser(userId);
      if (profile == null) {
        throw AuthUsecaseException('プロフィール取得に失敗しました');
      }

      return UserProfileData(
        uid: profile.id,
        email: profile.email,
        displayName: profile.displayName,
        photoUrl: profile.photoUrl,
      );
    } catch (e) {
      throw AuthUsecaseException('プロフィール取得に失敗しました: $e');
    }
  }

  /// ユーザープロフィール更新
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (displayName != null) {
        updateData['displayName'] = displayName;
      }
      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }

      if (updateData.isNotEmpty) {
        await _userRepository.updateUser(userId, updateData);
      }

      // Firebase Auth プロフィールも更新
      await _authService.updateUserProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
    } catch (e) {
      throw AuthUsecaseException('プロフィール更新に失敗しました: $e');
    }
  }
}

/// ユーザープロフィールデータ
class UserProfileData {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;

  UserProfileData({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
  });
}

/// AuthUsecase の例外クラス
class AuthUsecaseException implements Exception {
  final String message;
  AuthUsecaseException(this.message);

  @override
  String toString() => 'AuthUsecaseException: $message';
}
