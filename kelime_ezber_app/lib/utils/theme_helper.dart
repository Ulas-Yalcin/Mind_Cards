// lib/utils/theme_helper.dart
import 'package:flutter/material.dart';

class ThemeHelper {
  static Color getArticleColor(String? article) {
    // Eğer artikel bilgisi yoksa (null) veya boşsa -> SİYAH (Koyu Gri) döndür
    if (article == null || article.isEmpty) {
      return const Color(0xFF333333); // Siyah (Koyu Gri) - Fiiller vb. için
    }

    // Artikel varsa rengini seç
    switch (article.toLowerCase()) {
      case 'der':
        return Colors.blueAccent; // Mavi
      case 'die':
        return Colors.redAccent; // Kırmızı
      case 'das':
        return Colors.green; // Yeşil
      default:
        return const Color(
          0xFF333333,
        ); // Tanınmayan bir durum olursa yine Siyah
    }
  }
}
