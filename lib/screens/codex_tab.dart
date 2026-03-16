import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../data/game_data.dart';

class CodexTab extends StatelessWidget {
  const CodexTab({super.key});

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

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();

    final allAllyIds = GameData.allies.map((a) => a.id).toList();
    final allCropIds = GameData.crops.map((c) => c.id).toList();
    final allBossIds = GameData.bosses.map((b) => b.id).toList();

    final allyTotal = allAllyIds.length;
    final allyCollected = gs.codexAllies.length;
    final cropTotal = allCropIds.length;
    final cropCollected = gs.codexCrops.length;
    final bossTotal = allBossIds.length;
    final bossDefeated = gs.codexBosses.length;

    final totalItems = allyTotal + cropTotal + bossTotal;
    final totalCollected = allyCollected + cropCollected + bossDefeated;
    final overallProgress = totalItems > 0 ? totalCollected / totalItems : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            '\uD83D\uDCD6 \uB3C4\uAC10',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Overall progress
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '\uC218\uC9D1 \uC9C4\uD589\uB960',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$totalCollected / $totalItems',
                        style: const TextStyle(color: Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: overallProgress,
                      minHeight: 10,
                      backgroundColor: const Color(0xFF333333),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(overallProgress * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Ally collection
          _sectionTitle('\uD83D\uDC65 \uC544\uAD70 \uB3C4\uAC10', '$allyCollected/$allyTotal'),
          const SizedBox(height: 8),
          _buildGrid(
            context,
            allIds: allAllyIds,
            collectedIds: gs.codexAllies,
            getName: (id) {
              try {
                return GameData.allies.firstWhere((a) => a.id == id).name;
              } catch (_) {
                return id;
              }
            },
            getRarity: (id) {
              try {
                return GameData.allies.firstWhere((a) => a.id == id).rarity;
              } catch (_) {
                return 'Normal';
              }
            },
          ),

          const SizedBox(height: 16),

          // Crop collection
          _sectionTitle('\uD83C\uDF3E \uC791\uBB3C \uB3C4\uAC10', '$cropCollected/$cropTotal'),
          const SizedBox(height: 8),
          _buildGrid(
            context,
            allIds: allCropIds,
            collectedIds: gs.codexCrops,
            getName: (id) {
              try {
                return GameData.crops.firstWhere((c) => c.id == id).name;
              } catch (_) {
                return id;
              }
            },
            getRarity: (id) => 'Normal',
            isCrop: true,
          ),

          const SizedBox(height: 16),

          // Boss collection
          _sectionTitle('\uD83D\uDC79 \uBCF4\uC2A4 \uB3C4\uAC10', '$bossDefeated/$bossTotal'),
          const SizedBox(height: 8),
          _buildGrid(
            context,
            allIds: allBossIds,
            collectedIds: gs.codexBosses,
            getName: (id) {
              try {
                return GameData.bosses.firstWhere((b) => b.id == id).name;
              } catch (_) {
                return id;
              }
            },
            getRarity: (id) => 'Legendary',
            isBoss: true,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF0d1117),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Text(
            count,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(
    BuildContext context, {
    required List<String> allIds,
    required List<String> collectedIds,
    required String Function(String) getName,
    required String Function(String) getRarity,
    bool isCrop = false,
    bool isBoss = false,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.0,
      ),
      itemCount: allIds.length,
      itemBuilder: (context, i) {
        final id = allIds[i];
        final collected = collectedIds.contains(id);

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0d1117),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: collected
                  ? _rarityColor(getRarity(id)).withValues(alpha: 0.5)
                  : const Color(0xFF333333),
            ),
          ),
          child: Center(
            child: collected
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isBoss
                            ? '\uD83D\uDC79'
                            : isCrop
                                ? '\uD83C\uDF31'
                                : '\uD83D\uDC64',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          getName(id),
                          style: TextStyle(
                            color: _rarityColor(getRarity(id)),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '???',
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 20,
                        height: 2,
                        color: Colors.white12,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
