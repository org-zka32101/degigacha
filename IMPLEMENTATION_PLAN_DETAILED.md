# デジタルガチャ帳 - 詳細実装計画

**生成日**: 2026-08-28  
**計画期間**: 8-12週間（Phase 0 → Phase 17）  
**リリース目標**: Week 10-11

> この計画は AI Agentにより生成された段階的実装ロードマップです。
> Phase 3（AI精度検証）の成功が本開発の前提条件です。

## 📌 Executive Summary

- **MVP (Aha Moment)**: Week 4-5
- **Beta版**: Week 8
- **リリース候補(RC)**: Week 9-10
- **App Store/Play提出**: Week 10
- **本番リリース**: Week 10-11

## 🎯 前提条件

**🔴 CRITICAL**: Phase 3（AI画像認識検証）で以下を達成する必要があります：
- AI判定精度 ≥ 85%
- 修正率 ≤ 15%
- 平均判定時間 < 5秒

達成できない場合は、プロンプト最適化後に再検証するか、本開発を見送ります。

## 📊 17フェーズ詳細

### Phase 0: 基礎構築（Week 1）
**目標**: プロジェクト構造確立 & 開発環境セットアップ

**成果物**:
- Flutter新規プロジェクト初期化
- pubspec.yaml全依存パッケージ設定
- ディレクトリ構造構築
- Firebase接続確認
- iOS/Androidネイティブ設定

**チェックポイント**:
- [ ] `flutter pub get` 成功
- [ ] iOS Pods インストール完了
- [ ] Android Gradle ビルド成功
- [ ] Firebase初期化テスト
- [ ] 動作確認（アプリ起動）

**メイン依存パッケージ**:
```
riverpod, flutter_riverpod
cloud_firestore, firebase_auth, firebase_storage
image_picker, camera
lottie
go_router
firebase_analytics, firebase_crashlytics
http (Claude API)
```

---

### Phase 1-2: データモデル & Firebase設定（Week 1-3）

**Firestore コレクション構造**:
- `users/{uid}` - ユーザー情報
- `gacha_items/{docId}` - 所持アイテム（AI結果含む）
- `collection_templates/{templateId}` - 図鑑テンプレート
- `trade_requests/{tradeId}` - 交換リクエスト

**チェックポイント**:
- [ ] Firestore コレクション・セキュリティルール設定
- [ ] Dart models に fromJson/toJson/copyWith 実装
- [ ] Repository パターン確立
- [ ] Unit テスト

---

### 🔴 Phase 3: 7日AI認識検証（Week 3-4）

**目標**: 本開発の前提条件検証

**実施内容**:
1. **Day 1-2**: テスト画像DB作成（シリーズ3-5本分）
2. **Day 3-4**: Claude Vision照合テスト（20-30枚実写真）
3. **Day 5-6**: 精度分析 → 候補提示UI閾値調整
4. **Day 7**: Go/No-Go判定

**成功基準**:
- AI精度 ≥ 85%
- 修正率 ≤ 15%
- 判定時間 < 5秒

**失敗時対応**:
- プロンプト最適化 → 再テスト
- Claude他モデル試行
- 必要に応じ本開発見送り

---

### Phase 4-5: Aha Moment実装（Week 4-5）

**目標**: 3タップで完結する初回体験

**実装画面**:
1. Home画面（撮影ボタン大きく）
2. CaptureScreen（ネイティブカメラ）
3. AIJudgingScreen（Lottie紙吹雪）
4. ConfirmScreen（結果表示・修正オプション）
5. ManualEditScreen（手動調整）

**ユーザーフロー**:
```
Home → (撮影) → Capture → AI判定中 → Confirm → 登録完了
                           ↓
                      (修正希望) → ManualEdit → 保存
```

**チェックポイント**:
- [ ] 撮影～登録が 3-5 分以内
- [ ] Camera初期化エラーハンドリング
- [ ] AI API呼び出しテスト
- [ ] Firebase Analytics イベント発火

---

### Phase 6-8: 全画面UI & ナビゲーション（Week 5-7）

**実装画面**:
- Collection Home（グリッド・フィルタ・ソート）
- Collection Detail（アイテム詳細・拡大表示）
- Trade Management（ダブり一覧・交換マッチング）
- User Profile（統計情報）
- Settings（ログアウト・通知設定）
- Onboarding（4スライド）

**テーマ・デザイン**:
- Material Design 3準拠
- Light/Darkモード対応
- 多言語対応基盤

**ナビゲーション**:
- GoRouter による宣言的ナビゲーション
- ディープリンク対応

---

### Phase 9-11: 機能実装の深化（Week 7-8）

**Onboarding + Paywall**:
- 3-4スライドのオンボーディング
- Premium機能（台紙デザイン、テーマ、DM等）
- 課金実装（月額/年額プラン）

**Retention トリガー**:
- デイリーボーナス
- プッシュ通知
- ゲーミフィケーション（バッジ、マイルストーン）

**ダブり交換マッチング**:
- ダブル検出アルゴリズム
- 交換マッチングエンジン
- 交換リクエスト承認フロー

---

### Phase 12-14: 品質保証（Week 8-9）

**エラーハンドリング**:
- 例外処理フレームワーク
- ネットワークエラー・リトライ
- オフライン対応

**テスト**:
- Unit Tests (カバレッジ ≥ 70%)
- Widget Tests (全主要画面)
- Integration Tests (主要フロー)

**CI/CD**:
- GitHub Actions ワークフロー
- 自動テスト実行
- 自動ビルド (iOS/Android)
- デプロイ自動化

---

### Phase 15-17: リリース & 継続開発（Week 9-11+）

**リリース準備**:
- App Store Connect設定
- Google Play Console設定
- ガイドライン遵守確認
- Beta テスト実施（100+テスター）

**本番化後**:
- Metricsダッシュボード構築
- ユーザーフィードバック監視
- A/Bテスト実施
- 継続的改善ループ

---

## 🚨 リスク管理

| リスク | 影響度 | 対策 |
|--------|--------|------|
| AI精度不足 | 🔴 高 | Phase 3で85%達成が必須条件 |
| Firebase コスト超過 | 🟡 中 | インデックス設計・キャッシング |
| iOS/Android ネイティブ問題 | 🟡 中 | 早期実デバイステスト |
| API レート制限 | 🟡 中 | バッチ処理・キューシステム |
| セキュリティ脆弱性 | 🔴 高 | Code review・OWASP チェック |

---

## 📈 KPI 目標

| 指標 | 目標 | 測定方法 |
|------|------|---------|
| Day 7 リテンション | 15%+ | Firebase Analytics |
| Day 30 リテンション | 6%+ | Firebase Analytics |
| AI判定精度 | 70%+ | 本番環境実データ |
| 交換成立率 | 10%+ | Firestore クエリ |
| Crash Rate | < 1% | Firebase Crashlytics |

---

## 🎓 実装キー ファイル（優先順位）

**最初に作成すべき**:
1. `lib/main.dart` - アプリエントリーポイント・Router
2. `lib/data/models/gacha_item_model.dart` - コアデータモデル
3. `lib/services/ai_service.dart` - Claude Vision 統合
4. `lib/presentation/screens/capture_screen.dart` - Aha Moment中心
5. `lib/config/router.dart` - Navigation
6. `lib/presentation/riverpod/providers/gacha_provider.dart` - State管理
7. `.github/workflows/test.yml` - CI/CDパイプライン

---

## ✍️ 進捗追跡

各フェーズの完了時に以下をチェック：
- [ ] コード Review 実施
- [ ] 全テスト成功
- [ ] ドキュメント更新
- [ ] PRマージ
- [ ] デプロイ確認

---

**生成**: Plan エージェント  
**最終更新**: 2026-08-28
