import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ai_service.dart';
import '../../services/auth_service.dart';
import 'auth_notifier.dart';

// ========== Service Providers ==========

/// AuthService を提供するプロバイダー
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// AIService を提供するプロバイダー
final aiServiceProvider = Provider<AIService>((ref) {
  // TODO: Replace with actual API key from environment or secure storage
  const apiKey = 'sk-ant-example-key-replace-in-production';
  return AIService(apiKey: apiKey);
});

// ========== State Management Providers ==========

/// 認証状態を管理するプロバイダー
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// 現在のユーザーUID を取得するプロバイダー
final userIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user?.uid;
});

/// 現在のユーザーメール を取得するプロバイダー
final userEmailProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user?.email;
});

/// 認証済みかチェックするプロバイダー
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isAuthenticated;
});

// ========== Gacha Items State Management ==========
// TODO: Implement after Firestore repository setup

// /// ガチャアイテムリストプロバイダー
// final gachaItemsProvider = FutureProvider<List<GachaItem>>((ref) async {
//   final userId = ref.watch(userIdProvider);
//   if (userId == null) return [];
//
//   final repository = ref.watch(gachaRepositoryProvider);
//   return repository.getUserItems(userId);
// });

// /// ガチャアイテム追加プロバイダー
// final addGachaItemProvider = FutureProvider.family<void, GachaItem>((ref, item) async {
//   final repository = ref.watch(gachaRepositoryProvider);
//   await repository.addItem(item);
//   ref.refresh(gachaItemsProvider);
// });

// ========== AI Judgment State Management ==========
// TODO: Implement after AI service integration

// /// AI判定実行プロバイダー
// final aiJudgmentProvider = FutureProvider.family<AIResult, String>((ref, imagePath) async {
//   final aiService = ref.watch(aiServiceProvider);
//   return aiService.identifyGachaItem(imagePath);
// });

// ========== UI State Management ==========

/// アプリローディング状態
final appLoadingProvider = StateProvider<bool>((ref) {
  return false;
});

/// エラーメッセージ表示用
final errorMessageProvider = StateProvider<String?>((ref) {
  return null;
});

/// 成功メッセージ表示用
final successMessageProvider = StateProvider<String?>((ref) {
  return null;
});
