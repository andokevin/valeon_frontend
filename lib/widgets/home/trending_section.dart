import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/recommendation_provider.dart';
import '../common/cached_image.dart';

class TrendingSection extends ConsumerWidget {
  const TrendingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingProvider('week'));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Tendances', style: TextStyle(fontSize: 18,
        fontWeight: FontWeight.w700, color: AppTheme.onBackground)),
      const SizedBox(height: 16),
      trending.when(
        loading: () => const SizedBox(height: 120,
          child: Center(child: CircularProgressIndicator())),
        error: (_, __) => const SizedBox.shrink(),
        data: (items) => SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) => _TrendingCard(item: items[i]),
          ),
        ),
      ),
    ]);
  }
}

class _TrendingCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _TrendingCard({required this.item});

  @override
  Widget build(BuildContext context) => Container(
    width: 110,
    decoration: BoxDecoration(
      color: AppTheme.surface, borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: CachedImageWidget(url: item['image'], width: 110, height: 80),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(item['title'] ?? '', maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
            color: AppTheme.onBackground)),
      ),
    ]),
  );
}
