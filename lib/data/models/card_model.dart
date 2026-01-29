class CardModel {
  final int? id;
  final int deckId;

  // Content
  final String term;
  final String definition;
  final String type; // 'text', 'markdown', 'image'

  // Spaced Repetition State (SM-2)
  final int streak;
  final double easeFactor;
  final int interval; // Days
  final DateTime? nextReview;

  // Stats
  final int reviewCount;
  final int lapses;

  CardModel({
    this.id,
    required this.deckId,
    required this.term,
    required this.definition,
    this.type = 'text',
    this.streak = 0,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.nextReview,
    this.reviewCount = 0,
    this.lapses = 0,
  });

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'],
      deckId: map['deck_id'],
      term: map['term'],
      definition: map['definition'],
      type: map['type'] ?? 'text',
      streak: map['streak'] ?? 0,
      easeFactor: map['ease_factor'] ?? 2.5,
      interval: map['interval'] ?? 0,
      nextReview: map['next_review'] != null && map['next_review'] > 0
          ? DateTime.fromMillisecondsSinceEpoch(map['next_review'])
          : null,
      reviewCount: map['review_count'] ?? 0,
      lapses: map['lapses'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deck_id': deckId,
      'term': term,
      'definition': definition,
      'type': type,
      'streak': streak,
      'ease_factor': easeFactor,
      'interval': interval,
      'next_review': nextReview?.millisecondsSinceEpoch ?? 0,
      'review_count': reviewCount,
      'lapses': lapses,
    };
  }

  CardModel copyWith({
    int? id,
    int? deckId,
    String? term,
    String? definition,
    String? type,
    int? streak,
    double? easeFactor,
    int? interval,
    DateTime? nextReview,
    int? reviewCount,
    int? lapses,
  }) {
    return CardModel(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      term: term ?? this.term,
      definition: definition ?? this.definition,
      type: type ?? this.type,
      streak: streak ?? this.streak,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      nextReview: nextReview ?? this.nextReview,
      reviewCount: reviewCount ?? this.reviewCount,
      lapses: lapses ?? this.lapses,
    );
  }
}
