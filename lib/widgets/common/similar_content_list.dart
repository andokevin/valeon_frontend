// lib/widgets/common/similar_content_list.dart
import 'package:flutter/material.dart';
import '../common/cached_image.dart';

class SimilarContentList extends StatelessWidget {
  final List<dynamic> items;
  final String type;
  final String title;

  const SimilarContentList({
    super.key,
    required this.items,
    required this.type,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length > 5 ? 5 : items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildSimilarItem(context, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarItem(BuildContext context, dynamic item) {
    final title = item is Map ? (item['title'] ?? '') : item.toString();
    final artist =
        item is Map ? (item['artist'] ?? item['director'] ?? '') : '';
    final image = item is Map ? (item['image'] ?? item['thumbnail'] ?? '') : '';
    final year = item is Map ? (item['year'] ?? '') : '';

    return GestureDetector(
      onTap: () {
        // TODO: Naviguer vers le détail de cet élément
      },
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: CachedImageWidget(
                url: image,
                width: 120,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),

            // Infos
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (artist.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      artist,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (year.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      year,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
