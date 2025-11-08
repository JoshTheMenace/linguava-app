import 'package:flutter/material.dart';
import '../models/ui_component.dart';

/// Learning overlay widget for displaying Japanese learning components
class HUDOverlayWidget extends StatelessWidget {
  final UIComponent component;
  final VoidCallback? onDismiss;

  const HUDOverlayWidget({
    super.key,
    required this.component,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        border: Border.all(
          color: component.type.color.withOpacity(0.6),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: component.type.color.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Accent line on the left
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    component.type.color,
                    component.type.color.withOpacity(0.3),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 40, 12),
            child: _buildComponentContent(context),
          ),

          // Close button
          if (onDismiss != null)
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: component.type.color,
                ),
                onPressed: onDismiss,
                tooltip: 'Dismiss',
              ),
            ),

          // Type indicator
          Positioned(
            top: 8,
            right: 36,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: component.type.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: component.type.color.withOpacity(0.4),
                  width: 0.5,
                ),
              ),
              child: Text(
                component.type.displayName.toUpperCase(),
                style: TextStyle(
                  color: component.type.color,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentContent(BuildContext context) {
    switch (component.type) {
      case UIComponentType.flashcard:
        return _buildFlashcardContent();
      case UIComponentType.sentenceReview:
        return _buildSentenceReviewContent();
      case UIComponentType.speakingExercise:
        return _buildSpeakingExerciseContent();
      case UIComponentType.vocabularyList:
        return _buildVocabularyListContent();
      case UIComponentType.grammarExplanation:
        return _buildGrammarExplanationContent();
      case UIComponentType.kanjiPractice:
        return _buildKanjiPracticeContent();
      case UIComponentType.listeningComprehension:
        return _buildListeningComprehensionContent();
    }
  }

  Widget _buildFlashcardContent() {
    final front = component.data['front'] as String? ?? '';
    final back = component.data['back'] as String? ?? '';
    final hiragana = component.data['hiragana'] as String?;
    final romaji = component.data['romaji'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(component.type.icon, color: component.type.color, size: 20),
            const SizedBox(width: 8),
            Text(
              'Flashcard',
              style: TextStyle(
                color: component.type.color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          front,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (hiragana != null) ...[
          const SizedBox(height: 4),
          Text(
            hiragana,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
        if (romaji != null) ...[
          const SizedBox(height: 2),
          Text(
            romaji,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: component.type.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            back,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSentenceReviewContent() {
    final japanese = component.data['japanese'] as String? ?? '';
    final english = component.data['english'] as String? ?? '';
    final hiragana = component.data['hiragana'] as String?;
    final romaji = component.data['romaji'] as String?;
    final explanation = component.data['explanation'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(component.type.icon, color: component.type.color, size: 20),
            const SizedBox(width: 8),
            Text(
              'Sentence Review',
              style: TextStyle(
                color: component.type.color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          japanese,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (hiragana != null) ...[
          const SizedBox(height: 4),
          Text(
            hiragana,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
        if (romaji != null) ...[
          const SizedBox(height: 2),
          Text(
            romaji,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          english,
          style: TextStyle(
            color: component.type.color,
            fontSize: 14,
          ),
        ),
        if (explanation != null && explanation.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              explanation,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpeakingExerciseContent() {
    final prompt = component.data['prompt'] as String? ?? '';
    final targetPhrase = component.data['targetPhrase'] as String? ?? '';
    final hiragana = component.data['hiragana'] as String?;
    final romaji = component.data['romaji'] as String?;
    final hints = component.data['hints'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(component.type.icon, color: component.type.color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Speaking Exercise',
                style: TextStyle(
                  color: component.type.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          prompt,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: component.type.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: component.type.color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                targetPhrase,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hiragana != null) ...[
                const SizedBox(height: 4),
                Text(
                  hiragana,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
              if (romaji != null) ...[
                const SizedBox(height: 2),
                Text(
                  romaji,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (hints != null && hints.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 14,
                color: component.type.color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  hints,
                  style: TextStyle(
                    color: component.type.color.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildVocabularyListContent() {
    final title = component.data['title'] as String? ?? 'Vocabulary';
    final words = (component.data['words'] as List?)?.cast<Map<String, String>>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(component.type.icon, color: component.type.color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: component.type.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...words.take(5).map((word) {
          final japanese = word['japanese'] ?? word['word'] ?? '';
          final english = word['english'] ?? word['meaning'] ?? '';
          final hiragana = word['hiragana'] ?? word['reading'] ?? '';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '▸ ',
                  style: TextStyle(color: component.type.color, fontSize: 14),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        japanese,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (hiragana.isNotEmpty)
                        Text(
                          hiragana,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      Text(
                        english,
                        style: TextStyle(
                          color: component.type.color.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        if (words.length > 5)
          Text(
            '+ ${words.length - 5} more words',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildGrammarExplanationContent() {
    final title = component.data['title'] as String? ?? 'Grammar';
    final explanation = component.data['explanation'] as String? ?? '';
    final examples = (component.data['examples'] as List?)?.cast<String>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(component.type.icon, color: component.type.color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: component.type.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          explanation,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        if (examples.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Examples:',
            style: TextStyle(
              color: component.type.color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          ...examples.take(3).map((example) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $example',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildKanjiPracticeContent() {
    final kanji = component.data['kanji'] as String? ?? '';
    final meaning = component.data['meaning'] as String? ?? '';
    final readings = (component.data['readings'] as List?)?.cast<String>() ?? [];
    final examples = (component.data['examples'] as List?)?.cast<String>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(component.type.icon, color: component.type.color, size: 20),
            const SizedBox(width: 8),
            Text(
              'Kanji Practice',
              style: TextStyle(
                color: component.type.color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kanji,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meaning,
                    style: TextStyle(
                      color: component.type.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Readings:',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  ...readings.map((reading) => Text(
                        '• $reading',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
        if (examples.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Examples:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          ...examples.take(3).map((example) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '• $example',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildListeningComprehensionContent() {
    final instruction = component.data['instruction'] as String? ?? '';
    final targetSentence = component.data['targetSentence'] as String? ?? '';
    final hiragana = component.data['hiragana'] as String?;
    final romaji = component.data['romaji'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(component.type.icon, color: component.type.color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Listening Exercise',
                style: TextStyle(
                  color: component.type.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          instruction,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: component.type.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                targetSentence,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (hiragana != null) ...[
                const SizedBox(height: 4),
                Text(
                  hiragana,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
              if (romaji != null) ...[
                const SizedBox(height: 2),
                Text(
                  romaji,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
