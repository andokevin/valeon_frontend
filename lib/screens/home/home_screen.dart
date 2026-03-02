// lib/screens/home/home_screen.dart (SANS _buildQuickScanButtons)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valeon/models/content_model.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recommendation_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../widgets/home/scan_action_card.dart';
import '../../widgets/home/trending_section.dart';
import '../../widgets/home/recommendation_section.dart';
import '../../widgets/layout/space_background.dart';
import '../search/search_screen.dart';
import '../chat/chat_screen.dart';
import '../scan/scan_result_screen.dart';
import '../../services/recommendation_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ContentModel> _recommendations = [];
  bool _loadingRecommendations = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _loadAdditionalRecommendations();
    });
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final recs = Provider.of<RecommendationProvider>(context, listen: false);

    if (auth.user != null) {
      await recs.loadRecommendations(auth.user!);
    }
  }

  Future<void> _loadAdditionalRecommendations() async {
    setState(() {
      _loadingRecommendations = true;
    });

    try {
      final recService = RecommendationService();
      final recommendations = await recService.getPersonalized(limit: 10);

      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _loadingRecommendations = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Erreur chargement recommandations supplémentaires: $e');
      if (mounted) {
        setState(() {
          _loadingRecommendations = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final hPadding = ResponsiveHelper.paddingScreen(context);
    final connectivity = Provider.of<ConnectivityProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final recs = Provider.of<RecommendationProvider>(context);

    return SpaceBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, hPadding, auth, connectivity),
            Expanded(
              child: recs.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryBlue))
                  : recs.errorMessage != null && !connectivity.isOnline
                      ? _buildOfflineView()
                      : recs.errorMessage != null
                          ? _buildErrorView(context)
                          : _buildContent(context, recs, auth, isTablet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double hPadding, AuthProvider auth,
      ConnectivityProvider connectivity) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Padding(
      padding: EdgeInsets.all(hPadding),
      child: Row(
        children: [
          Container(
            width: isTablet ? 52 : 44,
            height: isTablet ? 52 : 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.lightPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.diamond,
              color: Colors.white,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          const Text(
            'Valeon',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          if (!auth.isPremium)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/premium');
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.premium.withOpacity(0.2),
                  foregroundColor: AppColors.premium,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Premium'),
              ),
            ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off,
            size: 64,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          const Text(
            'Pas de connexion internet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connectez-vous pour découvrir du contenu',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Provider.of<ConnectivityProvider>(context, listen: false)
                  .checkConnection();
            },
            child: const Text('Vérifier la connexion'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Une erreur est survenue',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Provider.of<RecommendationProvider>(context).errorMessage ?? '',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    RecommendationProvider recs,
    AuthProvider auth,
    bool isTablet,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveHelper.paddingScreen(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeMessage(context, auth.userName, isTablet),
          const SizedBox(height: 20),
          _buildSearchBar(context),
          const SizedBox(height: 32),

          // ===== SECTION TENDANCES =====
          if (recs.trending.isNotEmpty) ...[
            _buildSectionHeader(context, 'Tendances', () {
              // Voir tout
            }),
            const SizedBox(height: 16),
            TrendingSection(trending: recs.trending),
            const SizedBox(height: 32),
          ],

          // ===== SECTION RECOMMANDÉ POUR VOUS =====
          if (recs.personalized.isNotEmpty) ...[
            _buildSectionHeader(context, 'Recommandé pour vous', () {
              // Voir tout
            }),
            const SizedBox(height: 16),
            RecommendationSection(recommendations: recs.personalized),
            const SizedBox(height: 32),
          ],

          // ===== SECTION RECOMMANDATIONS SUPPLÉMENTAIRES =====
          if (!_loadingRecommendations && _recommendations.isNotEmpty) ...[
            _buildSectionHeader(context, 'Découvrez aussi', () {
              // Voir tout
            }),
            const SizedBox(height: 16),
            ..._recommendations.take(3).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildForYouItem(context, item, isTablet),
              );
            }),
            const SizedBox(height: 32),
          ] else if (_loadingRecommendations) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              ),
            ),
          ],

          // ===== SECTION POUR VOUS (si existe) =====
          if (recs.forYou.isNotEmpty) ...[
            _buildSectionHeader(context, 'Pour vous', () {
              // Voir tout
            }),
            const SizedBox(height: 16),
            _buildForYouList(context, recs.forYou, isTablet),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage(
      BuildContext context, String name, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour $name 👋',
          style: TextStyle(
            fontSize: isTablet ? 32 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Découvrez tout ce qui vous entoure',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isTablet ? 18 : 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.8),
              size: isTablet ? 26 : 22,
            ),
            SizedBox(width: isTablet ? 16 : 12),
            const Expanded(
              child: Text(
                'Rechercher musique, film, image...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onSeeAll,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveHelper.isTablet(context) ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            'Voir tout',
            style: TextStyle(
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForYouList(
      BuildContext context, List<ContentModel> items, bool isTablet) {
    return Column(
      children: items.take(3).map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildForYouItem(context, item, isTablet),
        );
      }).toList(),
    );
  }

  Widget _buildForYouItem(
      BuildContext context, ContentModel item, bool isTablet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ScanResultScreen(
                    scanResult: {
                      'title': item.contentTitle,
                      'artist': item.contentArtist ?? '',
                      'year': item.contentReleaseDate ?? '',
                      'type': item.contentType,
                      'description': item.contentDescription ?? '',
                      'image': item.contentImage ?? '',
                      'content_id': item.contentId,
                    },
                  )),
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getTypeColor(item.contentType).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getTypeColor(item.contentType).withOpacity(0.5),
                ),
              ),
              child: Icon(
                _getTypeIcon(item.contentType),
                color: _getTypeColor(item.contentType),
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.contentTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.contentArtist ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'music':
        return AppColors.primaryBlue;
      case 'movie':
      case 'movie_poster':
        return const Color(0xFF9B59B6);
      case 'image':
      case 'photo':
        return const Color(0xFF2ECC71);
      default:
        return AppColors.primaryBlue;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'music':
        return Icons.music_note;
      case 'movie':
      case 'movie_poster':
        return Icons.movie;
      case 'image':
      case 'photo':
        return Icons.image;
      default:
        return Icons.music_note;
    }
  }
}
