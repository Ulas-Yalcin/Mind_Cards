// lib/providers/game_provider.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import '../models/flashcard_model.dart';

class GameProvider extends ChangeNotifier {
  final Box _box = Hive.box('flashcards_box');
  List<Flashcard> _allCards = [];
  // ... (Kategoriler ve değişkenler aynen kalıyor)
  List<String> _germanCategories = [
    'Teknoloji',
    'Ev Eşyaları',
    'Yiyecekler',
    'Araçlar',
    'Hayvanlar',
    'Eğitim',
    'Fiiller',
    'Sıfatlar',
  ];
  int _correctCount = 0;
  int _totalSwiped = 0;

  GameProvider() {
    _loadFromDatabase();
  }

  // Getter'lar
  List<String> get germanCategories => _germanCategories;
  int get correctCount => _correctCount;
  int get totalSwiped => _totalSwiped;

  List<Flashcard> getCards(Language lang, {String? category}) {
    return _allCards.where((card) {
      if (card.language != lang) return false;
      if (category != null) return card.category == category;
      return true;
    }).toList();
  }

  // ... (isDuplicate, loadFromDatabase, saveToDatabase, resetGame, onCardSwiped aynen kalıyor)

  bool _isDuplicate(String term, Language lang) {
    return _allCards.any(
      (card) =>
          card.language == lang &&
          card.term.toLowerCase().trim() == term.toLowerCase().trim(),
    );
  }

  void _loadFromDatabase() {
    if (_box.containsKey('cards')) {
      List<dynamic> savedData = _box.get('cards');
      _allCards = savedData.map((e) => Flashcard.fromMap(e)).toList();
      notifyListeners();
    } else {
      _loadDefaultsInitial();
    }
  }

  void _saveToDatabase() {
    List<Map<String, dynamic>> dataToSave = _allCards
        .map((c) => c.toMap())
        .toList();
    _box.put('cards', dataToSave);
  }

  void resetGame() {
    _correctCount = 0;
    _totalSwiped = 0;
    _allCards.shuffle();
    notifyListeners();
  }

  void onCardSwiped(bool isRightSwipe) {
    if (isRightSwipe) _correctCount++;
    _totalSwiped++;
    notifyListeners();
  }

  void addCategory(String categoryName) {
    if (!_germanCategories.contains(categoryName)) {
      _germanCategories.add(categoryName);
      notifyListeners();
    }
  }

  bool addManualFlashcard(String term, String definition) {
    if (_isDuplicate(term, Language.english)) return false;
    _allCards.add(
      Flashcard(
        id: DateTime.now().toString(),
        term: term,
        definition: definition,
        language: Language.english,
      ),
    );
    _saveToDatabase();
    notifyListeners();
    return true;
  }

  void _loadDefaultsInitial() {
    // ... (Eski kodlar aynen kalsın)
    List<Flashcard> defaults = [
      Flashcard(
        id: 'e1',
        term: 'Algorithm',
        definition: 'Algoritma',
        language: Language.english,
      ),
      Flashcard(
        id: 'g1',
        term: 'Der Computer',
        definition: 'Bilgisayar',
        language: Language.german,
        article: 'der',
        category: 'Teknoloji',
      ),
    ];
    for (var card in defaults) {
      if (!_isDuplicate(card.term, card.language)) _allCards.add(card);
    }
    _saveToDatabase();
    notifyListeners();
  }

  // loadFromFile fonskyionu (Word/PDF destekli hali) aynen kalsın...
  Future<int> loadFromFile(Language language, {String? targetCategory}) async {
    // ... (Önceki cevaptaki kodun aynısı buraya gelecek, yer kaplamasın diye kısaltıyorum)
    // Sadece yukarıdaki importların ve bu fonksiyonun olduğu gibi durduğundan emin ol.
    int addedCount = 0;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'docx'],
      );
      if (result != null) {
        File file = File(result.files.single.path!);
        String extension = result.files.single.extension?.toLowerCase() ?? '';
        List<String> lines = [];
        if (extension == 'txt')
          lines = await file.readAsLines(encoding: utf8);
        else if (extension == 'pdf')
          lines = await _readPdfFile(file);
        else if (extension == 'docx')
          lines = await _readDocxFile(file);

        List<Flashcard> newCards = [];
        for (String line in lines) {
          if (line.trim().isEmpty || !line.contains('=')) continue;
          List<String> parts = line.split('=');
          if (parts.length < 2) continue;
          String term = parts[0].trim();
          String definition = parts[1].trim();
          if (_isDuplicate(term, language)) continue;

          String? extractedArticle;
          if (language == Language.german) {
            final firstWord = term.split(' ').first.toLowerCase();
            if (['der', 'die', 'das'].contains(firstWord))
              extractedArticle = firstWord;
          }
          newCards.add(
            Flashcard(
              id: DateTime.now().millisecondsSinceEpoch.toString() + term,
              term: term,
              definition: definition,
              language: language,
              article: extractedArticle,
              category: targetCategory,
            ),
          );
          addedCount++;
        }
        if (newCards.isNotEmpty) {
          _allCards.addAll(newCards);
          _saveToDatabase();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Hata: $e");
    }
    return addedCount;
  }

  // Helper fonksiyonlar (PDF/Docx) aynen kalsın
  Future<List<String>> _readPdfFile(File file) async {
    try {
      final List<int> bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      String text = PdfTextExtractor(document).extractText();
      document.dispose();
      return text.split('\n');
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> _readDocxFile(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final contentFile = archive.findFile('word/document.xml');
      if (contentFile == null) return [];
      final contentXml = utf8.decode(contentFile.content);
      final document = XmlDocument.parse(contentXml);
      List<String> extractedLines = [];
      for (var paragraph in document.findAllElements('w:p')) {
        final texts = paragraph
            .findAllElements('w:t')
            .map((node) => node.text)
            .join();
        if (texts.isNotEmpty) extractedLines.add(texts);
      }
      return extractedLines;
    } catch (e) {
      return [];
    }
  }

  // --- YENİ EKLENENLER: SİLME VE GÜNCELLEME ---

  // 1. Çoklu Silme
  void deleteFlashcards(List<String> idsToDelete) {
    _allCards.removeWhere((card) => idsToDelete.contains(card.id));
    _saveToDatabase();
    notifyListeners();
  }

  // 2. Kart Düzenleme
  void updateFlashcard(String id, String newTerm, String newDefinition) {
    final index = _allCards.indexWhere((c) => c.id == id);
    if (index != -1) {
      Flashcard oldCard = _allCards[index];

      // Almanca ise yine artikel kontrolü yapalım
      String? newArticle;
      if (oldCard.language == Language.german) {
        final firstWord = newTerm.split(' ').first.toLowerCase();
        if (['der', 'die', 'das'].contains(firstWord)) newArticle = firstWord;
      }

      _allCards[index] = Flashcard(
        id: oldCard.id,
        term: newTerm,
        definition: newDefinition,
        language: oldCard.language,
        category: oldCard.category,
        article: newArticle ?? oldCard.article,
      );
      _saveToDatabase();
      notifyListeners();
    }
  }
}
