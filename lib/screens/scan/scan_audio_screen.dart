// lib/screens/scan/scan_audio_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:valeon/models/scan_model.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scan_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../widgets/scan/scan_progress_widget.dart';
import 'scan_result_screen.dart';

class ScanAudioScreen extends StatefulWidget {
  const ScanAudioScreen({super.key});

  @override
  State<ScanAudioScreen> createState() => _ScanAudioScreenState();
}

class _ScanAudioScreenState extends State<ScanAudioScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordPath;

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecord() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
        _recordPath = path;
      });
      if (path != null) {
        await _startScan(File(path));
      }
    } else {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        _showError('Permission micro refusée');
        return;
      }
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/valeon_record_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // ✅ CORRECTION ICI : RecordConfig est un constructeur, pas une constante
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc, // Spécifier l'encodeur
          bitRate: 128000, // Bitrate en bits par seconde
          sampleRate: 44100, // Taux d'échantillonnage
        ),
        path: path,
      );
      setState(() => _isRecording = true);
    }
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final file = await picker.pickMedia();
    if (file != null) {
      await _startScan(File(file.path));
    }
  }

  Future<void> _startScan(File file) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;

    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    await scanProvider.scanAudio(file, authProvider.user!);

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
      // Reset le scan provider après retour
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

    // Écouter les changements d'état
    if (scanState.phase == ScanPhase.done && scanState.result != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToResult(scanState.result!);
      });
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: scanState.phase != ScanPhase.idle
          ? ScanProgressWidget(
              phase: scanState.phase,
              error: scanState.errorMessage,
              onRetry: scanState.reset,
            )
          : Column(
              children: [
                const Spacer(),

                // Indicateur plan Free
                if (!isPremium) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.onSurface, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Plan Free: 5 scans/jour',
                          style: TextStyle(
                              color: AppColors.onSurface, fontSize: 13),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/premium'),
                          child: const Text(
                            'Upgrade',
                            style: TextStyle(
                                color: AppColors.premium, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Bannière hors ligne
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
                            'Mode hors ligne - Scan sauvegardé localement',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!connectivity.isOnline) const SizedBox(height: 24),

                // Bouton d'enregistrement
                GestureDetector(
                  onTap: _toggleRecord,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isRecording
                            ? [Colors.red, const Color(0xFFFF6B6B)]
                            : [AppColors.primaryBlue, AppColors.lightPurple],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording
                                  ? Colors.red
                                  : AppColors.primaryBlue)
                              .withOpacity(0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isRecording
                      ? 'Enregistrement en cours...'
                      : 'Appuyez pour enregistrer',
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 48),

                // Bouton d'import
                OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Importer un fichier audio'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
    );
  }
}
