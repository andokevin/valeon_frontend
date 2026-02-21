import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/scan_provider.dart';
import '../../widgets/scan/scan_progress_widget.dart';

class ScanVideoScreen extends ConsumerStatefulWidget {
  const ScanVideoScreen({super.key});
  @override
  ConsumerState<ScanVideoScreen> createState() => _ScanVideoScreenState();
}

class _ScanVideoScreenState extends ConsumerState<ScanVideoScreen> {
  final _picker = ImagePicker();

  Future<void> _pickVideo(ImageSource source) async {
    final video = await _picker.pickVideo(source: source,
      maxDuration: const Duration(minutes: 5));
    if (video != null) {
      await ref.read(scanProvider.notifier).scanVideo(File(video.path));
    }
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
      appBar: AppBar(
        title: const Text('Scanner Vidéo'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.premium.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(children: [
              Icon(Icons.star_rounded, color: AppTheme.premium, size: 14),
              SizedBox(width: 4),
              Text('Premium', style: TextStyle(color: AppTheme.premium, fontSize: 12)),
            ]),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: scanState.phase != ScanPhase.idle
            ? ScanProgressWidget(phase: scanState.phase, error: scanState.error,
                onRetry: ref.read(scanProvider.notifier).reset)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.video_library_rounded,
                      size: 80, color: AppTheme.secondary),
                  ),
                  const SizedBox(height: 32),
                  const Text('Scanner une vidéo',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                      color: AppTheme.onBackground)),
                  const SizedBox(height: 8),
                  const Text('Identifiez films, séries et clips musicaux\ndepuis votre vidéo',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.onSurface)),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: () => _pickVideo(ImageSource.camera),
                    icon: const Icon(Icons.videocam_rounded),
                    label: const Text('Enregistrer une vidéo'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _pickVideo(ImageSource.gallery),
                    icon: const Icon(Icons.video_library_rounded),
                    label: const Text('Choisir depuis la galerie'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.secondary,
                      side: const BorderSide(color: AppTheme.secondary),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
