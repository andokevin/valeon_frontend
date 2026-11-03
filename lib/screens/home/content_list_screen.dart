// lib/screens/home/content_list_screen.dart
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/content_model.dart';
import '../../widgets/common/cached_image.dart';
import '../../widgets/layout/space_background.dart';
import '../scan/scan_result_screen.dart';

/// Page « Voir tout » : liste complète d'une section de l'accueil.
/// Un appui ouvre la fiche détaillée (infos, liens, similaires proposés par Gemini).
class ContentListScreen extends StatelessWidget {
  final String title;
  final List<ContentModel> items;

  const ContentListScreen({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return SpaceBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(title)),
        body: SafeArea(
          child: items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Rien à afficher pour le moment.\nScannez des musiques pour enrichir cette liste.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(ResponsiveHelper.paddingScreen(context)),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _ContentTile(item: items[index]),
                ),
        ),
      ),
    );
  }
}

class _ContentTile extends StatelessWidget {
  final ContentModel item;

  const _ContentTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final subtitle = item.contentArtist ?? item.contentDirector;
    final reason = item.raw?['reason']?.toString();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanResultScreen(scanResult: item.toScanResult()),
          ),
        ),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: (item.contentImage != null && item.contentImage!.isNotEmpty)
                      ? CachedImageWidget(url: item.contentImage!, fit: BoxFit.cover)
                      : Container(
                          color: AppColors.primaryBlue.withValues(alpha: 0.3),
                          child: Icon(
                            item.isMusic ? Icons.music_note : Icons.movie,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.contentTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty)
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    if (reason != null && reason.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(reason,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
