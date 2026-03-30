import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/models.dart';
import '../data/game_data.dart';
import '../services/game_engine.dart';

class BondTab extends StatelessWidget {
  final GameEngine engine;
  const BondTab({super.key, required this.engine});

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'Mythic': return const Color(0xFFFFD700);
      case 'Legendary': return const Color(0xFF9C27B0);
      case 'Rookie': return const Color(0xFF2196F3);
      case 'Normal': return const Color(0xFF4CAF50);
      default: return const Color(0xFFAAAAAA);
    }
  }

  String _effectName(String stat) {
    const map = {
      'atk': 'ATK', 'def': 'DEF', 'spd': 'SPD', 'hp': 'HP',
      'gold': '골드', 'growth': '성장', 'golden': '황금확률',
      'bossDmg': '보스뎀', 'allStat': '전스탯',
    };
    return map[stat] ?? stat;
  }

  String _allyName(String id) {
    return GameData.allies.where((a) => a.id == id).firstOrNull?.name ?? id;
  }

  String _allyRarity(String id) {
    return GameData.allies.where((a) => a.id == id).firstOrNull?.rarity ?? 'Newbie';
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final ownedIds = gs.allies.map((a) => a.id).toSet();
    final bonuses = engine.getBondBonuses();

    // Separate active vs inactive bonds
    final activeBonds = <BondData>[];
    final inactiveBonds = <BondData>[];
    for (final bond in GameData.bonds) {
      if (bond.unitIds.every((id) => ownedIds.contains(id))) {
        activeBonds.add(bond);
      } else {
        inactiveBonds.add(bond);
      }
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        // Active bonuses summary
        const Text('🤝 인연 보너스', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        Text('활성: ${activeBonds.length}/${GameData.bonds.length}',
          style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 11)),
        if (bonuses.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xFF1a1a2e), borderRadius: BorderRadius.circular(4)),
            child: Wrap(spacing: 8, runSpacing: 4, children: bonuses.entries.map((e) =>
              Text('${_effectName(e.key)} +${(e.value * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 10))).toList()),
          ),
        ],
        const SizedBox(height: 10),

        // Active bonds
        if (activeBonds.isNotEmpty) ...[
          const Text('✅ 활성 인연', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...activeBonds.map((bond) => _bondCard(gs, bond, true)),
          const SizedBox(height: 10),
        ],

        // Inactive bonds
        const Text('🔒 미활성 인연', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        ...inactiveBonds.map((bond) => _bondCard(gs, bond, false)),
      ],
    );
  }

  Widget _bondCard(GameState gs, BondData bond, bool active) {
    final ownedIds = gs.allies.map((a) => a.id).toSet();

    // Calculate bond level
    int bondLevel = 0;
    if (active) {
      int minAwaken = 999;
      for (final uid in bond.unitIds) {
        final ally = gs.allies.firstWhere((a) => a.id == uid);
        if (ally.awakening < minAwaken) minAwaken = ally.awakening;
      }
      bondLevel = minAwaken + 1;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF0d1117) : const Color(0xFF0a0a10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: active ? const Color(0xFF4CAF50).withValues(alpha: 0.4) : const Color(0xFF222222)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Text(bond.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(bond.name, style: TextStyle(
            color: active ? Colors.white : Colors.white38,
            fontSize: 12, fontWeight: FontWeight.bold)),
          if (active) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3)),
              child: Text('Lv.$bondLevel', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ],
          const Spacer(),
          Text('${bond.unitIds.length}유닛', style: const TextStyle(color: Colors.white38, fontSize: 9)),
        ]),
        const SizedBox(height: 4),
        // Units
        Wrap(spacing: 4, runSpacing: 2, children: bond.unitIds.map((uid) {
          final owned = ownedIds.contains(uid);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: owned ? _rarityColor(_allyRarity(uid)).withValues(alpha: 0.15) : const Color(0xFF1a1a1a),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: owned ? _rarityColor(_allyRarity(uid)).withValues(alpha: 0.4) : const Color(0xFF333333))),
            child: Text(owned ? _allyName(uid) : '???',
              style: TextStyle(
                color: owned ? _rarityColor(_allyRarity(uid)) : Colors.white24,
                fontSize: 9)),
          );
        }).toList()),
        const SizedBox(height: 4),
        // Effects
        Row(children: bond.effects.map((eff) =>
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '${_effectName(eff.stat)} +${(eff.perLevel * (active ? bondLevel : 1) * 100).toStringAsFixed(0)}%${active ? '' : ' /lv'}',
              style: TextStyle(
                color: active ? const Color(0xFF4CAF50) : Colors.white24,
                fontSize: 9, fontWeight: FontWeight.bold)),
          )).toList()),
      ]),
    );
  }
}
