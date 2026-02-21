import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/scan_provider.dart';
import '../../widgets/scan/scan_progress_widget.dart';

class ScanImageScreen extends ConsumerStatefulWidget {
  const ScanImageScreen({super.key});
  @override
  ConsumerState<ScanImageScreen> createState() => _ScanImageScreenState();
}

class _ScanImageScreenState extends ConsumerState<ScanImageScreen> {
  File? _selectedImage;
  final _picker = ImagePicker();

  Future<void> _pickFromCamera() async {
    final img = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (img != null) {
      setState(() => _selectedImage = File(img.path));
      await _startScan(File(img.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img != null) {
      setState(() => _selectedImage = File(img.path));
      await _startScan(File(img.path));
    }
  }

  Future<void> _startScan(File file) async {
    await ref.read(scanProvider.notifier).scanImage(file);
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);

    ref.listen(scanProvider, (_, next) {
      if (next.phase == ScanPhase.done && next.result != null) {
        ref.read(scanProvider.notifier).reset();
        context.go('/scan/result', extra: next.result!.result);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Scanner Image')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: scanState.phase != ScanPhase.idle
            ? ScanProgressWidget(phase: scanState.phase, error: scanState.error,
                onRetry: ref.read(scanProvider.notifier).reset)
            : Column(
                children: [
                  const Spacer(),
                  if (_selectedImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_selectedImage!, height: 200, width: double.infinity,
                        fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    Container(
                      height: 200, width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 2),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_search_rounded, size: 56, color: AppTheme.onSurface),
                          SizedBox(height: 12),
                          Text('Aucune image sélectionnée',
                            style: TextStyle(color: AppTheme.onSurface)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Row(
                    children: [
                      Expanded(child: ElevatedButton.icon(
                        onPressed: _pickFromCamera,
                        icon: const Icon(Icons.camera_alt_rounded),
                        label: const Text('Appareil photo'),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: OutlinedButton.icon(
                        onPressed: _pickFromGallery,
                        icon: const Icon(Icons.photo_library_rounded),
                        label: const Text('Galerie'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      )),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
      ),
    );
  }
}
