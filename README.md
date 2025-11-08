# Linguava

<div align="center">

**An AI-powered Japanese language learning app with conversational practice and spaced repetition**

</div>

---

## Overview

Linguava is an innovative Flutter-based Japanese language learning application that combines conversational AI tutoring with scientifically-proven spaced repetition techniques. Using Google's Gemini Live API for real-time voice conversations and the FSRS (Free Spaced Repetition Scheduler) algorithm, Linguava provides an immersive and effective way to master Japanese vocabulary and conversation.

The application features a structured lesson flow with pre-lesson word preview, interactive AI-powered conversation practice, and comprehensive progress tracking through an intelligent card review system.

## Key Features

- **AI Conversation Tutor** - Real-time voice conversations with Google Gemini Live API for authentic Japanese practice
- **FSRS Spaced Repetition** - Scientifically-optimized review scheduling for maximum vocabulary retention
- **Structured Lesson Flow** - Pre-lesson word preview, conversational practice, and post-lesson summary
- **Smart Card Management** - Skip words you already know, focus on what you need to learn
- **Progress Tracking** - Comprehensive card review system showing due dates, stability, and difficulty
- **Persistent Storage** - SQLite database ensures your learning progress is never lost
- **Bidirectional Audio Streaming** - Natural, lag-free conversations with the AI tutor
- **Beautiful Material Design UI** - Clean, modern interface with purple/deep space theme

## Prerequisites

Before setting up Linguava, ensure you have the following:

- **Flutter SDK** (version 3.5.4 or higher)
- **Android Device or Emulator** (iOS support coming soon)
- **Google Gemini API Key** - [Get your API key](https://aistudio.google.com/app/apikey)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/JoshTheMenace/jarvis.git
cd jarvis
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Environment Variables

Create a `.env` file in the root directory with your Gemini API key:

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

**Note:** Make sure to get a Gemini API key that supports the Gemini Live API (bidirectional streaming).

### 4. Run the Application

```bash
flutter run
```

## How It Works

### 1. Home Screen
Start your Japanese learning journey from the home screen with three main options:
- **Start Lesson** - Begin a new vocabulary lesson
- **Review Cards** - View all your vocabulary cards and their review status
- **Progress** - Track your learning statistics (coming soon)

### 2. Pre-Lesson Screen
Before each lesson, you'll see:
- Preview of 2 vocabulary words (configurable)
- Japanese characters, romaji, and English meanings
- Example sentences with translations
- Option to skip words you already know well

### 3. Conversational Practice
Engage in natural voice conversation with your AI tutor:
- AI teaches you the vocabulary words in context
- Practice pronunciation and usage
- Receive real-time feedback
- Cards are automatically rated based on your performance

### 4. Post-Lesson Summary
Review your progress:
- See which words you practiced
- View words you marked as already known
- Track your learning statistics

### 5. Card Review System
Monitor all your vocabulary cards:
- Due dates and review schedule
- Stability and difficulty metrics
- Current learning state (New, Learning, Review, Relearning)

## Permissions

Linguava requires the following permission to function properly:

- **Microphone Access** - For voice conversations with the AI tutor

This permission will be requested automatically on first launch.

## Technology Stack

Linguava is built using modern, production-ready technologies:

- **[Flutter](https://flutter.dev/)** - Cross-platform mobile development framework
- **[Google Gemini Live API](https://deepmind.google/technologies/gemini/)** - Real-time bidirectional audio streaming for natural conversations
- **[FSRS](https://github.com/open-spaced-repetition/fsrs-rs)** - Free Spaced Repetition Scheduler algorithm for optimal learning
- **[SQLite](https://pub.dev/packages/sqflite)** - Local database for persistent card storage
- **WebSocket** - Real-time bidirectional communication with Gemini Live
- **[Just Audio](https://pub.dev/packages/just_audio)** - High-performance audio playback for AI responses
- **[Record](https://pub.dev/packages/record)** - Audio recording for voice input

## Architecture

The application follows a clean architecture pattern with separation of concerns:

- **Presentation Layer** - Flutter UI components (Home, Lesson Intro, HUD, Summary, Cards Review)
- **Business Logic Layer** - FSRS scheduling, card management, lesson flow control
- **Data Layer** - SQLite persistence, vocabulary repository
- **Services** - Gemini Live API integration, audio recording/playback, FSRS scheduling

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── screens/
│   ├── home_screen.dart              # Main home screen
│   ├── lesson_intro_screen.dart      # Pre-lesson word preview
│   ├── lesson_summary_screen.dart    # Post-lesson summary
│   └── cards_review_screen.dart      # Card review and progress
├── hud_screen.dart                   # Conversational practice screen
├── services/
│   ├── gemini_live_service.dart      # Gemini Live API integration
│   ├── audio_recorder_service.dart   # Audio input handling
│   └── fsrs_service.dart             # FSRS card scheduling
├── repositories/
│   └── vocabulary_repository.dart    # Vocabulary and card management
├── data/
│   └── vocabulary_data.dart          # Predefined vocabulary list
└── models/
    ├── ui_component.dart             # UI state models
    └── learning_item.dart            # Learning item models
```

## Contributing

Contributions are welcome! If you'd like to contribute to Linguava, please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Future Enhancements

- [ ] Grammar lessons and explanations
- [ ] Kanji learning and writing practice
- [ ] Sentence pattern drills
- [ ] Progress statistics and analytics
- [ ] Custom vocabulary lists
- [ ] Multiple difficulty levels
- [ ] Achievement system
- [ ] iOS support

## License

This project is available for educational and personal use.

## Acknowledgments

- Built with Flutter and powered by Google's Gemini Live API
- FSRS algorithm by [open-spaced-repetition](https://github.com/open-spaced-repetition)
- Vocabulary data sourced from common Japanese learning resources

---

<div align="center">

**Master Japanese with AI • Built with ❤️ using Flutter**

</div>
