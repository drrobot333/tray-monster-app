import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/models.dart';
import '../data/game_data.dart';

class CropPickerDialog extends StatelessWidget {
  final int tileRow;
  final int tileCol;

  const CropPickerDialog({super.key, required this.tileRow, required this.tileCol});

  Color _categoryColor(String category) {
    switch (category) {
      case 'basic':
        return const Color(0xFF4CAF50);
      case 'combat':
        return const Color(0xFFFF5252);
      case 'rare':
        return const Color(0xFF9C27B0);
      case 'mutation':
        return const Color(0xFFFFD700);
      default:
        return const Color(0xFFAAAAAA);
    }
  }

  String _cropEmoji(String cropId) {
    switch (cropId) {
      case 'wheat':
        return '\uD83C\uDF3E';
      case 'corn':
        return '\uD83C\uDF3D';
      case 'carrot':
        return '\uD83E\uDD55';
      case 'tomato':
        return '\uD83C\uDF45';
      case 'berry':
        return '\uD83C\uDF53';
      case 'herb':
        return '\uD83C\uDF3F';
      case 'mushroom':
        return '\uD83C\uDF44';
      case 'crystal_flower':
        return '\uD83D\uDC8E';
      case 'dragon_fruit':
        return '\uD83C\uDF09';
      default:
        return '\uD83C\uDF31';
    }
  }

  String _dropIcon(String type) {
    switch (type) {
      case 'Attack Crystal': return '⚔';
      case 'Defense Core': return '🛡';
      case 'Speed Chip': return '⚡';
      case 'Mutagen': return '🧬';
      case 'Egg Fragment': return '🥚';
      case 'random_material': return '🎲';
      case 'golden_boost': return '✨';
      case 'golden_guarantee': return '🌟';
      default: return '📦';
    }
  }

  String _formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s > 0 ? '${m}m${s}s' : '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    // Get available crops: unlocked + non-mutation
    final availableCrops = GameData.crops.where((c) =>
        gs.unlockedCrops.contains(c.id) && c.category != 'mutation').toList();
    final hasBatchPlant = gs.skills.contains('batch_plant');
    final currentAssigned = gs.farmTiles[tileRow][tileCol].assignedCrop;

    return SimpleDialog(
      backgroundColor: const Color(0xFF1a1a2e),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF333333)),
      ),
      title: Row(
        children: [
          const Text(
            '\uD83C\uDF31 \uC791\uBB3C \uC120\uD0DD',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Auto button
          InkWell(
            onTap: () {
              gs.farmTiles[tileRow][tileCol].assignedCrop = null;
              gs.notify();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF2196F3)),
              ),
              child: const Text(
                '\uC790\uB3D9',
                style: TextStyle(
                  color: Color(0xFF2196F3),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      children: [
        // Current assignment display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (currentAssigned != null ? const Color(0xFF4CAF50) : const Color(0xFF2196F3)).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: (currentAssigned != null ? const Color(0xFF4CAF50) : const Color(0xFF2196F3)).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Text(currentAssigned != null ? '📌' : '⚙️', style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  currentAssigned != null
                    ? '고정: ${GameData.crops.where((c) => c.id == currentAssigned).firstOrNull?.name ?? currentAssigned}'
                    : '고정 없음 (자동)',
                  style: TextStyle(
                    color: currentAssigned != null ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
                    fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

        // Batch plant button (if skill unlocked)
        if (hasBatchPlant)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF9C27B0).withValues(alpha: 0.3)),
              ),
              child: const ListTile(
                dense: true,
                leading: Text('\uD83C\uDF3E', style: TextStyle(fontSize: 18)),
                title: Text(
                  '\uC804\uCCB4 \uC801\uC6A9',
                  style: TextStyle(
                    color: Color(0xFF9C27B0),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  '\uC120\uD0DD\uD55C \uC791\uBB3C\uC744 \uBAA8\uB4E0 \uD0C0\uC77C\uC5D0 \uC801\uC6A9',
                  style: TextStyle(color: Colors.white54, fontSize: 10),
                ),
                trailing: Icon(Icons.select_all, color: Color(0xFF9C27B0), size: 18),
              ),
            ),
          ),

        // Crop list
        ...availableCrops.map((crop) {
          return SimpleDialogOption(
            onPressed: () {
              if (hasBatchPlant) {
                _showBatchDialog(context, gs, crop);
              } else {
                gs.farmTiles[tileRow][tileCol].assignedCrop = crop.id;
                gs.notify();
                Navigator.pop(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0d1117),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: Row(
                children: [
                  Text(
                    _cropEmoji(crop.id),
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              crop.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: _categoryColor(crop.category).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                crop.category,
                                style: TextStyle(
                                  color: _categoryColor(crop.category),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            // Show gold or drop icons
                            if (crop.value > 0)
                              Text('💰${crop.value}',
                                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11)),
                            if (crop.drops.isNotEmpty) ...[
                              if (crop.value > 0) const SizedBox(width: 4),
                              ...crop.drops.map((d) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text('${_dropIcon(d.type)}${d.amount}',
                                  style: const TextStyle(color: Color(0xFF88CCFF), fontSize: 11)),
                              )),
                            ],
                            if (crop.value == 0 && crop.drops.isEmpty)
                              const Text('—', style: TextStyle(color: Colors.white38, fontSize: 11)),
                            const Spacer(),
                            Text('⏰${_formatTime(crop.growTime)}',
                              style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (currentAssigned == crop.id)
                    const Text('📌', style: TextStyle(fontSize: 14))
                  else
                    const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showBatchDialog(BuildContext context, GameState gs, CropData crop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF333333)),
        ),
        title: Text(
          '${crop.name} \uC801\uC6A9',
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        content: const Text(
          '\uC5B4\uB5BB\uAC8C \uC801\uC6A9\uD560\uAE4C\uC694?',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              gs.farmTiles[tileRow][tileCol].assignedCrop = crop.id;
              gs.notify();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('\uC774 \uD0C0\uC77C\uB9CC'),
          ),
          ElevatedButton(
            onPressed: () {
              for (int r = 0; r < gs.farmTiles.length; r++) {
                for (int c = 0; c < gs.farmTiles[r].length; c++) {
                  gs.farmTiles[r][c].assignedCrop = crop.id;
                }
              }
              gs.notify();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
            ),
            child: const Text('\uC804\uCCB4 \uC801\uC6A9'),
          ),
        ],
      ),
    );
  }
}
