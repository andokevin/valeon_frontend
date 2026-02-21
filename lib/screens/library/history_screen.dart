import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/library_provider.dart';
import '../../models/scan_model.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historique des Scans')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (scans) => scans.isEmpty
            ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.history_rounded, size: 64, color: AppTheme.onSurface),
                SizedBox(height: 16),
                Text('Aucun historique', style: TextStyle(color: AppTheme.onSurface, fontSize: 16)),
              ]))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: scans.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final scan = scans[i];
                  final c = scan.content;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: _typeColor(scan.scanType).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_typeIcon(scan.scanType),
                          color: _typeColor(scan.scanType), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c?.contentTitle ?? 'Scan ${scan.scanType.name}',
                          style: const TextStyle(fontWeight: FontWeight.w600,
                            color: AppTheme.onBackground)),
                        Text(DateFormat('dd/MM/yyyy HH:mm').format(scan.scanDate),
                          style: const TextStyle(color: AppTheme.onSurface, fontSize: 12)),
                      ])),
                      _StatusBadge(status: scan.status),
                    ]),
                  );
                },
              ),
      ),
    );
  }

  Color _typeColor(ScanType t) {
    switch (t) {
      case ScanType.audio: return AppTheme.primary;
      case ScanType.image: return const Color(0xFF00B4D8);
      case ScanType.video: return AppTheme.secondary;
    }
  }

  IconData _typeIcon(ScanType t) {
    switch (t) {
      case ScanType.audio: return Icons.mic_rounded;
      case ScanType.image: return Icons.image_rounded;
      case ScanType.video: return Icons.videocam_rounded;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final ScanStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ScanStatus.completed => ('✓', Colors.green),
      ScanStatus.failed => ('✗', AppTheme.error),
      ScanStatus.processing => ('⟳', Colors.orange),
      ScanStatus.pending => ('…', AppTheme.onSurface),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 14)),
    );
  }
}
