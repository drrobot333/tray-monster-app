import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../services/game_engine.dart';

class MissionPanel extends StatelessWidget {
  final GameEngine engine;

  const MissionPanel({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final missions = gs.missions;
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final diff = midnight.difference(now);
    final timeStr = '${diff.inHours}h ${diff.inMinutes % 60}m';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            children: [
              const Text('📋 미션',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('⏰ $timeStr',
                style: const TextStyle(color: Colors.white38, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 4),
          // 3 missions in a row
          Expanded(
            child: Row(
              children: List.generate(3, (i) {
                if (i >= missions.length) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: i > 0 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF151520),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text('--', style: TextStyle(color: Colors.white24, fontSize: 10)),
                      ),
                    ),
                  );
                }
                final m = missions[i];
                final pct = m.target > 0 ? (m.progress / m.target).clamp(0.0, 1.0) : 0.0;

                return Expanded(
                  child: GestureDetector(
                    onTap: m.completed && !m.claimed ? () => engine.claimMission(i) : null,
                    child: Container(
                      margin: EdgeInsets.only(left: i > 0 ? 4 : 0),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: m.claimed
                            ? const Color(0xFF0a0a12)
                            : m.completed
                                ? const Color(0xFF1a2e1a)
                                : const Color(0xFF151520),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: m.completed && !m.claimed
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF2a2a3a),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description
                          Text(m.desc,
                            style: TextStyle(
                              color: m.claimed ? Colors.white30 : Colors.white,
                              fontSize: 9, fontWeight: FontWeight.bold),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          // Progress bar + count
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    minHeight: 3,
                                    backgroundColor: const Color(0xFF333333),
                                    valueColor: AlwaysStoppedAnimation(
                                      m.completed ? const Color(0xFF4CAF50) : const Color(0xFF2196F3)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text('${m.progress}/${m.target}',
                                style: const TextStyle(color: Colors.white38, fontSize: 7)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          // Reward + status
                          Row(
                            children: [
                              Text(_rewardText(m.reward),
                                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 8)),
                              const Spacer(),
                              if (m.completed && !m.claimed)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    borderRadius: BorderRadius.circular(3)),
                                  child: const Text('수령',
                                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                )
                              else if (m.claimed)
                                const Text('✓', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _rewardText(Map<String, dynamic> reward) {
    final type = reward['type'] as String?;
    final amount = reward['amount'];
    if (type == 'gold') return '💰$amount';
    if (type == 'eggFragment') return '🥚$amount';
    if (type == 'material') return '⚡$amount';
    return '🎁';
  }
}
