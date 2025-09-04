import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_routes.dart';
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

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
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
  ],
);