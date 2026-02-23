// lib/widgets/home/recommendation_section.dart
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/content_model.dart';

class RecommendationSection extends StatelessWidget {
  final List<ContentModel> recommendations;

  const RecommendationSection({super.key, required this.recommendations});

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          'Scannez plus de contenus pour des recommandations personnalisées',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      );
    }

    return Column(
      children: recommendations.take(5).map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildRecommendationTile(context, item),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendationTile(BuildContext context, ContentModel item) {
    final (icon, color) = _getTypeData(item.contentType);

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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.contentTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.contentArtist != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.contentArtist!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _getTypeData(String type) {
    switch (type) {
      case 'music':
        return (Icons.music_note, AppColors.primaryBlue);
      case 'movie':
      case 'movie_poster':
        return (Icons.movie, Colors.purple);
      case 'tv_show':
        return (Icons.tv, Colors.teal);
      default:
        return (Icons.star, AppColors.secondary);
    }
  }
}
