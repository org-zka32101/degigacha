const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

// ========== User Management ==========

/**
 * ユーザー作成時のオンボーディング処理
 */
exports.onUserCreate = functions.auth.user().onCreate(async (user) => {
  try {
    console.log(`Creating user profile for: ${user.uid}`);

    const userData = {
      uid: user.uid,
      email: user.email,
      displayName: user.displayName || '',
      photoUrl: user.photoURL || '',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastSignInAt: admin.firestore.FieldValue.serverTimestamp(),
      preferences: {
        language: 'ja',
        theme: 'system',
        notifications: true,
      },
      statistics: {
        totalItems: 0,
        completedSeries: 0,
        tradesCompleted: 0,
      },
    };

    await db.collection('users').doc(user.uid).set(userData);
    console.log(`User profile created for: ${user.uid}`);
  } catch (error) {
    console.error('Error creating user profile:', error);
    throw error;
  }
});

/**
 * ユーザー削除時のクリーンアップ処理
 */
exports.onUserDelete = functions.auth.user().onDelete(async (user) => {
  try {
    console.log(`Deleting user data for: ${user.uid}`);

    const batch = db.batch();

    // ユーザードキュメント削除
    batch.delete(db.collection('users').doc(user.uid));

    // ユーザーのガチャアイテム削除
    const gachaItemsRef = db
      .collection('users')
      .doc(user.uid)
      .collection('gacha_items');

    const gachaItems = await gachaItemsRef.get();
    gachaItems.forEach((doc) => {
      batch.delete(doc.ref);
    });

    // バッチコミット
    await batch.commit();
    console.log(`User data deleted for: ${user.uid}`);
  } catch (error) {
    console.error('Error deleting user data:', error);
    throw error;
  }
});

// ========== Gacha Items Analytics ==========

/**
 * ガチャアイテム登録時のアナリティクス記録
 */
exports.onGachaItemCreated = functions.firestore
  .document('users/{userId}/gacha_items/{itemId}')
  .onCreate(async (snap, context) => {
    try {
      const { userId, itemId } = context.params;
      const itemData = snap.data();

      console.log(`Recording analytics for item: ${itemId} in user: ${userId}`);

      // アナリティクスイベント記録
      await db.collection('analytics').add({
        eventType: 'item_registered',
        userId: userId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        metadata: {
          itemId: itemId,
          series: itemData.aiResult?.series || 'unknown',
          rarity: itemData.aiResult?.rarity || 'unknown',
          confidence: itemData.aiResult?.confidence || 0,
        },
      });

      // ユーザーの統計を更新
      const userRef = db.collection('users').doc(userId);
      await userRef.update({
        'statistics.totalItems': admin.firestore.FieldValue.increment(1),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Analytics recorded for item: ${itemId}`);
    } catch (error) {
      console.error('Error recording analytics:', error);
      throw error;
    }
  });

/**
 * ガチャアイテム削除時のアナリティクス記録
 */
exports.onGachaItemDeleted = functions.firestore
  .document('users/{userId}/gacha_items/{itemId}')
  .onDelete(async (snap, context) => {
    try {
      const { userId, itemId } = context.params;

      console.log(`Recording deletion analytics for item: ${itemId}`);

      // アナリティクスイベント記録
      await db.collection('analytics').add({
        eventType: 'item_deleted',
        userId: userId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        metadata: {
          itemId: itemId,
        },
      });

      // ユーザーの統計を更新
      const userRef = db.collection('users').doc(userId);
      await userRef.update({
        'statistics.totalItems': admin.firestore.FieldValue.increment(-1),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Deletion analytics recorded for item: ${itemId}`);
    } catch (error) {
      console.error('Error recording deletion analytics:', error);
      throw error;
    }
  });

// ========== AI Judgment Analytics ==========

/**
 * AI 判定の精度トラッキング
 * （ユーザーが手動編集した場合に記録）
 */
exports.onItemManuallyEdited = functions.firestore
  .document('users/{userId}/gacha_items/{itemId}')
  .onUpdate(async (change, context) => {
    try {
      const { userId, itemId } = context.params;
      const beforeData = change.before.data();
      const afterData = change.after.data();

      // 手動編集フラグが変わった場合のみ処理
      if (beforeData.isManualEdit !== afterData.isManualEdit && afterData.isManualEdit) {
        console.log(`Recording manual edit for item: ${itemId}`);

        // アナリティクスイベント記録
        await db.collection('analytics').add({
          eventType: 'ai_judgment_corrected',
          userId: userId,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          metadata: {
            itemId: itemId,
            originalResult: beforeData.aiResult,
            correctedResult: afterData.aiResult,
          },
        });

        // ユーザーの統計を更新
        const userRef = db.collection('users').doc(userId);
        await userRef.update({
          'statistics': admin.firestore.FieldValue.arrayUnion(['manuallyEditedItems']),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log(`Manual edit recorded for item: ${itemId}`);
      }
    } catch (error) {
      console.error('Error recording manual edit:', error);
      throw error;
    }
  });

// ========== Admin Functions ==========

/**
 * ユーザー統計の定期クリーンアップ
 */
exports.cleanupAnalytics = functions.pubsub
  .schedule('every day 03:00')
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    try {
      console.log('Starting analytics cleanup...');

      // 90日以上前のアナリティクスを削除
      const ninetyDaysAgo = new Date();
      ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90);

      const snapshot = await db
        .collection('analytics')
        .where('timestamp', '<', ninetyDaysAgo)
        .get();

      const batch = db.batch();
      snapshot.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();

      console.log(`Deleted ${snapshot.size} old analytics documents`);
    } catch (error) {
      console.error('Error cleaning up analytics:', error);
      throw error;
    }
  });

// ========== Exports for Testing ==========

module.exports = {
  onUserCreate: exports.onUserCreate,
  onUserDelete: exports.onUserDelete,
  onGachaItemCreated: exports.onGachaItemCreated,
  onGachaItemDeleted: exports.onGachaItemDeleted,
  onItemManuallyEdited: exports.onItemManuallyEdited,
  cleanupAnalytics: exports.cleanupAnalytics,
};
