import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/notifications/push_notification_service.dart';
import 'core/network/api_client.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase may be unavailable in local/dev builds until config files are added.
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (_) {
    // Allow app startup without Firebase so the app doesn't crash in unconfigured envs.
  }

  if (firebaseReady) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  runApp(const ProviderScope(child: EstateLogicApp()));
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class EstateLogicApp extends ConsumerStatefulWidget {
  const EstateLogicApp({super.key});

  @override
  ConsumerState<EstateLogicApp> createState() => _EstateLogicAppState();
}

class _EstateLogicAppState extends ConsumerState<EstateLogicApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Initialize push notifications
      ref.read(pushNotificationServiceProvider).initialize();

      // Load persisted theme mode (light/dark/system)
      final storage = ref.read(secureStorageProvider);
      try {
        final val = await storage.read(key: 'theme_mode');
        if (val != null) {
          if (val == 'light') {
            ref.read(themeModeProvider.notifier).state = ThemeMode.light;
          } else if (val == 'dark') {
            ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
          } else {
            ref.read(themeModeProvider.notifier).state = ThemeMode.system;
          }
        }
      } catch (e) {
        // ignore storage read errors
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Estate Logic CRM',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
