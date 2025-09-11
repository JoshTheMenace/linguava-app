import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/router_service.dart';
import 'services/auth_service.dart';
import 'services/subscription_service.dart';
import 'services/user_session_service.dart';
import 'providers/learning_path_provider.dart';

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
    ProviderScope(
      child: const LinguavaApp(),
      overrides: [],
    ),
  );
}

class LinguavaApp extends ConsumerStatefulWidget {
  const LinguavaApp({super.key});

  @override
  ConsumerState<LinguavaApp> createState() => _LinguavaAppState();
}

class _LinguavaAppState extends ConsumerState<LinguavaApp> {
  @override
  void initState() {
    super.initState();
    // Initialize templates on app start
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final templateService = ref.read(learningPathTemplateServiceProvider);
        
        // Force reinitialize templates for debugging (uncomment if needed)
        // await templateService.forceReinitializeTemplates();
        
        final areInitialized = await templateService.areTemplatesInitialized();
        if (!areInitialized) {
          print('Initializing learning path templates...');
          await templateService.initializeAllTemplates();
          print('Templates initialized successfully!');
        } else {
          print('Templates already initialized.');
        }
      } catch (error) {
        print('Error initializing templates: $error');
        print('Stack trace: $error');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Linguava',
      theme: AppTheme.darkTheme,
      routerConfig: RouterService.createRouter(ref),
      debugShowCheckedModeBanner: false,
    );
  }
}