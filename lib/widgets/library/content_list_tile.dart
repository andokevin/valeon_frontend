// lib/widgets/library/content_list_tile.dart
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../common/cached_image.dart';

class ContentListTile extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String subtitle;
  final String type;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ContentListTile({
    super.key,
    this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.type,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _getTypeData(type);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedImageWidget(
                url: imageUrl,
                width: 52,
                height: 52,
                placeholder: Container(
                  width: 52,
                  height: 52,
                  color: color.withOpacity(0.2),
                  child: Icon(icon, color: color, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _buildTypeChip(type, color),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
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
      case 'album_cover':
        return (Icons.album, Colors.purple);
      default:
        return (Icons.insert_drive_file, Colors.grey);
    }
  }

  Widget _buildTypeChip(String type, Color color) {
    String label;
    switch (type) {
      case 'music':
        label = '🎵 Musique';
        break;
      case 'movie':
      case 'movie_poster':
        label = '🎬 Film';
        break;
      case 'tv_show':
        label = '📺 Série';
        break;
      case 'album_cover':
        label = '💿 Album';
        break;
      default:
        label = '📁 Contenu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
