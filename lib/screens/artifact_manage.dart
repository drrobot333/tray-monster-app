import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../services/game_engine.dart';
import '../data/game_data.dart';

class ArtifactManage extends StatelessWidget {
  final GameEngine engine;
  const ArtifactManage({super.key, required this.engine});

  String _effectName(String type) {
    const map = {
      'goldMult': '골드 수입', 'atkMult': '공격력', 'defMult': '방어력',
      'spdMult': '속도', 'hpMult': '체력', 'growthMult': '성장속도',
      'hatchMult': '부화시간 감소', 'goldenMult': '황금작물 확률',
    };
    return map[type] ?? type;
  }

  Color _rarityColor(String r) {
    switch (r) {
      case 'Mythic': return const Color(0xFFFFD700);
      case 'Legendary': return const Color(0xFF9C27B0);
      case 'Rookie': return const Color(0xFF2196F3);
      case 'Normal': return const Color(0xFF4CAF50);
      default: return const Color(0xFFAAAAAA);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        // Bonuses summary
        const Text('🔮 유물 보너스 (상시 적용)', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Builder(builder: (ctx) {
          final bonuses = engine.getArtifactBonuses();
          if (bonuses.isEmpty) return const Text('보유 유물 없음', style: TextStyle(color: Colors.white38, fontSize: 11));
          return Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xFF1a1a2e), borderRadius: BorderRadius.circular(4)),
            child: Wrap(spacing: 8, runSpacing: 4, children: bonuses.entries.map((e) =>
              Text('${_effectName(e.key)} +${(e.value * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 10))).toList()),
          );
        }),
        const SizedBox(height: 12),
        // Owned
        Text('📜 보유 유물 (${gs.ownedArtifacts.length})',
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        if (gs.ownedArtifacts.isEmpty)
          const Text('상점에서 상자를 열어 유물을 획득하세요!', style: TextStyle(color: Colors.white38, fontSize: 11)),
        ...gs.ownedArtifacts.asMap().entries.map((entry) {
          final idx = entry.key;
          final art = entry.value;
          final data = GameData.artifacts.where((a) => a.id == art.artifactId).firstOrNull;
          final upgradeCost = (300 * pow(1.5, art.level - 1)).floor();
          final canUpgrade = gs.gold >= upgradeCost && art.level < art.maxLevel;
          final promoNeeded = art.promotionDuplicatesNeeded;

          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0d1117),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _rarityColor(art.rarity).withValues(alpha: 0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(data?.emoji ?? '🔮', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(data?.name ?? art.artifactId,
                      style: TextStyle(color: _rarityColor(art.rarity), fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: _rarityColor(art.rarity).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(3)),
                      child: Text(art.rarity, style: TextStyle(color: _rarityColor(art.rarity), fontSize: 8)),
                    ),
                  ]),
                  Text('Lv.${art.level}/${art.maxLevel}  ${_effectName(data?.effectType ?? '')} +${(art.effectValue * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white54, fontSize: 10)),
                ])),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: canUpgrade ? () => engine.upgradeArtifact(idx) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: canUpgrade ? const Color(0xFF2196F3).withValues(alpha: 0.3) : const Color(0xFF222222),
                      borderRadius: BorderRadius.circular(4)),
                    child: Text(art.level >= art.maxLevel ? 'MAX' : '강화 💰$upgradeCost',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: canUpgrade ? Colors.white : Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                )),
                const SizedBox(width: 6),
                if (promoNeeded != null)
                  Expanded(child: GestureDetector(
                    onTap: art.duplicates >= promoNeeded ? () => engine.promoteArtifact(idx) : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: art.duplicates >= promoNeeded
                          ? const Color(0xFF9C27B0).withValues(alpha: 0.3) : const Color(0xFF222222),
                        borderRadius: BorderRadius.circular(4)),
                      child: Text('승급 (${art.duplicates}/$promoNeeded)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: art.duplicates >= promoNeeded ? Colors.white : Colors.white38,
                          fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  )),
              ]),
            ]),
          );
        }),
      ],
    );
  }
}
