# Linguava - Flutter Spaced Repetition Learning App

## Project Overview

Linguava is a Flutter-based spaced repetition learning application designed for language learning and flashcard-based studying. The app implements the FSRS (Free Spaced Repetition Scheduler) algorithm for optimized learning intervals and provides a comprehensive learning experience with user authentication, deck management, and progress tracking.

## Key Technologies

- **Flutter SDK**: ^3.8.1
- **State Management**: Riverpod (flutter_riverpod: ^2.5.1)
- **Navigation**: GoRouter (go_router: ^14.2.7)
- **Local Database**: Drift (drift: ^2.16.0)
- **Backend**: Supabase (supabase_flutter: ^2.8.2)
- **Spaced Repetition**: FSRS algorithm (fsrs: ^2.0.1)
- **UI Components**: Google Fonts, FL Chart, Lottie animations
- **Authentication**: Google Sign In, Apple Sign In
- **Subscriptions**: In-App Purchase

## Project Structure

### Root Directory Structure

```
linguava/
├── android/                    # Android platform configuration
├── ios/                       # iOS platform configuration  
├── lib/                       # Main Dart source code
├── test/                      # Unit and widget tests
├── pubspec.yaml              # Project dependencies and metadata
├── supabase_schema.sql       # Database schema for Supabase
├── SUPABASE_SETUP.md         # Supabase configuration guide
├── USER_SESSION_MANAGEMENT.md # User session documentation
└── README.md                 # Project documentation
```

### Core Application Structure (`lib/`)

#### **Core Infrastructure (`lib/core/`)**

**Configuration (`lib/core/config/`)**
- `supabase_config.dart` - Supabase URL and API key configuration for authentication backend

**Constants (`lib/core/constants/`)**
- `app_colors.dart` - Application color palette and theme constants
- `app_routes.dart` - Centralized route path definitions for navigation
- `app_spacing.dart` - Consistent spacing and sizing constants

**Theme (`lib/core/theme/`)**
- `app_theme.dart` - Application theme configuration (dark theme implementation)

**Utilities (`lib/core/utils/`)**
- `app_router.dart` - Basic GoRouter configuration (legacy)
- `router_service.dart` - Advanced router service with auth-based redirects and navigation guards

#### **Data Layer (`lib/database/`)**

**Database Management**
- `database.dart` - Main Drift database configuration with table definitions:
  - `Decks` - User flashcard decks
  - `Flashcards` - Individual cards with front/back content
  - `FlashcardTags` - Tag system for categorization
  - `StudyCards` - FSRS algorithm data and review statistics
  - `ReviewLogs` - Historical review performance tracking
  - `StudySessionsTable` - Study session analytics

**Data Access Objects (`lib/database/daos/`)**
- `deck_dao.dart` / `deck_dao.g.dart` - CRUD operations for decks
- `flashcard_dao.dart` / `flashcard_dao.g.dart` - CRUD operations for flashcards
- `study_card_dao.dart` / `study_card_dao.g.dart` - FSRS card data management
- `review_log_dao.dart` / `review_log_dao.g.dart` - Review history operations

#### **Data Models (`lib/models/`)**

- `deck.dart` - Deck entity with metadata, progress tracking, and statistics calculation
- `flashcard.dart` - Flashcard entity with content, tags, and review metrics
- `study_card.dart` - FSRS-integrated card with spaced repetition data and scheduling logic

#### **Services Layer (`lib/services/`)**

**Authentication Service (`auth_service.dart`)**
- Supabase authentication integration
- Email/password, Google, and Apple sign-in
- User profile management
- Session handling and security

**Subscription Service (`subscription_service.dart`)**
- In-app purchase management
- Premium subscription handling
- Purchase verification and restoration
- Cross-platform payment processing

**User Session Service (`user_session_service.dart`)**
- Local session persistence with SharedPreferences
- Onboarding state management
- User preference storage
- Session validation and cleanup

#### **State Management (`lib/providers/`)**

**Authentication Provider (`auth_provider.dart`)**
- Riverpod-based authentication state management
- Auth state tracking (authenticated, loading, error states)
- Onboarding flow management
- Integration with auth and session services

#### **User Interface (`lib/screens/`)**

**Authentication Flow (`lib/screens/auth/`)**
- `login_screen.dart` - Email/social login interface
- `signup_screen.dart` - User registration with multiple auth options

**Onboarding (`lib/screens/onboarding/`)**
- `splash_screen.dart` - App initialization and loading screen
- `onboarding_screen.dart` - First-time user introduction and setup

**Main Application (`lib/screens/home/`)**
- `home_screen.dart` - Dashboard with deck overview and quick access

**Study Experience (`lib/screens/study/`)**
- `study_screen.dart` - Pre-study setup and deck selection
- `study_session_screen.dart` - Active flashcard study with FSRS grading

**Deck Management (`lib/screens/deck_management/`)**
- `deck_management_screen.dart` - Deck listing and organization
- `create_deck_screen.dart` - New deck creation interface
- `edit_deck_screen.dart` - Deck modification and settings
- `add_card_screen.dart` - Individual card creation
- `edit_card_screen.dart` - Card content editing

**Analytics and Tracking (`lib/screens/stats/`)**
- `stats_screen.dart` - Study progress visualization and analytics

**User Management (`lib/screens/profile/`)**
- `profile_screen.dart` - User profile and account management

**App Configuration (`lib/screens/settings/`)**
- `settings_screen.dart` - Application preferences and configuration

**Content Discovery (`lib/screens/search/`)**
- `search_screen.dart` - Deck and card search functionality

**Development Tools (`lib/screens/debug/`)**
- `debug_screen.dart` - Development debugging interface

#### **Shared Components (`lib/widgets/`)**
- Common UI components and reusable widgets

### **Application Entry Point**
- `main.dart` - App initialization, service setup, and root widget configuration

## Application Flow

### **1. App Initialization (`main.dart`)**
```dart
main() async {
  // System UI configuration
  // Service initialization:
  await AuthService().initialize();      // Supabase setup
  await SubscriptionService().initialize(); // Payment processing
  await UserSessionService().initialize();  // Local session management
  
  // Launch app with Riverpod state management
}
```

### **2. Navigation and Routing (`router_service.dart`)**
The app uses a sophisticated routing system with authentication guards:

- **Splash Screen** → Loading and service initialization
- **Onboarding** → First-time user setup (if not completed)
- **Authentication** → Login/signup (if not authenticated)
- **Home** → Main dashboard (if authenticated and onboarded)

Route protection ensures users cannot access protected screens without proper authentication.

### **3. Authentication Flow**
1. **User Registration/Login** via `AuthService`
2. **Profile Creation** in Supabase backend
3. **Session Persistence** via `UserSessionService`
4. **State Updates** through `AuthProvider`

### **4. Study Flow**
1. **Deck Selection** from home screen
2. **Study Setup** with mode selection
3. **FSRS-Based Review** with spaced repetition algorithm
4. **Progress Tracking** and analytics update

### **5. Data Management**
- **Local Storage**: Drift SQLite database for offline functionality
- **Remote Sync**: Supabase for user data and cross-device synchronization
- **FSRS Integration**: Advanced spaced repetition scheduling

## Database Schema

### **Local Database (Drift)**
- **Decks**: Flashcard collections with metadata
- **Flashcards**: Individual learning cards
- **StudyCards**: FSRS algorithm data
- **ReviewLogs**: Historical performance data
- **StudySessionsTable**: Session analytics

### **Remote Database (Supabase)**
- **profiles**: User account information
- **purchases**: Subscription and payment tracking

## Key Features

### **Spaced Repetition Learning**
- FSRS algorithm implementation for optimal review scheduling
- Adaptive difficulty adjustment based on performance
- Multiple study modes and grading options

### **User Management**
- Multi-platform authentication (Email, Google, Apple)
- Premium subscription system
- Cross-device data synchronization

### **Content Management**
- Hierarchical deck organization
- Rich flashcard content with media support
- Tagging and categorization system

### **Analytics and Progress**
- Detailed study statistics
- Progress visualization with charts
- Performance tracking over time

### **Developer Experience**
- Comprehensive debug tooling
- Modular architecture with clean separation of concerns
- Type-safe database operations with Drift
- Reactive state management with Riverpod

## Development Guidelines

### **Architecture Patterns**
- **Clean Architecture**: Separation of data, domain, and presentation layers
- **Repository Pattern**: Data access abstraction via DAOs
- **Provider Pattern**: Centralized state management with Riverpod

### **Code Organization**
- Feature-based folder structure for scalability
- Shared utilities and constants for consistency
- Generated code integration with build_runner

### **State Management Flow**
```
UI Layer (Screens) → Providers (Riverpod) → Services → Database (Drift/Supabase)
```

This architecture ensures maintainable, testable, and scalable code for the spaced repetition learning application.