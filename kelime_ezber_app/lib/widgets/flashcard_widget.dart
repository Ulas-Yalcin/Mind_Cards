// lib/widgets/flashcard_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/flashcard_model.dart';
import '../utils/theme_helper.dart';

class FlashcardWidget extends StatefulWidget {
  final Flashcard card;
  const FlashcardWidget({super.key, required this.card});

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool showDefinition = false;

  // --- BU FONKSİYON YENİ ---
  // Kart verisi değiştiğinde (kaydırıldığında) otomatik olarak ön yüze dön
  @override
  void didUpdateWidget(covariant FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.id != widget.card.id) {
      setState(() {
        showDefinition = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor = widget.card.language == Language.german
        ? ThemeHelper.getArticleColor(widget.card.article)
        : const Color(0xFF3B82F6);

    return GestureDetector(
      onTap: () => setState(() => showDefinition = !showDefinition),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accentColor.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              showDefinition ? widget.card.definition : widget.card.term,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: showDefinition
                    ? const Color(0xFF4B5563)
                    : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
