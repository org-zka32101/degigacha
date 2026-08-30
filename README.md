# デジタルガチャ帳 (Digital Gacha Collection) 📱

> ガチャの戦利品を撮るだけで、AIが自動認識してあなただけの図鑑に。
> 
> 撮影 → AI自動判定 → 図鑑登録 の3タップで、集める喜びが記録に変わる。

## 🎯 ビジョン

「ガチャで得た1つ1つの戦利品が、撮るだけで自分だけの図鑑になり、集める喜びが記録として残り続ける世界」

## ⭐ コア機能

| 機能 | 説明 |
|------|------|
| **📸 AI自動判定** | 撮った写真からカプセルトイの品番を自動認識 (Claude Vision) |
| **📖 自動図鑑登録** | AI判定結果を即座にコレクション帳に追加 |
| **📊 進捗ゲーム化** | シリーズ完成度をゲージで可視化 |
| **🔄 ダブり交換** | 重複アイテムを他ユーザーと交換可能 |
| **🎨 台紙カスタマイズ** | コレクション帳の背景・並び替え自由 |
| **🚫 手動修正** | AI誤判定時も手入力で即対応 |

## 🛠 テック スタック

```
Frontend:    Flutter 3.x / Dart + Riverpod
Backend:     Firestore + Firebase Auth + Firebase Storage
AI:          Claude Vision API (petit_ai層経由)
Analytics:   Firebase Analytics / Crashlytics / Remote Config
Monetize:    RevenueCat (課金管理)
UI/UX:       Lottie (アニメ) + ハプティクス + Sound FX
CI/CD:       GitHub Actions → TestFlight / Firebase App Distribution
```

## 📋 Must機能（リリース必須）

- [x] カメラ撮影 → AI自動判定 → 図鑑登録
- [x] コンプ進捗ゲージ + 演出
- [x] 手動編集（誤判定修正/フォールバック）
- [x] ダブり管理 + 交換マッチング（継続性の核）
- [x] 図鑝カスタマイズ（台紙・並び替え）

## 🎮 Aha Moment

**初回撮影でAIがシリーズ認識 → 図鑑に自動登録される瞬間**

→ Lottie紙吹雪 + コレクション帳に滑り込むアニメで感動体験

## 💰 マネタイズ戦略

- **AI認識**: 無料（コア差別化を課金障壁にしない）
- **課金対象**:
  - 限定デコ台紙
  - 演出スキン
  - 交換マッチング優先表示
  - DM機能
- **ペイウォール位置**: コンプ達成直後の「記念台紙」購入導線

## 📊 KPI

| 指標 | 目標 |
|------|------|
| Day7 リテンション | 15%+ |
| Day30 リテンション | 6%+ |
| AI判定成功率 | 70%+ (7日プロトで検証) |
| 交換マッチング成立率 | 10%+ |

## 🚀 開発ステータス

**Current Phase**: Phase 6 Preview ✅ COMPLETE (50% Overall Progress)

### Completed Phases
- ✅ Phase 0: Flutter Infrastructure Setup
- ✅ Phase 1: Firebase Firestore & Data Persistence
- ✅ Phase 2: Authentication Flow
- ✅ Phase 4-5: Aha Moment Implementation (Capture + AI + Storage)
- ✅ Phase 6 Preview: Onboarding & Collection Display
  - OnboardingScreen (series selection grid)
  - CollectionDisplayScreen (statistics & progress)
  - 65+ unit/widget tests
  - Firestore data seeding

### Next Critical Phase: Phase 3 AI Validation Testing 🔴
- **Status**: Ready for execution
- **Success Criteria**: ≥85% AI accuracy required
- **Timeline**: 7 days (data collection + testing)
- **Blocking**: Must pass before Phase 6+ full features

詳細は下記を参照:
- `PROJECT_STATUS.md` - 全体の進捗管理
- `IMPLEMENTATION_PLAN_DETAILED.md` - 17フェーズの詳細ロードマップ
- `docs/PHASE_3_EXECUTION_CHECKLIST.md` - Phase 3実行チェックリスト

## 🚀 クイックスタート

### 環境セットアップ

```bash
# 依存関係をインストール
flutter pub get

# Firestoreシードデータをセットアップ
dart scripts/seed_firestore_series.dart

# テストを実行
flutter test

# アプリを起動
flutter run
```

### Phase 3 AI Validation Testing を実行

**1. テスト画像を準備 (1-2日)**
```bash
# テスト画像ディレクトリを作成
mkdir -p test/ai_validation/test_images/{normal,blurry,damaged,poor_lighting}

# 100-150+ のガチャアイテム画像を配置
# 推奨: Normal (50+), Blurry (20+), Damaged (15+), Poor Lighting (15+)
```

**2. Ground Truth マニフェストを作成 (1日)**
```bash
# test/ai_validation/test_data_manifest.json を編集
# 各画像に対して期待値（name, series, rarity）を記録
```

**3. テストを実行 (3-4日)**
```bash
flutter test test/ai_validation/ai_validator_test.dart -v
```

**4. 結果を分析 (1日)**
```bash
# test/ai_validation/RESULTS.md を作成
# 精度メトリクスが ≥85% を達成したか確認
```

詳細: `docs/PHASE_3_EXECUTION_CHECKLIST.md`

## 📚 ドキュメント

| ドキュメント | 説明 |
|-------------|------|
| `PROJECT_STATUS.md` | 全体進捗、完了フェーズ、次のステップ |
| `IMPLEMENTATION_PLAN_DETAILED.md` | 17フェーズの詳細なロードマップ |
| `docs/FIRESTORE_SCHEMA.md` | Firestoreのデータベーススキーマ |
| `docs/PHASE_3_EXECUTION_GUIDE.md` | Phase 3の詳細実行ガイド |
| `docs/PHASE_3_EXECUTION_CHECKLIST.md` | Phase 3実行チェックリスト |
| `docs/PHASE_6_PREVIEW_IMPLEMENTATION.md` | Phase 6実装の詳細 |
| `docs/PHASE_6_TEST_IMPLEMENTATION.md` | テスト実装ドキュメント |
| `docs/FIRESTORE_SETUP_GUIDE.md` | Firestoreセットアップガイド |

## ⚠️ 重要な注意事項

🔴 **AI画像認識精度は Phase 3 で検証予定** 
- Phase 3 実行で ≥85% 達成が必須
- ガチャ商品特化の精度実績データなし
- 候補提示型UI前提で設計（100%自動 ≠ 成功条件）

## 📞 サポート

- 質問は GitHub Issues で
- 開発ドキュメントは `docs/` ディレクトリ参照
- テスト実行は `flutter test` コマンド使用