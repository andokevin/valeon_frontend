import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/library_provider.dart';
import '../../widgets/common/cached_image.dart';

class ScanResultScreen extends ConsumerWidget {
  final Map<String, dynamic>? scanResult;
  const ScanResultScreen({super.key, this.scanResult});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (scanResult == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Résultat')),
        body: const Center(child: Text('Aucun résultat disponible',
          style: TextStyle(color: AppTheme.onSurface))),
      );
    }
    final r = scanResult!;
    final title = r['title'] ?? r['content_title'] ?? 'Inconnu';
    final type = r['type'] ?? r['content_type'] ?? 'unknown';
    final artist = r['artist'] ?? r['content_artist'];
    final image = r['image'] ?? r['content_image'];
    final description = r['description'] ?? r['content_description'];
    final confidence = ((r['confidence'] ?? 0.0) * 100).toInt();
    final metadata = r['metadata'] as Map<String, dynamic>? ?? {};
    final externalLinks = r['external_links'] as Map<String, dynamic>? ?? {};
    final streaming = r['streaming'] as Map<String, dynamic>?;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go('/home'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
                if (image != null)
                  CachedImageWidget(url: image, fit: BoxFit.cover)
                else
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.music_note_rounded, size: 80, color: Colors.white54),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppTheme.background.withOpacity(0.9)],
                    ),
                  ),
                ),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(delegate: SliverChildListDelegate([
              // Badge type + confidence
              Row(children: [
                _TypeBadge(type: type),
                const SizedBox(width: 8),
                if (confidence > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _confidenceColor(confidence).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$confidence% confiance',
                      style: TextStyle(color: _confidenceColor(confidence), fontSize: 12)),
                  ),
              ]),
              const SizedBox(height: 12),
              Text(title,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700,
                  color: AppTheme.onBackground)),
              if (artist != null) ...[
                const SizedBox(height: 4),
                Text(artist, style: const TextStyle(fontSize: 16, color: AppTheme.onSurface)),
              ],
              if (description != null) ...[
                const SizedBox(height: 16),
                Text(description, style: const TextStyle(color: AppTheme.onSurface, height: 1.6)),
              ],
              // Metadata
              if (metadata.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('Détails', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppTheme.onBackground)),
                const SizedBox(height: 12),
                _MetadataGrid(metadata: metadata),
              ],
              // Streaming
              if (streaming != null && (streaming['streaming'] as List?)?.isNotEmpty == true) ...[
                const SizedBox(height: 24),
                const Text('Disponible sur', style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w700, color: AppTheme.onBackground)),
                const SizedBox(height: 12),
                _StreamingList(providers: List<Map<String, dynamic>>.from(streaming['streaming'])),
              ],
              // Actions
              const SizedBox(height: 32),
              Row(children: [
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Nouveau scan'),
                )),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => context.go('/library'),
                  icon: const Icon(Icons.library_add_rounded),
                  label: const Text('Bibliothèque'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )),
              ]),
              const SizedBox(height: 32),
            ])),
          ),
        ],
      ),
    );
  }

  Color _confidenceColor(int c) {
    if (c >= 80) return Colors.green;
    if (c >= 50) return Colors.orange;
    return AppTheme.error;
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      'music' => ('🎵 Musique', AppTheme.primary),
      'movie' || 'movie_poster' => ('🎬 Film', Colors.orange),
      'tv_show' => ('📺 Série', Colors.teal),
      'album_cover' => ('💿 Album', Colors.purple),
      _ => ('📁 Contenu', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _MetadataGrid extends StatelessWidget {
  final Map<String, dynamic> metadata;
  const _MetadataGrid({required this.metadata});

  @override
  Widget build(BuildContext context) {
    final entries = metadata.entries
        .where((e) => e.value != null && e.value.toString().isNotEmpty)
        .take(6).toList();
    return Wrap(spacing: 8, runSpacing: 8, children: entries.map((e) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(e.key, style: const TextStyle(color: AppTheme.onSurface, fontSize: 11)),
        Text(e.value.toString(),
          style: const TextStyle(color: AppTheme.onBackground, fontSize: 13,
            fontWeight: FontWeight.w500)),
      ]),
    )).toList());
  }
}

class _StreamingList extends StatelessWidget {
  final List<Map<String, dynamic>> providers;
  const _StreamingList({required this.providers});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 12, runSpacing: 12, children: providers.map((p) {
      final name = p['provider'] ?? '';
      final url = p['url'] ?? '';
      return InkWell(
        onTap: () async {
          if (url.isNotEmpty) {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) launchUrl(uri);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
          ),
          child: Text(name, style: const TextStyle(color: AppTheme.onBackground,
            fontWeight: FontWeight.w500)),
        ),
      );
    }).toList());
  }
}
