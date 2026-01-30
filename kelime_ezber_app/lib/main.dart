// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Hive import
import 'providers/game_provider.dart';
import 'screens/home/home_screen.dart';

void main() async {
  // Flutter motorunu başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Veritabanını (Hive) başlat
  await Hive.initFlutter();

  // 'flashcards' adında bir kutu (tablo) aç
  await Hive.openBox('flashcards_box');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => GameProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flashcard App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Poppins', // Eğer font eklediysen
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
