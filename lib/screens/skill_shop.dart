import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../services/game_engine.dart';
import '../data/game_data.dart';

class SkillShop extends StatelessWidget {
  final GameEngine engine;
  const SkillShop({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        const Text('🔓 스킬 상점', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...GameData.skills.map((skill) {
          final owned = gs.skills.contains(skill.id);
          final canBuy = gs.gold >= skill.cost;
          final requirementMet = skill.requires == null || gs.skills.contains(skill.requires);
          return Card(
            color: const Color(0xFF0d1117),
            child: ListTile(
              dense: true,
              leading: Icon(
                owned ? Icons.check_circle : requirementMet ? Icons.lock_open : Icons.lock,
                color: owned ? const Color(0xFF4CAF50) : Colors.white38, size: 18),
              title: Text(skill.name,
                style: TextStyle(color: owned ? const Color(0xFF4CAF50) : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(skill.desc, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                if (skill.requires != null && !requirementMet)
                  Text('필요: ${GameData.skills.where((s) => s.id == skill.requires).firstOrNull?.name ?? skill.requires}',
                    style: const TextStyle(color: Color(0xFFFF5252), fontSize: 10)),
              ]),
              trailing: owned
                ? const Text('보유', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 11))
                : ElevatedButton(
                    onPressed: canBuy && requirementMet ? () => engine.buySkill(skill.id) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canBuy && requirementMet ? const Color(0xFF4CAF50) : const Color(0xFF333333),
                      padding: const EdgeInsets.symmetric(horizontal: 12)),
                    child: Text('💰${skill.cost}', style: const TextStyle(fontSize: 11)),
                  ),
            ),
          );
        }),
      ],
    );
  }
}
