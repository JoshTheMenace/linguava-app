import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Service class to handle Gemini Live API WebSocket communication
/// Supports bidirectional audio and text streaming
class GeminiLiveService {
  WebSocketChannel? _channel;
  final String apiKey;
  bool _isConnected = false;
  bool _isDisposed = false;
  int _componentIdCounter = 0;
  List<Map<String, dynamic>> _studyCards = [];
  bool _isLessonMode = false;

  // Streams for bidirectional communication
  final StreamController<Uint8List> _audioOutputController =
      StreamController<Uint8List>.broadcast();
  final StreamController<String> _textOutputController =
      StreamController<String>.broadcast();
  final StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();
  final StreamController<Map<String, dynamic>> _toolCallController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _turnCompleteController =
      StreamController<bool>.broadcast();

  /// Stream of audio data received from Gemini (PCM 24kHz, 16-bit, mono)
  Stream<Uint8List> get audioOutputStream => _audioOutputController.stream;

  /// Stream of text responses received from Gemini
  Stream<String> get textOutputStream => _textOutputController.stream;

  /// Stream of connection state changes
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  /// Stream of tool calls from Gemini (for display_text function)
  Stream<Map<String, dynamic>> get toolCallStream => _toolCallController.stream;

  /// Stream of turn complete events
  Stream<bool> get turnCompleteStream => _turnCompleteController.stream;

  /// Whether the service is currently connected
  bool get isConnected => _isConnected;

  GeminiLiveService({required this.apiKey});

  /// Set the study cards for the current session
  void setStudyCards(List<Map<String, dynamic>> cards, {bool isLessonMode = false}) {
    _studyCards = cards;
    _isLessonMode = isLessonMode;
    print('Updated study cards: ${cards.length} cards loaded (lesson mode: $isLessonMode)');
  }

  /// Get current study cards
  List<Map<String, dynamic>> get studyCards => _studyCards;

  /// Start the teaching session automatically
  Future<void> startTeachingSession() async {
    if (!_isConnected) {
      print('Cannot start teaching session - not connected');
      return;
    }

    if (_studyCards.isEmpty) {
      print('Cannot start teaching session - no study cards loaded');
      return;
    }

    // Send an initial message to prompt the AI to start teaching
    await Future.delayed(const Duration(milliseconds: 500)); // Give connection time to stabilize

    final initialMessage = '''Hello! I'm ready to learn Japanese. Let's start with the vocabulary review session. Please teach me the words you have prepared for me today, starting with the most overdue ones.''';

    try {
      await sendText(initialMessage);
      print('Teaching session started');
    } catch (e) {
      print('Failed to start teaching session: $e');
    }
  }

  /// Connect to the Gemini Live API
  Future<void> connect({
    String model = 'models/gemini-2.5-flash-native-audio-preview-09-2025',
    String voiceName = 'Algenib',
    List<String> responseModalities = const ['AUDIO'],
  }) async {
    try {
      // Construct WebSocket URL with API key
      final wsUrl = Uri.parse(
        'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent?key=$apiKey',
      );

      print('Connecting to Gemini Live API...');
      _channel = WebSocketChannel.connect(wsUrl);

      // Send setup message to configure the session with function calling
      final setupMsg = {
        'setup': {
          'model': model,
          'systemInstruction': {
            'parts': [
              {
                'text': '''You are a friendly and supportive Japanese language learning AI assistant. You are patient, encouraging, and skilled at teaching Japanese in an engaging way.

Your main goals are to:
- Help users learn and practice Japanese conversation
- Teach vocabulary, grammar, kanji, and pronunciation
- Provide natural Japanese examples with translations
- Correct pronunciation and grammar gently but clearly
- Create interactive learning exercises and flashcards
- Adapt to the user's skill level (beginner, intermediate, advanced)

When teaching, always consider:
- Provide hiragana readings for kanji when helpful
- Include romaji for complete beginners when requested
- Explain grammar points clearly with examples
- Use natural, conversational Japanese
- Be encouraging and celebrate progress

Use the learning tools available to you:
- show_flashcard: Display vocabulary flashcards with Japanese and English
- show_sentence_review: Present sentences for study with translations and explanations
- show_speaking_exercise: Create speaking practice prompts for the user
- show_vocabulary_list: Display organized vocabulary lists by theme
- show_grammar_explanation: Explain grammar concepts with examples
- show_kanji_practice: Teach kanji with readings and example words
- show_listening_exercise: Create listening comprehension exercises
- clear_screen: Remove all displayed components

${_studyCards.isNotEmpty ? '''
CURRENT STUDY SESSION:
${_isLessonMode ? 'This is a STRUCTURED LESSON with exactly ${_studyCards.length} word${_studyCards.length == 1 ? '' : 's'}.' : 'You are conducting a vocabulary review session.'}
${_isLessonMode ? 'After teaching all ${_studyCards.length} word${_studyCards.length == 1 ? '' : 's'}, the lesson will END automatically.' : ''}

Words to teach:
${_studyCards.map((card) => '- ${card['word']} (${card['romaji']}): ${card['meaning']}\n  Example: ${card['example']} = ${card['exampleMeaning']}${card['isDue'] == true ? ' [DUE FOR REVIEW]' : ' [NEW]'}').join('\n')}

Please teach these words one by one. For each word:
1. Show a flashcard using show_flashcard
2. Teach pronunciation and usage
3. Give example sentences
4. Have the user practice saying it
5. **IMPORTANT**: Before moving to the next word, ALWAYS call update_card_rating to track progress:
   - Use "again" if user couldn't recall, used incorrectly, or said they don't know it
   - Use "hard" if user struggled but eventually got it with help
   - Use "good" (DEFAULT) if user practiced correctly and showed understanding
   - Use "easy" ONLY if user explicitly says they know it very well or demonstrates mastery
6. ${_isLessonMode ? 'If there are more words, move to the next word. If this was the LAST word, say a brief congratulatory message like "Great work! You\'ve completed today\'s lesson." and STOP. Do NOT ask what else they want to learn.' : 'Move to the next word'}

Focus ONLY on these words in this session. ${!_isLessonMode ? 'Start with the most overdue cards first.' : ''}
CRITICAL: You MUST call update_card_rating for each word before moving on - this is how we track learning progress!
${_isLessonMode ? '\nREMEMBER: After teaching ALL ${_studyCards.length} word${_studyCards.length == 1 ? '' : 's'}, say congratulations and END the conversation. The lesson will complete automatically.' : ''}
''' : ''}

Be conversational, patient, and make learning Japanese fun and engaging!'''
              }
            ]
          },
          'generationConfig': {
            'responseModalities': responseModalities,
            'speechConfig': {
              'voiceConfig': {
                'prebuiltVoiceConfig': {'voiceName': voiceName}
              }
            }
          },
          'tools': [
            {
              'functionDeclarations': [
                {
                  'name': 'show_flashcard',
                  'description': 'Display a flashcard for vocabulary learning. Use this when teaching new words or when the user requests flashcards.',
                  'parameters': {
                    'type': 'object',
                    'properties': {
                      'front': {
                        'type': 'string',
                        'description': 'The front of the flashcard (typically Japanese word/phrase)'
                      },
                      'back': {
                        'type': 'string',
                        'description': 'The back of the flashcard (typically English meaning)'
                      },
                      'hiragana': {
                        'type': 'string',
                        'description': 'Hiragana reading of the Japanese text (optional)'
                      },
                      'romaji': {
                        'type': 'string',
                        'description': 'Romaji transliteration (optional, for beginners)'
                      }
                    },
                    'required': ['front', 'back']
                  }
                },
                {
                  'name': 'show_sentence_review',
                  'description': 'Display a sentence for review and study. Use this to teach sentence patterns and real usage examples.',
                  'parameters': {
                    'type': 'object',
                    'properties': {
                      'japanese': {
                        'type': 'string',
                        'description': 'The Japanese sentence'
                      },
                      'english': {
                        'type': 'string',
                        'description': 'English translation of the sentence'
                      },
                      'hiragana': {
                        'type': 'string',
                        'description': 'Hiragana reading (optional)'
                      },
                      'romaji': {
                        'type': 'string',
                        'description': 'Romaji transliteration (optional)'
                      },
                      'explanation': {
                        'type': 'string',
                        'description': 'Grammar or usage explanation (optional)'
                      }
                    },
                    'required': ['japanese', 'english']
                  }
                },
                {
                  'name': 'show_speaking_exercise',
                  'description': 'Create a speaking practice exercise for the user. Use this to encourage oral practice.',
                  'parameters': {
                    'type': 'object',
                    'properties': {
                      'prompt': {
                        'type': 'string',
                        'description': 'The instruction or scenario for the speaking exercise (e.g., "Introduce yourself in Japanese")'
                      },
                      'targetPhrase': {
                        'type': 'string',
                        'description': 'The target phrase or sentence the user should practice'
                      },
                      'hiragana': {
                        'type': 'string',
                        'description': 'Hiragana reading (optional)'
                      },
                      'romaji': {
                        'type': 'string',
                        'description': 'Romaji transliteration (optional)'
                      },
                      'hints': {
                        'type': 'string',
                        'description': 'Optional hints or tips for pronunciation'
                      }
                    },
                    'required': ['prompt', 'targetPhrase']
                  }
                },
                {
                  'name': 'show_vocabulary_list',
                  'description': 'Display an organized vocabulary list. Use this to present themed vocabulary or word lists.',
                  'parameters': {
                    'type': 'object',
                    'properties': {
                      'title': {
                        'type': 'string',
                        'description': 'The title/theme of the vocabulary list (e.g., "Food Vocabulary", "Daily Greetings")'
                      },
                      'words': {
                        'type': 'array',
                        'items': {'type': 'object'},
                        'description': 'Array of word objects with japanese, english, and optional hiragana/romaji fields'
                      }
                    },
                    'required': ['title', 'words']
                  }
                },
                {
                  'name': 'show_grammar_explanation',
                  'description': 'Display a grammar explanation. Use this to teach grammar concepts, particles, verb forms, etc.',
                  'parameters': {
                    'type': 'object',
                    'properties': {
                      'title': {
                        'type': 'string',
                        'description': 'The grammar topic (e.g., "Using the particle は (wa)", "Te-form verbs")'
                      },
                      'explanation': {
                        'type': 'string',
                        'description': 'Clear explanation of the grammar concept'
                      },
                      'examples': {
                        'type': 'array',
                        'items': {'type': 'string'},
                        'description': 'Example sentences demonstrating the grammar (optional)'
                      }
                    },
                    'required': ['title', 'explanation']
                  }
                },
                {
                  'name': 'show_kanji_practice',
                  'description': 'Display kanji for practice and study. Use this when teaching kanji characters.',
                  'parameters': {
                    'type': 'object',
                    'properties': {
                      'kanji': {
                        'type': 'string',
                        'description': 'The kanji character to practice'
                      },
                      'meaning': {
                        'type': 'string',
                        'description': 'The meaning of the kanji in English'
                      },
                      'readings': {
                        'type': 'array',
                        'items': {'type': 'string'},
                        'description': 'On-yomi and kun-yomi readings'
                      },
                      'examples': {
                        'type': 'array',
                        'items': {'type': 'string'},
                        'description': 'Example words using this kanji (optional)'
                      }
                    },
                    'required': ['kanji', 'meaning', 'readings']
                  }
                },
                {
                  'name': 'show_listening_exercise',
                  'description': 'Create a listening comprehension exercise. Use this to practice listening skills.',
                  'parameters': {
                    'type': 'object',
                    'properties': {
                      'instruction': {
                        'type': 'string',
                        'description': 'Instructions for the listening exercise'
                      },
                      'targetSentence': {
                        'type': 'string',
                        'description': 'The Japanese sentence to listen for'
                      },
                      'hiragana': {
                        'type': 'string',
                        'description': 'Hiragana reading (optional)'
                      },
                      'romaji': {
                        'type': 'string',
                        'description': 'Romaji transliteration (optional)'
                      }
                    },
                    'required': ['instruction', 'targetSentence']
                  }
                },
                {
                  'name': 'update_card_rating',
                  'description': '''Update the spaced repetition rating for a vocabulary word after the user has practiced it.
Call this when moving on to the next word to track the user's learning progress.

Rating guidelines:
- again (1): User used word incorrectly, expressed they don't know it, or couldn't recall it
- hard (2): User had trouble but eventually understood/used it correctly with help
- good (3): User practiced correctly, showed understanding (DEFAULT - use this most often)
- easy (4): ONLY if user explicitly says they know it very well or demonstrates mastery

Always call this before moving to the next word to ensure progress is tracked.''',
                  'parameters': {
                    'type': 'object',
                    'properties': {
                      'word': {
                        'type': 'string',
                        'description': 'The Japanese word being rated (e.g., "こんにちは")'
                      },
                      'rating': {
                        'type': 'string',
                        'enum': ['again', 'hard', 'good', 'easy'],
                        'description': 'The rating based on user performance: again (didn\'t know), hard (difficult), good (understood), easy (mastered)'
                      },
                      'reason': {
                        'type': 'string',
                        'description': 'Brief explanation of why this rating was chosen (optional, for logging)'
                      }
                    },
                    'required': ['word', 'rating']
                  }
                },
                {
                  'name': 'clear_screen',
                  'description': 'Clear all UI components from the screen. Use this when the user wants to start fresh or clear all displayed learning materials.',
                  'parameters': {
                    'type': 'object',
                    'properties': {}
                  }
                }
              ]
            }
          ]
        }
      };

      print('=== Setup message: ${jsonEncode(setupMsg)}');

      _channel!.sink.add(jsonEncode(setupMsg));
      _isConnected = true;
      _connectionStateController.add(true);
      print('Connected to Gemini Live API');

      // Listen to incoming messages
      _channel!.stream.listen(
        _handleIncomingMessage,
        onError: (error) {
          print('!!! WebSocket error: $error');
          print('!!! Error type: ${error.runtimeType}');
          _isConnected = false;
          if (!_isDisposed && !_connectionStateController.isClosed) {
            _connectionStateController.add(false);
          }
        },
        onDone: () {
          print('!!! WebSocket connection closed');
          _isConnected = false;
          if (!_isDisposed && !_connectionStateController.isClosed) {
            _connectionStateController.add(false);
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      print('Error connecting to Gemini Live API: $e');
      _isConnected = false;
      if (!_isDisposed && !_connectionStateController.isClosed) {
        _connectionStateController.add(false);
      }
      rethrow;
    }
  }

  /// Handle incoming messages from the WebSocket
  void _handleIncomingMessage(dynamic message) {
    // Ignore messages if service is disposed
    if (_isDisposed) {
      return;
    }

    try {
      // Convert binary data to string if needed
      String messageString;
      if (message is String) {
        messageString = message;
      } else if (message is Uint8List) {
        messageString = utf8.decode(message);
      } else if (message is List<int>) {
        messageString = utf8.decode(message);
      } else {
        print('Unknown message type: ${message.runtimeType}');
        return;
      }

      final data = jsonDecode(messageString);
      print('<<< Received message: ${data.keys.join(", ")}');

      // Check for errors
      if (data['error'] != null) {
        print('!!! ERROR from server: ${jsonEncode(data['error'])}');
        return;
      }

      // Handle setup completion
      if (data['setupComplete'] != null) {
        print('Setup complete');
        return;
      }

      // Handle server response with content
      if (data['serverContent'] != null) {
        final modelTurn = data['serverContent']['modelTurn'];
        if (modelTurn != null && modelTurn['parts'] != null) {
          final parts = modelTurn['parts'] as List;
          print('>>> Processing ${parts.length} parts from Gemini');

          for (var part in parts) {
            // Audio data (base64 encoded PCM)
            if (part['inlineData'] != null) {
              final audioB64 = part['inlineData']['data'];
              final audioBytes = base64Decode(audioB64);
              print('>>> Received audio: ${audioBytes.length} bytes');
              if (!_isDisposed && !_audioOutputController.isClosed) {
                _audioOutputController.add(audioBytes);
              }
            }

            // Text data (regular text responses)
            if (part['text'] != null) {
              print('>>> Received text: ${part['text']}');
              if (!_isDisposed && !_textOutputController.isClosed) {
                _textOutputController.add(part['text']);
              }
            }
          }
        }

        // Check for turn completion (interruption handling)
        if (data['serverContent']['turnComplete'] == true) {
          print('>>> Turn complete');
          if (!_isDisposed && !_turnCompleteController.isClosed) {
            _turnCompleteController.add(true);
          }
        }
      }

      // Handle tool calls
      if (data['toolCall'] != null) {
        final toolCall = data['toolCall'];
        print('=== Tool call received');

        // Parse functionCalls array
        if (toolCall['functionCalls'] != null) {
          final functionCalls = toolCall['functionCalls'] as List;
          for (var functionCall in functionCalls) {
            print('=== Calling function: ${functionCall['name']}');
            _handleFunctionCall(functionCall);
          }
        }
      }

      // Also check for functionCall in serverContent parts
      if (data['serverContent'] != null &&
          data['serverContent']['modelTurn'] != null &&
          data['serverContent']['modelTurn']['parts'] != null) {
        final parts = data['serverContent']['modelTurn']['parts'] as List;
        for (var part in parts) {
          if (part['functionCall'] != null) {
            print('=== Function call in parts: ${part['functionCall']['name']}');
            _handleFunctionCall(part['functionCall']);
          }
        }
      }
    } catch (e) {
      print('Error handling incoming message: $e');
    }
  }

  /// Send audio data to Gemini
  /// Audio should be PCM 16kHz, 16-bit, mono
  Future<void> sendAudio(Uint8List audioData) async {
    if (!_isConnected) {
      throw Exception('Not connected to Gemini Live API');
    }

    try {
      final message = {
        'realtimeInput': {
          'mediaChunks': [
            {
              'mimeType': 'audio/pcm',
              'data': base64Encode(audioData),
            }
          ]
        }
      };

      _channel?.sink.add(jsonEncode(message));

      // Log every 50th chunk to avoid spam
      if (DateTime.now().millisecond % 50 == 0) {
        print('>>> Sent audio chunk: ${audioData.length} bytes');
      }
    } catch (e) {
      print('Error sending audio: $e');
      rethrow;
    }
  }

  /// Send text message to Gemini
  Future<void> sendText(String text) async {
    if (!_isConnected) {
      throw Exception('Not connected to Gemini Live API');
    }

    try {
      final message = {
        'clientContent': {
          'turns': [
            {
              'role': 'user',
              'parts': [
                {'text': text}
              ]
            }
          ],
          'turnComplete': true
        }
      };

      _channel?.sink.add(jsonEncode(message));
      print('Sent text: $text');
    } catch (e) {
      print('Error sending text: $e');
      rethrow;
    }
  }

  /// Send video frame to Gemini
  /// Frame should be JPEG encoded image bytes
  Future<void> sendVideoFrame(Uint8List imageBytes) async {
    if (!_isConnected) {
      throw Exception('Not connected to Gemini Live API');
    }

    try {
      final message = {
        'realtimeInput': {
          'mediaChunks': [
            {
              'mimeType': 'image/jpeg',
              'data': base64Encode(imageBytes),
            }
          ]
        }
      };

      _channel?.sink.add(jsonEncode(message));

      // Log every 10th frame to avoid spam
      if (DateTime.now().second % 10 == 0) {
        print('>>> Sent video frame: ${imageBytes.length} bytes');
      }
    } catch (e) {
      print('Error sending video frame: $e');
      rethrow;
    }
  }

  /// Handle function calls from Gemini
  void _handleFunctionCall(Map<String, dynamic> functionCall) {
    // Ignore if service is disposed
    if (_isDisposed || _toolCallController.isClosed) {
      return;
    }

    final functionName = functionCall['name'];
    final functionId = functionCall['id'];
    final args = functionCall['args'] as Map<String, dynamic>?;

    print('=== Function called: $functionName (ID: $functionId)');

    String result = 'success';

    switch (functionName) {
      case 'show_flashcard':
        if (args != null) {
          print('=== Creating flashcard: ${args['front']}');
          _toolCallController.add({
            'function': 'show_flashcard',
            'front': args['front'],
            'back': args['back'],
            'hiragana': args['hiragana'],
            'romaji': args['romaji'],
          });
          result = 'Flashcard displayed successfully';
        }
        break;

      case 'show_sentence_review':
        if (args != null) {
          print('=== Creating sentence review: ${args['japanese']}');
          _toolCallController.add({
            'function': 'show_sentence_review',
            'japanese': args['japanese'],
            'english': args['english'],
            'hiragana': args['hiragana'],
            'romaji': args['romaji'],
            'explanation': args['explanation'],
          });
          result = 'Sentence review displayed successfully';
        }
        break;

      case 'show_speaking_exercise':
        if (args != null) {
          print('=== Creating speaking exercise: ${args['targetPhrase']}');
          _toolCallController.add({
            'function': 'show_speaking_exercise',
            'prompt': args['prompt'],
            'targetPhrase': args['targetPhrase'],
            'hiragana': args['hiragana'],
            'romaji': args['romaji'],
            'hints': args['hints'],
          });
          result = 'Speaking exercise displayed successfully';
        }
        break;

      case 'show_vocabulary_list':
        if (args != null) {
          print('=== Creating vocabulary list: ${args['title']}');
          _toolCallController.add({
            'function': 'show_vocabulary_list',
            'title': args['title'],
            'words': args['words'],
          });
          result = 'Vocabulary list "${args['title']}" displayed successfully';
        }
        break;

      case 'show_grammar_explanation':
        if (args != null) {
          print('=== Creating grammar explanation: ${args['title']}');
          _toolCallController.add({
            'function': 'show_grammar_explanation',
            'title': args['title'],
            'explanation': args['explanation'],
            'examples': args['examples'],
          });
          result = 'Grammar explanation "${args['title']}" displayed successfully';
        }
        break;

      case 'show_kanji_practice':
        if (args != null) {
          print('=== Creating kanji practice: ${args['kanji']}');
          _toolCallController.add({
            'function': 'show_kanji_practice',
            'kanji': args['kanji'],
            'meaning': args['meaning'],
            'readings': args['readings'],
            'examples': args['examples'],
          });
          result = 'Kanji practice for "${args['kanji']}" displayed successfully';
        }
        break;

      case 'show_listening_exercise':
        if (args != null) {
          print('=== Creating listening exercise: ${args['targetSentence']}');
          _toolCallController.add({
            'function': 'show_listening_exercise',
            'instruction': args['instruction'],
            'targetSentence': args['targetSentence'],
            'hiragana': args['hiragana'],
            'romaji': args['romaji'],
          });
          result = 'Listening exercise displayed successfully';
        }
        break;

      case 'update_card_rating':
        if (args != null) {
          final word = args['word'];
          final rating = args['rating'];
          final reason = args['reason'] ?? 'No reason provided';
          print('=== Updating card rating: $word -> $rating ($reason)');
          _toolCallController.add({
            'function': 'update_card_rating',
            'word': word,
            'rating': rating,
            'reason': reason,
          });
          result = 'Card rating updated successfully for "$word"';
        }
        break;

      case 'clear_screen':
        print('=== Clearing screen');
        _toolCallController.add({
          'function': 'clear_screen',
        });
        result = 'Screen cleared successfully';
        break;

      default:
        print('=== Unknown function: $functionName');
        result = 'Unknown function: $functionName';
    }

    // Send function response back to Gemini
    if (functionId != null) {
      _sendFunctionResponse(functionId, functionName, result);
    }
  }

  /// Send function response back to Gemini
  Future<void> _sendFunctionResponse(String functionId, String functionName, String result) async {
    if (!_isConnected) return;

    try {
      final message = {
        'toolResponse': {
          'functionResponses': [
            {
              'id': functionId,
              'name': functionName,
              'response': {
                'output': {
                  'result': result,
                }
              }
            }
          ]
        }
      };

      _channel?.sink.add(jsonEncode(message));
      print('>>> Sent function response for $functionName (ID: $functionId)');
    } catch (e) {
      print('Error sending function response: $e');
    }
  }

  /// Disconnect from the Gemini Live API
  Future<void> disconnect() async {
    try {
      await _channel?.sink.close();
      _isConnected = false;
      if (!_isDisposed && !_connectionStateController.isClosed) {
        _connectionStateController.add(false);
      }
      print('Disconnected from Gemini Live API');
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  /// Dispose of all resources
  void dispose() {
    _isDisposed = true;
    disconnect();
    _audioOutputController.close();
    _textOutputController.close();
    _connectionStateController.close();
    _toolCallController.close();
    _turnCompleteController.close();
  }
}
