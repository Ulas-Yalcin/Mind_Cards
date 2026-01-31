// lib/screens/german/german_deck_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../providers/game_provider.dart';
import '../../models/flashcard_model.dart';
import '../../widgets/flashcard_widget.dart';
import '../../widgets/swipe_counter_widget.dart';
import '../../utils/theme_helper.dart'; // Renkleri listede göstermek için

class GermanDeckScreen extends StatefulWidget {
  final String categoryName;
  const GermanDeckScreen({super.key, required this.categoryName});

  @override
  State<GermanDeckScreen> createState() => _GermanDeckScreenState();
}

class _GermanDeckScreenState extends State<GermanDeckScreen> {
  bool isGameMode = false;
  Set<String> selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final currentCards = provider.getCards(
      Language.german,
      category: widget.categoryName,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(
          isGameMode
              ? widget.categoryName
              : (selectedIds.isNotEmpty
                    ? "${selectedIds.length} Seçildi"
                    : widget.categoryName),
        ),
        backgroundColor: selectedIds.isNotEmpty
            ? Colors.redAccent
            : Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                provider.deleteFlashcards(selectedIds.toList());
                setState(() => selectedIds.clear());
              },
            )
          else if (!isGameMode)
            IconButton(
              icon: const Icon(
                Icons.play_circle_filled,
                size: 32,
                color: Colors.redAccent,
              ),
              onPressed: () {
                if (currentCards.isEmpty) return;
                provider.resetGame();
                setState(() => isGameMode = true);
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.list, size: 32, color: Colors.redAccent),
              onPressed: () => setState(() => isGameMode = false),
            ),
        ],
      ),
      body: isGameMode
          ? _buildGameView(currentCards, provider)
          : _buildListView(currentCards, provider),

      floatingActionButton: !isGameMode && selectedIds.isEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                int added = await provider.loadFromFile(
                  Language.german,
                  targetCategory: widget.categoryName,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        added > 0
                            ? "$added kelime eklendi!"
                            : "Eklenecek yeni kelime yok.",
                      ),
                      backgroundColor: added > 0 ? Colors.green : Colors.orange,
                    ),
                  );
                }
              },
              label: const Text("Dosya Yükle"),
              icon: const Icon(Icons.upload_file),
              backgroundColor: Colors.redAccent,
            )
          : null,
    );
  }

  Widget _buildListView(List<Flashcard> cards, GameProvider provider) {
    if (cards.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        final isSelected = selectedIds.contains(card.id);

        // Listede de Almanca renklerini gösterelim
        Color articleColor = ThemeHelper.getArticleColor(card.article);

        return Card(
          color: isSelected ? Colors.red.shade50 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            // Seçili değilse sol tarafına artikel renginde çizgi koyalım
            side: isSelected
                ? const BorderSide(color: Colors.red, width: 2)
                : BorderSide.none,
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              // Sol tarafa renkli şerit
              border: isSelected
                  ? null
                  : Border(left: BorderSide(color: articleColor, width: 6)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                card.term,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                card.definition,
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.red)
                  : const Icon(Icons.edit, color: Colors.grey),
              onLongPress: () => setState(() => selectedIds.add(card.id)),
              onTap: () {
                if (selectedIds.isNotEmpty) {
                  setState(() {
                    if (isSelected)
                      selectedIds.remove(card.id);
                    else
                      selectedIds.add(card.id);
                  });
                } else {
                  _showEditDialog(context, provider, card);
                }
              },
            ),
          ),
        );
      },
    );
  }

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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text(
                        "Tekrar Oyna",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

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
        title: const Text("Kelimeyi Düzenle"),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Kaydet", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.style, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Bu kategoride kelime yok.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "Dosya yükle butonuna bas 👇",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
