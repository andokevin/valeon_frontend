// lib/screens/scan/scan_video_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:valeon/models/scan_model.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scan_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../widgets/scan/scan_progress_widget.dart';
import 'scan_result_screen.dart';

class ScanVideoScreen extends StatefulWidget {
  const ScanVideoScreen({super.key});

  @override
  State<ScanVideoScreen> createState() => _ScanVideoScreenState();
}

class _ScanVideoScreenState extends State<ScanVideoScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo(ImageSource source) async {
    final video = await _picker.pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 5),
    );
    if (video != null) {
      await _startScan(File(video.path));
    }
  }

  Future<void> _startScan(File file) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final connectivityProvider =
        Provider.of<ConnectivityProvider>(context, listen: false);

    if (authProvider.user == null) return;

    if (!connectivityProvider.isOnline) {
      _showError('Connexion internet requise pour scanner');
      return;
    }

    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    await scanProvider.scanVideo(file, authProvider.user!);

    if (scanProvider.phase == ScanPhase.done && scanProvider.result != null) {
      _navigateToResult(scanProvider.result!);
    }
  }

  void _navigateToResult(ScanModel scan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanResultScreen(scanResult: scan.result),
      ),
    ).then((_) {
      Provider.of<ScanProvider>(context, listen: false).reset();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanState = Provider.of<ScanProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final connectivity = Provider.of<ConnectivityProvider>(context);
    final isPremium = auth.isPremium;

    if (isPremium) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.premium.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star,
                size: 64,
                color: AppColors.premium,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Fonctionnalité Premium',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Passez à Premium pour scanner des vidéos',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.premium,
                foregroundColor: Colors.black,
              ),
              child: const Text('Voir les offres'),
            ),
          ],
        ),
      );
     }
    

    if (scanState.phase != ScanPhase.idle) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: ScanProgressWidget(
          phase: scanState.phase,
          error: scanState.errorMessage,
          onRetry: scanState.reset,
        ),
      );
    }

    if (scanState.phase == ScanPhase.done && scanState.result != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToResult(scanState.result!);
      });
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!connectivity.isOnline)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Connexion internet requise pour scanner',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          if (!connectivity.isOnline) const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.video_library,
              size: 80,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Scanner une vidéo',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Identifiez films, séries et clips musicaux\ndepuis votre vidéo',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: connectivity.isOnline
                ? () => _pickVideo(ImageSource.camera)
                : null,
            icon: const Icon(Icons.videocam),
            label: const Text('Enregistrer une vidéo'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: connectivity.isOnline
                ? () => _pickVideo(ImageSource.gallery)
                : null,
            icon: const Icon(Icons.video_library),
            label: const Text('Choisir depuis la galerie'),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  connectivity.isOnline ? AppColors.secondary : Colors.grey,
              side: BorderSide(
                color:
                    connectivity.isOnline ? AppColors.secondary : Colors.grey,
              ),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
