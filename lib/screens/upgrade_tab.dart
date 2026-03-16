import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../services/game_engine.dart';
import '../data/game_data.dart';

class UpgradeTab extends StatelessWidget {
  final GameEngine engine;

  const UpgradeTab({super.key, required this.engine});

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

  int _robotUpgradeCost(GameState gs, String stat) {
    final data = GameData.robotUpgrades[stat];
    if (data == null) return 0;
    final level = gs.robotUpgrades[stat] ?? 0;
    return ((data['baseCost'] as num) * pow((data['costMult'] as num), level)).floor();
  }

  int _workstationUpgradeCost(int level, String stat, bool isFishing) {
    final data = isFishing ? GameData.fishingUpgrades[stat] : GameData.miningUpgrades[stat];
    if (data == null) return 0;
    return ((data['baseCost'] as num) * pow((data['costMult'] as num), level)).floor();
  }

  int _allyUpgradeCost(int level) {
    return (100 * pow(1.5, level - 1)).floor();
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '\uD83D\uDCCA \uAC15\uD654',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\uACE8\uB4DC: ${gs.gold}',
            style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Robot upgrades section
          _sectionHeader('\uD83E\uDD16 \uB85C\uBD07 \uAC15\uD654'),
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
                  _upgradeRow(
                    context,
                    icon: '\u26A1',
                    label: '\uC2A4\uD0DC\uBBF8\uB098',
                    currentValue: '${gs.robot.maxStamina.toInt()}',
                    cost: _robotUpgradeCost(gs, 'stamina'),
                    onUpgrade: () => engine.upgradeRobot('stamina'),
                    canAfford: gs.gold >= _robotUpgradeCost(gs, 'stamina'),
                  ),
                  const Divider(color: Color(0xFF333333), height: 16),
                  _upgradeRow(
                    context,
                    icon: '\uD83D\uDCA8',
                    label: '\uC18D\uB3C4',
                    currentValue: 'Lv.${gs.robotUpgrades['moveSpeed'] ?? 0}',
                    cost: _robotUpgradeCost(gs, 'moveSpeed'),
                    onUpgrade: () => engine.upgradeRobot('moveSpeed'),
                    canAfford: gs.gold >= _robotUpgradeCost(gs, 'moveSpeed'),
                  ),
                  const Divider(color: Color(0xFF333333), height: 16),
                  _upgradeRow(
                    context,
                    icon: '\uD83C\uDF31',
                    label: '\uC218\uD655\uB7C9',
                    currentValue: 'Lv.${gs.robotUpgrades['growthBoost'] ?? 0}',
                    cost: _robotUpgradeCost(gs, 'growthBoost'),
                    onUpgrade: () => engine.upgradeRobot('growthBoost'),
                    canAfford: gs.gold >= _robotUpgradeCost(gs, 'growthBoost'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Fishing upgrades section
          _sectionHeader('\uD83C\uDFA3 \uB09A\uC2DC \uAC15\uD654'),
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
                  _upgradeRow(
                    context,
                    icon: '\uD83C\uDFA3',
                    label: '\uB09A\uC2EF\uB300 (\uC18D\uB3C4)',
                    currentValue: 'Lv.${gs.fishingUpgrades['rod'] ?? 0}',
                    cost: _workstationUpgradeCost(gs.fishingUpgrades['rod'] ?? 0, 'rod', true),
                    onUpgrade: () => engine.upgradeFishing('rod'),
                    canAfford: gs.gold >= _workstationUpgradeCost(gs.fishingUpgrades['rod'] ?? 0, 'rod', true),
                  ),
                  const Divider(color: Color(0xFF333333), height: 16),
                  _upgradeRow(
                    context,
                    icon: '\uD83C\uDF1F',
                    label: '\uBBF8\uB07C (\uD76C\uADC0\uD655\uB960)',
                    currentValue: 'Lv.${gs.fishingUpgrades['bait'] ?? 0}',
                    cost: _workstationUpgradeCost(gs.fishingUpgrades['bait'] ?? 0, 'bait', true),
                    onUpgrade: () => engine.upgradeFishing('bait'),
                    canAfford: gs.gold >= _workstationUpgradeCost(gs.fishingUpgrades['bait'] ?? 0, 'bait', true),
                  ),
                  const Divider(color: Color(0xFF333333), height: 16),
                  _upgradeRow(
                    context,
                    icon: '\u26F5',
                    label: '\uBCF4\uD2B8 (\uC2A4\uD0DC\uBBF8\uB098)',
                    currentValue: 'Lv.${gs.fishingUpgrades['boat'] ?? 0}',
                    cost: _workstationUpgradeCost(gs.fishingUpgrades['boat'] ?? 0, 'boat', true),
                    onUpgrade: () => engine.upgradeFishing('boat'),
                    canAfford: gs.gold >= _workstationUpgradeCost(gs.fishingUpgrades['boat'] ?? 0, 'boat', true),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Mining upgrades section
          _sectionHeader('\u26CF \uCC44\uAD11 \uAC15\uD654'),
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
                  _upgradeRow(
                    context,
                    icon: '\u26CF',
                    label: '\uACE1\uAD2D\uC774 (\uC18D\uB3C4)',
                    currentValue: 'Lv.${gs.miningUpgradesState['pickaxe'] ?? 0}',
                    cost: _workstationUpgradeCost(gs.miningUpgradesState['pickaxe'] ?? 0, 'pickaxe', false),
                    onUpgrade: () => engine.upgradeMining('pickaxe'),
                    canAfford: gs.gold >= _workstationUpgradeCost(gs.miningUpgradesState['pickaxe'] ?? 0, 'pickaxe', false),
                  ),
                  const Divider(color: Color(0xFF333333), height: 16),
                  _upgradeRow(
                    context,
                    icon: '\uD83D\uDD29',
                    label: '\uB4DC\uB9B4 (\uD76C\uADC0\uD655\uB960)',
                    currentValue: 'Lv.${gs.miningUpgradesState['drill'] ?? 0}',
                    cost: _workstationUpgradeCost(gs.miningUpgradesState['drill'] ?? 0, 'drill', false),
                    onUpgrade: () => engine.upgradeMining('drill'),
                    canAfford: gs.gold >= _workstationUpgradeCost(gs.miningUpgradesState['drill'] ?? 0, 'drill', false),
                  ),
                  const Divider(color: Color(0xFF333333), height: 16),
                  _upgradeRow(
                    context,
                    icon: '\uD83D\uDED2',
                    label: '\uC218\uB808 (\uC2A4\uD0DC\uBBF8\uB098)',
                    currentValue: 'Lv.${gs.miningUpgradesState['cart'] ?? 0}',
                    cost: _workstationUpgradeCost(gs.miningUpgradesState['cart'] ?? 0, 'cart', false),
                    onUpgrade: () => engine.upgradeMining('cart'),
                    canAfford: gs.gold >= _workstationUpgradeCost(gs.miningUpgradesState['cart'] ?? 0, 'cart', false),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Ally upgrades section
          _sectionHeader('\uD83D\uDC65 \uC544\uAD70 \uAC15\uD654'),
          const SizedBox(height: 8),

          if (gs.allies.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0d1117),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: const Text(
                '\uC544\uAD70\uC774 \uC5C6\uC2B5\uB2C8\uB2E4',
                style: TextStyle(color: Colors.white38, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),

          ...gs.allies.asMap().entries.map((entry) {
            final allyIndex = entry.key;
            final ally = entry.value;
            final upgradeCost = _allyUpgradeCost(ally.level);
            return Card(
              color: const Color(0xFF0d1117),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: _rarityColor(ally.rarity).withValues(alpha: 0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                        Text(
                          'Lv.${ally.level}',
                          style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _allyStatButton(
                          context,
                          icon: '\u2694',
                          label: '공격',
                          value: '${ally.baseAtk}',
                          color: const Color(0xFFFF5252),
                          cost: upgradeCost,
                          onUpgrade: () => engine.upgradeAlly(allyIndex, 'atk'),
                          canAfford: gs.gold >= upgradeCost,
                        ),
                        const SizedBox(width: 6),
                        _allyStatButton(
                          context,
                          icon: '\uD83D\uDEE1',
                          label: '방어',
                          value: '${ally.baseDef}',
                          color: const Color(0xFF2196F3),
                          cost: upgradeCost,
                          onUpgrade: () => engine.upgradeAlly(allyIndex, 'def'),
                          canAfford: gs.gold >= upgradeCost,
                        ),
                        const SizedBox(width: 6),
                        _allyStatButton(
                          context,
                          icon: '\u26A1',
                          label: '속도',
                          value: '${ally.baseSpd}',
                          color: const Color(0xFFFFD700),
                          cost: upgradeCost,
                          onUpgrade: () => engine.upgradeAlly(allyIndex, 'spd'),
                          canAfford: gs.gold >= upgradeCost,
                        ),
                        const SizedBox(width: 6),
                        _allyStatButton(
                          context,
                          icon: '\u2764',
                          label: 'HP',
                          value: '${ally.baseHp}',
                          color: const Color(0xFF4CAF50),
                          cost: upgradeCost,
                          onUpgrade: () => engine.upgradeAlly(allyIndex, 'hp'),
                          canAfford: gs.gold >= upgradeCost,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Skill shop section
          _sectionHeader('\uD83D\uDCA1 \uC2A4\uD0AC \uC0F5'),
          const SizedBox(height: 8),

          ...GameData.skills.map((skill) {
            final owned = gs.skills.contains(skill.id);
            final canBuy = !owned && gs.gold >= skill.cost;
            final requirementMet = skill.requires == null || gs.skills.contains(skill.requires);

            return Card(
              color: const Color(0xFF0d1117),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: owned
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF333333),
                ),
              ),
              child: ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: owned
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                        : const Color(0xFF1a1a2e),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: owned
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF333333),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      owned ? Icons.check : Icons.lock_open,
                      color: owned ? const Color(0xFF4CAF50) : Colors.white38,
                      size: 18,
                    ),
                  ),
                ),
                title: Text(
                  skill.name,
                  style: TextStyle(
                    color: owned ? const Color(0xFF4CAF50) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.desc,
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    if (skill.requires != null && !requirementMet)
                      Text(
                        '\uD544\uC694: ${GameData.skills.where((s) => s.id == skill.requires).firstOrNull?.name ?? skill.requires}',
                        style: const TextStyle(color: Color(0xFFFF5252), fontSize: 10),
                      ),
                  ],
                ),
                trailing: owned
                    ? const Text(
                        '\uBCF4\uC720',
                        style: TextStyle(color: Color(0xFF4CAF50), fontSize: 11),
                      )
                    : ElevatedButton(
                        onPressed: canBuy && requirementMet
                            ? () => engine.buySkill(skill.id)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canBuy && requirementMet
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF333333),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text(
                          '\uD83D\uDCB0${skill.cost}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
              ),
            );
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _upgradeRow(
    BuildContext context, {
    required String icon,
    required String label,
    required String currentValue,
    required int cost,
    required VoidCallback onUpgrade,
    required bool canAfford,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Text(
                currentValue,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: canAfford ? onUpgrade : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canAfford ? const Color(0xFF4CAF50) : const Color(0xFF333333),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: Text(
            '\u2B06 \uD83D\uDCB0$cost',
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _allyStatButton(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    required Color color,
    required int cost,
    required VoidCallback onUpgrade,
    required bool canAfford,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: TextStyle(fontSize: 12, color: color)),
                const SizedBox(width: 4),
                Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 22,
              child: ElevatedButton(
                onPressed: canAfford ? onUpgrade : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: canAfford ? color.withValues(alpha: 0.3) : const Color(0xFF333333),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(
                  '$label \uD83D\uDCB0$cost',
                  style: const TextStyle(fontSize: 7, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
