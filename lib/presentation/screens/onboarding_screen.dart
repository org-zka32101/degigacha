import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../riverpod/providers.dart';
import '../../data/models/gacha_series_model.dart';

/// オンボーディング画面
///
/// ユーザーが初回ログイン時にシリーズを選択する画面。
/// 複数のガチャシリーズを閲覧し、興味のあるシリーズを選択できます。
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesAsync = ref.watch(allActiveSeriesProvider);
    final userCollectedAsync = ref.watch(userCollectedSeriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('シリーズを選択'),
        centerTitle: true,
      ),
      body: seriesAsync.when(
        data: (series) {
          if (series.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.collections_bookmark,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'シリーズが見つかりません',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'お気に入りのガチャシリーズを追加してください',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('ホームに戻る'),
                  ),
                ],
              ),
            );
          }

          return userCollectedAsync.when(
            data: (collectedSeries) {
              final collectedNames = collectedSeries.map((s) => s.name).toSet();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Text(
                        'ガチャを撮るシリーズを選択してください',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: series.length,
                      itemBuilder: (context, index) {
                        final gachaSeries = series[index];
                        final isCollected =
                            collectedNames.contains(gachaSeries.name);
                        final collectedCount = collectedSeries
                            .firstWhere(
                              (s) => s.name == gachaSeries.name,
                              orElse: () => gachaSeries,
                            )
                            .collectedItems;

                        return _SeriesCard(
                          series: gachaSeries,
                          isCollected: isCollected,
                          collectedCount: collectedCount,
                          onTap: () => _selectSeries(context, ref, gachaSeries),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    if (series.isNotEmpty)
                      TextButton(
                        onPressed: () => context.go('/'),
                        child: const Text('スキップしてホームへ'),
                      ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'エラーが発生しました',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('ホームに戻る'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'シリーズの読み込みに失敗しました',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('ホームに戻る'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectSeries(
    BuildContext context,
    WidgetRef ref,
    GachaSeries series,
  ) {
    ref.read(selectedSeriesProvider.notifier).state = series;
    context.go('/collection/${series.id}');
  }
}

/// シリーズカード
class _SeriesCard extends StatelessWidget {
  final GachaSeries series;
  final bool isCollected;
  final int collectedCount;
  final VoidCallback onTap;

  const _SeriesCard({
    required this.series,
    required this.isCollected,
    required this.collectedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Center(
                  child: Icon(
                    Icons.collections_bookmark,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    series.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  if (isCollected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'コレクション中 ($collectedCount)',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    )
                  else
                    Text(
                      '${series.totalItems}個',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
