import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson.dart' as models;
import '../models/lesson_content.dart';
import '../providers/learning_path_provider.dart';

// Single lesson provider
final lessonProvider = FutureProvider.family<models.Lesson?, String>((ref, lessonId) async {
  final service = ref.watch(learningPathServiceProvider);
  return await service.getLessonById(lessonId);
});

// Lesson content provider
final lessonContentProvider = FutureProvider.family<LessonContentData?, String>((ref, lessonId) async {
  // For now, return sample content based on lesson ID
  // In a real app, this would fetch from a database or API
  return _getSampleLessonContent(lessonId);
});

// Sample lesson content generator (replace with actual data fetching)
LessonContentData? _getSampleLessonContent(String lessonId) {
  // Generate different content based on lesson ID
  if (lessonId == 'jlpt-n5-lesson-01') {
    return LessonContentData(
      lessonId: lessonId,
      contents: [
        ExplanationContent(
          id: '${lessonId}_explain_1',
          lessonId: lessonId,
          orderIndex: 0,
          title: 'Japanese Greetings',
          instruction: 'Learn the basic greetings used in Japanese daily conversation',
          content: '''Japanese greetings are essential for daily communication. They show politeness and respect, which are very important in Japanese culture.

The most common greetings change depending on the time of day and level of formality. Let's learn the basic ones first.''',
          examples: [
            'おはようございます (Ohayou gozaimasu) - Good morning (polite)',
            'こんにちは (Konnichiwa) - Hello/Good afternoon',
            'こんばんは (Konbanwa) - Good evening',
            'はじめまして (Hajimemashite) - Nice to meet you'
          ],
        ),
        FlashcardContent(
          id: '${lessonId}_flash_1',
          lessonId: lessonId,
          orderIndex: 1,
          title: 'Good Morning',
          instruction: 'Learn how to say good morning politely',
          front: 'おはようございます',
          back: 'Good morning',
          pronunciation: 'Ohayou gozaimasu',
          tags: ['greetings', 'morning', 'polite'],
        ),
        FlashcardContent(
          id: '${lessonId}_flash_2',
          lessonId: lessonId,
          orderIndex: 2,
          title: 'Hello',
          instruction: 'The most common greeting',
          front: 'こんにちは',
          back: 'Hello / Good afternoon',
          pronunciation: 'Konnichiwa',
          tags: ['greetings', 'common'],
        ),
        MultipleChoiceContent(
          id: '${lessonId}_mc_1',
          lessonId: lessonId,
          orderIndex: 3,
          title: 'Greeting Quiz',
          instruction: 'Choose the correct greeting for this situation',
          question: 'What would you say when meeting someone at 2 PM?',
          options: [
            'おはようございます (Ohayou gozaimasu)',
            'こんにちは (Konnichiwa)',
            'こんばんは (Konbanwa)',
            'おやすみなさい (Oyasumi nasai)',
          ],
          correctAnswerIndex: 1,
          explanation: 'こんにちは (Konnichiwa) is used from late morning until late afternoon, making it perfect for 2 PM.',
        ),
        FillInBlankContent(
          id: '${lessonId}_fill_1',
          lessonId: lessonId,
          orderIndex: 4,
          title: 'Complete the Greeting',
          instruction: 'Fill in the blanks to complete the greetings',
          text: 'Good morning in Japanese is [blank]ございます, and hello is [blank]。',
          answers: ['おはよう', 'こんにちは'],
          hint: 'Think about the formal morning greeting and the afternoon greeting',
        ),
        MatchingContent(
          id: '${lessonId}_match_1',
          lessonId: lessonId,
          orderIndex: 5,
          title: 'Match the Greetings',
          instruction: 'Match the Japanese greetings with their English meanings',
          pairs: [
            MatchingPair(left: 'おはようございます', right: 'Good morning'),
            MatchingPair(left: 'こんにちは', right: 'Hello'),
            MatchingPair(left: 'こんばんは', right: 'Good evening'),
            MatchingPair(left: 'はじめまして', right: 'Nice to meet you'),
          ],
        ),
      ],
    );
  }
  
  if (lessonId == 'jlpt-n5-lesson-02') {
    return LessonContentData(
      lessonId: lessonId,
      contents: [
        ExplanationContent(
          id: '${lessonId}_explain_1',
          lessonId: lessonId,
          orderIndex: 0,
          title: 'Self Introduction',
          instruction: 'Learn how to introduce yourself in Japanese',
          content: '''Self-introduction (自己紹介 - jikoshōkai) is a fundamental skill in Japanese. It's typically used when meeting new people, starting a new job, or joining a group.

The basic pattern follows this structure:
1. Greeting
2. Name introduction
3. Additional information (nationality, occupation, etc.)
4. Closing phrase''',
          examples: [
            'はじめまして。田中です。よろしくお願いします。',
            'My name is... - 私の名前は...です',
            'I am from... - ...から来ました',
            'I am a student - 学生です'
          ],
        ),
        FlashcardContent(
          id: '${lessonId}_flash_1',
          lessonId: lessonId,
          orderIndex: 1,
          title: 'My name is...',
          instruction: 'Learn how to say your name',
          front: '私の名前は...です',
          back: 'My name is...',
          pronunciation: 'Watashi no namae wa ... desu',
          tags: ['introduction', 'name'],
        ),
        FlashcardContent(
          id: '${lessonId}_flash_2',
          lessonId: lessonId,
          orderIndex: 2,
          title: 'Please treat me well',
          instruction: 'A polite closing for introductions',
          front: 'よろしくお願いします',
          back: 'Please treat me well / Nice to meet you',
          pronunciation: 'Yoroshiku onegaishimasu',
          tags: ['introduction', 'polite', 'closing'],
        ),
        MultipleChoiceContent(
          id: '${lessonId}_mc_1',
          lessonId: lessonId,
          orderIndex: 3,
          title: 'Introduction Order',
          instruction: 'What should come first in a Japanese self-introduction?',
          question: 'When introducing yourself in Japanese, what should you say first?',
          options: [
            'Your name',
            'Your nationality', 
            'A greeting like はじめまして',
            'Your occupation',
          ],
          correctAnswerIndex: 2,
          explanation: 'Always start with a greeting like はじめまして (hajimemashite) before giving your name or other information.',
        ),
      ],
    );
  }
  
  // Default content for other lessons
  return LessonContentData(
    lessonId: lessonId,
    contents: [
      ExplanationContent(
        id: '${lessonId}_default',
        lessonId: lessonId,
        orderIndex: 0,
        title: 'Lesson Content',
        content: 'This lesson content is coming soon! We\'re working on creating interactive content for all lessons.',
      ),
    ],
  );
}