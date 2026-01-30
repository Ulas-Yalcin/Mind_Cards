// lib/models/flashcard_model.dart

enum Language { english, german }

class Flashcard {
  final String id;
  final String term;
  final String definition;
  final Language language;
  final String? category;
  final String? article;

  Flashcard({
    required this.id,
    required this.term,
    required this.definition,
    required this.language,
    this.category,
    this.article,
  });

  // 1. Veritabanına kaydetmek için nesneyi Map'e çevirir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'term': term,
      'definition': definition,
      'language': language.name, // Enum'ı yazı olarak kaydet (english/german)
      'category': category,
      'article': article,
    };
  }

  // 2. Veritabanından okurken Map'i nesneye çevirir
  factory Flashcard.fromMap(Map<dynamic, dynamic> map) {
    return Flashcard(
      id: map['id'] ?? '',
      term: map['term'] ?? '',
      definition: map['definition'] ?? '',
      // Yazıyı tekrar Enum'a çevir
      language: map['language'] == 'german'
          ? Language.german
          : Language.english,
      category: map['category'],
      article: map['article'],
    );
  }
}
