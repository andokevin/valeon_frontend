// lib/widgets/home/trending_section.dart
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/content_model.dart';
import '../common/cached_image.dart';

class TrendingSection extends StatelessWidget {
  final List<ContentModel> trending;

  const TrendingSection({super.key, required this.trending});

  @override
  Widget build(BuildContext context) {
    if (trending.isEmpty) {
      return const SizedBox();
    }

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: trending.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = trending[index];
          return _buildTrendingCard(context, item);
        },
      ),
    );
  }

  Widget _buildTrendingCard(BuildContext context, ContentModel item) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final width = ResponsiveHelper.trendingCardWidth(context);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/scan/result',
          arguments: {
            'title': item.contentTitle,
            'artist': item.contentArtist,
            'type': item.contentType,
            'image': item.contentImage,
            'content_id': item.contentId,
          },
        );
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: CachedImageWidget(
                url: item.contentImage,
                width: width,
                height: isTablet ? 100 : 80,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.contentTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.contentArtist ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
