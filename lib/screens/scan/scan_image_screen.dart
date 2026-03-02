// lib/screens/scan/scan_image_screen.dart
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

class ScanImageScreen extends StatefulWidget {
  const ScanImageScreen({super.key});

  @override
  State<ScanImageScreen> createState() => _ScanImageScreenState();
}

class _ScanImageScreenState extends State<ScanImageScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromCamera() async {
    final connectivity =
        Provider.of<ConnectivityProvider>(context, listen: false);

    if (!connectivity.isOnline) {
      _showError('Connexion internet requise pour scanner');
      return;
    }

    final img = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (img != null) {
      setState(() => _selectedImage = File(img.path));
      await _startScan(File(img.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final connectivity =
        Provider.of<ConnectivityProvider>(context, listen: false);

    if (!connectivity.isOnline) {
      _showError('Connexion internet requise pour scanner');
      return;
    }

    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (img != null) {
      setState(() => _selectedImage = File(img.path));
      await _startScan(File(img.path));
    }
  }

  Future<void> _startScan(File file) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;

    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    await scanProvider.scanImage(file, authProvider.user!);

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
    final connectivity = Provider.of<ConnectivityProvider>(context);

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
                if (!connectivity.isOnline) const SizedBox(height: 24),
                if (_selectedImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _selectedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_search,
                            size: 56, color: AppColors.onSurface),
                        SizedBox(height: 12),
                        Text(
                          'Aucune image sélectionnée',
                          style: TextStyle(color: AppColors.onSurface),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            connectivity.isOnline ? _pickFromCamera : null,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Appareil photo'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            connectivity.isOnline ? _pickFromGallery : null,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galerie'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: connectivity.isOnline
                              ? AppColors.primaryBlue
                              : Colors.grey,
                          side: BorderSide(
                            color: connectivity.isOnline
                                ? AppColors.primaryBlue
                                : Colors.grey,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
    );
  }
}
