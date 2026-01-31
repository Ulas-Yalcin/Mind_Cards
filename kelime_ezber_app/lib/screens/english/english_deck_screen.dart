// lib/screens/english/english_deck_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../providers/game_provider.dart';
import '../../models/flashcard_model.dart';
import '../../widgets/flashcard_widget.dart';
import '../../widgets/swipe_counter_widget.dart';

class EnglishDeckScreen extends StatefulWidget {
  const EnglishDeckScreen({super.key});

  @override
  State<EnglishDeckScreen> createState() => _EnglishDeckScreenState();
}

class _EnglishDeckScreenState extends State<EnglishDeckScreen> {
  bool isGameMode = false; // Başlangıçta LİSTE modu
  Set<String> selectedIds = {}; // Seçilen kartların ID'leri

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final englishCards = provider.getCards(Language.english);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(
          isGameMode
              ? "İngilizce (Oyun)"
              : (selectedIds.isEmpty
                    ? "İngilizce Kelimeler"
                    : "${selectedIds.length} Seçildi"),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: selectedIds.isNotEmpty
            ? Colors.redAccent
            : Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          // Eğer seçim varsa "Sil" butonu göster
          if (selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                provider.deleteFlashcards(selectedIds.toList());
                setState(() => selectedIds.clear());
              },
            )
          else
          // Seçim yoksa ve Liste modundaysak "Oyna" butonu göster
          if (!isGameMode)
            IconButton(
              icon: const Icon(Icons.play_circle_filled, size: 32),
              tooltip: "Başlat / Karıştır",
              onPressed: () {
                if (englishCards.isEmpty) return;
                provider.resetGame();
                setState(() => isGameMode = true);
              },
            )
          else
            // Oyun modundaysak "Listeye Dön" butonu
            IconButton(
              icon: const Icon(Icons.list, size: 32),
              tooltip: "Listeye Dön",
              onPressed: () => setState(() => isGameMode = false),
            ),
        ],
      ),
      body: isGameMode
          ? _buildGameView(englishCards, provider)
          : _buildListView(englishCards, provider),

      // Sadece Liste modunda dosya yükleme butonu görünsün
      floatingActionButton: !isGameMode && selectedIds.isEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                int added = await provider.loadFromFile(Language.english);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        added > 0
                            ? "$added yeni kelime eklendi!"
                            : "Yeni kelime yok.",
                      ),
                      backgroundColor: added > 0 ? Colors.green : Colors.orange,
                    ),
                  );
                }
              },
              label: const Text("Dosya Yükle"),
              icon: const Icon(Icons.upload_file),
              backgroundColor: Colors.blueAccent,
            )
          : null,
    );
  }

  // --- 1. LİSTE GÖRÜNÜMÜ ---
  Widget _buildListView(List<Flashcard> cards, GameProvider provider) {
    if (cards.isEmpty) return _buildEmptyState(provider);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        final isSelected = selectedIds.contains(card.id);

        return Card(
          color: isSelected ? Colors.red.shade50 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? const BorderSide(color: Colors.red, width: 2)
                : BorderSide.none,
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              card.term,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              card.definition,
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.red)
                : const Icon(Icons.edit, color: Colors.grey),
            onLongPress: () {
              setState(() {
                selectedIds.add(card.id);
              });
            },
            onTap: () {
              if (selectedIds.isNotEmpty) {
                // Seçim modundaysak seç/bırak
                setState(() {
                  if (isSelected)
                    selectedIds.remove(card.id);
                  else
                    selectedIds.add(card.id);
                });
              } else {
                // Normal moddaysak düzenle
                _showEditDialog(context, provider, card);
              }
            },
          ),
        );
      },
    );
  }

  // --- 2. OYUN GÖRÜNÜMÜ (SWIPER) ---
  Widget _buildGameView(List<Flashcard> cards, GameProvider provider) {
    return Column(
      children: [
        const SwipeCounterWidget(),
        Expanded(
          child: CardSwiper(
            cardsCount: cards.length,
            cardBuilder: (context, index, x, y) =>
                FlashcardWidget(card: cards[index]),
            onSwipe: (prev, current, direction) {
              provider.onCardSwiped(direction == CardSwiperDirection.right);
              return true;
            },
            onEnd: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => AlertDialog(
                  title: const Text("Bitti!"),
                  content: const Text("Tüm kartları gördünüz."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() => isGameMode = false);
                      },
                      child: const Text("Listeye Dön"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        provider.resetGame();
                      },
                      child: const Text("Tekrar Oyna"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Düzenleme Penceresi
  void _showEditDialog(
    BuildContext context,
    GameProvider provider,
    Flashcard card,
  ) {
    final termCtrl = TextEditingController(text: card.term);
    final defCtrl = TextEditingController(text: card.definition);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Kartı Düzenle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: termCtrl,
              decoration: const InputDecoration(labelText: "Kelime"),
            ),
            TextField(
              controller: defCtrl,
              decoration: const InputDecoration(labelText: "Anlamı"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateFlashcard(card.id, termCtrl.text, defCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(GameProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_none, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text(
            "Liste boş.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          TextButton(
            onPressed: () => provider.addManualFlashcard("Hello", "Merhaba"),
            child: const Text("Örnek Ekle"),
          ),
        ],
      ),
    );
  }
}
