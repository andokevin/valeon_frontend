// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valeon/models/content_model.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recommendation_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/sync_provider.dart';
import '../../widgets/home/scan_action_card.dart';
import '../../widgets/home/trending_section.dart';
import '../../widgets/home/recommendation_section.dart';
import '../../widgets/layout/space_background.dart';
import '../../widgets/layout/offline_banner.dart';
import '../search/search_screen.dart';
import '../chat/chat_screen.dart';
import '../scan/scan_result_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final recs = Provider.of<RecommendationProvider>(context, listen: false);
    final syncProvider = Provider.of<SyncProvider>(context, listen: false);

    if (auth.user != null) {
      await recs.loadRecommendations(auth.user!);

      // Déclencher la synchronisation si connecté
      if (!syncProvider.isSyncing) {
        syncProvider.syncAll(user: auth.user);
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
            // Bannière hors ligne
            if (!connectivity.isOnline) const OfflineBanner(),

            // Header
            _buildHeader(context, hPadding, auth),

            Expanded(
              child: recs.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryBlue))
                  : recs.errorMessage != null
                      ? _buildErrorView(context)
                      : _buildContent(context, recs, auth, isTablet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, double hPadding, AuthProvider auth) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Padding(
      padding: EdgeInsets.all(hPadding),
      child: Row(
        children: [
          // Logo
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

          // Titre
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

          // Bouton premium si pas premium
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
                child: const Row(
                  children: [
                    Icon(Icons.star, size: 16),
                    SizedBox(width: 4),
                    Text('Premium', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),

          // Bouton chat IA
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

          // Bouton recherche
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
          // Message de bienvenue
          _buildWelcomeMessage(context, auth.userName, isTablet),

          const SizedBox(height: 20),

          // Barre de recherche rapide
          _buildSearchBar(context),

          const SizedBox(height: 32),

          // Boutons de scan rapide
          _buildQuickScanButtons(context, auth.isPremium),

          const SizedBox(height: 32),

          // Section Tendances
          if (recs.trending.isNotEmpty) ...[
            _buildSectionHeader(context, 'Tendances', () {
              // Voir tout
            }),
            const SizedBox(height: 16),
            TrendingSection(trending: recs.trending),
          ],

          const SizedBox(height: 32),

          // Section Recommandations
          if (recs.personalized.isNotEmpty) ...[
            _buildSectionHeader(context, 'Recommandé pour vous', () {
              // Voir tout
            }),
            const SizedBox(height: 16),
            RecommendationSection(recommendations: recs.personalized),
          ],

          const SizedBox(height: 32),

          // Section Pour vous
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

  Widget _buildQuickScanButtons(BuildContext context, bool isPremium) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ScanActionCard(
          icon: Icons.mic,
          label: 'Audio',
          color: AppColors.primaryBlue,
          onTap: () {
            if (widget.onNavigate != null) {
              widget.onNavigate!(1);
            } else {
              Navigator.pushNamed(context, '/scan/audio');
            }
          },
        ),
        const SizedBox(width: 12),
        ScanActionCard(
          icon: Icons.image,
          label: 'Image',
          color: const Color(0xFF9B59B6),
          onTap: () {
            if (widget.onNavigate != null) {
              widget.onNavigate!(1);
            } else {
              Navigator.pushNamed(context, '/scan/image');
            }
          },
        ),
        const SizedBox(width: 12),
        ScanActionCard(
          icon: Icons.videocam,
          label: 'Vidéo',
          color: const Color(0xFF2ECC71),
          isPremiumOnly: true,
          isPremium: isPremium,
          onTap: () {
            if (isPremium) {
              if (widget.onNavigate != null) {
                widget.onNavigate!(1);
              } else {
                Navigator.pushNamed(context, '/scan/video');
              }
            } else {
              Navigator.pushNamed(context, '/premium');
            }
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onSeeAll,
  ) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
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
