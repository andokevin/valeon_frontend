import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/recommendation_provider.dart';

class RecommendationSection extends ConsumerWidget {
  const RecommendationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reco = ref.watch(personalizedProvider);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Recommandé pour vous',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
          color: AppTheme.onBackground)),
      const SizedBox(height: 16),
      reco.when(
        loading: () => const SizedBox(height: 80,
          child: Center(child: CircularProgressIndicator())),
        error: (_, __) => const SizedBox.shrink(),
        data: (items) => items.isEmpty
            ? const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Scannez plus de contenus pour des recommandations personnalisées',
                  style: TextStyle(color: AppTheme.onSurface, fontSize: 13),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length > 5 ? 5 : items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) => _RecommendationTile(item: items[i]),
              ),
      ),
    ]);
  }
}

class _RecommendationTile extends StatelessWidget {
  final Map<String, dynamic> item;
  const _RecommendationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final type = item['type'] ?? 'unknown';
    final (icon, color) = switch (type) {
      'music' => (Icons.music_note_rounded, AppTheme.primary),
      'movie' => (Icons.movie_rounded, Colors.orange),
      'tv_show' => (Icons.tv_rounded, Colors.teal),
      _ => (Icons.star_rounded, AppTheme.secondary),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['title'] ?? '',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600,
              color: AppTheme.onBackground, fontSize: 14)),
          if (item['artist'] != null)
            Text(item['artist'],
              style: const TextStyle(color: AppTheme.onSurface, fontSize: 12)),
          if (item['reason'] != null)
            Text(item['reason'],
              style: TextStyle(color: color, fontSize: 11,
                fontWeight: FontWeight.w500)),
        ])),
        if (item['confidence'] != null)
          Text('${((item['confidence'] as num) * 100).toInt()}%',
            style: const TextStyle(color: AppTheme.onSurface, fontSize: 12)),
      ]),
    );
  }
}
