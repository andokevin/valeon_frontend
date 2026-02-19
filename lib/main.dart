import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/scan_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/sync_provider.dart';
import 'screens/auth_wrapper.dart';
import 'core/network/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Firebase
  await Firebase.initializeApp();

  // Initialisation Facebook
  await FacebookAuth.instance.webAndDesktopInitialize(
    appId: "1409022630714902",
    cookie: true,
    xfbml: true,
    version: "v18.0",
  );

  // Configuration de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const ValeonApp());
  });
}

class ValeonApp extends StatelessWidget {
  const ValeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: Consumer<ConnectivityService>(
        builder: (context, connectivity, child) {
          return MaterialApp(
            title: 'Valeon',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
