/// Firestore Series Data Seeding Script
///
/// This script populates Firestore with sample gacha series data for testing.
///
/// Usage:
///   dart scripts/seed_firestore_series.dart
///
/// Requirements:
///   - Firebase project configured in firebase_options.dart
///   - Firestore database initialized
///   - Write permissions to gacha_series collection
///
/// Note: This is a standalone script for development/testing purposes.
/// For production data, use Firebase admin console or dedicated admin panel.

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// Sample series data for seeding
const List<Map<String, dynamic>> sampleSeriesData = [
  {
    'name': 'Genshin Impact',
    'imageUrl': 'https://via.placeholder.com/200?text=Genshin+Impact',
    'description': 'Genshin Impactキャラクターコレクション',
    'totalItems': 20,
    'isActive': true,
    'createdAtMillis': 1693209600000, // 2023-08-28
  },
  {
    'name': 'Honkai Star Rail',
    'imageUrl': 'https://via.placeholder.com/200?text=Star+Rail',
    'description': '崩壊：スターレイルキャラクターコレクション',
    'totalItems': 18,
    'isActive': true,
    'createdAtMillis': 1693296000000, // 2023-08-29
  },
  {
    'name': 'Fate Series',
    'imageUrl': 'https://via.placeholder.com/200?text=Fate+Series',
    'description': 'Fateシリーズサーヴァントコレクション',
    'totalItems': 25,
    'isActive': true,
    'createdAtMillis': 1693382400000, // 2023-08-30
  },
  {
    'name': 'Demon Slayer',
    'imageUrl': 'https://via.placeholder.com/200?text=Demon+Slayer',
    'description': '鬼滅の刃キャラクターコレクション',
    'totalItems': 15,
    'isActive': true,
    'createdAtMillis': 1693468800000, // 2023-08-31
  },
  {
    'name': 'My Hero Academia',
    'imageUrl': 'https://via.placeholder.com/200?text=My+Hero',
    'description': '僕のヒーローアカデミアキャラクターコレクション',
    'totalItems': 22,
    'isActive': true,
    'createdAtMillis': 1693555200000, // 2023-09-01
  },
  {
    'name': 'Jujutsu Kaisen',
    'imageUrl': 'https://via.placeholder.com/200?text=Jujutsu+Kaisen',
    'description': '呪術廻戦キャラクターコレクション',
    'totalItems': 19,
    'isActive': true,
    'createdAtMillis': 1693641600000, // 2023-09-02
  },
  {
    'name': 'Persona 5',
    'imageUrl': 'https://via.placeholder.com/200?text=Persona+5',
    'description': 'ペルソナ5キャラクターコレクション',
    'totalItems': 16,
    'isActive': true,
    'createdAtMillis': 1693728000000, // 2023-09-03
  },
  {
    'name': 'Fire Emblem',
    'imageUrl': 'https://via.placeholder.com/200?text=Fire+Emblem',
    'description': 'ファイアーエムブレムキャラクターコレクション',
    'totalItems': 24,
    'isActive': true,
    'createdAtMillis': 1693814400000, // 2023-09-04
  },
  {
    'name': 'Pokemon',
    'imageUrl': 'https://via.placeholder.com/200?text=Pokemon',
    'description': 'ポケットモンスターコレクション',
    'totalItems': 30,
    'isActive': true,
    'createdAtMillis': 1693900800000, // 2023-09-05
  },
  {
    'name': 'Zelda',
    'imageUrl': 'https://via.placeholder.com/200?text=Zelda',
    'description': 'ゼルダの伝説キャラクターコレクション',
    'totalItems': 14,
    'isActive': true,
    'createdAtMillis': 1693987200000, // 2023-09-06
  },
];

void main(List<String> arguments) async {
  print('🌱 Firestore Series Data Seeding Script');
  print('=====================================\n');

  try {
    // Initialize Firebase
    print('📱 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized\n');

    final firestore = FirebaseFirestore.instance;

    // Get reference to gacha_series collection
    final seriesCollection = firestore.collection('gacha_series');

    print('📊 Sample data to be seeded:');
    print('Total series: ${sampleSeriesData.length}');
    print('---\n');

    int successCount = 0;
    int errorCount = 0;

    // Seed each series
    for (final seriesData in sampleSeriesData) {
      try {
        final seriesName = seriesData['name'] as String;
        print('📝 Adding series: $seriesName');

        // Add document to Firestore
        await seriesCollection.add(seriesData);

        successCount++;
        print('   ✅ Successfully added: $seriesName\n');
      } catch (e) {
        errorCount++;
        print('   ❌ Error adding series: $e\n');
      }
    }

    // Summary
    print('=====================================');
    print('📊 Seeding Summary');
    print('=====================================');
    print('✅ Successfully added: $successCount');
    print('❌ Failed: $errorCount');
    print('Total processed: ${sampleSeriesData.length}\n');

    if (errorCount == 0) {
      print('🎉 All series data seeded successfully!');
      print('You can now view these series in the app.');
    } else {
      print('⚠️  Some errors occurred during seeding.');
      print('Please check your Firebase configuration and permissions.');
    }

    print('\n📋 Next steps:');
    print('1. Open the app and navigate to the Onboarding screen');
    print('2. You should see the seeded series in the grid');
    print('3. Select a series to view collection display');
    print('4. Run tests with: flutter test\n');
  } catch (e) {
    print('❌ Fatal error: $e');
    print('\nTroubleshooting:');
    print('1. Verify Firebase is initialized in main.dart');
    print('2. Check firebase_options.dart configuration');
    print('3. Ensure Firestore database is enabled');
    print('4. Check your Firebase project permissions');
  }
}
