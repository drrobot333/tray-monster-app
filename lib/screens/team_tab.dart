import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../services/game_engine.dart';

class TeamTab extends StatelessWidget {
  final GameEngine engine;

  const TeamTab({super.key, required this.engine});

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

  String _roleEmoji(String role) {
    switch (role) {
      case 'tank':
        return '\uD83D\uDEE1\uFE0F';
      case 'dps':
        return '\u2694\uFE0F';
      case 'healer':
        return '\uD83D\uDC9A';
      case 'support':
        return '\u2728';
      default:
        return '\uD83D\uDC64';
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'tank':
        return '\uD0F1\uCEE4';
      case 'dps':
        return '\uB518\uB7EC';
      case 'healer':
        return '\uD790\uB7EC';
      case 'support':
        return '\uC11C\uD3EC\uD130';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final allies = gs.allies;
    final team = gs.team; // List<int> - indices into allies

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                '\uD83D\uDC65 \uD300 \uD3B8\uC131',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0d1117),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: Text(
                  '${team.length}/5',
                  style: TextStyle(
                    color: team.length >= 5
                        ? const Color(0xFFFF5252)
                        : const Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Team display
          if (team.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0d1117),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  ...team.map((allyIdx) {
                    if (allyIdx < 0 || allyIdx >= allies.length) {
                      return const Expanded(child: SizedBox.shrink());
                    }
                    final ally = allies[allyIdx];
                    return Expanded(
                      child: Column(
                        children: [
                          Text(_roleEmoji(ally.role), style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 2),
                          Text(
                            ally.name,
                            style: TextStyle(
                              color: _rarityColor(ally.rarity),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }),
                  // Empty slots
                  ...List.generate(5 - team.length, (_) {
                    return Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF333333)),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text('+', style: TextStyle(color: Colors.white24, fontSize: 16)),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '\uBE48 \uC790\uB9AC',
                            style: TextStyle(color: Colors.white24, fontSize: 9),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Ally list
          Expanded(
            child: allies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('\uD83E\uDD5A', style: TextStyle(fontSize: 40)),
                        SizedBox(height: 12),
                        Text(
                          '\uC544\uC9C1 \uC544\uAD70\uC774 \uC5C6\uC2B5\uB2C8\uB2E4.\n\uC54C\uC744 \uBD80\uD654\uD574\uBCF4\uC138\uC694!',
                          style: TextStyle(color: Colors.white38, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: allies.length,
                    itemBuilder: (context, i) {
                      final ally = allies[i];
                      final isInTeam = team.contains(i);

                      return Card(
                        color: const Color(0xFF0d1117),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isInTeam
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFF333333),
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            if (isInTeam) {
                              gs.team.remove(i);
                            } else if (team.length < 5) {
                              gs.team.add(i);
                            } else {
                              gs.notification = '팀이 가득 찼습니다! (최대 5명)';
                              gs.notificationTimer = 3;
                            }
                            gs.notify();
                          },
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_roleEmoji(ally.role), style: const TextStyle(fontSize: 22)),
                              Text(
                                _roleLabel(ally.role),
                                style: const TextStyle(color: Colors.white54, fontSize: 9),
                              ),
                            ],
                          ),
                          title: Row(
                            children: [
                              Text(
                                ally.name,
                                style: TextStyle(
                                  color: _rarityColor(ally.rarity),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: _rarityColor(ally.rarity).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  ally.rarity,
                                  style: TextStyle(
                                    color: _rarityColor(ally.rarity),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Text(
                                  'Lv.${ally.level}',
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _statChip('\u2694', '${ally.atk}', const Color(0xFFFF5252)),
                                const SizedBox(width: 6),
                                _statChip('\uD83D\uDEE1', '${ally.def}', const Color(0xFF2196F3)),
                                const SizedBox(width: 6),
                                _statChip('\u26A1', '${ally.spd}', const Color(0xFFFFD700)),
                                const SizedBox(width: 6),
                                _statChip('\u2764', '${ally.hp}', const Color(0xFF4CAF50)),
                              ],
                            ),
                          ),
                          trailing: isInTeam
                              ? const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24)
                              : team.length < 5
                                  ? const Icon(Icons.add_circle_outline, color: Colors.white24, size: 24)
                                  : const Icon(Icons.block, color: Colors.white12, size: 24),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: TextStyle(fontSize: 10, color: color)),
        const SizedBox(width: 2),
        Text(value, style: TextStyle(color: color, fontSize: 10)),
      ],
    );
  }
}
