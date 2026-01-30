// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '../english/english_deck_screen.dart';
import '../german/german_category_screen.dart'; // Yeni import

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Flashcard Master"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuButton(
              context,
              "🇬🇧 İngilizce Çalış",
              Colors.blue.shade600,
              const EnglishDeckScreen(),
            ),
            const SizedBox(height: 20),
            // Burası artık kategori ekranına gidiyor
            _buildMenuButton(
              context,
              "🇩🇪 Almanca Çalış",
              Colors.redAccent.shade400,
              const GermanCategoryScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    Color color,
    Widget page,
  ) {
    return SizedBox(
      width: 280,
      height: 70,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 8,
          shadowColor: color.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
