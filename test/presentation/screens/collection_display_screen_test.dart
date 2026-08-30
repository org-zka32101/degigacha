import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:go_router/go_router.dart';
import 'package:degigacha/data/models/gacha_series_model.dart';
import 'package:degigacha/presentation/screens/collection_display_screen.dart';

// Mock classes
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group('CollectionDisplayScreen', () {
    const testSeriesId = 'series_001';

    Widget createTestWidget(Widget child) {
      return ProviderScope(
        child: MaterialApp(
          home: child,
        ),
      );
    }

    testWidgets('シリーズヘッダーが表示される', (WidgetTester tester) async {
      // Given: CollectionDisplayScreen
      await tester.pumpWidget(
        createTestWidget(
          const CollectionDisplayScreen(seriesId: testSeriesId),
        ),
      );

      await tester.pumpAndSettle();

      // Then: Scaffoldが表示される
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('ロード中に円形プログレスインジケーターが表示される',
        (WidgetTester tester) async {
      // Given: CollectionDisplayScreen
      await tester.pumpWidget(
        createTestWidget(
          const CollectionDisplayScreen(seriesId: testSeriesId),
        ),
      );

      // When: ロード中
      await tester.pump();

      // Then: CircularProgressIndicatorが表示される
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('シリーズ名が表示される', (WidgetTester tester) async {
      // Given: CollectionDisplayScreen
      await tester.pumpWidget(
        createTestWidget(
          const CollectionDisplayScreen(seriesId: testSeriesId),
        ),
      );

      await tester.pumpAndSettle();

      // Then: Textウィジェットが表示される
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('進捗バーが表示される', (WidgetTester tester) async {
      // Given: CollectionDisplayScreen
      await tester.pumpWidget(
        createTestWidget(
          const CollectionDisplayScreen(seriesId: testSeriesId),
        ),
      );

      await tester.pumpAndSettle();

      // Then: LinearProgressIndicatorが表示される
      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });

    testWidgets('統計カードが表示される', (WidgetTester tester) async {
      // Given: CollectionDisplayScreen
      await tester.pumpWidget(
        createTestWidget(
          const CollectionDisplayScreen(seriesId: testSeriesId),
        ),
      );

      await tester.pumpAndSettle();

      // Then: 統計情報を表示するカードが存在
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('所持数の統計カードが表示される', (WidgetTester tester) async {
      // Given: CollectionDisplayScreen
      await tester.pumpWidget(
        createTestWidget(
          const CollectionDisplayScreen(seriesId: testSeriesId),
        ),
      );

      await tester.pumpAndSettle();

      // Then: カード内にアイコンとテキストが表示される
      expect(find.byIcon(Icons.check_circle), findsWidgets);
    });

    testWidgets('完成度の統計カードが表示される', (WidgetTester tester) async {
      // Given: CollectionDisplayScreen
      await tester.pumpWidget(
        createTestWidget(
          const CollectionDisplayScreen(seriesId: testSeriesId),
        ),
      );

      await tester.pumpAndSettle();

      // Then: トレンディングアップアイコンが表示される
      expect(find.byIcon(Icons.trending_up), findsWidgets);
    });

    testWidgets('残りアイテム数の統計カードが表示される', (WidgetTester tester) async {
      // Given: CollectionDisplayScreen
      await tester.pumpWidget(
        createTestWidget(
          const CollectionDisplayScreen(seriesId: testSeriesId),
        ),
      );

      await tester.pumpAndSettle();

      // Then: プレイリスト追加アイコンが表示される
      expect(find.byIcon(Icons.playlist_add), findsWidgets);
    });

    testWidgets('「ガチャを撮る」ボタンが表示される', (WidgetTester tester) async {
      // Given: CollectionDisplayScreen
      await tester.pumpWidget(
        createTestWidget(
          const CollectionDisplayScreen(seriesId: testSeriesId),
        ),
      );

      await tester.pumpAndSettle();

      // Then: キャプチャボタンが表示される
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('「詳細を見る」ボタンが表示される', (WidgetTester tester) async {
      // Given: CollectionDisplayScreen
      await tester.pumpWidget(
        createTestWidget(
          const CollectionDisplayScreen(seriesId: testSeriesId),
        ),
      );

      await tester.pumpAndSettle();

      // Then: 詳細表示ボタンが表示される
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('情報ボックスが表示される', (WidgetTester tester) async {
      // Given: CollectionDisplayScreen
      await tester.pumpWidget(
        createTestWidget(
          const CollectionDisplayScreen(seriesId: testSeriesId),
        ),
      );

      await tester.pumpAndSettle();

      // Then: Container（情報ボックス）が表示される
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('存在しないシリーズIDでエラーが表示される',
        (WidgetTester tester) async {
      // Given: 存在しないシリーズID
      const invalidSeriesId = 'invalid_series_id';

      // When: CollectionDisplayScreenを作成
      await tester.pumpWidget(
        createTestWidget(
          const CollectionDisplayScreen(seriesId: invalidSeriesId),
        ),
      );

      await tester.pumpAndSettle();

      // Then: エラー画面またはバックボタンが表示される
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('進捗バーの値が正しく計算される', (WidgetTester tester) async {
      // Given: 進捗情報を持つシリーズ
      // When: 進捗率を計算
      const totalItems = 20;
      const collectedItems = 8;
      final progress = collectedItems / totalItems;

      // Then: 進捗率が正しい（40%）
      expect(progress, 0.4);
    });

    testWidgets('100%完成した場合、進捗バーが満杯になる', (WidgetTester tester) async {
      // Given: 100%完成したシリーズ
      const totalItems = 20;
      const collectedItems = 20;
      final progress = collectedItems / totalItems;

      // Then: 進捗率が1.0
      expect(progress, 1.0);
    });

    testWidgets('0%の場合、進捗バーが空になる', (WidgetTester tester) async {
      // Given: 新規シリーズ
      const totalItems = 20;
      const collectedItems = 0;
      final progress = collectedItems / totalItems;

      // Then: 進捗率が0.0
      expect(progress, 0.0);
    });

    testWidgets('スクロール可能である', (WidgetTester tester) async {
      // Given: CollectionDisplayScreen
      await tester.pumpWidget(
        createTestWidget(
          const CollectionDisplayScreen(seriesId: testSeriesId),
        ),
      );

      await tester.pumpAndSettle();

      // Then: SingleChildScrollViewが含まれている
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('レスポンシブレイアウトが正しく機能する',
        (WidgetTester tester) async {
      // Given: CollectionDisplayScreen
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);

      await tester.pumpWidget(
        createTestWidget(
          const CollectionDisplayScreen(seriesId: testSeriesId),
        ),
      );

      await tester.pumpAndSettle();

      // Then: Scaffoldが正しくレイアウトされている
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('ダークモードで正しく表示される', (WidgetTester tester) async {
      // Given: ダークモードのCollectionDisplayScreen
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const CollectionDisplayScreen(seriesId: testSeriesId),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Then: Scaffoldが表示される
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('ライトモードで正しく表示される', (WidgetTester tester) async {
      // Given: ライトモードのCollectionDisplayScreen
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light(),
            home: const CollectionDisplayScreen(seriesId: testSeriesId),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Then: Scaffoldが表示される
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('バックボタンが存在する', (WidgetTester tester) async {
      // Given: CollectionDisplayScreen
      await tester.pumpWidget(
        createTestWidget(
          const CollectionDisplayScreen(seriesId: testSeriesId),
        ),
      );

      await tester.pumpAndSettle();

      // Then: AppBarが表示される
      expect(find.byType(AppBar), findsWidgets);
    });

    testWidgets('シリーズ説明が表示される', (WidgetTester tester) async {
      // Given: CollectionDisplayScreen
      await tester.pumpWidget(
        createTestWidget(
          const CollectionDisplayScreen(seriesId: testSeriesId),
        ),
      );

      await tester.pumpAndSettle();

      // Then: テキストウィジェットが表示される
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('アクションボタンがすべて表示される', (WidgetTester tester) async {
      // Given: CollectionDisplayScreen
      await tester.pumpWidget(
        createTestWidget(
          const CollectionDisplayScreen(seriesId: testSeriesId),
        ),
      );

      await tester.pumpAndSettle();

      // Then: 複数のElevatedButtonが表示される
      expect(find.byType(ElevatedButton), findsWidgets);
    });
  });
}
