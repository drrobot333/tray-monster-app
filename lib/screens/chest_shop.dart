import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../services/game_engine.dart';
import '../data/game_data.dart';

class ChestShop extends StatelessWidget {
  final GameEngine engine;
  const ChestShop({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        const Text('📦 상자 열기', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        Text('🔑 열쇠: ${gs.keyFragments}', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11)),
        const SizedBox(height: 6),
        ...GameData.chestTiers.map((chest) {
          final canGold = gs.gold >= chest.goldCost;
          final canKey = gs.keyFragments >= chest.keyCost;
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0d1117), borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Row(children: [
              SizedBox(width: 70, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(chest.name, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                Text('유물 ${chest.artifactW}%', style: const TextStyle(color: Colors.white38, fontSize: 8)),
              ])),
              const SizedBox(width: 8),
              Expanded(child: GestureDetector(
                onTap: canGold ? () => engine.openChest(chest.id) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: canGold ? const Color(0xFF4CAF50).withValues(alpha: 0.3) : const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(4)),
                  child: Text('💰${chest.goldCost}', textAlign: TextAlign.center,
                    style: TextStyle(color: canGold ? Colors.white : Colors.white38, fontSize: 10)),
                ),
              )),
              const SizedBox(width: 6),
              Expanded(child: GestureDetector(
                onTap: canKey ? () => engine.openChest(chest.id, useKeys: true) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: canKey ? const Color(0xFFFFD700).withValues(alpha: 0.3) : const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(4)),
                  child: Text('🔑${chest.keyCost}', textAlign: TextAlign.center,
                    style: TextStyle(color: canKey ? Colors.white : Colors.white38, fontSize: 10)),
                ),
              )),
            ]),
          );
        }),
      ],
    );
  }
}
