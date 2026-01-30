// lib/screens/german/german_deck_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../providers/game_provider.dart';
import '../../models/flashcard_model.dart';
import '../../widgets/flashcard_widget.dart';
import '../../widgets/swipe_counter_widget.dart';

class GermanDeckScreen extends StatelessWidget {
  final String categoryName;

  const GermanDeckScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final currentCards = provider.getCards(
      Language.german,
      category: categoryName,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.shuffle_rounded, color: Colors.redAccent),
              tooltip: "Kartları Karıştır",
              onPressed: () {
                provider.resetGame();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Kartlar karıştırıldı!"),
                    duration: Duration(milliseconds: 800),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SwipeCounterWidget(),
          Expanded(
            child: currentCards.isEmpty
                ? _buildEmptyState()
                : CardSwiper(
                    cardsCount: currentCards.length,
                    cardBuilder: (context, index, x, y) {
                      return FlashcardWidget(card: currentCards[index]);
                    },
                    onSwipe: (prev, current, direction) {
                      bool isRight = direction == CardSwiperDirection.right;
                      provider.onCardSwiped(isRight);
                      return true;
                    },
                    onEnd: () => _showCompletionDialog(context, provider),
                  ),
          ),
          const SizedBox(height: 50),
        ],
      ),
      // --- GÜNCELLENEN BUTON ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // 1. İşlemi Bekle (Kategori bilgisiyle beraber)
          int addedCount = await provider.loadFromFile(
            Language.german,
            targetCategory: categoryName,
          );

          // 2. Mesaj Göster
          if (context.mounted) {
            if (addedCount > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "$addedCount yeni kelime $categoryName kategorisine eklendi!",
                  ),
                  backgroundColor: Colors.green, // Başarılı
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Yeni kelime eklenmedi (Dosyadakiler zaten mevcut).",
                  ),
                  backgroundColor: Colors.orange, // Uyarı
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        label: const Text("Bu Kategoriye Kelime Yükle"),
        icon: const Icon(Icons.upload_file),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, GameProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 60),
            SizedBox(height: 10),
            Text("Tebrikler!"),
          ],
        ),
        content: const Text(
          "Bu kategorideki bütün kartları gördünüz.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              "Kategorilere Dön",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.resetGame();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text(
              "Tekrar Başlat",
              style: TextStyle(color: Colors.white),
            ),
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
          Text(
            "Bu kategoride henüz kelime yok.",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "Dosya yükleyerek başlayın 👇",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
