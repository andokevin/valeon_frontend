// lib/utils/app_links.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppLinks {
  static const String website = 'https://andokevin.github.io/valeon_frontend/';
  static const String privacyPolicy =
      'https://andokevin.github.io/valeon_frontend/privacy.html';
  static const String deleteAccount =
      'https://andokevin.github.io/valeon_frontend/suppression.html';
  static const String supportEmail = 'andokevin05@gmail.com';
  static const String appVersion = '2.0.0';

  static Future<void> open(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Impossible d'ouvrir le lien")),
      );
    }
  }

  static Future<void> contactSupport(BuildContext context) => open(
        context,
        'mailto:$supportEmail?subject=${Uri.encodeComponent('Support Valeon')}',
      );

  static void showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Valeon',
      applicationVersion: appVersion,
      applicationLegalese: '© Valeon',
      children: const [
        SizedBox(height: 12),
        Text('Know what you see, hear, and watch.'),
      ],
    );
  }
}
