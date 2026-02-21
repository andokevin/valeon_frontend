import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
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
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedImageWidget(
            url: imageUrl,
            width: 52,
            height: 52,
            placeholder: Container(
              width: 52, height: 52,
              color: AppTheme.surfaceVariant,
              child: Icon(_typeIcon(type), color: _typeColor(type), size: 24),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600,
              color: AppTheme.onBackground, fontSize: 14)),
          const SizedBox(height: 2),
          Text(subtitle,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.onSurface, fontSize: 12)),
          const SizedBox(height: 4),
          _TypeChip(type: type),
        ])),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ]),
    ),
  );

  IconData _typeIcon(String t) {
    switch (t) {
      case 'music': return Icons.music_note_rounded;
      case 'movie': case 'movie_poster': return Icons.movie_rounded;
      case 'tv_show': return Icons.tv_rounded;
      case 'album_cover': return Icons.album_rounded;
      default: return Icons.insert_drive_file_rounded;
    }
  }

  Color _typeColor(String t) {
    switch (t) {
      case 'music': return AppTheme.primary;
      case 'movie': case 'movie_poster': return Colors.orange;
      case 'tv_show': return Colors.teal;
      case 'album_cover': return Colors.purple;
      default: return Colors.grey;
    }
  }
}

class _TypeChip extends StatelessWidget {
  final String type;
  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      'music' => ('🎵 Musique', AppTheme.primary),
      'movie' || 'movie_poster' => ('🎬 Film', Colors.orange),
      'tv_show' => ('📺 Série', Colors.teal),
      'album_cover' => ('💿 Album', Colors.purple),
      _ => ('📁 Autre', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10,
        fontWeight: FontWeight.w500)),
    );
  }
}
