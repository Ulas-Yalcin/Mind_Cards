// lib/screens/german/german_category_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/game_provider.dart';
import 'german_deck_screen.dart';

class GermanCategoryScreen extends StatelessWidget {
  const GermanCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Açık gri modern zemin
      appBar: AppBar(
        title: Text(
          "Kategoriler",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Yan yana 2 kutu
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: provider.germanCategories.length,
          itemBuilder: (context, index) {
            final categoryName = provider.germanCategories[index];
            return _buildCategoryCard(context, categoryName);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context, provider),
        label: const Text("Kategori Ekle"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.black87,
      ),
    );
  }

  // Kategori Kartı Tasarımı
  Widget _buildCategoryCard(BuildContext context, String name) {
    return GestureDetector(
      onTap: () {
        // Tıklanınca o kategorinin içine gir
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GermanDeckScreen(categoryName: name),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 40,
              color: Colors.blueGrey[700],
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Yeni Kategori Ekleme Penceresi
  void _showAddCategoryDialog(BuildContext context, GameProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Yeni Kategori"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Örn: Fiiller, Eşyalar...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.addCategory(controller.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
            child: const Text("Ekle", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
