import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../services/game_engine.dart';
import '../data/game_data.dart';

class EggTab extends StatelessWidget {
  final GameEngine engine;

  const EggTab({super.key, required this.engine});

  static const _tierKeys = ['bronze', 'silver', 'gold', 'ruby', 'diamond'];
  static const _tierNames = ['브론즈', '실버', '골드', '루비', '다이아'];
  static const _tierColors = [
    Color(0xFFCD7F32),
    Color(0xFFC0C0C0),
    Color(0xFFFFD700),
    Color(0xFFFF1744),
    Color(0xFF00BFFF),
  ];

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'Mythic':
        return const Color(0xFFFFD700);
      case 'Legendary':
        return const Color(0xFF9C27B0);
      case 'Rookie':
        return const Color(0xFF2196F3);
      case 'Normal':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFFAAAAAA);
    }
  }

  static String _rarityName(String rarity) {
    const map = {
      'Mythic': '신화',
      'Legendary': '전설',
      'Rookie': '루키',
      'Normal': '일반',
    };
    return map[rarity] ?? rarity;
  }

  static String _tierDisplayName(String tier) {
    const map = {
      'bronze': '브론즈',
      'silver': '실버',
      'gold': '골드',
      'ruby': '루비',
      'diamond': '다이아',
    };
    return map[tier] ?? tier;
  }

  String _formatTime(double seconds) {
    final total = seconds.toInt();
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final eggFragments = gs.materials['eggFragment'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            '\uD83E\uDD5A \uC54C \uBD80\uD654\uC2E4',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\uC54C \uC870\uAC01: $eggFragments',
            style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13),
          ),
          const SizedBox(height: 12),

          // 5 egg tier cards
          SizedBox(
            height: 110,
            child: Row(
              children: List.generate(5, (i) {
                final tierKey = _tierKeys[i];
                final eggTier = GameData.eggTiers[tierKey];
                final cost = eggTier?.cost ?? 0;
                final canAfford = gs.gold >= cost;

                return Expanded(
                  child: Card(
                    color: const Color(0xFF0d1117),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: _tierColors[i].withValues(alpha: 0.5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '\uD83E\uDD5A',
                            style: TextStyle(
                              fontSize: 22,
                              shadows: [
                                Shadow(
                                  color: _tierColors[i],
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tierNames[i],
                            style: TextStyle(
                              color: _tierColors[i],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$cost G',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 20,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: canAfford
                                  ? () => engine.buyEgg(tierKey)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: canAfford
                                    ? _tierColors[i].withValues(alpha: 0.6)
                                    : const Color(0xFF333333),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Text(
                                '\uAD6C\uB9E4',
                                style: TextStyle(fontSize: 9, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // Incubation slots
          const Text(
            '\uD83D\uDD25 \uBD80\uD654 \uC2AC\uB86F',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          if (gs.eggs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0d1117),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: const Text(
                '\uBD80\uD654 \uC911\uC778 \uC54C\uC774 \uC5C6\uC2B5\uB2C8\uB2E4.\n\uC54C\uC744 \uAD6C\uB9E4\uD574\uBCF4\uC138\uC694!',
                style: TextStyle(color: Colors.white38, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),

          ...gs.eggs.asMap().entries.map((entry) {
            final idx = entry.key;
            final egg = entry.value;
            final progress = egg.totalTime > 0
                ? ((egg.totalTime - egg.timeLeft) / egg.totalTime).clamp(0.0, 1.0)
                : 0.0;

            return Card(
              color: const Color(0xFF0d1117),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: egg.ready
                      ? const Color(0xFFFFD700)
                      : const Color(0xFF333333),
                ),
              ),
              child: ListTile(
                leading: Text(
                  egg.ready ? '\uD83D\uDC23' : '\uD83E\uDD5A',
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  '${_tierDisplayName(egg.tier)} \uC54C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFF333333),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          egg.ready
                              ? const Color(0xFFFFD700)
                              : const Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      egg.ready
                          ? '\uBD80\uD654 \uC644\uB8CC!'
                          : '\uB0A8\uC740 \uC2DC\uAC04: ${_formatTime(egg.timeLeft)}',
                      style: TextStyle(
                        color: egg.ready ? const Color(0xFFFFD700) : Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                trailing: egg.ready
                    ? ElevatedButton(
                        onPressed: () => engine.hatchEgg(idx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text('\uBD80\uD654', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    : null,
              ),
            );
          }),

          const SizedBox(height: 16),

          // Fragment exchange
          const Text(
            '\uD83D\uDD04 \uC870\uAC01 \uAD50\uD658',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: const Color(0xFF0d1117),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFF333333)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ListTile(
                    dense: true,
                    leading: const Text('\uD83D\uDCB0', style: TextStyle(fontSize: 20)),
                    title: const Text(
                      '\uACE8\uB4DC \u2192 \uC54C \uC870\uAC01',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    subtitle: const Text(
                      '500 \uACE8\uB4DC = 50 \uC870\uAC01',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    trailing: ElevatedButton(
                      onPressed: gs.gold >= 500
                          ? () {
                              gs.gold -= 500;
                              gs.materials['eggFragment'] = (gs.materials['eggFragment'] ?? 0) + 50;
                              gs.notify();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('\uAD50\uD658', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const Divider(color: Color(0xFF333333), height: 16),
                  const Text(
                    '\uD83E\uDD5A \uC54C \uC870\uAC01\uC73C\uB85C \uC54C \uAD6C\uB9E4',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(5, (i) {
                    final tierKey = _tierKeys[i];
                    final fragmentCost = [50, 150, 400, 1000, 3000][i];
                    final frags = gs.materials['eggFragment'] ?? 0;
                    final canExchange = frags >= fragmentCost && gs.eggs.length < gs.maxEggSlots;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text(
                            ['\uD83E\uDD4E', '\u26AA', '\uD83D\uDFE1', '\uD83D\uDD34', '\uD83D\uDD35'][i],
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${_tierNames[i]} ($fragmentCost \uC870\uAC01)',
                              style: const TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: canExchange
                                ? () {
                                    gs.materials['eggFragment'] = frags - fragmentCost;
                                    engine.exchangeEgg(tierKey);
                                    gs.notify();
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canExchange ? _tierColors[i] : const Color(0xFF333333),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            ),
                            child: const Text('\uAD50\uD658', style: TextStyle(fontSize: 10)),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
