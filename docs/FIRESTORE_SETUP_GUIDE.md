# Firestore Setup Guide

**Updated**: 2026-08-29  
**Status**: Ready for Phase 6+ Development

---

## 🚀 Quick Start

### Prerequisites
- Firebase project configured (see `firebase_options.dart`)
- Firestore database initialized
- Dart SDK 3.1+ installed
- Flutter 3.16+ SDK installed

### Seed Sample Data

Run the seeding script to populate Firestore with test series data:

```bash
dart scripts/seed_firestore_series.dart
```

**Expected Output**:
```
🌱 Firestore Series Data Seeding Script
=====================================

📱 Initializing Firebase...
✅ Firebase initialized

📊 Sample data to be seeded:
Total series: 10
---

📝 Adding series: Genshin Impact
   ✅ Successfully added: Genshin Impact
...
=====================================
📊 Seeding Summary
=====================================
✅ Successfully added: 10
❌ Failed: 0
Total processed: 10

🎉 All series data seeded successfully!
```

---

## 📋 Sample Data Included

The seeding script includes 10 popular gacha series:

1. **Genshin Impact** (20 items)
   - Popular anime gacha game
   - Character collectible figures

2. **Honkai Star Rail** (18 items)
   - Turn-based gacha RPG
   - Character & equipment collectibles

3. **Fate Series** (25 items)
   - Fate series servant figures
   - High rarity collectibles

4. **Demon Slayer** (15 items)
   - 鬼滅の刃 character figures
   - Popular anime series

5. **My Hero Academia** (22 items)
   - 僕のヒーローアカデミア collectibles
   - Character figures and merchandise

6. **Jujutsu Kaisen** (19 items)
   - 呪術廻戦 character figures
   - Popular anime/manga series

7. **Persona 5** (16 items)
   - Persona 5 game collectibles
   - Character figurines

8. **Fire Emblem** (24 items)
   - Fire Emblem character figures
   - Nintendo game series

9. **Pokemon** (30 items)
   - Pokemon collectible figures
   - Largest item count for testing

10. **Zelda** (14 items)
    - The Legend of Zelda series
    - Character collectibles

---

## 🗂️ Database Schema

### gacha_series Collection

```
Firestore Database
├── gacha_series/
│   ├── {seriesId_1}/
│   │   ├── name: String
│   │   ├── imageUrl: String
│   │   ├── description: String
│   │   ├── totalItems: int
│   │   ├── createdAtMillis: int (Timestamp)
│   │   └── isActive: boolean
│   ├── {seriesId_2}/
│   └── ...
└── gacha_items/
    ├── {userId}/
    │   ├── {itemId_1}/
    │   │   ├── name: String
    │   │   ├── series: String
    │   │   ├── rarity: String
    │   │   ├── imageUrl: String
    │   │   ├── aiResult: object
    │   │   └── addedAt: Timestamp
    │   └── ...
```

### Series Document Fields

| Field | Type | Description |
|-------|------|-------------|
| name | String | Series name (e.g., "Genshin Impact") |
| imageUrl | String | Series cover image URL |
| description | String | Brief series description (Japanese) |
| totalItems | int | Total items in complete collection |
| createdAtMillis | int | Firestore timestamp (milliseconds) |
| isActive | boolean | Whether series is available for collection |

---

## 🔍 Verification

### In-App Verification

1. Start the app after seeding:
```bash
flutter run
```

2. Navigate to home screen

3. Tap "コレクション" (Collections) in bottom navigation

4. Verify series grid displays 10 series cards

5. Tap a series to view collection display screen

### Firebase Console Verification

1. Go to [Firebase Console](https://console.firebase.google.com)

2. Select your project

3. Navigate to Firestore Database

4. Expand `gacha_series` collection

5. Verify 10 documents exist with correct fields

### CLI Verification

```bash
# List all series
firebase firestore:query gacha_series --limit 20

# Query active series
firebase firestore:query gacha_series --where "isActive==true"

# Get specific series count
firebase firestore:query gacha_series --count
```

---

## ✏️ Manual Data Entry

### Add Custom Series

Use Firebase Console:

1. Go to Firestore Database
2. Click "Add Collection" → enter `gacha_series`
3. Click "Add Document"
4. Add fields:
   - `name`: Your series name
   - `imageUrl`: Image URL
   - `description`: Series description
   - `totalItems`: Total collectibles
   - `createdAtMillis`: Current timestamp (ms)
   - `isActive`: true/false

### Modify Existing Series

1. Open series document in Firebase Console
2. Edit fields directly
3. Changes propagate immediately to app

---

## 🗑️ Clear/Reset Data

### Clear Series Collection

```bash
# Delete all documents in gacha_series collection
firebase firestore:delete gacha_series --recursive --force
```

### Delete Specific Series

1. Go to Firestore Console
2. Select series document
3. Click delete icon

---

## 🔐 Security Rules

### Current Rules

```firestore
match /gacha_series/{document=**} {
  allow read: if request.auth.uid != null;
  allow write: if false; // Admin only
}
```

**Restrictions**:
- ✅ Any authenticated user can read
- ❌ Only admin can write (via Firebase Console or Admin SDK)

### For Development Only

To temporarily allow writes (development only):

```firestore
match /gacha_series/{document=**} {
  allow read: if request.auth.uid != null;
  allow write: if request.auth.uid != null; // ⚠️ TEMPORARY
}
```

**⚠️ WARNING**: Never use this in production! Reset to admin-only writes before release.

---

## 🚨 Troubleshooting

### Issue: Script Fails with "Firebase not initialized"

**Solution**:
1. Verify firebase_options.dart exists
2. Check Android/iOS native configuration
3. Run: `flutter pub get`

### Issue: "Permission denied" when writing

**Solution**:
1. Check Firestore security rules
2. Ensure user is authenticated
3. Check Firebase project permissions
4. Temporarily allow write in console (dev only)

### Issue: Data not visible in app

**Solution**:
1. Verify seeding script completed successfully
2. Check Firebase connection in app logs
3. Force app refresh (hot reload not enough)
4. Check user is authenticated

### Issue: Series not appearing in OnboardingScreen

**Solution**:
1. Verify data is in Firestore console
2. Check `isActive` field is set to true
3. Check user is logged in
4. Reload app completely (hot restart)

---

## 📝 Data Format Examples

### Example Series Document

```json
{
  "createdAtMillis": 1693209600000,
  "description": "Genshin Impactキャラクターコレクション",
  "imageUrl": "https://via.placeholder.com/200?text=Genshin+Impact",
  "isActive": true,
  "name": "Genshin Impact",
  "totalItems": 20
}
```

### Example User Item Document

```json
{
  "addedAt": "2026-08-29T10:30:00Z",
  "aiResult": {
    "confidence": 0.92,
    "itemName": "Fischl (Winter)",
    "rarity": "SSR",
    "series": "Genshin Impact"
  },
  "imageUrl": "gs://bucket/user_123/item_abc123.jpg",
  "name": "Fischl (Winter)",
  "rarity": "SSR",
  "series": "Genshin Impact"
}
```

---

## 🔄 Workflow

### Development Setup

```
1. Initialize Firebase ✅
   └─ flutter pub get

2. Configure firebase_options.dart ✅
   └─ Already configured in Phase 1

3. Start app
   └─ flutter run

4. Seed Firestore data
   └─ dart scripts/seed_firestore_series.dart

5. Verify in app
   └─ Check Onboarding screen shows series

6. Test functionality
   └─ flutter test

7. Monitor via Firebase Console
   └─ Check Firestore usage
```

### Testing Workflow

```
1. Ensure series data exists in Firestore
   └─ Run seed script if needed

2. Run tests
   └─ flutter test

3. Check coverage
   └─ flutter test --coverage

4. View results
   └─ lcov --list coverage/lcov.info
```

---

## 📚 Related Documentation

- `docs/FIRESTORE_SCHEMA.md` - Detailed schema design
- `docs/PHASE_6_PREVIEW_IMPLEMENTATION.md` - Series model details
- `docs/PHASE_6_TEST_IMPLEMENTATION.md` - Test suite
- `docs/PROJECT_STATUS.md` - Overall project progress

---

## 💡 Tips

### For Adding More Series

1. Edit `scripts/seed_firestore_series.dart`
2. Add entry to `sampleSeriesData` list
3. Run script: `dart scripts/seed_firestore_series.dart`
4. Restart app to see new series

### For Custom Images

Replace placeholder URLs:
```dart
'imageUrl': 'https://via.placeholder.com/200?text=Series+Name',
```

With real image URLs:
```dart
'imageUrl': 'https://your-cdn.com/series-cover.jpg',
```

### For Batch Operations

Use Firebase Admin SDK:

```bash
npm install -g firebase-tools
firebase firestore:import firestore-backup.json
```

---

## ✅ Checklist

Before proceeding to Phase 3 validation:

- [ ] Firebase project configured
- [ ] Firestore database created
- [ ] seed_firestore_series.dart script exists
- [ ] Sample data seeded (10 series)
- [ ] OnboardingScreen shows series in grid
- [ ] CollectionDisplayScreen calculates stats
- [ ] Tests pass (flutter test)
- [ ] No errors in Firestore console

---

**Document Version**: 1.0  
**Last Updated**: 2026-08-29  
**Author**: Claude (AI)  
**Status**: Ready for Testing

