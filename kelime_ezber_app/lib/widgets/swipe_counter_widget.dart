// lib/widgets/swipe_counter_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class SwipeCounterWidget extends StatelessWidget {
  const SwipeCounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider'dan verileri dinliyoruz
    final provider = Provider.of<GameProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Toplam Sayaç (Sol Taraf)
          _buildCounterBox(
            label: "Toplam",
            count: provider.totalSwiped,
            color: Colors.grey,
            icon: Icons.history,
          ),

          // Doğru Sayaç (Sağ Taraf - Yeşil)
          _buildCounterBox(
            label: "Doğru",
            count: provider.correctCount,
            color: Colors.green,
            icon: Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterBox({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Column(
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(label, style: TextStyle(fontSize: 12, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
