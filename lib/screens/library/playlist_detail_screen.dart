// lib/screens/library/playlist_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valeon/models/content_model.dart';
import '../../config/app_theme.dart';
import '../../providers/library_provider.dart';
import '../../widgets/layout/space_background.dart';
import '../../widgets/library/content_list_tile.dart';
import '../scan/scan_result_screen.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final int playlistId;
  final String playlistName;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  List<ContentModel> _contents = [];

  @override
  void initState() {
    super.initState();
    _loadContents();
  }

  Future<void> _loadContents() async {
    // TODO: Charger les contenus de la playlist
    // Pour l'instant, on utilise des données mock
    setState(() {
      _contents = [
        ContentModel(
          contentId: 1,
          contentType: 'music',
          contentTitle: 'Blinding Lights',
          contentArtist: 'The Weeknd',
          contentImage: '',
        ),
        ContentModel(
          contentId: 2,
          contentType: 'music',
          contentTitle: 'Heat Waves',
          contentArtist: 'Glass Animals',
          contentImage: '',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final hPadding = ResponsiveHelper.paddingScreen(context);
    final library = Provider.of<LibraryProvider>(context);

    return SpaceBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, hPadding, isTablet),
            Expanded(
              child: _contents.isEmpty
                  ? _buildEmptyState(isTablet)
                  : ListView.separated(
                      padding: EdgeInsets.all(hPadding),
                      itemCount: _contents.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final content = _contents[index];
                        return ContentListTile(
                          imageUrl: content.contentImage,
                          title: content.contentTitle,
                          subtitle: content.contentArtist ?? '',
                          type: content.contentType,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () {
                              // TODO: Retirer de la playlist
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScanResultScreen(
                                  scanResult: {
                                    'title': content.contentTitle,
                                    'artist': content.contentArtist,
                                    'type': content.contentType,
                                    'image': content.contentImage,
                                    'content_id': content.contentId,
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double hPadding, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(hPadding),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Text(
              widget.playlistName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'delete') {
                // TODO: Supprimer la playlist
                Navigator.pop(context);
              } else if (value == 'rename') {
                // TODO: Renommer la playlist
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'rename',
                child: Text('Renommer'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Supprimer', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_add,
            size: isTablet ? 80 : 60,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          const Text(
            'Playlist vide',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajoutez des contenus depuis vos scans',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Ajouter des contenus
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter des contenus'),
          ),
        ],
      ),
    );
  }
}
