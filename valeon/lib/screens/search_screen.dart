import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import 'result_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  // Données de recherche simulées
  final List<Map<String, dynamic>> _allResults = [
    {
      'title': 'Blinding Lights',
      'artist': 'The Weeknd',
      'year': '2019',
      'genre': 'Synth-pop',
      'type': 'music',
      'description': 'Chanson populaire de The Weeknd sortie en 2019.',
    },
    {
      'title': 'Heat Waves',
      'artist': 'Glass Animals',
      'year': '2020',
      'genre': 'Indie Pop',
      'type': 'music',
      'description': 'Chanson populaire du groupe Glass Animals sortie en 2020.',
    },
    {
      'title': 'Sunflower',
      'artist': 'Post Malone & Swae Lee',
      'year': '2018',
      'genre': 'Hip-hop',
      'type': 'music',
      'description': 'Chanson du film Spider-Man: Into the Spider-Verse.',
    },
    {
      'title': 'Another Love',
      'artist': 'Tom Odell',
      'year': '2013',
      'genre': 'Indie Pop',
      'type': 'music',
      'description': 'Chanson émouvante de Tom Odell.',
    },
    {
      'title': 'Lose Yourself',
      'artist': 'Eminem',
      'year': '2002',
      'genre': 'Hip-hop',
      'type': 'music',
      'description': 'Chanson emblématique d\'Eminem.',
    },
    {
      'title': 'Inception',
      'artist': 'Christopher Nolan',
      'year': '2010',
      'genre': 'Science-fiction',
      'type': 'film',
      'description': 'Un voleur qui s\'infiltre dans les rêves.',
    },
    {
      'title': 'Interstellar',
      'artist': 'Christopher Nolan',
      'year': '2014',
      'genre': 'Science-fiction',
      'type': 'film',
      'description': 'Un voyage à travers les étoiles.',
    },
    {
      'title': 'The Dark Knight',
      'artist': 'Christopher Nolan',
      'year': '2008',
      'genre': 'Action',
      'type': 'film',
      'description': 'Batman affronte le Joker.',
    },
    {
      'title': 'Avengers: Endgame',
      'artist': 'Russo Brothers',
      'year': '2019',
      'genre': 'Action',
      'type': 'film',
      'description': 'La bataille finale des Avengers.',
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

  List<Map<String, dynamic>> _filteredResults = [];

  // Suggestions rapides selon la maquette
  final List<Map<String, dynamic>> _trendingSuggestions = [
    {'title': 'Blinding Lights', 'type': 'music'},
    {'title': 'Inception', 'type': 'film'},
    {'title': 'Heat Waves', 'type': 'music'},
    {'title': 'Van Gogh', 'type': 'image'},
    {'title': 'Interstellar', 'type': 'film'},
  ];

  @override
  void initState() {
    super.initState();
    _filteredResults = [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredResults = [];
      } else {
        _filteredResults = _allResults
            .where((item) =>
                item['title']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                item['artist']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                item['genre']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header avec barre de recherche
              _buildSearchHeader(),

              const SizedBox(height: 16),

              // Contenu
              Expanded(
                child: _isSearching
                    ? _buildSearchResults()
                    : _buildSuggestionsContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingScreen),
      child: Row(
        children: [
          // Bouton retour
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),

          // Barre de recherche
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusButton),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      autofocus: true,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: AppStrings.searchPlaceholder,
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      child: Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingScreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trending
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trending',
                style: AppTextStyles.titleSmall.copyWith(fontSize: 18),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Voir tout',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Suggestions rapides
          ..._trendingSuggestions.map((suggestion) {
            return _buildSuggestionItem(suggestion);
          }).toList(),

          const SizedBox(height: 32),

          // Catégories
          Text(
            'Catégories',
            style: AppTextStyles.titleSmall.copyWith(fontSize: 18),
          ),

          const SizedBox(height: 16),

          // Grid catégories
          Row(
            children: [
              Expanded(
                child: _buildCategoryCard(
                  icon: Icons.music_note,
                  label: 'Musiques',
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCategoryCard(
                  icon: Icons.movie,
                  label: 'Films',
                  color: const Color(0xFF9B59B6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildCategoryCard(
                  icon: Icons.image,
                  label: 'Images',
                  color: const Color(0xFF2ECC71),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCategoryCard(
                  icon: Icons.video_library,
                  label: 'Vidéos',
                  color: const Color(0xFFE67E22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(Map<String, dynamic> suggestion) {
    IconData icon;
    switch (suggestion['type']) {
      case 'music':
        icon = Icons.music_note;
        break;
      case 'film':
        icon = Icons.movie;
        break;
      case 'image':
        icon = Icons.image;
        break;
      default:
        icon = Icons.search;
    }

    return GestureDetector(
      onTap: () {
        _searchController.text = suggestion['title'];
        _onSearchChanged(suggestion['title']);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                suggestion['title'],
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.north_west,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _onSearchChanged(label);
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: color.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_filteredResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: AppColors.textSecondary,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat pour "$_searchQuery"',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez un autre mot-clé',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.paddingScreen),
      itemCount: _filteredResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _filteredResults[index];
        return _buildResultItem(item);
      },
    );
  }

  Widget _buildResultItem(Map<String, dynamic> item) {
    IconData icon;
    Color color;

    switch (item['type']) {
      case 'music':
        icon = Icons.music_note;
        color = AppColors.primaryBlue;
        break;
      case 'film':
        icon = Icons.movie;
        color = const Color(0xFF9B59B6);
        break;
      case 'image':
        icon = Icons.image;
        color = const Color(0xFF2ECC71);
        break;
      default:
        icon = Icons.search;
        color = AppColors.primaryBlue;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: item['title'],
              artist: item['artist'],
              year: item['year'],
              genre: item['genre'],
              description: item['description'],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: color.withOpacity(0.4),
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['artist'],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item['genre'],
                          style: AppTextStyles.bodySmall.copyWith(
                            color: color,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item['year'],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}