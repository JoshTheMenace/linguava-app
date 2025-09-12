import 'dart:convert';

// Base class for all lesson content types
abstract class LessonContent {
  final String id;
  final String lessonId;
  final int orderIndex;
  final LessonContentType type;
  final String title;
  final String? instruction;

  const LessonContent({
    required this.id,
    required this.lessonId,
    required this.orderIndex,
    required this.type,
    required this.title,
    this.instruction,
  });

  Map<String, dynamic> toJson();
  
  static LessonContent fromJson(Map<String, dynamic> json) {
    final type = LessonContentType.values.firstWhere(
      (e) => e.name == json['type'],
    );
    
    switch (type) {
      case LessonContentType.explanation:
        return ExplanationContent.fromJson(json);
      case LessonContentType.flashcard:
        return FlashcardContent.fromJson(json);
      case LessonContentType.multipleChoice:
        return MultipleChoiceContent.fromJson(json);
      case LessonContentType.fillInBlank:
        return FillInBlankContent.fromJson(json);
      case LessonContentType.matching:
        return MatchingContent.fromJson(json);
    }
  }
}

enum LessonContentType {
  explanation,
  flashcard,
  multipleChoice,
  fillInBlank,
  matching,
}

// Explanation/Tutorial content
class ExplanationContent extends LessonContent {
  final String content;
  final List<String>? examples;
  final String? imageUrl;
  final String? audioUrl;

  const ExplanationContent({
    required super.id,
    required super.lessonId,
    required super.orderIndex,
    required super.title,
    super.instruction,
    required this.content,
    this.examples,
    this.imageUrl,
    this.audioUrl,
  }) : super(type: LessonContentType.explanation);

  factory ExplanationContent.fromJson(Map<String, dynamic> json) {
    return ExplanationContent(
      id: json['id'],
      lessonId: json['lessonId'],
      orderIndex: json['orderIndex'],
      title: json['title'],
      instruction: json['instruction'],
      content: json['content'],
      examples: json['examples'] != null 
        ? List<String>.from(json['examples'])
        : null,
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'lessonId': lessonId,
    'orderIndex': orderIndex,
    'type': type.name,
    'title': title,
    'instruction': instruction,
    'content': content,
    'examples': examples,
    'imageUrl': imageUrl,
    'audioUrl': audioUrl,
  };
}

// Flashcard content for vocabulary/phrases
class FlashcardContent extends LessonContent {
  final String front;
  final String back;
  final String? pronunciation;
  final String? audioUrl;
  final String? imageUrl;
  final List<String>? tags;

  const FlashcardContent({
    required super.id,
    required super.lessonId,
    required super.orderIndex,
    required super.title,
    super.instruction,
    required this.front,
    required this.back,
    this.pronunciation,
    this.audioUrl,
    this.imageUrl,
    this.tags,
  }) : super(type: LessonContentType.flashcard);

  factory FlashcardContent.fromJson(Map<String, dynamic> json) {
    return FlashcardContent(
      id: json['id'],
      lessonId: json['lessonId'],
      orderIndex: json['orderIndex'],
      title: json['title'],
      instruction: json['instruction'],
      front: json['front'],
      back: json['back'],
      pronunciation: json['pronunciation'],
      audioUrl: json['audioUrl'],
      imageUrl: json['imageUrl'],
      tags: json['tags'] != null 
        ? List<String>.from(json['tags'])
        : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'lessonId': lessonId,
    'orderIndex': orderIndex,
    'type': type.name,
    'title': title,
    'instruction': instruction,
    'front': front,
    'back': back,
    'pronunciation': pronunciation,
    'audioUrl': audioUrl,
    'imageUrl': imageUrl,
    'tags': tags,
  };
}

// Multiple choice question
class MultipleChoiceContent extends LessonContent {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;
  final String? audioUrl;

  const MultipleChoiceContent({
    required super.id,
    required super.lessonId,
    required super.orderIndex,
    required super.title,
    super.instruction,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
    this.audioUrl,
  }) : super(type: LessonContentType.multipleChoice);

  factory MultipleChoiceContent.fromJson(Map<String, dynamic> json) {
    return MultipleChoiceContent(
      id: json['id'],
      lessonId: json['lessonId'],
      orderIndex: json['orderIndex'],
      title: json['title'],
      instruction: json['instruction'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'],
      explanation: json['explanation'],
      audioUrl: json['audioUrl'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'lessonId': lessonId,
    'orderIndex': orderIndex,
    'type': type.name,
    'title': title,
    'instruction': instruction,
    'question': question,
    'options': options,
    'correctAnswerIndex': correctAnswerIndex,
    'explanation': explanation,
    'audioUrl': audioUrl,
  };
}

// Fill in the blank exercise
class FillInBlankContent extends LessonContent {
  final String text; // Text with [blank] placeholders
  final List<String> answers;
  final bool caseSensitive;
  final String? hint;

  const FillInBlankContent({
    required super.id,
    required super.lessonId,
    required super.orderIndex,
    required super.title,
    super.instruction,
    required this.text,
    required this.answers,
    this.caseSensitive = false,
    this.hint,
  }) : super(type: LessonContentType.fillInBlank);

  factory FillInBlankContent.fromJson(Map<String, dynamic> json) {
    return FillInBlankContent(
      id: json['id'],
      lessonId: json['lessonId'],
      orderIndex: json['orderIndex'],
      title: json['title'],
      instruction: json['instruction'],
      text: json['text'],
      answers: List<String>.from(json['answers']),
      caseSensitive: json['caseSensitive'] ?? false,
      hint: json['hint'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'lessonId': lessonId,
    'orderIndex': orderIndex,
    'type': type.name,
    'title': title,
    'instruction': instruction,
    'text': text,
    'answers': answers,
    'caseSensitive': caseSensitive,
    'hint': hint,
  };
}

// Matching exercise
class MatchingContent extends LessonContent {
  final List<MatchingPair> pairs;
  final bool shuffle;

  const MatchingContent({
    required super.id,
    required super.lessonId,
    required super.orderIndex,
    required super.title,
    super.instruction,
    required this.pairs,
    this.shuffle = true,
  }) : super(type: LessonContentType.matching);

  factory MatchingContent.fromJson(Map<String, dynamic> json) {
    return MatchingContent(
      id: json['id'],
      lessonId: json['lessonId'],
      orderIndex: json['orderIndex'],
      title: json['title'],
      instruction: json['instruction'],
      pairs: (json['pairs'] as List)
          .map((pair) => MatchingPair.fromJson(pair))
          .toList(),
      shuffle: json['shuffle'] ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'lessonId': lessonId,
    'orderIndex': orderIndex,
    'type': type.name,
    'title': title,
    'instruction': instruction,
    'pairs': pairs.map((pair) => pair.toJson()).toList(),
    'shuffle': shuffle,
  };
}

class MatchingPair {
  final String left;
  final String right;

  const MatchingPair({
    required this.left,
    required this.right,
  });

  factory MatchingPair.fromJson(Map<String, dynamic> json) {
    return MatchingPair(
      left: json['left'],
      right: json['right'],
    );
  }

  Map<String, dynamic> toJson() => {
    'left': left,
    'right': right,
  };
}

// Complete lesson content structure
class LessonContentData {
  final String lessonId;
  final List<LessonContent> contents;

  const LessonContentData({
    required this.lessonId,
    required this.contents,
  });

  factory LessonContentData.fromJson(Map<String, dynamic> json) {
    return LessonContentData(
      lessonId: json['lessonId'],
      contents: (json['contents'] as List)
          .map((content) => LessonContent.fromJson(content))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'lessonId': lessonId,
    'contents': contents.map((content) => content.toJson()).toList(),
  };

  String get contentsJson => jsonEncode(toJson());

  static LessonContentData fromJsonString(String jsonString) {
    return LessonContentData.fromJson(jsonDecode(jsonString));
  }
}