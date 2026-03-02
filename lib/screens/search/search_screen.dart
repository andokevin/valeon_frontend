// lib/screens/search/search_screen.dart (MODIFIÉ - suppression bordure)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/search_service.dart';
import '../../widgets/layout/space_background.dart';
import '../scan/scan_result_screen.dart';
import '../../widgets/common/theme_switch.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final SearchService _searchService = SearchService();

  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _suggestions = [];
  List<Map<String, dynamic>> _trending = [];
  bool _isSearching = false;
  bool _isLoading = false;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _loadTrending();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTrending() async {
    final trending = await _searchService.getTrending();
    if (mounted) {
      setState(() {
        _trending = trending;
      });
    }
  }

  Future<void> _onSearchChanged(String query) async {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
      _isLoading = query.isNotEmpty;
    });

    if (query.isNotEmpty) {
      // Récupérer les suggestions
      final suggestions = await _searchService.getSuggestions(query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
        });
      }

      // Lancer la recherche après un délai (debounce)
      Future.delayed(const Duration(milliseconds: 500), () async {
        if (query == _searchQuery && mounted) {
          final results = await _searchService.search(
            query: query,
            type: _selectedType,
          );
          if (mounted) {
            setState(() {
              _searchResults =
                  List<Map<String, dynamic>>.from(results['results'] ?? []);
              _isLoading = false;
            });
          }
        }
      });
    } else {
      setState(() {
        _searchResults = [];
        _suggestions = [];
        _isLoading = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
    _focusNode.requestFocus();
  }

  void _applySuggestion(String suggestion) {
    _searchController.text = suggestion;
    _onSearchChanged(suggestion);
  }

  void _filterByType(String? type) {
    setState(() {
      _selectedType = type;
    });
    if (_searchQuery.isNotEmpty) {
      _onSearchChanged(_searchQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final hPadding = ResponsiveHelper.paddingScreen(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.darkPurple,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(context, hPadding, isTablet, isDark),
            _buildFilterTabs(isTablet, isDark),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryBlue))
                  : _isSearching
                      ? _buildSearchResults(context, isTablet, isDark)
                      : _buildSuggestions(context, isTablet, isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ===== MODIFICATION: SUPPRESSION DE LA BORDURE ET AMÉLIORATION VISUELLE =====
  Widget _buildSearchHeader(
      BuildContext context, double hPadding, bool isTablet, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(hPadding),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back,
                color: isDark ? AppColors.darkTextPrimary : Colors.white),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface.withOpacity(0.8)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                // ===== SUPPRESSION DE border =====
                // border: Border.all(...),  // Supprimé
              ),
              child: Row(
                children: [
                  Icon(Icons.search,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.primaryBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: _onSearchChanged,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Rechercher musique, film, image...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : Colors.grey[600],
                          ),
                          border: InputBorder.none, // Pas de bordure
                        ),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Icon(Icons.close,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textDark),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          const ThemeSwitch(showLabel: false),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isTablet, bool isDark) {
    final filters = [
      {'label': 'Tout', 'value': null},
      {'label': 'Musique', 'value': 'music'},
      {'label': 'Films', 'value': 'movie'},
      {'label': 'Séries', 'value': 'tv_show'},
    ];

    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.paddingScreen(context)),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedType == filter['value'];

          return FilterChip(
            label: Text(filter['label'] as String),
            selected: isSelected,
            onSelected: (_) => _filterByType(filter['value']),
            backgroundColor:
                isDark ? AppColors.darkSurface : Colors.white.withOpacity(0.1),
            selectedColor: AppColors.primaryBlue,
            labelStyle: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.darkTextSecondary : Colors.white70),
            ),
            side: BorderSide.none,
          );
        },
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, bool isTablet, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveHelper.paddingScreen(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_suggestions.isNotEmpty) ...[
            const Text(
              'Suggestions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ..._suggestions.map((suggestion) {
              return _buildSuggestionItem(
                  context, suggestion, isTablet, isDark);
            }),
            const SizedBox(height: 32),
          ],
          const Text(
            'Tendances',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ..._trending.map((trend) {
            return _buildTrendingItem(context, trend, isTablet, isDark);
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
          _buildCategoryGrid(context, isTablet, isDark),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(
      BuildContext context, String suggestion, bool isTablet, bool isDark) {
    return GestureDetector(
      onTap: () => _applySuggestion(suggestion),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isDark ? AppColors.darkDivider : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.history,
                color: isDark ? AppColors.darkTextSecondary : Colors.white54),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                suggestion,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.arrow_upward,
              color: isDark ? AppColors.darkTextSecondary : Colors.white54,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingItem(BuildContext context, Map<String, dynamic> trend,
      bool isTablet, bool isDark) {
    return GestureDetector(
      onTap: () => _applySuggestion(trend['title']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isDark ? AppColors.darkDivider : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.trending_up,
                color: isDark ? AppColors.primaryBlue : AppColors.primaryBlue),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                trend['title'],
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${trend['count']} scans',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, bool isTablet, bool isDark) {
    final categories = [
      {
        'icon': Icons.music_note,
        'label': 'Musique',
        'color': AppColors.primaryBlue,
        'type': 'music'
      },
      {
        'icon': Icons.movie,
        'label': 'Films',
        'color': Colors.purple,
        'type': 'movie'
      },
      {
        'icon': Icons.tv,
        'label': 'Séries',
        'color': Colors.orange,
        'type': 'tv_show'
      },
      {
        'icon': Icons.album,
        'label': 'Albums',
        'color': Colors.green,
        'type': 'music'
      },
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
            _filterByType(cat['type'] as String);
            _searchController.text = cat['label'] as String;
            _onSearchChanged(cat['label'] as String);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface
                  : (cat['color'] as Color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? AppColors.darkDivider
                    : (cat['color'] as Color).withOpacity(0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cat['icon'] as IconData,
                  color: isDark
                      ? (cat['color'] as Color)
                      : (cat['color'] as Color),
                  size: isTablet ? 36 : 28,
                ),
                const SizedBox(height: 8),
                Text(
                  cat['label'] as String,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : (cat['color'] as Color),
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

  Widget _buildSearchResults(BuildContext context, bool isTablet, bool isDark) {
    if (_searchResults.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: isTablet ? 80 : 60,
              color: isDark ? AppColors.darkTextSecondary : Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat pour "$_searchQuery"',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? AppColors.darkTextPrimary : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez un autre mot-clé',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : Colors.white70,
              ),
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
        return _buildResultItem(context, item, isTablet, isDark);
      },
    );
  }

  Widget _buildResultItem(BuildContext context, Map<String, dynamic> item,
      bool isTablet, bool isDark) {
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
      case 'tv_show':
        icon = Icons.tv;
        color = Colors.orange;
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
                'description': item['description'] ?? '',
                'image': item['image'],
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isDark ? AppColors.darkDivider : Colors.white.withOpacity(0.2),
          ),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item['artist'] != null)
                    Text(
                      item['artist'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : Colors.white70,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (item['year'] != null)
                        Text(
                          item['year'],
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      if (item['source'] != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['source'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
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
