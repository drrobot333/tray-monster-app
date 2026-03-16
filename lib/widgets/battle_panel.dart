import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../services/game_engine.dart';
import '../data/game_data.dart';
import 'sprite_widget.dart';

class BattlePanel extends StatelessWidget {
  final GameEngine engine;

  const BattlePanel({super.key, required this.engine});

  String _getBossName(int stage) {
    try {
      return GameData.bosses.firstWhere((b) => b.stage == stage).name;
    } catch (_) {
      return 'Boss';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final battle = gs.battle;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: battle.active ? _buildActiveBattle(context, gs, battle) : _buildInactive(context, gs, battle),
    );
  }

  Widget _buildInactive(BuildContext context, GameState gs, dynamic battle) {
    final bossName = _getBossName(gs.currentStage);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text(
              '\u2694\uFE0F ',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Stage ${gs.currentStage} - $bossName',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (battle.result != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: battle.result == 'win'
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                      : const Color(0xFFFF5252).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  battle.result == 'win' ? '\uD83C\uDFC6 \uC2B9\uB9AC!' : '\uD83D\uDCA5 \uD328\uBC30',
                  style: TextStyle(
                    color: battle.result == 'win'
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF5252),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => engine.startBattle(gs.currentStage),
              icon: const Icon(Icons.play_arrow, size: 16),
              label: const Text('\uC804\uD22C \uC2DC\uC791'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            if (battle.result != null)
              ElevatedButton.icon(
                onPressed: () => engine.startBattle(gs.currentStage),
                icon: const Icon(Icons.replay, size: 16),
                label: const Text('\uB2E4\uC2DC \uC2DC\uC791'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF333333),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveBattle(BuildContext context, GameState gs, dynamic battle) {
    final bossName = _getBossName(battle.stage);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Timer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Stage ${battle.stage}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.white54, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${battle.timer.toInt()}s',
                  style: TextStyle(
                    color: battle.timer < 10 ? const Color(0xFFFF5252) : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Battle field: allies vs boss
        Expanded(
          child: Row(
            children: [
              // Allies (left)
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    const Text('\uD83D\uDC65 \uC544\uAD70', style: TextStyle(color: Colors.white54, fontSize: 10)),
                    const SizedBox(height: 2),
                    Expanded(
                      child: ListView.builder(
                        itemCount: battle.allyStates.length,
                        itemBuilder: (context, i) {
                          final ally = battle.allyStates[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            child: Row(
                              children: [
                                PixelSprite(
                                  spriteId: allySpriteId(ally.id),
                                  size: 28,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ally.name,
                                        style: TextStyle(
                                          color: ally.alive ? Colors.white : Colors.white24,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: LinearProgressIndicator(
                                          value: ally.maxHp > 0
                                              ? (ally.hp / ally.maxHp).clamp(0.0, 1.0)
                                              : 0,
                                          minHeight: 4,
                                          backgroundColor: const Color(0xFF333333),
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            ally.alive
                                                ? const Color(0xFF4CAF50)
                                                : const Color(0xFF555555),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${ally.hp}',
                                  style: TextStyle(
                                    color: ally.alive ? Colors.white54 : Colors.white24,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // VS divider
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  'VS',
                  style: TextStyle(
                    color: Color(0xFFFF5252),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              // Boss (right)
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PixelSprite(
                      spriteId: bossSpriteId(battle.stage),
                      size: 52,
                      flipX: true,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bossName,
                      style: const TextStyle(
                        color: Color(0xFFFF5252),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: battle.bossMaxHp > 0
                            ? (battle.bossHp / battle.bossMaxHp).clamp(0.0, 1.0)
                            : 0,
                        minHeight: 8,
                        backgroundColor: const Color(0xFF333333),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF5252)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${battle.bossHp}/${battle.bossMaxHp}',
                      style: const TextStyle(color: Colors.white54, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Battle log
        Container(
          height: 32,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ListView.builder(
            reverse: true,
            itemCount: battle.log.length,
            itemBuilder: (context, i) {
              final logIndex = battle.log.length - 1 - i;
              return Text(
                battle.log[logIndex],
                style: const TextStyle(color: Colors.white38, fontSize: 9),
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
        ),
      ],
    );
  }

}
