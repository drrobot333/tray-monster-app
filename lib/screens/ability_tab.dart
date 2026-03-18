import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/models.dart';
import '../services/game_engine.dart';

class AbilityTab extends StatelessWidget {
  final GameEngine engine;
  const AbilityTab({super.key, required this.engine});

  Color _gradeColor(String g) {
    switch (g) {
      case 'Legendary': return const Color(0xFFFFD700);
      case 'Epic': return const Color(0xFF9C27B0);
      case 'Rare': return const Color(0xFF2196F3);
      default: return const Color(0xFFAAAAAA);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final ab = gs.ability;
    final needed = ab.promotionRerollsNeeded;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Header
        Row(children: [
          const Text('⭐ 어빌리티', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _gradeColor(ab.tier).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _gradeColor(ab.tier)),
            ),
            child: Text(ab.tier, style: TextStyle(color: _gradeColor(ab.tier), fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 4),

        // Progress to promotion
        if (needed != null) ...[
          Row(children: [
            Text('승급까지: ${ab.rerollCount}/$needed',
              style: const TextStyle(color: Colors.white54, fontSize: 10)),
            const Spacer(),
            if (ab.canPromote)
              GestureDetector(
                onTap: () => engine.promoteAbility(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFFFD700)),
                  ),
                  child: Text('→ ${ab.nextTier} 승급!',
                    style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
          ]),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (ab.rerollCount / needed).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFF333333),
              valueColor: AlwaysStoppedAnimation(ab.canPromote ? const Color(0xFFFFD700) : const Color(0xFF4CAF50)),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Slot selector (1~5)
        Row(children: List.generate(5, (i) {
          final isViewing = ab.viewingSlot == i;
          final isActive = ab.activeSlot == i;
          return Expanded(child: GestureDetector(
            onTap: () { engine.viewAbilitySlot(i); gs.notify(); },
            child: Container(
              margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isViewing ? const Color(0xFF4CAF50).withValues(alpha: 0.2) : const Color(0xFF0d1117),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isActive ? const Color(0xFFFFD700) : isViewing ? const Color(0xFF4CAF50) : const Color(0xFF333333),
                  width: isActive ? 2 : 1),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${i + 1}', style: TextStyle(color: isViewing ? Colors.white : Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                if (isActive) const Text('적용중', style: TextStyle(color: Color(0xFFFFD700), fontSize: 7)),
              ]),
            ),
          ));
        })),
        const SizedBox(height: 4),
        // Apply button
        if (ab.viewingSlot != ab.activeSlot)
          GestureDetector(
            onTap: () => engine.activateAbilitySlot(ab.viewingSlot),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFFD700)),
              ),
              child: const Text('이 슬롯 적용하기', textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        // 3 Ability Lines (of viewing slot)
        ...List.generate(3, (i) {
          final line = ab.viewingLines[i];
          final name = engine.abilityOptionName(line.optionId);
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: line.locked
                ? const Color(0xFF2a2a1a)
                : _gradeColor(line.grade).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: line.locked ? const Color(0xFFFF9800) : _gradeColor(line.grade).withValues(alpha: 0.4),
                width: line.locked ? 2 : 1),
            ),
            child: Row(children: [
              // Lock button
              GestureDetector(
                onTap: () { engine.toggleAbilityLock(i); gs.notify(); },
                child: Text(line.locked ? '🔒' : '🔓',
                  style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              // Grade badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: _gradeColor(line.grade).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4)),
                child: Text(line.grade,
                  style: TextStyle(color: _gradeColor(line.grade), fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              // Option
              Expanded(child: Text('$name +${line.value}%',
                style: TextStyle(color: _gradeColor(line.grade), fontSize: 14, fontWeight: FontWeight.bold))),
            ]),
          );
        }),
        const SizedBox(height: 8),

        // Reroll button
        GestureDetector(
          onTap: () => engine.rerollAbility(),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: gs.gold >= ab.rerollGoldCost
                ? const Color(0xFF4CAF50).withValues(alpha: 0.3) : const Color(0xFF222222),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: gs.gold >= ab.rerollGoldCost
                ? const Color(0xFF4CAF50) : const Color(0xFF333333)),
            ),
            child: Column(children: [
              Text('🎲 리롤', style: TextStyle(
                color: gs.gold >= ab.rerollGoldCost ? Colors.white : Colors.white38,
                fontSize: 14, fontWeight: FontWeight.bold)),
              Text('💰${ab.rerollGoldCost}G', style: TextStyle(
                color: gs.gold >= ab.rerollGoldCost ? const Color(0xFFFFD700) : Colors.white38, fontSize: 11)),
            ]),
          ),
        ),
        const SizedBox(height: 6),
        // Lock cost info
        Text(
          '잠금 0줄: ${AbilityState.rerollCost[ab.tier]}G  |  1줄: ×2  |  2줄: ×5',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white38, fontSize: 9)),
      ],
    );
  }
}
