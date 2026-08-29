# Firestore Database Schema

Digital Gacha Collection アプリの Firestore データベーススキーマドキュメント

## Overview

```
Firestore
├── users/{userId}                          # ユーザープロフィール
│   ├── uid: string
│   ├── email: string
│   ├── displayName: string (optional)
│   ├── photoUrl: string (optional)
│   ├── createdAt: timestamp
│   ├── updatedAt: timestamp
│   ├── lastSignInAt: timestamp
│   ├── preferences: object
│   │   ├── language: string (ja, en, etc.)
│   │   ├── theme: string (system, light, dark)
│   │   └── notifications: boolean
│   ├── statistics: object
│   │   ├── totalItems: int
│   │   ├── completedSeries: int
│   │   └── tradesCompleted: int
│   │
│   └── gacha_items/{itemId}                # ユーザーのガチャアイテム
│       ├── id: string (document id)
│       ├── userId: string
│       ├── imageUrl: string
│       ├── aiResult: object
│       │   ├── name: string
│       │   ├── series: string
│       │   ├── rarity: string (N, R, SR, SSR)
│       │   ├── confidence: number (0.0-1.0)
│       │   └── notes: string (optional)
│       ├── createdAt: int (milliseconds since epoch)
│       ├── updatedAt: int (milliseconds since epoch)
│       ├── isManualEdit: boolean
│       └── isDuplicate: boolean
│
├── analytics/{document}                    # アナリティクスデータ
│   ├── eventType: string
│   ├── userId: string
│   ├── timestamp: timestamp
│   └── metadata: object
│
└── config/{document}                       # アプリ設定
    ├── version: string
    ├── maintenanceMode: boolean
    ├── featureFlags: object
    └── lastUpdated: timestamp
```

## Collection Details

### users Collection

ユーザーのプロフィール情報と設定を格納します。

**Document Path**: `users/{userId}`
**Security**: ユーザーは自身のドキュメントのみアクセス可能

**Fields**:

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| uid | string | Firebase Auth UID | `"user123"` |
| email | string | ユーザーメール | `"user@example.com"` |
| displayName | string | 表示名 | `"太郎"` |
| photoUrl | string | プロフィール画像URL | `"https://..."` |
| createdAt | timestamp | アカウント作成日時 | `2024-01-15T10:30:00Z` |
| updatedAt | timestamp | 最終更新日時 | `2024-08-28T15:45:00Z` |
| lastSignInAt | timestamp | 最終ログイン日時 | `2024-08-28T09:00:00Z` |
| preferences | object | ユーザー設定 | - |
| preferences.language | string | 言語設定 | `"ja"` |
| preferences.theme | string | テーマ設定 | `"system"` \| `"light"` \| `"dark"` |
| preferences.notifications | boolean | 通知有効化 | `true` |
| statistics | object | 統計情報 | - |
| statistics.totalItems | int | 総アイテム数 | `42` |
| statistics.completedSeries | int | 完成シリーズ数 | `3` |
| statistics.tradesCompleted | int | 完了取引数 | `5` |

**Example Document**:
```json
{
  "uid": "abc123xyz",
  "email": "user@example.com",
  "displayName": "太郎",
  "photoUrl": "https://storage.googleapis.com/...",
  "createdAt": {
    "_seconds": 1705315800,
    "_nanoseconds": 0
  },
  "updatedAt": {
    "_seconds": 1724856300,
    "_nanoseconds": 0
  },
  "lastSignInAt": {
    "_seconds": 1724811600,
    "_nanoseconds": 0
  },
  "preferences": {
    "language": "ja",
    "theme": "system",
    "notifications": true
  },
  "statistics": {
    "totalItems": 42,
    "completedSeries": 3,
    "tradesCompleted": 5
  }
}
```

### gacha_items Subcollection

各ユーザーが所持するガチャアイテムを格納します。

**Document Path**: `users/{userId}/gacha_items/{itemId}`
**Security**: ユーザーは自身のアイテムのみアクセス可能
**Indexes**: 
- `aiResult.series` + `createdAt`
- `aiResult.rarity` + `createdAt`
- `isDuplicate` + `createdAt`

**Fields**:

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| id | string | Document ID | `"item_uuid_123"` |
| userId | string | 所有者 UID | `"user123"` |
| imageUrl | string | 画像URL (Firebase Storage) | `"https://storage.googleapis.com/..."` |
| aiResult | object | AI判定結果 | - |
| aiResult.name | string | アイテム名 | `"ピカチュウ"` |
| aiResult.series | string | シリーズ名 | `"ポケモン第1世代"` |
| aiResult.rarity | string | レアリティ | `"SSR"` |
| aiResult.confidence | number | AI信頼度 | `0.92` |
| aiResult.notes | string | メモ (optional) | `"箱傷あり"` |
| createdAt | int | 登録日時（ミリ秒） | `1705315800000` |
| updatedAt | int | 更新日時（ミリ秒） | `1724856300000` |
| isManualEdit | boolean | 手動編集済み | `false` |
| isDuplicate | boolean | 重複フラグ | `false` |

**Example Document**:
```json
{
  "id": "item_uuid_001",
  "userId": "abc123xyz",
  "imageUrl": "https://storage.googleapis.com/degigacha-demo.appspot.com/images/...",
  "aiResult": {
    "name": "ピカチュウ",
    "series": "ポケモン第1世代",
    "rarity": "SSR",
    "confidence": 0.92,
    "notes": "状態良好"
  },
  "createdAt": 1705315800000,
  "updatedAt": 1724856300000,
  "isManualEdit": false,
  "isDuplicate": false
}
```

### analytics Collection

ユーザーアクティビティとイベントログを格納します（Cloud Functions により書き込み）。

**Document Path**: `analytics/{autoId}`
**Security**: 認証ユーザーのみ読取、書き込みは禁止

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| eventType | string | イベント種類 (ai_judgment, item_registered, trade_initiated, etc.) |
| userId | string | ユーザー UID |
| timestamp | timestamp | イベント発生時刻 |
| metadata | object | イベント固有データ |

### config Collection

アプリケーション設定とフィーチャーフラグを格納します。

**Document Path**: `config/{docId}`
**Security**: 認証ユーザーのみ読取、書き込みは禁止

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| version | string | アプリケーションバージョン |
| maintenanceMode | boolean | メンテナンスモード |
| featureFlags | object | フィーチャーフラグ |
| lastUpdated | timestamp | 最終更新時刻 |

## Data Relationships

### User → GachaItems
- 1ユーザーが複数のガチャアイテムを所有
- Subcollection で表現: `users/{userId}/gacha_items/{itemId}`

### Series Grouping
- `gacha_items` 内で `aiResult.series` フィールドでシリーズ別にグループ化
- Firestore Query: `where('aiResult.series', '==', seriesName)`

### Rarity Distribution
- `aiResult.rarity` フィールドでレアリティ別にグループ化
- Firestore Query: `where('aiResult.rarity', '==', 'SSR')`

## Indexes

### Auto-Generated Indexes
Firestore は以下のシンプルなクエリについて自動でインデックスを生成します:
- 単一フィールドでの等価条件
- 単一フィールドでのソート

### Composite Indexes
複数フィールドでのフィルタ + ソートには、以下の複合インデックスが必要です：

1. **シリーズ別 + 日付ソート**
   - `aiResult.series` (ASC) + `createdAt` (DESC)
   
2. **レアリティ別 + 日付ソート**
   - `aiResult.rarity` (ASC) + `createdAt` (DESC)

3. **重複フラグ + 日付ソート**
   - `isDuplicate` (ASC) + `createdAt` (DESC)

これらは `firestore.indexes.json` で定義され、Firebase CLI でデプロイされます。

## Backup & Disaster Recovery

### Backup Strategy
- Firebase の自動バックアップを有効化（30日保持）
- 重要なデータについては Cloud Firestore のエクスポート機能を定期的に実行

### Data Retention
- ユーザー削除時：ユーザードキュメントと紐付いた全ての gacha_items を削除
- 削除後のデータ復旧：30日以内であれば自動バックアップから復旧可能

## Performance Considerations

### Document Size Limits
- Firestore の最大ドキュメントサイズは 1MB
- `aiResult` は小さいため問題なし
- 画像は Firebase Storage に保存

### Subcollection Queries
- gacha_items の大規模クエリを避けるため、ページネーション実装
- 初回クエリは最新25件に制限

### Index Updates
- Composite Index 作成時はバックグラウンドで自動構築
- 大規模コレクションの場合は数分～数時間かかる場合あり

## Migration Guide

### Firebase Console での設定

1. **Firestore Database 作成**
   - ロケーション: `asia-northeast1` (東京)
   - モード: Native モード

2. **Security Rules をデプロイ**
   ```bash
   firebase deploy --only firestore:rules
   ```

3. **Indexes をデプロイ**
   ```bash
   firebase deploy --only firestore:indexes
   ```

4. **Storage Rules をデプロイ** (別途実装)
   ```bash
   firebase deploy --only storage
   ```

## Notes

- 全タイムスタンプは UTC で統一
- `createdAt` と `updatedAt` は Cloud Functions により自動設定
- ユーザー削除はカスケード削除対応 (Cloud Functions で実装予定)
- 大規模データ削除時は Cloud Firestore の一括削除機能を使用
