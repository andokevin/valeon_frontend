// lib/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/layout/space_background.dart';
import '../scan/scan_result_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  final List<Map<String, dynamic>> _mockResults = [
    {
      'title': 'Blinding Lights',
      'artist': 'The Weeknd',
      'year': '2019',
      'genre': 'Synth-pop',
      'type': 'music',
      'description': 'Chanson populaire de The Weeknd.',
    },
    {
      'title': 'Heat Waves',
      'artist': 'Glass Animals',
      'year': '2020',
      'genre': 'Indie Pop',
      'type': 'music',
      'description': 'Chanson populaire du groupe Glass Animals.',
    },
    {
      'title': 'Inception',
      'artist': 'Christopher Nolan',
      'year': '2010',
      'genre': 'Science-fiction',
      'type': 'movie',
      'description': 'Un voleur qui s\'infiltre dans les rêves.',
    },
    {
      'title': 'Interstellar',
      'artist': 'Christopher Nolan',
      'year': '2014',
      'genre': 'Science-fiction',
      'type': 'movie',
      'description': 'Un voyage à travers les étoiles.',
    },
    {
      'title': 'La Nuit Étoilée',
      'artist': 'Vincent Van Gogh',
      'year': '1889',
      'genre': 'Post-impressionnisme',
      'type': 'image',
      'description': 'Tableau célèbre de Van Gogh.',
    },
  ];

  final List<Map<String, dynamic>> _trendingSuggestions = [
    {'title': 'Blinding Lights', 'type': 'music'},
    {'title': 'Inception', 'type': 'movie'},
    {'title': 'Heat Waves', 'type': 'music'},
    {'title': 'Interstellar', 'type': 'movie'},
    {'title': 'Van Gogh', 'type': 'image'},
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;

      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _mockResults.where((item) {
          return item['title']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              item['artist']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final hPadding = ResponsiveHelper.paddingScreen(context);

    return SpaceBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(context, hPadding, isTablet),
            Expanded(
              child: _isSearching
                  ? _buildSearchResults(context, isTablet)
                  : _buildSuggestions(context, isTablet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(
      BuildContext context, double hPadding, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(hPadding),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white54),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Rechercher...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: const Icon(Icons.close, color: Colors.white54),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveHelper.paddingScreen(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tendances',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ..._trendingSuggestions.map((suggestion) {
            return _buildSuggestionItem(context, suggestion, isTablet);
          }),
          const SizedBox(height: 32),
          const Text(
            'Catégories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoryGrid(context, isTablet),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(
      BuildContext context, Map<String, dynamic> suggestion, bool isTablet) {
    IconData icon;
    Color color;

    switch (suggestion['type']) {
      case 'music':
        icon = Icons.music_note;
        color = AppColors.primaryBlue;
        break;
      case 'movie':
        icon = Icons.movie;
        color = Colors.purple;
        break;
      case 'image':
        icon = Icons.image;
        color = Colors.green;
        break;
      default:
        icon = Icons.search;
        color = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        _searchController.text = suggestion['title'];
        _onSearchChanged(suggestion['title']);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                suggestion['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(
              Icons.north_west,
              color: Colors.white54,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, bool isTablet) {
    final categories = [
      {
        'icon': Icons.music_note,
        'label': 'Musique',
        'color': AppColors.primaryBlue
      },
      {'icon': Icons.movie, 'label': 'Films', 'color': Colors.purple},
      {'icon': Icons.image, 'label': 'Images', 'color': Colors.green},
      {'icon': Icons.tv, 'label': 'Séries', 'color': Colors.orange},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return GestureDetector(
          onTap: () {
            _searchController.text = cat['label'] as String;
            _onSearchChanged(cat['label'] as String);
          },
          child: Container(
            decoration: BoxDecoration(
              color: (cat['color'] as Color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: (cat['color'] as Color).withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cat['icon'] as IconData,
                  color: cat['color'] as Color,
                  size: isTablet ? 36 : 28,
                ),
                const SizedBox(height: 8),
                Text(
                  cat['label'] as String,
                  style: TextStyle(
                    color: cat['color'] as Color,
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(BuildContext context, bool isTablet) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: isTablet ? 80 : 60,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat pour "$_searchQuery"',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Essayez un autre mot-clé',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(ResponsiveHelper.paddingScreen(context)),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return _buildResultItem(context, item, isTablet);
      },
    );
  }

  Widget _buildResultItem(
      BuildContext context, Map<String, dynamic> item, bool isTablet) {
    IconData icon;
    Color color;

    switch (item['type']) {
      case 'music':
        icon = Icons.music_note;
        color = AppColors.primaryBlue;
        break;
      case 'movie':
        icon = Icons.movie;
        color = Colors.purple;
        break;
      case 'image':
        icon = Icons.image;
        color = Colors.green;
        break;
      default:
        icon = Icons.search;
        color = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultScreen(
              scanResult: {
                'title': item['title'],
                'artist': item['artist'],
                'year': item['year'],
                'type': item['type'],
                'description': item['description'],
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['artist'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item['genre'],
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item['year'],
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
