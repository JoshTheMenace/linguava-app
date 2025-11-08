import 'package:flutter/material.dart';
import 'services/gemini_live_service.dart';
import 'services/audio_recorder_service.dart';
import 'services/audio_player_service.dart';
import 'services/fsrs_service.dart';
import 'repositories/vocabulary_repository.dart';
import 'models/ui_component.dart';
import 'widgets/hud_overlay_widget.dart';
import 'widgets/waveform_visualizer.dart';
import 'dart:async';
import 'package:fsrs/fsrs.dart' hide State;

/// Linguava Learning Screen - Japanese language learning interface
class JarvisHUDScreen extends StatefulWidget {
  final String apiKey;
  final List<Map<String, dynamic>>? lessonWords;

  const JarvisHUDScreen({
    super.key,
    required this.apiKey,
    this.lessonWords,
  });

  @override
  State<JarvisHUDScreen> createState() => _JarvisHUDScreenState();
}

class _JarvisHUDScreenState extends State<JarvisHUDScreen>
    with TickerProviderStateMixin {
  late GeminiLiveService _geminiService;
  late AudioRecorderService _audioRecorder;
  late AudioPlayerService _audioPlayer;
  late FSRSService _fsrsService;
  late VocabularyRepository _vocabularyRepo;

  final List<UIComponent> _uiComponents = [];
  final Map<String, AnimationController> _componentAnimations = {};

  bool _isConnected = false;
  bool _isRecording = false;
  bool _showTranscript = false;
  String _lastTranscript = '';
  int _componentIdCounter = 0;

  double _currentAudioLevel = 0.0;

  Timer? _pulseTimer;
  double _micPulse = 1.0;

  List<Map<String, dynamic>> _currentStudyCards = [];
  bool _isLoadingCards = true;
  StreamSubscription<bool>? _connectionStateSubscription;
  Set<String> _ratedWords = {}; // Track which words have been rated
  bool _isLessonMode = false; // Whether this is a structured lesson

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _startPulseAnimation();
  }

  /// Initialize Gemini and audio services
  void _initializeServices() {
    // Initialize FSRS and vocabulary
    _fsrsService = FSRSService();
    _vocabularyRepo = VocabularyRepository(_fsrsService);

    _geminiService = GeminiLiveService(apiKey: widget.apiKey);
    _audioRecorder = AudioRecorderService(_geminiService);
    _audioPlayer = AudioPlayerService(_geminiService);

    // Load cards to study
    _loadStudyCards();

    // Listen to audio level updates for waveform
    _audioRecorder.audioLevelStream.listen((level) {
      if (mounted) {
        setState(() {
          _currentAudioLevel = level;
        });
      }
    });

    // Listen to text responses for transcript
    _geminiService.textOutputStream.listen((text) {
      if (mounted) {
        setState(() {
          _lastTranscript = text;
          _showTranscript = true;
        });

        // Auto-hide transcript after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showTranscript = false;
            });
          }
        });
      }
    });

    // Listen to connection state
    _connectionStateSubscription = _geminiService.connectionStateStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });

        // Auto-reconnect if disconnected
        if (!isConnected) {
          print('Connection lost - attempting to reconnect...');
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && !_geminiService.isConnected) {
              _reconnect();
            }
          });
        }
      }
    });

    // Listen to tool calls and create UI components
    _geminiService.toolCallStream.listen((toolCall) {
      _handleToolCall(toolCall);
    });

    // Listen to turn complete events (but don't auto-stop recording for language learning)
    _geminiService.turnCompleteStream.listen((_) {
      print('Turn completed - AI finished speaking');
      // Don't auto-stop recording to allow natural conversation flow
    });

    // Auto-connect to Gemini
    _connect();
  }

  /// Start pulse animation for microphone
  void _startPulseAnimation() {
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isRecording && mounted) {
        setState(() {
          _micPulse = _micPulse == 1.0 ? 1.3 : 1.0;
        });
      }
    });
  }

  /// Load cards to study from vocabulary repository
  Future<void> _loadStudyCards() async {
    try {
      setState(() {
        _isLoadingCards = true;
      });

      // Always initialize vocabulary repository (needed for card reviews)
      await _vocabularyRepo.initialize();

      // Check if lesson words were provided
      if (widget.lessonWords != null && widget.lessonWords!.isNotEmpty) {
        // Use provided lesson words
        setState(() {
          _currentStudyCards = widget.lessonWords!;
          _isLessonMode = true;
          _isLoadingCards = false;
        });
        print('Loaded ${widget.lessonWords!.length} lesson words');
      } else {
        // Get cards to study from repository
        final cards = await _vocabularyRepo.getCardsToStudy(limit: 10);

        setState(() {
          _currentStudyCards = cards;
          _isLessonMode = false;
          _isLoadingCards = false;
        });

        print('Loaded ${cards.length} cards to study');
      }

      for (var card in _currentStudyCards) {
        print('  - ${card['word']} (${card['romaji']}): ${card['meaning']}');
      }
    } catch (e) {
      print('Failed to load study cards: $e');
      setState(() {
        _isLoadingCards = false;
      });
    }
  }

  /// Connect to Gemini
  Future<void> _connect() async {
    try {
      // Wait for cards to load before connecting
      while (_isLoadingCards) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Set the study cards in the Gemini service
      _geminiService.setStudyCards(_currentStudyCards, isLessonMode: _isLessonMode);

      // Connect to Gemini
      await _geminiService.connect();

      // Auto-start the teaching session
      await _geminiService.startTeachingSession();
    } catch (e) {
      print('Failed to connect: $e');
    }
  }

  /// Reconnect to Gemini after disconnection
  Future<void> _reconnect() async {
    try {
      print('Reconnecting to Gemini...');

      // Stop recording if active
      if (_isRecording) {
        await _audioRecorder.stopRecording();
        setState(() {
          _isRecording = false;
        });
      }

      // Set the study cards in the Gemini service
      _geminiService.setStudyCards(_currentStudyCards, isLessonMode: _isLessonMode);

      // Reconnect to Gemini
      await _geminiService.connect();

      print('Reconnected successfully');
    } catch (e) {
      print('Failed to reconnect: $e');
    }
  }

  /// Handle tool calls from Gemini
  void _handleToolCall(Map<String, dynamic> toolCall) {
    final function = toolCall['function'] as String?;
    if (function == null) return;

    final componentId = toolCall['id'] as String? ?? 'component_${_componentIdCounter++}';
    UIComponent? component;

    switch (function) {
      case 'show_flashcard':
        component = UIComponent.flashcard(
          id: componentId,
          front: toolCall['front'] ?? '',
          back: toolCall['back'] ?? '',
          hiragana: toolCall['hiragana'],
          romaji: toolCall['romaji'],
        );
        break;

      case 'show_sentence_review':
        component = UIComponent.sentenceReview(
          id: componentId,
          japanese: toolCall['japanese'] ?? '',
          english: toolCall['english'] ?? '',
          hiragana: toolCall['hiragana'],
          romaji: toolCall['romaji'],
          explanation: toolCall['explanation'],
        );
        break;

      case 'show_speaking_exercise':
        component = UIComponent.speakingExercise(
          id: componentId,
          prompt: toolCall['prompt'] ?? '',
          targetPhrase: toolCall['targetPhrase'] ?? '',
          hiragana: toolCall['hiragana'],
          romaji: toolCall['romaji'],
          hints: toolCall['hints'],
        );
        break;

      case 'show_vocabulary_list':
        final words = (toolCall['words'] as List?)?.map((w) {
          if (w is Map) {
            return Map<String, String>.from(w.map((key, value) => MapEntry(key.toString(), value.toString())));
          }
          return <String, String>{};
        }).toList() ?? [];

        component = UIComponent.vocabularyList(
          id: componentId,
          title: toolCall['title'] ?? 'Vocabulary',
          words: words,
        );
        break;

      case 'show_grammar_explanation':
        final examples = (toolCall['examples'] as List?)?.cast<String>() ?? [];
        component = UIComponent.grammarExplanation(
          id: componentId,
          title: toolCall['title'] ?? 'Grammar',
          explanation: toolCall['explanation'] ?? '',
          examples: examples,
        );
        break;

      case 'show_kanji_practice':
        final readings = (toolCall['readings'] as List?)?.cast<String>() ?? [];
        final examples = (toolCall['examples'] as List?)?.cast<String>() ?? [];
        component = UIComponent.kanjiPractice(
          id: componentId,
          kanji: toolCall['kanji'] ?? '',
          meaning: toolCall['meaning'] ?? '',
          readings: readings,
          examples: examples,
        );
        break;

      case 'show_listening_exercise':
        component = UIComponent.listeningComprehension(
          id: componentId,
          instruction: toolCall['instruction'] ?? '',
          targetSentence: toolCall['targetSentence'] ?? '',
          hiragana: toolCall['hiragana'],
          romaji: toolCall['romaji'],
        );
        break;

      case 'update_card_rating':
        final word = toolCall['word'] as String?;
        final ratingStr = toolCall['rating'] as String?;
        final reason = toolCall['reason'] as String?;

        if (word != null && ratingStr != null) {
          // Convert string rating to Rating enum
          Rating rating;
          switch (ratingStr.toLowerCase()) {
            case 'again':
              rating = Rating.again;
              break;
            case 'hard':
              rating = Rating.hard;
              break;
            case 'good':
              rating = Rating.good;
              break;
            case 'easy':
              rating = Rating.easy;
              break;
            default:
              rating = Rating.good; // Default to Good
          }

          print('Updating card "$word" with rating: $rating${reason != null ? ' - $reason' : ''}');
          _updateCardReview(word, rating);
        }
        return;

      case 'clear_screen':
        _clearAllComponents();
        return;
    }

    if (component != null) {
      _addComponentWithAnimation(component);
    }
  }

  /// Add component with slide-in animation
  void _addComponentWithAnimation(UIComponent component) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    setState(() {
      _uiComponents.add(component);
      _componentAnimations[component.id] = controller;
    });

    controller.forward();
  }

  /// Remove component with animation
  void _removeComponent(String id) {
    final controller = _componentAnimations[id];
    if (controller != null) {
      controller.reverse().then((_) {
        if (mounted) {
          setState(() {
            _uiComponents.removeWhere((component) => component.id == id);
            _componentAnimations.remove(id);
          });
        }
        controller.dispose();
      });
    }
  }

  /// Clear all components from the screen
  void _clearAllComponents() {
    print('Clearing all components');

    // Reverse all animations
    for (var controller in _componentAnimations.values) {
      controller.reverse();
    }

    // After animations complete, clear everything
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _uiComponents.clear();
          for (var controller in _componentAnimations.values) {
            controller.dispose();
          }
          _componentAnimations.clear();
        });
      }
    });
  }

  /// Toggle voice recording
  Future<void> _toggleRecording() async {
    if (!_isConnected) {
      print('Cannot record - not connected to Gemini');
      // Show a snackbar or message to user
      return;
    }

    if (_isRecording) {
      await _audioRecorder.stopRecording();
      setState(() {
        _isRecording = false;
        _micPulse = 1.0;
      });
    } else {
      try {
        await _audioRecorder.startRecording();
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        print('Failed to start recording: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade900,
                    Colors.black,
                    Colors.deepPurple.shade800,
                  ],
                ),
              ),
            ),
          ),

          // Subtle grid pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),

          // UI Components floating overlays
          ...List.generate(_uiComponents.length, (index) {
            final component = _uiComponents[index];
            final animation = _componentAnimations[component.id];

            if (animation == null) return const SizedBox.shrink();

            return Positioned(
              top: 80 + (index * 20.0),
              left: 20,
              right: 20,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: HUDOverlayWidget(
                    component: component,
                    onDismiss: () => _removeComponent(component.id),
                  ),
                ),
              ),
            );
          }),

          // Transcript overlay (bottom)
          if (_showTranscript)
            Positioned(
              bottom: 120,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  border: Border.all(
                    color: Colors.purpleAccent.withOpacity(0.5),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _lastTranscript,
                  style: const TextStyle(
                    color: Colors.purpleAccent,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),

          // App title (top)
          Positioned(
            top: 40,
            left: 20,
            child: Text(
              'Linguava',
              style: TextStyle(
                color: Colors.purpleAccent.withOpacity(0.8),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),

          // Connection status
          Positioned(
            top: 45,
            right: 20,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isConnected ? Colors.greenAccent : Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    color: _isConnected ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Waveform visualizer and microphone button (bottom)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                WaveformVisualizer(
                  isActive: _isRecording,
                  audioLevel: _currentAudioLevel,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _toggleRecording,
                  child: AnimatedScale(
                    scale: _isRecording ? _micPulse : 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording
                            ? Colors.purpleAccent
                            : Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.purpleAccent,
                          width: 2,
                        ),
                        boxShadow: _isRecording
                            ? [
                                BoxShadow(
                                  color: Colors.purpleAccent.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                )
                              ]
                            : null,
                      ),
                      child: Icon(
                        _isRecording ? Icons.mic : Icons.mic_none,
                        color: _isRecording ? Colors.white : Colors.purpleAccent,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Update FSRS card after reviewing a word
  /// This should be called when the user has practiced a word
  Future<void> _updateCardReview(String word, Rating rating) async {
    final success = await _vocabularyRepo.reviewCard(word, rating);
    if (success) {
      print('Successfully updated review for: $word with rating: $rating');

      // Track rated words in lesson mode
      if (_isLessonMode) {
        _ratedWords.add(word);
        print('Rated ${_ratedWords.length}/${_currentStudyCards.length} words');

        // Check if all words have been rated
        if (_ratedWords.length >= _currentStudyCards.length) {
          print('All words completed! Lesson finished.');
          _completLesson();
        }
      }
    } else {
      print('Failed to update review for: $word');
    }
  }

  /// Complete the lesson and pop with result
  void _completLesson() {
    if (_isLessonMode && mounted) {
      print('Lesson complete! Popping screen with results...');

      // Stop recording if active
      if (_isRecording) {
        _audioRecorder.stopRecording();
      }

      // Pop the screen with the learned words as result
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pop(context, _currentStudyCards);
        }
      });
    }
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    _connectionStateSubscription?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _geminiService.dispose();
    _fsrsService.dispose();
    for (var controller in _componentAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

/// Custom painter for grid effect
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purpleAccent.withOpacity(0.03)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Vertical lines
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
