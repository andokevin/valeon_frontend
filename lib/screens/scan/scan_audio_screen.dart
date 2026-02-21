import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scan_provider.dart';
import '../../widgets/scan/scan_progress_widget.dart';

class ScanAudioScreen extends ConsumerStatefulWidget {
  const ScanAudioScreen({super.key});
  @override
  ConsumerState<ScanAudioScreen> createState() => _ScanAudioScreenState();
}

class _ScanAudioScreenState extends ConsumerState<ScanAudioScreen> {
  final _recorder = AudioRecorder();
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
      setState(() { _isRecording = false; _recordPath = path; });
      if (path != null) {
        await _startScan(File(path));
      }
    } else {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission micro refusée')));
        return;
      }
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/valeon_record_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: path);
      setState(() => _isRecording = true);
    }
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final file = await picker.pickMedia();
    if (file != null) await _startScan(File(file.path));
  }

  Future<void> _startScan(File file) async {
    await ref.read(scanProvider.notifier).scanAudio(file);
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);
    final isPremium = ref.watch(isPremiumProvider);

    ref.listen(scanProvider, (_, next) {
      if (next.phase == ScanPhase.done && next.result != null) {
        ref.read(scanProvider.notifier).reset();
        context.go('/scan/result', extra: next.result!.result);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Scanner Audio')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: scanState.phase != ScanPhase.idle
            ? ScanProgressWidget(phase: scanState.phase, error: scanState.error,
                onRetry: ref.read(scanProvider.notifier).reset)
            : Column(
                children: [
                  const Spacer(),
                  // Free plan indicator
                  if (!isPremium) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        const Icon(Icons.info_outline, color: AppTheme.onSurface, size: 16),
                        const SizedBox(width: 8),
                        Text('Plan Free: 5 scans/jour',
                          style: const TextStyle(color: AppTheme.onSurface, fontSize: 13)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.go('/premium'),
                          child: const Text('Upgrade', style: TextStyle(color: AppTheme.premium, fontSize: 12)),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Record button
                  GestureDetector(
                    onTap: _toggleRecord,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _isRecording
                              ? [AppTheme.error, const Color(0xFFFF6B6B)]
                              : [AppTheme.primary, AppTheme.secondary],
                        ),
                        boxShadow: [BoxShadow(
                          color: (_isRecording ? AppTheme.error : AppTheme.primary).withOpacity(0.4),
                          blurRadius: 24, spreadRadius: 4,
                        )],
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        size: 56, color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isRecording ? 'Enregistrement en cours...' : 'Appuyez pour enregistrer',
                    style: const TextStyle(color: AppTheme.onSurface, fontSize: 15),
                  ),
                  const SizedBox(height: 48),
                  OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text('Importer un fichier audio'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
      ),
    );
  }
}
