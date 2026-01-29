class Deck {
  final int? id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final int cardCount; // Optional: For UI display

  Deck({
    this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.cardCount = 0,
  });

  // Convert Storage Map to Model
  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      cardCount: map['card_count'] ?? 0,
    );
  }

  // Convert Model to Storage Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  Deck copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    int? cardCount,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      cardCount: cardCount ?? this.cardCount,
    );
  }
}
