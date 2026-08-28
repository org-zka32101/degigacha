import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';

/// 認証状態の変更を通知
///
/// ユーザーのサインイン/サインアウト状態を管理します
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState.initial()) {
    // Listen to auth state changes
    _authService.authStateStream.listen((user) {
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    });

    // Check initial auth state
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      state = AuthState.authenticated(currentUser);
    }
  }

  /// メール/パスワードでサインイン
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      final user = _authService.currentUser;
      if (user != null) {
        state = AuthState.authenticated(user);
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// メール/パスワードでサインアップ
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      final user = _authService.currentUser;
      if (user != null) {
        state = AuthState.authenticated(user);
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Google Sign-In
  Future<void> signInWithGoogle() async {
    state = const AuthState.loading();
    try {
      await _authService.signInWithGoogle();
      final user = _authService.currentUser;
      if (user != null) {
        state = AuthState.authenticated(user);
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Apple Sign-In
  Future<void> signInWithApple() async {
    state = const AuthState.loading();
    try {
      await _authService.signInWithApple();
      final user = _authService.currentUser;
      if (user != null) {
        state = AuthState.authenticated(user);
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// サインアウト
  Future<void> signOut() async {
    state = const AuthState.loading();
    try {
      await _authService.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// パスワードリセット
  Future<void> resetPassword(String email) async {
    state = const AuthState.loading();
    try {
      await _authService.resetPassword(email);
      state = const AuthState.passwordResetSent();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}

/// 認証状態を表現するクラス
sealed class AuthState {
  const AuthState();

  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
  const factory AuthState.passwordResetSent() = _PasswordResetSent;

  bool get isLoading => this is _Loading;
  bool get isAuthenticated => this is _Authenticated;
  User? get user => switch (this) {
        _Authenticated(user: final user) => user,
        _ => null,
      };
  String? get errorMessage => switch (this) {
        _Error(message: final message) => message,
        _ => null,
      };
}

class _Initial extends AuthState {
  const _Initial();
}

class _Loading extends AuthState {
  const _Loading();
}

class _Authenticated extends AuthState {
  final User user;
  const _Authenticated(this.user);
}

class _Unauthenticated extends AuthState {
  const _Unauthenticated();
}

class _Error extends AuthState {
  final String message;
  const _Error(this.message);
}

class _PasswordResetSent extends AuthState {
  const _PasswordResetSent();
}
