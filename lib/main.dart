import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/router_service.dart';
import 'services/auth_service.dart';
import 'services/subscription_service.dart';
import 'services/user_session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  await AuthService().initialize();
  await SubscriptionService().initialize();
  await UserSessionService().initialize();
  
  runApp(
    const ProviderScope(
      child: LinguavaApp(),
    ),
  );
}

class LinguavaApp extends ConsumerWidget {
  const LinguavaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Linguava',
      theme: AppTheme.darkTheme,
      routerConfig: RouterService.createRouter(ref),
      debugShowCheckedModeBanner: false,
    );
  }
}