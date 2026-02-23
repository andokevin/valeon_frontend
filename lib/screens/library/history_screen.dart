// lib/screens/library/history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:valeon/providers/auth_provider.dart';
import '../../config/app_theme.dart';
import '../../providers/library_provider.dart';
import '../../widgets/layout/space_background.dart';
import '../scan/scan_result_screen.dart';
import '../../models/scan_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final library = Provider.of<LibraryProvider>(context, listen: false);

    if (auth.user != null) {
      await library.loadUserLibrary(auth.user!);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Aujourd'hui à ${DateFormat.Hm().format(date)}";
    } else if (difference.inDays == 1) {
      return "Hier à ${DateFormat.Hm().format(date)}";
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'audio':
      case 'music':
        return AppColors.primaryBlue;
      case 'image':
      case 'photo':
        return const Color(0xFF9B59B6);
      case 'video':
      case 'movie':
        return const Color(0xFF2ECC71);
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'audio':
      case 'music':
        return Icons.music_note;
      case 'image':
      case 'photo':
        return Icons.image;
      case 'video':
      case 'movie':
        return Icons.videocam;
      default:
        return Icons.history;
    }
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
              child: library.history.isEmpty
                  ? _buildEmptyState(isTablet)
                  : ListView.separated(
                      padding: EdgeInsets.all(hPadding),
                      itemCount: library.history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final scan = library.history[index];
                        final type = scan.scanType.name;
                        final color = _getTypeColor(type);
                        final icon = _getTypeIcon(type);

                        return GestureDetector(
                          onTap: () {
                            if (scan.result != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScanResultScreen(
                                    scanResult: scan.result,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2)),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        scan.content?.contentTitle ??
                                            'Scan ${scan.scanType.name}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(scan.scanDate),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scan.status == ScanStatus.completed
                                        ? Colors.green.withOpacity(0.2)
                                        : scan.status == ScanStatus.failed
                                            ? Colors.red.withOpacity(0.2)
                                            : Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    scan.statusLabel,
                                    style: TextStyle(
                                      color: scan.status == ScanStatus.completed
                                          ? Colors.green
                                          : scan.status == ScanStatus.failed
                                              ? Colors.red
                                              : Colors.orange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
          const Expanded(
            child: Text(
              'Historique',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, color: Colors.white),
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
            Icons.history,
            size: isTablet ? 80 : 60,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun historique',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Scannez du contenu pour voir votre historique',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
