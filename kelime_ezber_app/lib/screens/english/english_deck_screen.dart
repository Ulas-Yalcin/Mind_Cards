// lib/screens/english/english_deck_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../providers/game_provider.dart';
import '../../models/flashcard_model.dart';
import '../../widgets/flashcard_widget.dart';
import '../../widgets/swipe_counter_widget.dart';

class EnglishDeckScreen extends StatelessWidget {
  const EnglishDeckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final englishCards = provider.getCards(Language.english);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          "İngilizce Kelimeler",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle_rounded, color: Colors.white),
            tooltip: "Kartları Karıştır",
            onPressed: () {
              provider.resetGame();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Kartlar karıştırıldı!"),
                  duration: Duration(milliseconds: 800),
                  backgroundColor: Colors.blueAccent,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SwipeCounterWidget(),
          Expanded(
            child: englishCards.isEmpty
                ? _buildEmptyState(context, provider)
                : CardSwiper(
                    cardsCount: englishCards.length,
                    cardBuilder: (context, index, x, y) {
                      return FlashcardWidget(card: englishCards[index]);
                    },
                    onSwipe: (prev, current, direction) {
                      bool isRight = direction == CardSwiperDirection.right;
                      provider.onCardSwiped(isRight);
                      return true;
                    },
                    onEnd: () => _showCompletionDialog(context, provider),
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      // --- GÜNCELLENEN BUTON ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // 1. İşlemi Bekle ve Sonucu Al
          int addedCount = await provider.loadFromFile(Language.english);

          // 2. Eğer ekran hala açıksa mesaj göster
          if (context.mounted) {
            if (addedCount > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$addedCount yeni kelime başarıyla eklendi!"),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Yeni kelime eklenmedi (Dosyadakiler zaten mevcut).",
                  ),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        label: const Text("Dosya Yükle"),
        icon: const Icon(Icons.upload_file),
        backgroundColor: Colors.blueAccent,
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
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text("Harika İş!"),
          ],
        ),
        content: const Text(
          "Bütün kartları gördünüz.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Çıkış", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.resetGame();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: const Text(
              "Tekrar Başlat",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, GameProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_none, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            "Henüz kart yok.",
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => provider.addManualFlashcard("Hello", "Merhaba"),
            child: const Text("Örnek Kart Ekle"),
          ),
        ],
      ),
    );
  }
}
