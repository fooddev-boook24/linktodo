import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'utils/hive_utils.dart';
import 'config/theme.dart';
import 'services/notification_service.dart';
import 'services/ad_service.dart';
import 'services/appsflyer_service.dart';
import 'services/iap_service.dart';
import 'providers/settings_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive初期化
  await HiveUtils.init();

  // Firebase初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 通知サービス初期化
  await NotificationService().init();

  // 広告初期化
  await AdService().init();

  // AppsFlyer初期化
  await AppsFlyerService().init();

  // IAP初期化
  await IAPService().init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'LinkTodo',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      home: settings.isFirstLaunch
          ? const OnboardingScreen()
          : const MainScreen(),
    );
  }
}