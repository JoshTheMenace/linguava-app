import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../screens/onboarding/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/study/study_screen.dart';
import '../../screens/study/study_session_screen.dart';
import '../../screens/deck_management/add_card_screen.dart';
import '../../screens/deck_management/edit_card_screen.dart';
import '../../screens/deck_management/deck_management_screen.dart';
import '../../screens/deck_management/create_deck_screen.dart';
import '../../screens/deck_management/edit_deck_screen.dart';
import '../../screens/stats/stats_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/debug/debug_screen.dart';
import '../../screens/learning_paths/learning_paths_screen.dart';
import '../../screens/learning_paths/learning_path_progress_screen.dart';
import '../../screens/lessons/lesson_screen.dart';

class RouterService {
  static GoRouter createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (context, state) {
        final authState = ref.read(authProvider);
        
        if (kDebugMode) {
          print('=== ROUTER DEBUG ===');
          print('Current route: ${state.uri}');
          print('Auth state - authenticated: ${authState.isAuthenticated}, loading: ${authState.isLoading}');
          print('Has completed onboarding: ${authState.hasCompletedOnboarding}');
        }
        
        final isOnAuth = state.uri.toString() == AppRoutes.login || 
                        state.uri.toString() == AppRoutes.signup;
        
        if (authState.isLoading && !isOnAuth) {
          return AppRoutes.splash;
        }
        
        final isOnSplash = state.uri.toString() == AppRoutes.splash;
        final isOnOnboarding = state.uri.toString() == AppRoutes.onboarding;
        
        // Only check onboarding completion - don't require authentication for most pages
        if (!authState.hasCompletedOnboarding && !isOnOnboarding && !isOnSplash) {
          if (kDebugMode) {
            print('Router: Redirecting to onboarding');
          }
          return AppRoutes.onboarding;
        }
        
        // After onboarding, redirect to home from splash
        if (authState.hasCompletedOnboarding && isOnSplash) {
          if (kDebugMode) {
            print('Router: Redirecting from splash to home');
          }
          return AppRoutes.home;
        }
        
        // If user is authenticated and on auth screens, go to home
        if (authState.hasCompletedOnboarding && authState.isAuthenticated && isOnAuth) {
          if (kDebugMode) {
            print('Router: User authenticated, redirecting from auth to home');
          }
          return AppRoutes.home;
        }
        
        // After completing onboarding, redirect from onboarding to home (not login)
        if (isOnOnboarding && authState.hasCompletedOnboarding) {
          if (kDebugMode) {
            print('Router: Redirecting from onboarding to home');
          }
          return AppRoutes.home;
        }
        
        if (kDebugMode) {
          print('Router: No redirect needed');
        }
        
        return null;
      },
      refreshListenable: AuthChangeNotifier(ref),
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.signup,
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.study,
          name: 'study',
          builder: (context, state) {
            final deckId = state.uri.queryParameters['deckId'] ?? '';
            return StudyScreen(deckId: deckId);
          },
        ),
        GoRoute(
          path: AppRoutes.studySession,
          name: 'studySession',
          builder: (context, state) {
            final deckId = state.uri.queryParameters['deckId'] ?? '';
            final studyMode = state.uri.queryParameters['studyMode'] ?? 'flashcard';
            return StudySessionScreen(deckId: deckId, studyMode: studyMode);
          },
        ),
        GoRoute(
          path: AppRoutes.addCard,
          name: 'addCard',
          builder: (context, state) {
            final deckId = state.uri.queryParameters['deckId'];
            return AddCardScreen(deckId: deckId);
          },
        ),
        GoRoute(
          path: AppRoutes.editCard,
          name: 'editCard',
          builder: (context, state) {
            final cardId = state.uri.queryParameters['cardId'] ?? '';
            return EditCardScreen(cardId: cardId);
          },
        ),
        GoRoute(
          path: AppRoutes.deckManagement,
          name: 'deckManagement',
          builder: (context, state) => const DeckManagementScreen(),
        ),
        GoRoute(
          path: AppRoutes.createDeck,
          name: 'createDeck',
          builder: (context, state) => const CreateDeckScreen(),
        ),
        GoRoute(
          path: AppRoutes.editDeck,
          name: 'editDeck',
          builder: (context, state) {
            final deckId = state.uri.queryParameters['deckId'] ?? '';
            return EditDeckScreen(deckId: deckId);
          },
        ),
        GoRoute(
          path: AppRoutes.stats,
          name: 'stats',
          builder: (context, state) => const StatsScreen(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.search,
          name: 'search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.debug,
          name: 'debug',
          builder: (context, state) => const DebugScreen(),
        ),
        GoRoute(
          path: AppRoutes.learningPaths,
          name: 'learningPaths',
          builder: (context, state) => const LearningPathsScreen(),
        ),
        GoRoute(
          path: '${AppRoutes.learningPathProgress}/:pathId',
          name: 'learningPathProgress',
          builder: (context, state) {
            final pathId = state.pathParameters['pathId'] ?? '';
            return LearningPathProgressScreen(pathId: pathId);
          },
        ),
        GoRoute(
          path: '/lesson/:lessonId',
          name: 'lesson',
          builder: (context, state) {
            final lessonId = state.pathParameters['lessonId'] ?? '';
            final pathId = state.uri.queryParameters['pathId'];
            return LessonScreen(lessonId: lessonId, pathId: pathId);
          },
        ),
      ],
    );
  }
}

class AuthChangeNotifier extends ChangeNotifier {
  final WidgetRef _ref;
  
  AuthChangeNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated ||
          previous?.hasCompletedOnboarding != next.hasCompletedOnboarding ||
          previous?.isLoading != next.isLoading) {
        notifyListeners();
      }
    });
  }
}