import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

/// Firebase認証サービス
///
/// ユーザー認証を管理します：
/// - Google Sign-In
/// - Apple Sign-In
/// - メール/パスワード認証
/// - ユーザーセッション管理
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  /// 現在のユーザーを取得
  User? get currentUser => _firebaseAuth.currentUser;

  /// ユーザー認証状態ストリーム
  Stream<User?> get authStateStream => _firebaseAuth.authStateChanges();

  /// ユーザーがログイン済みかチェック
  bool get isLoggedIn => currentUser != null;

  /// ユーザーUID を取得
  String? get userId => currentUser?.uid;

  /// Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      _logger.i('Google Sign-In開始');

      // TODO: Implement Google Sign-In
      // GoogleSignInプラグインを使用して実装予定
      // final GoogleSignIn googleSignIn = GoogleSignIn();
      // final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      // final GoogleSignInAuthentication googleAuth =
      //     await googleUser!.authentication;
      // final credential = GoogleAuthProvider.credential(
      //   accessToken: googleAuth.accessToken,
      //   idToken: googleAuth.idToken,
      // );
      // return await _firebaseAuth.signInWithCredential(credential);

      throw UnimplementedError('Google Sign-Inはまだ実装されていません');
    } catch (e) {
      _logger.e('Google Sign-Inエラー: $e');
      throw AuthServiceException('Google Sign-Inに失敗しました: $e');
    }
  }

  /// Apple Sign-In (iOS)
  Future<UserCredential?> signInWithApple() async {
    try {
      _logger.i('Apple Sign-In開始');

      // TODO: Implement Apple Sign-In
      // sign_in_with_appleプラグインを使用して実装予定

      throw UnimplementedError('Apple Sign-Inはまだ実装されていません');
    } catch (e) {
      _logger.e('Apple Sign-Inエラー: $e');
      throw AuthServiceException('Apple Sign-Inに失敗しました: $e');
    }
  }

  /// メール/パスワード でサインアップ
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('メールでサインアップ開始: $email');
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger.i('メールでサインアップ成功: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      _logger.e('メールサインアップエラー: ${e.code} - ${e.message}');
      throw AuthServiceException(_getErrorMessage(e.code));
    } catch (e) {
      _logger.e('メールサインアップエラー: $e');
      throw AuthServiceException('サインアップに失敗しました: $e');
    }
  }

  /// メール/パスワード でサインイン
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('メールでサインイン開始: $email');
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger.i('メールでサインイン成功: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      _logger.e('メールサインインエラー: ${e.code} - ${e.message}');
      throw AuthServiceException(_getErrorMessage(e.code));
    } catch (e) {
      _logger.e('メールサインインエラー: $e');
      throw AuthServiceException('サインインに失敗しました: $e');
    }
  }

  /// サインアウト
  Future<void> signOut() async {
    try {
      _logger.i('サインアウト開始');
      await _firebaseAuth.signOut();
      _logger.i('サインアウト成功');
    } catch (e) {
      _logger.e('サインアウトエラー: $e');
      throw AuthServiceException('サインアウトに失敗しました: $e');
    }
  }

  /// パスワードリセット
  Future<void> resetPassword(String email) async {
    try {
      _logger.i('パスワードリセット開始: $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _logger.i('パスワードリセットメール送信成功');
    } on FirebaseAuthException catch (e) {
      _logger.e('パスワードリセットエラー: ${e.code} - ${e.message}');
      throw AuthServiceException(_getErrorMessage(e.code));
    } catch (e) {
      _logger.e('パスワードリセットエラー: $e');
      throw AuthServiceException('パスワードリセットに失敗しました: $e');
    }
  }

  /// ユーザープロフィール更新
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      _logger.i('ユーザープロフィール更新開始');
      await currentUser?.updateProfile(
        displayName: displayName ?? currentUser?.displayName,
        photoURL: photoUrl ?? currentUser?.photoURL,
      );
      _logger.i('ユーザープロフィール更新成功');
    } catch (e) {
      _logger.e('プロフィール更新エラー: $e');
      throw AuthServiceException('プロフィール更新に失敗しました: $e');
    }
  }

  /// メール検証
  Future<void> sendEmailVerification() async {
    try {
      _logger.i('メール検証メール送信開始');
      await currentUser?.sendEmailVerification();
      _logger.i('メール検証メール送信成功');
    } catch (e) {
      _logger.e('メール検証エラー: $e');
      throw AuthServiceException('メール検証に失敗しました: $e');
    }
  }

  /// Firebase Auth エラーメッセージを日本語に変換
  String _getErrorMessage(String errorCode) {
    return switch (errorCode) {
      'user-not-found' => 'ユーザーが見つかりません',
      'wrong-password' => 'パスワードが間違っています',
      'email-already-in-use' => 'このメールアドレスは既に登録されています',
      'weak-password' => 'パスワードが弱すぎます（6文字以上）',
      'invalid-email' => 'メールアドレスが無効です',
      'user-disabled' => 'このユーザーアカウントは無効化されています',
      'too-many-requests' => 'リクエストが多すぎます。後でお試しください',
      'operation-not-allowed' => 'この操作は許可されていません',
      'invalid-credential' => '認証情報が無効です',
      _ => 'エラーが発生しました: $errorCode',
    };
  }
}

/// AuthService の例外クラス
class AuthServiceException implements Exception {
  final String message;
  AuthServiceException(this.message);

  @override
  String toString() => 'AuthServiceException: $message';
}
