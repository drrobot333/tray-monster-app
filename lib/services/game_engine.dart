import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../models/game_state.dart';
import '../data/game_data.dart';

// ============================================================
// Material name mapping
// ============================================================
String matKey(String name) {
  const map = {
    'Attack Crystal': 'attackCrystal',
    'Defense Core': 'defenseCore',
    'Speed Chip': 'speedChip',
    'Mutagen': 'mutagen',
    'Egg Fragment': 'eggFragment',
    'Star Dust': 'starDust',
    'random_material': 'random',
    'golden_boost': 'golden_boost',
    'golden_guarantee': 'golden_guarantee',
    'attackCrystal': 'attackCrystal',
    'defenseCore': 'defenseCore',
    'speedChip': 'speedChip',
    'mutagen': 'mutagen',
    'eggFragment': 'eggFragment',
    'starDust': 'starDust',
    'random': 'random',
  };
  return map[name] ?? name;
}

// ============================================================
// Egg loot tables
// ============================================================
class _EggLoot {
  final int goldW, matW, unitW, matMin, matMax;
  const _EggLoot(this.goldW, this.matW, this.unitW, this.matMin, this.matMax);
}

const Map<String, _EggLoot> _eggLoot = {
  'bronze':  _EggLoot(20, 25, 55,  2,   5),
  'silver':  _EggLoot(15, 25, 60,  5,  12),
  'gold':    _EggLoot(10, 20, 70, 10,  25),
  'ruby':    _EggLoot(10, 15, 75, 20,  50),
  'diamond': _EggLoot( 5, 10, 85, 40, 100),
};

// ============================================================
// Skill definitions
// ============================================================
const List<Map<String, dynamic>> skillDefs = [
  {'id': 'batch_plant',    'name': '일괄 심기',      'desc': '모든 밭에 같은 작물을 한 번에 지정',       'cost': 5000},
  {'id': 'auto_water',     'name': '자동 관수',       'desc': '로봇이 물 안 줘도 작물 성장 80%',         'cost': 15000},
  {'id': 'egg_slot_3',     'name': '부화 슬롯 +1',   'desc': '부화 슬롯 2개 → 3개',                     'cost': 30000},
  {'id': 'battle_speed',   'name': '전투 가속',       'desc': '전투 턴 간격 50% 감소',                   'cost': 50000},
  {'id': 'fast_hatch',     'name': '빠른 부화',       'desc': '알 부화 시간 30% 감소',                   'cost': 80000},
  {'id': 'offline_bonus',  'name': '오프라인 보너스',  'desc': '백그라운드 수익 효율 50% → 80%',         'cost': 120000},
  {'id': 'egg_slot_4',     'name': '부화 슬롯 +2',   'desc': '부화 슬롯 3개 → 4개',                     'cost': 200000, 'requires': 'egg_slot_3'},
  {'id': 'double_harvest', 'name': '이중 수확',       'desc': '수확 시 20% 확률로 보상 2배',             'cost': 500000},
];

// ============================================================
// Mission templates
// ============================================================
const List<Map<String, dynamic>> _missionTemplates = [
  {'id': 'harvest',  'desc': '작물 {n}개 수확',  'targets': [5, 10, 15], 'rewardType': 'gold',        'rewardAmounts': [300, 600, 1000]},
  {'id': 'battle',   'desc': '보스 {n}번 도전',  'targets': [1, 2, 3],   'rewardType': 'gold',        'rewardAmounts': [500, 1000, 2000]},
  {'id': 'egg',      'desc': '알 {n}개 부화',    'targets': [1, 2],      'rewardType': 'eggFragment', 'rewardAmounts': [5, 10]},
  {'id': 'gold',     'desc': '골드 {n} 획득',    'targets': [500, 1000, 2000], 'rewardType': 'material', 'rewardAmounts': [5, 10, 15]},
  {'id': 'upgrade',  'desc': '업그레이드 {n}번',  'targets': [1, 3, 5],   'rewardType': 'gold',        'rewardAmounts': [400, 800, 1500]},
];

// ============================================================
// GameEngine
// ============================================================
class GameEngine {
  final GameState state;
  final Random _rng = Random();

  GameEngine(this.state);

  // ── Helpers ──
  CropData? getCropData(String cropId) {
    try {
      return GameData.crops.firstWhere((c) => c.id == cropId);
    } catch (_) {
      return null;
    }
  }

  AllyData? getAllyData(String allyId) {
    try {
      return GameData.allies.firstWhere((a) => a.id == allyId);
    } catch (_) {
      return null;
    }
  }

  BossData? getBossData(int stage) {
    try {
      return GameData.bosses.firstWhere((b) => b.stage == stage);
    } catch (_) {
      return null;
    }
  }

  bool hasSkill(String id) => state.skills.contains(id);

  String _weightedRandom(Map<String, int> weights) {
    final entries = weights.entries.toList();
    final total = entries.fold<int>(0, (s, e) => s + e.value);
    var r = _rng.nextDouble() * total;
    for (final e in entries) {
      r -= e.value;
      if (r <= 0) return e.key;
    }
    return entries.last.key;
  }

  void _notify(String text) {
    state.notification = text;
    state.notificationTimer = 3;
  }

  // ============================================================
  // MAIN UPDATE
  // ============================================================
  void update(double dt) {
    state.time += dt;

    final eventMult = state.farmEvent == 'overdrive' ? 3.0
        : state.farmEvent == 'fertile' ? 2.0
        : 1.0;

    updateWeather(dt);
    updateCrops(dt * eventMult);
    updateRobot(dt * (state.farmEvent == 'overdrive' ? 3.0 : 1.0));
    updateFishingTiles(dt);
    updateFishingRobot(dt);
    updateMiningTiles(dt);
    updateMiningRobot(dt);
    updateCooking(dt);
    updateMarket(dt);
    updateEggs(dt);
    updateBattle(dt);
    updateFarmEvents(dt);
    syncCodex();
    _updateFloatingTexts(dt);

    // Mission refresh at midnight (local time)
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (state.lastMissionResetDay != today) {
      generateMissions();
      state.lastMissionResetDay = today;
      if (state.lastMissionResetDay.isNotEmpty) {
        _notify('새로운 일일 미션!');
      }
    }

    if (state.notificationTimer > 0) {
      state.notificationTimer -= dt;
    }

    state.notify();
  }

  // ============================================================
  // WEATHER
  // ============================================================
  void updateWeather(double dt) {
    state.weatherTimer -= dt;
    if (state.weatherTimer <= 0) {
      state.currentWeather = state.nextWeather;
      const pool = ['sunny', 'rain', 'storm', 'night'];
      const rare = ['heatwave', 'frost'];
      if (_rng.nextDouble() < 0.1) {
        state.nextWeather = rare[_rng.nextInt(rare.length)];
      } else {
        final filtered = pool.where((w) => w != state.currentWeather).toList();
        state.nextWeather = filtered[_rng.nextInt(filtered.length)];
      }
      state.weatherTimer = state.weatherDuration;
      _notify('날씨 변경: ${getWeatherName(state.currentWeather)}');
    }
  }

  String getWeatherName(String w) {
    const names = {
      'sunny': '맑음', 'rain': '비', 'storm': '폭풍',
      'night': '밤', 'heatwave': '폭염', 'frost': '서리',
    };
    return names[w] ?? w;
  }

  Map<String, dynamic> _weatherEffects() {
    final w = state.currentWeather;
    return {
      'growthMult': w == 'sunny' ? 1.3 : w == 'rain' ? 1.1 : w == 'frost' ? 0.8 : 1.0,
      'autoWater': w == 'rain',
      'rareDropMult': w == 'storm' ? 2.0 : 1.0,
      'mutationMult': w == 'night' ? 1.5 : 1.0,
      'staminaDrain': w == 'storm' ? 1.5 : 1.0,
    };
  }

  // ============================================================
  // CROPS
  // ============================================================
  void updateCrops(double dt) {
    final weather = _weatherEffects();
    final growthBoost = _getGrowthBoost();
    final codexBonus = getCodexBonus();

    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        final tile = state.farmTiles[r][c];
        if (tile.crop != null && tile.growthProgress < 1.0) {
          final cropData = getCropData(tile.crop!);
          if (cropData != null && cropData.growTime > 0) {
            final waterMult = tile.watered ? 1.0 : (hasSkill('auto_water') ? 0.8 : 0.5);
            final growRate = (1 / cropData.growTime) * waterMult *
                (weather['growthMult'] as double) * growthBoost *
                (1 + codexBonus['growthMult']!);
            tile.growthProgress += growRate * dt;
            if (tile.growthProgress >= 1.0) {
              tile.growthProgress = 1.0;
              // Golden chance
              double goldenChance = 0.005;
              for (int rr = 0; rr < 3; rr++) {
                for (int cc = 0; cc < 3; cc++) {
                  if (state.farmTiles[rr][cc].crop == 'lucky_clover') {
                    goldenChance += 0.001;
                  }
                }
              }
              goldenChance *= (weather['rareDropMult'] as double);
              if (_rng.nextDouble() < goldenChance) {
                tile.golden = true;
                _notify('황금 작물 발견!');
                state.stats['goldenCrops'] = (state.stats['goldenCrops'] ?? 0) + 1;
              }
            }
          }
        }
        // Auto water in rain
        if ((weather['autoWater'] as bool) && tile.crop != null && !tile.watered) {
          tile.watered = true;
        }
      }
    }
  }

  // ============================================================
  // HARVEST
  // ============================================================
  void harvestTile(int row, int col) {
    final tile = state.farmTiles[row][col];
    if (tile.crop == null || tile.growthProgress < 1.0) return;

    final cropData = getCropData(tile.crop!);
    if (cropData == null) {
      tile.crop = null;
      return;
    }

    // Track crop in codex
    if (!state.codexCrops.contains(cropData.id)) {
      state.codexCrops.add(cropData.id);
    }

    // Check mutation
    final mutationResult = checkMutation(row, col);

    int goldEarned = cropData.value;
    List<Drop> drops = List.from(cropData.drops);

    if (mutationResult != null) {
      final mutCrop = getCropData(mutationResult);
      if (mutCrop != null) {
        goldEarned = mutCrop.value;
        drops = List.from(mutCrop.drops);
        _notify('돌연변이! ${mutCrop.name}');
        if (!state.codexCrops.contains(mutationResult)) {
          state.codexCrops.add(mutationResult);
        }
      }
    }

    if (tile.golden) {
      goldEarned *= 10;
      state.materials['eggFragment'] = (state.materials['eggFragment'] ?? 0) + 2;
      _notify('황금 ${cropData.name}! ${goldEarned}G');
    }

    // Apply codex gold bonus
    goldEarned = (goldEarned * (1 + getCodexBonus()['goldMult']!)).floor();

    // Double harvest skill
    if (hasSkill('double_harvest') && _rng.nextDouble() < 0.2) {
      goldEarned *= 2;
    }

    state.gold += goldEarned;
    state.stats['totalGoldEarned'] = (state.stats['totalGoldEarned'] ?? 0) + goldEarned;
    state.stats['cropsHarvested'] = (state.stats['cropsHarvested'] ?? 0) + 1;

    // Process drops
    for (final drop in drops) {
      final key = matKey(drop.type);
      if (key == 'random' || key == 'random_material') {
        const mats = ['attackCrystal', 'defenseCore', 'speedChip'];
        final chosen = mats[_rng.nextInt(mats.length)];
        state.materials[chosen] = (state.materials[chosen] ?? 0) + drop.amount;
      } else if (key == 'golden_boost' || key == 'golden_guarantee') {
        // Special effects handled elsewhere
      } else if (state.materials.containsKey(key)) {
        state.materials[key] = (state.materials[key] ?? 0) + drop.amount;
      }
    }

    // Cooking ingredient: 작물 ID 자체가 재료 (50% 확률)
    if (cropData.category != 'mutation' && _rng.nextDouble() < 0.5) {
      state.cookingIngredients[cropData.id] =
          (state.cookingIngredients[cropData.id] ?? 0) + 1;
    }

    // Track total harvests for spice (50회당 1개)
    state.totalHarvestCount++;
    if (state.totalHarvestCount % 50 == 0) {
      state.cookingIngredients['spice'] =
          (state.cookingIngredients['spice'] ?? 0) + 1;
    }

    // Clear tile
    tile.crop = null;
    tile.growthProgress = 0;
    tile.watered = false;
    tile.golden = false;

    // Floating text
    state.floatingTexts.add(FloatingText(
      text: '+${goldEarned}G',
      col: col, row: row,
      color: goldEarned > 100 ? 0xFFFF69B4 : 0xFFFFD700,
    ));

    // Mission tracking
    advanceMission('harvest', 1);
    advanceMission('gold', goldEarned);
  }

  // ============================================================
  // MUTATION (single-crop chance based, NOT neighbor based)
  // ============================================================
  String? checkMutation(int row, int col) {
    final tile = state.farmTiles[row][col];
    if (tile.crop == null) return null;
    final weather = _weatherEffects();

    for (final recipe in GameData.mutations) {
      if (recipe.cropId != tile.crop) continue;
      if (_rng.nextDouble() < recipe.chance * (weather['mutationMult'] as double)) {
        return recipe.resultId;
      }
    }
    return null;
  }

  // ============================================================
  // ROBOT
  // ============================================================
  double _getRobotSpeed() => (1.0 + state.robotUpgrades['moveSpeed']! * 0.08) * 48;

  double _getGrowthBoost() => 1.0 + state.robotUpgrades['growthBoost']! * 0.03;

  int _getMaxStamina() => 100 + state.robotUpgrades['stamina']! * 5;

  CropData? _getBestCropToPlant() {
    final available = GameData.crops.where((c) =>
        state.unlockedCrops.contains(c.id) && c.category != 'mutation').toList();
    if (available.isEmpty) return null;
    available.sort((a, b) => (b.value / b.growTime).compareTo(a.value / a.growTime));
    return available.first;
  }

  void updateRobot(double dt) {
    final robot = state.robot;
    final tiles = state.farmTiles;
    final weather = _weatherEffects();

    robot.maxStamina = _getMaxStamina().toDouble();

    // Animation timer
    robot.animTimer += dt;
    if (robot.animTimer > 0.3) {
      robot.animTimer = 0;
      robot.animFrame = (robot.animFrame + 1) % 2;
    }

    final staminaDrain = weather['staminaDrain'] as double;

    switch (robot.state) {
      case 'idle':
        _decideRobotAction(robot, tiles, weather);
        break;

      case 'walking':
        final speed = _getRobotSpeed();
        final tx = robot.targetX * 48.0 + 24;
        final ty = robot.targetY * 48.0 + 24;
        final dx = tx - robot.pixelX;
        final dy = ty - robot.pixelY;
        final dist = sqrt(dx * dx + dy * dy);
        final moveAmount = speed * dt;
        if (dist < 2 || moveAmount >= dist) {
          robot.x = robot.targetX;
          robot.y = robot.targetY;
          robot.pixelX = tx;
          robot.pixelY = ty;
          robot.state = robot.nextAction ?? 'idle';
          robot.stateTimer = robot.nextAction == 'harvesting' ? 0.8
              : robot.nextAction == 'watering' ? 0.6
              : robot.nextAction == 'planting' ? 0.7
              : 0;
          robot.stamina -= 0.5 * staminaDrain;
        } else {
          robot.pixelX += (dx / dist) * moveAmount;
          robot.pixelY += (dy / dist) * moveAmount;
          robot.stamina -= 0.2 * dt * staminaDrain;
        }
        break;

      case 'planting':
        robot.stateTimer -= dt;
        if (robot.stateTimer <= 0) {
          final tile = tiles[robot.y][robot.x];
          if (tile.crop == null) {
            final cropId = tile.assignedCrop ?? _getBestCropToPlant()?.id;
            if (cropId != null) {
              tile.crop = cropId;
              tile.growthProgress = 0;
              tile.watered = false;
              tile.golden = false;
            }
          }
          robot.stamina -= 2 * staminaDrain;
          robot.state = 'idle';
        }
        break;

      case 'watering':
        robot.stateTimer -= dt;
        if (robot.stateTimer <= 0) {
          final tile = tiles[robot.y][robot.x];
          if (tile.crop != null && !tile.watered) {
            tile.watered = true;
          }
          robot.stamina -= 1.5 * staminaDrain;
          robot.state = 'idle';
        }
        break;

      case 'harvesting':
        robot.stateTimer -= dt;
        if (robot.stateTimer <= 0) {
          harvestTile(robot.y, robot.x);
          robot.stamina -= 2 * staminaDrain;
          robot.state = 'idle';
        }
        break;

      case 'resting':
        robot.stamina += 8 * dt;
        if (robot.stamina >= robot.maxStamina * 0.8) {
          robot.stamina = robot.stamina.clamp(0, robot.maxStamina);
          robot.state = 'idle';
        }
        break;
    }

    robot.stamina = robot.stamina.clamp(0, robot.maxStamina);
  }

  void _decideRobotAction(RobotState robot, List<List<FarmTile>> tiles, Map<String, dynamic> weather) {
    // Check stamina
    if (robot.stamina <= robot.maxStamina * 0.1) {
      robot.state = 'resting';
      return;
    }

    // Priority 1: Harvest ready crops
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        final tile = tiles[r][c];
        if (tile.crop != null && tile.growthProgress >= 1.0) {
          _moveRobotTo(robot, c, r, 'harvesting');
          return;
        }
      }
    }

    // Priority 2: Water unwatered growing crops (skip if rain)
    if (!(weather['autoWater'] as bool)) {
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          final tile = tiles[r][c];
          if (tile.crop != null && tile.growthProgress < 1.0 && !tile.watered) {
            _moveRobotTo(robot, c, r, 'watering');
            return;
          }
        }
      }
    }

    // Priority 3: Plant empty tiles
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (tiles[r][c].crop == null) {
          _moveRobotTo(robot, c, r, 'planting');
          return;
        }
      }
    }

    // Nothing to do - slow regen while idle
    robot.stamina += 2 * 0.016;
  }

  void _moveRobotTo(RobotState robot, int x, int y, String action) {
    if (robot.x == x && robot.y == y) {
      robot.state = action;
      robot.stateTimer = action == 'harvesting' ? 0.8
          : action == 'watering' ? 0.6
          : action == 'planting' ? 0.7
          : 0;
    } else {
      robot.targetX = x;
      robot.targetY = y;
      robot.state = 'walking';
      robot.nextAction = action;
    }
  }

  // ============================================================
  // EGGS
  // ============================================================
  void updateEggs(double dt) {
    for (final egg in state.eggs) {
      if (egg.timeLeft > 0) {
        egg.timeLeft -= dt;
        if (egg.timeLeft <= 0) {
          egg.timeLeft = 0;
          egg.ready = true;
          _notify('알이 부화 준비 완료!');
        }
      }
    }
  }

  void buyEgg(String tier) {
    final eggData = GameData.eggTiers[tier];
    if (eggData == null) return;
    if (state.gold < eggData.cost) {
      _notify('골드가 부족합니다!');
      return;
    }
    if (state.eggs.length >= state.maxEggSlots) {
      _notify('부화 슬롯이 가득 찼습니다!');
      return;
    }

    state.gold -= eggData.cost;
    final incTime = eggData.incubationTime * (hasSkill('fast_hatch') ? 0.7 : 1.0);

    state.eggs.add(IncubatingEgg(
      tier: tier,
      rarity: 'unknown',
      timeLeft: incTime,
      totalTime: incTime,
    ));

    const tierNames = {
      'bronze': '브론즈', 'silver': '실버', 'gold': '골드',
      'ruby': '루비', 'diamond': '다이아',
    };
    _notify('${tierNames[tier] ?? tier} 알 구매!');
  }

  void exchangeEgg(String tier) {
    final eggData = GameData.eggTiers[tier];
    if (eggData == null) return;
    if (state.eggs.length >= state.maxEggSlots) {
      _notify('부화 슬롯이 가득 찼습니다!');
      return;
    }

    final incTime = eggData.incubationTime * (hasSkill('fast_hatch') ? 0.7 : 1.0);

    state.eggs.add(IncubatingEgg(
      tier: tier,
      rarity: 'unknown',
      timeLeft: incTime,
      totalTime: incTime,
    ));

    const tierNames = {
      'bronze': '브론즈', 'silver': '실버', 'gold': '골드',
      'ruby': '루비', 'diamond': '다이아',
    };
    _notify('조각으로 ${tierNames[tier] ?? tier} 알 교환!');
  }

  void hatchEgg(int index) {
    if (index < 0 || index >= state.eggs.length) return;
    final egg = state.eggs[index];
    if (!egg.ready) {
      _notify('아직 부화 중입니다!');
      return;
    }

    final tier = egg.tier;
    final eggTierData = GameData.eggTiers[tier];
    // 부화 시점에 rarity 결정
    final rarity = (eggTierData != null) ? _weightedRandom(eggTierData.rarityWeights) : 'Newbie';
    final loot = _eggLoot[tier] ?? _eggLoot['bronze']!;
    final eggCost = GameData.eggTiers[tier]?.cost ?? 500;

    // Roll what comes out
    final totalW = loot.goldW + loot.matW + loot.unitW;
    final roll = _rng.nextDouble() * totalW;

    if (roll < loot.goldW) {
      // Gold reward: 80%~150% of egg cost, rounded to nearest 100
      final raw = eggCost * (0.8 + _rng.nextDouble() * 0.7);
      final amount = (raw / 100).floor() * 100;
      state.gold += amount;
      _notify('${_formatGold(amount)}G 획득!');
    } else if (roll < loot.goldW + loot.matW) {
      // Material reward
      final amount = (loot.matMin + _rng.nextDouble() * (loot.matMax - loot.matMin)).floor();
      final matRoll = _rng.nextDouble();
      String matName;
      if (matRoll < 0.33) {
        state.materials['attackCrystal'] = (state.materials['attackCrystal'] ?? 0) + amount;
        matName = '공격 크리스탈';
      } else if (matRoll < 0.66) {
        state.materials['defenseCore'] = (state.materials['defenseCore'] ?? 0) + amount;
        matName = '방어 코어';
      } else {
        state.materials['speedChip'] = (state.materials['speedChip'] ?? 0) + amount;
        matName = '속도 칩';
      }
      _notify('$matName x$amount 획득!');
    } else {
      // Unit reward
      final candidates = GameData.allies.where((a) => a.rarity == rarity).toList();
      if (candidates.isEmpty) {
        // Fallback to gold
        final raw = eggCost * (0.8 + _rng.nextDouble() * 0.7);
        final amount = (raw / 100).floor() * 100;
        state.gold += amount;
        _notify('${_formatGold(amount)}G 획득!');
      } else {
        final allyData = candidates[_rng.nextInt(candidates.length)];
        final existingIdx = state.allies.indexWhere((a) => a.id == allyData.id);
        if (existingIdx >= 0) {
          // Duplicate -> materials
          final dupAmount = (loot.matMax * 0.8).floor();
          state.materials['attackCrystal'] = (state.materials['attackCrystal'] ?? 0) + dupAmount;
          state.materials['defenseCore'] = (state.materials['defenseCore'] ?? 0) + dupAmount;
          state.materials['speedChip'] = (state.materials['speedChip'] ?? 0) + dupAmount;
          _notify('중복! ${allyData.name} -> 재료 x$dupAmount!');
        } else {
          state.allies.add(OwnedAlly.fromAllyData(allyData));
          if (!state.codexAllies.contains(allyData.id)) {
            state.codexAllies.add(allyData.id);
          }
          _notify('${allyData.name} 부화! ($rarity)');
          if (state.team.length < 5) {
            state.team.add(state.allies.length - 1);
          }
        }
      }
    }

    state.eggs.removeAt(index);
    state.stats['eggsHatched'] = (state.stats['eggsHatched'] ?? 0) + 1;
    advanceMission('egg', 1);
  }

  String _formatGold(num n) {
    if (n >= 1000000) return '${(n / 1000000 * 10).floor() / 10}M';
    if (n >= 10000) return '${(n / 1000 * 10).floor() / 10}K';
    return n.floor().toString();
  }

  // ============================================================
  // BATTLE
  // ============================================================
  void startBattle(int stage) {
    final bossData = getBossData(stage);
    if (bossData == null) return;
    if (state.team.isEmpty) {
      _notify('팀에 아군을 배치하세요!');
      return;
    }

    advanceMission('battle', 1);

    final battle = state.battle;
    battle.active = true;
    battle.bossId = bossData.id;
    battle.stage = stage;
    battle.bossHp = bossData.hp;
    battle.bossMaxHp = bossData.hp;
    battle.timer = 60;
    battle.log = ['전투 시작!'];
    battle.turnInterval = hasSkill('battle_speed') ? 1.0 : 2.0;
    battle.turnTimer = battle.turnInterval * 0.75;
    battle.result = null;
    battle.resultTimer = 0;

    battle.bossState = {
      'atk': bossData.atk,
      'def': bossData.def,
      'spd': bossData.spd,
      'buffs': <Map<String, dynamic>>[],
      'debuffs': <Map<String, dynamic>>[],
      'abilityCooldowns': List<int>.filled(bossData.abilities.length, 0),
    };

    battle.allyStates = state.team.map((idx) {
      final ally = state.allies[idx];
      final levelMult = 1 + (ally.level - 1) * 0.1;
      final codexAtkMult = 1 + getCodexBonus()['atkMult']!;
      return BattleAllyState(
        id: ally.id,
        name: ally.name,
        role: ally.role,
        hp: (ally.baseHp * levelMult).floor(),
        maxHp: (ally.baseHp * levelMult).floor(),
        atk: (ally.baseAtk * levelMult * codexAtkMult).floor(),
        def: (ally.baseDef * levelMult).floor(),
        spd: (ally.baseSpd * levelMult).floor(),
        ability: ally.ability,
      );
    }).toList();
  }

  void updateBattle(double dt) {
    final battle = state.battle;
    if (!battle.active) return;

    if (battle.result != null) {
      battle.resultTimer -= dt;
      if (battle.resultTimer <= 0) {
        if (battle.result == 'win') {
          collectBossRewards();
        }
        battle.active = false;
        battle.result = null;
      }
      return;
    }

    // Timer countdown
    battle.timer -= dt;
    if (battle.timer <= 0) {
      battle.result = 'lose';
      battle.resultTimer = 2;
      battle.log.add('시간 초과! 패배...');
      return;
    }

    // Turn processing
    battle.turnTimer -= dt;
    if (battle.turnTimer <= 0) {
      battle.turnTimer = battle.turnInterval;
      processTurn();
    }

    // Update buff/debuff durations
    _updateBuffs(battle);
  }

  int _getEffectiveStat(Map<String, dynamic> entity, String stat) {
    num base = (entity[stat] ?? 0) as num;
    final buffs = entity['buffs'] as List<Map<String, dynamic>>?;
    if (buffs != null) {
      for (final buff in buffs) {
        if (buff['stat'] == stat) base *= (1 + (buff['amount'] as num));
      }
    }
    final debuffs = entity['debuffs'] as List<Map<String, dynamic>>?;
    if (debuffs != null) {
      for (final debuff in debuffs) {
        if (debuff['stat'] == stat) base *= (1 - (debuff['amount'] as num));
      }
    }
    return max(1, base.floor());
  }

  int _getEffectiveStatAlly(BattleAllyState ally, String stat) {
    num base;
    switch (stat) {
      case 'atk': base = ally.atk; break;
      case 'def': base = ally.def; break;
      case 'spd': base = ally.spd; break;
      case 'hp': base = ally.hp; break;
      default: base = 0;
    }
    for (final buff in ally.buffs) {
      if (buff['stat'] == stat) base *= (1 + (buff['amount'] as num));
    }
    for (final debuff in ally.debuffs) {
      if (debuff['stat'] == stat) base *= (1 - (debuff['amount'] as num));
    }
    return max(1, base.floor());
  }

  int calculateDamage(int atk, int def) {
    final raw = atk * (1 + _rng.nextDouble() * 0.2) - def * 0.5;
    return max(1, raw.floor());
  }

  void processTurn() {
    final battle = state.battle;
    final bossData = getBossData(battle.stage);
    if (bossData == null) return;

    // Allies act first (sorted by speed)
    final aliveAllies = battle.allyStates.where((a) => a.alive).toList();
    aliveAllies.sort((a, b) => _getEffectiveStatAlly(b, 'spd') - _getEffectiveStatAlly(a, 'spd'));

    for (final ally in aliveAllies) {
      if (!battle.active || battle.bossHp <= 0) break;

      if (ally.cooldown > 0) {
        ally.cooldown--;
        // Basic attack
        final dmg = calculateDamage(
          _getEffectiveStatAlly(ally, 'atk'),
          _getEffectiveStat(battle.bossState, 'def'),
        );
        battle.bossHp -= dmg;
        battle.log.add('${ally.name}: $dmg 데미지');
      } else {
        // Use ability
        _executeAllyAbility(ally);
        ally.cooldown = ally.ability.cooldown;
      }
    }

    // Check boss death
    if (battle.bossHp <= 0) {
      battle.bossHp = 0;
      battle.result = 'win';
      battle.resultTimer = 2;
      battle.log.add('보스 처치! 승리!');
      return;
    }

    // Boss acts
    executeBossAction(bossData);

    // Check ally deaths
    final stillAlive = battle.allyStates.where((a) => a.alive).toList();
    if (stillAlive.isEmpty) {
      battle.result = 'lose';
      battle.resultTimer = 2;
      battle.log.add('전멸! 패배...');
    }
  }

  void _executeAllyAbility(BattleAllyState ally) {
    final battle = state.battle;
    final ability = ally.ability;
    final eff = ability.effect;

    if (eff.isEmpty) {
      // Basic attack fallback
      final dmg = calculateDamage(
        _getEffectiveStatAlly(ally, 'atk'),
        _getEffectiveStat(battle.bossState, 'def'),
      );
      battle.bossHp -= dmg;
      battle.log.add('${ally.name}: $dmg 데미지');
      return;
    }

    final type = eff['type'] as String? ?? '';

    switch (type) {
      case 'damage':
        final mult = (eff['multiplier'] ?? 1.0) as num;
        final dmg = calculateDamage(
          (_getEffectiveStatAlly(ally, 'atk') * mult).floor(),
          _getEffectiveStat(battle.bossState, 'def'),
        );
        battle.bossHp -= dmg;
        battle.log.add('${ally.name} ${ability.name}! $dmg');
        break;

      case 'heal':
        List<BattleAllyState> targetList;
        if (eff['target'] == 'all_allies') {
          targetList = battle.allyStates.where((a) => a.alive).toList();
        } else {
          final sorted = battle.allyStates.where((a) => a.alive).toList()
              ..sort((a, b) => (a.hp / a.maxHp).compareTo(b.hp / b.maxHp));
          targetList = sorted.isNotEmpty ? [sorted.first] : [];
        }
        for (final t in targetList) {
          final heal = (t.maxHp * ((eff['amount'] ?? 0.2) as num)).floor();
          t.hp = min(t.maxHp, t.hp + heal);
          battle.log.add('${ally.name} ${ability.name}! +${heal}HP');
        }
        break;

      case 'buff':
        final targets = eff['target'] == 'all_allies'
            ? battle.allyStates.where((a) => a.alive).toList()
            : [ally];
        for (final t in targets) {
          t.buffs.add({
            'stat': eff['stat'], 'amount': eff['amount'],
            'duration': eff['duration'] ?? 2,
          });
        }
        battle.log.add('${ally.name} ${ability.name}! ${(eff['stat'] as String).toUpperCase()}↑');
        break;

      case 'debuff':
        final debuffs = battle.bossState['debuffs'] as List<Map<String, dynamic>>;
        debuffs.add({
          'stat': eff['stat'], 'amount': eff['amount'],
          'duration': eff['duration'] ?? 2,
        });
        battle.log.add('${ally.name} ${ability.name}! 보스 ${(eff['stat'] as String).toUpperCase()}↓');
        break;

      case 'shield':
        final targets = eff['target'] == 'all_allies'
            ? battle.allyStates.where((a) => a.alive).toList()
            : [ally];
        for (final t in targets) {
          t.buffs.add({'stat': 'shield', 'amount': 1, 'duration': eff['duration'] ?? 1});
        }
        battle.log.add('${ally.name} ${ability.name}!');
        break;

      case 'dot':
        final debuffs = battle.bossState['debuffs'] as List<Map<String, dynamic>>;
        debuffs.add({
          'stat': 'dot', 'amount': eff['damagePercent'] ?? 0.05,
          'duration': eff['duration'] ?? 3,
        });
        battle.log.add('${ally.name} ${ability.name}! 독 부여');
        break;

      case 'multi_hit':
        final hits = (eff['hits'] ?? 3) as int;
        int totalDmg = 0;
        for (int i = 0; i < hits; i++) {
          final dmg = calculateDamage(
            (_getEffectiveStatAlly(ally, 'atk') * ((eff['multiplier'] ?? 0.5) as num)).floor(),
            _getEffectiveStat(battle.bossState, 'def'),
          );
          totalDmg += dmg;
        }
        battle.bossHp -= totalDmg;
        battle.log.add('${ally.name} ${ability.name}! $hits연타 $totalDmg');
        break;

      default:
        final dmg = calculateDamage(
          _getEffectiveStatAlly(ally, 'atk'),
          _getEffectiveStat(battle.bossState, 'def'),
        );
        battle.bossHp -= dmg;
        battle.log.add('${ally.name}: $dmg');
    }
  }

  void executeBossAction(BossData bossData) {
    final battle = state.battle;
    final aliveAllies = battle.allyStates.where((a) => a.alive).toList();
    if (aliveAllies.isEmpty) return;

    // Process DOT on boss
    final bossDebuffs = battle.bossState['debuffs'] as List<Map<String, dynamic>>?;
    if (bossDebuffs != null) {
      for (final d in bossDebuffs) {
        if (d['stat'] == 'dot') {
          final dotDmg = (battle.bossMaxHp * (d['amount'] as num)).floor();
          battle.bossHp -= dotDmg;
          battle.log.add('독 데미지: $dotDmg');
        }
      }
    }

    // Pick ability or basic attack
    bool usedAbility = false;
    final cooldowns = battle.bossState['abilityCooldowns'] as List<int>;

    for (int i = 0; i < bossData.abilities.length; i++) {
      if (cooldowns[i] <= 0) {
        final ab = bossData.abilities[i];
        cooldowns[i] = ab.cooldown;

        final abEffect = ab.effect;
        String effType = abEffect['type'] as String? ?? 'basic';
        final target = abEffect['target'] as String?;

        // Normalize effect type
        if (effType == 'damage' && target == 'all') {
          effType = 'damage_all';
        } else if (effType == 'damage' && target == 'single') {
          effType = 'damage_single';
        } else if (effType == 'debuff' && target == 'all') {
          effType = 'debuff_all';
        } else if (effType == 'heal' && target == 'self') {
          effType = 'heal_self';
        } else if (effType == 'buff' && target == 'self') {
          effType = 'buff_self';
        }

        switch (effType) {
          case 'damage_all':
            final mult = (abEffect['multiplier'] ?? 1.0) as num;
            for (final ally in aliveAllies) {
              final shieldIdx = ally.buffs.indexWhere((b) => b['stat'] == 'shield');
              if (shieldIdx >= 0) {
                ally.buffs.removeAt(shieldIdx);
                battle.log.add('${ally.name} 쉴드로 방어!');
              } else {
                final dmg = calculateDamage((bossData.atk * mult).floor(), _getEffectiveStatAlly(ally, 'def'));
                ally.hp -= dmg;
                if (ally.hp <= 0) { ally.hp = 0; ally.alive = false; }
              }
            }
            battle.log.add('보스 ${ab.name}!');
            break;

          case 'damage_single':
            final singleTarget = aliveAllies[_rng.nextInt(aliveAllies.length)];
            final shieldIdx = singleTarget.buffs.indexWhere((b) => b['stat'] == 'shield');
            if (shieldIdx >= 0) {
              singleTarget.buffs.removeAt(shieldIdx);
              battle.log.add('${singleTarget.name} 쉴드로 방어!');
            } else {
              final mult = (abEffect['multiplier'] ?? 1.0) as num;
              final dmg = calculateDamage((bossData.atk * mult).floor(), _getEffectiveStatAlly(singleTarget, 'def'));
              singleTarget.hp -= dmg;
              if (singleTarget.hp <= 0) {
                singleTarget.hp = 0;
                singleTarget.alive = false;
                battle.log.add('${singleTarget.name} 쓰러짐!');
              }
            }
            battle.log.add('보스 ${ab.name}!');
            break;

          case 'debuff_all':
            for (final ally in aliveAllies) {
              ally.debuffs.add({
                'stat': abEffect['stat'],
                'amount': abEffect['amount'],
                'duration': abEffect['duration'] ?? 2,
              });
            }
            battle.log.add('보스 ${ab.name}! ${abEffect['stat']}↓');
            break;

          case 'heal_self':
            final heal = (battle.bossMaxHp * ((abEffect['amount'] ?? 0.1) as num)).floor();
            battle.bossHp = min(battle.bossMaxHp, battle.bossHp + heal);
            battle.log.add('보스 ${ab.name}! +${heal}HP');
            break;

          case 'buff_self':
            final bossBuffs = battle.bossState['buffs'] as List<Map<String, dynamic>>;
            bossBuffs.add({
              'stat': abEffect['stat'],
              'amount': abEffect['amount'],
              'duration': abEffect['duration'] ?? 2,
            });
            battle.log.add('보스 ${ab.name}! ${abEffect['stat']}↑');
            break;

          default:
            final basicTarget = aliveAllies[_rng.nextInt(aliveAllies.length)];
            final dmg = calculateDamage(bossData.atk, _getEffectiveStatAlly(basicTarget, 'def'));
            basicTarget.hp -= dmg;
            if (basicTarget.hp <= 0) { basicTarget.hp = 0; basicTarget.alive = false; }
            battle.log.add('보스 공격! ${basicTarget.name}에게 $dmg');
        }

        usedAbility = true;
        break;
      }
    }

    // Reduce all cooldowns
    for (int i = 0; i < cooldowns.length; i++) {
      if (cooldowns[i] > 0) cooldowns[i]--;
    }

    if (!usedAbility) {
      // Basic attack
      final basicTarget = aliveAllies[_rng.nextInt(aliveAllies.length)];
      final dmg = calculateDamage(bossData.atk, _getEffectiveStatAlly(basicTarget, 'def'));
      basicTarget.hp -= dmg;
      if (basicTarget.hp <= 0) {
        basicTarget.hp = 0;
        basicTarget.alive = false;
        battle.log.add('${basicTarget.name} 쓰러짐!');
      }
      battle.log.add('보스 공격 -> ${basicTarget.name} $dmg');
    }
  }

  void _updateBuffs(BattleState battle) {
    // Ally buffs/debuffs
    for (final ally in battle.allyStates) {
      ally.buffs = ally.buffs.where((b) {
        b['duration'] = (b['duration'] as int) - 1;
        return (b['duration'] as int) > 0;
      }).toList();
      ally.debuffs = ally.debuffs.where((d) {
        d['duration'] = (d['duration'] as int) - 1;
        return (d['duration'] as int) > 0;
      }).toList();
    }
    // Boss buffs/debuffs
    final bossBuffs = battle.bossState['buffs'] as List<Map<String, dynamic>>?;
    if (bossBuffs != null) {
      battle.bossState['buffs'] = bossBuffs.where((b) {
        b['duration'] = (b['duration'] as int) - 1;
        return (b['duration'] as int) > 0;
      }).toList();
    }
    final bossDebuffs = battle.bossState['debuffs'] as List<Map<String, dynamic>>?;
    if (bossDebuffs != null) {
      battle.bossState['debuffs'] = bossDebuffs.where((d) {
        d['duration'] = (d['duration'] as int) - 1;
        return (d['duration'] as int) > 0;
      }).toList();
    }
  }

  void collectBossRewards() {
    final stage = state.battle.stage;
    final bossData = getBossData(stage);
    if (bossData == null) return;

    // Track boss in codex
    if (!state.codexBosses.contains(bossData.id)) {
      state.codexBosses.add(bossData.id);
    }

    final drops = bossData.drops;
    final isFirstClear = stage > state.maxClearedStage;
    final mult = isFirstClear ? 1.0 : 0.4;

    state.gold += (drops.gold * mult).floor();
    state.materials['eggFragment'] = (state.materials['eggFragment'] ?? 0) + (drops.eggFragments * mult).floor();

    for (final mat in drops.materials) {
      final amount = (mat.amount * mult).floor();
      final key = matKey(mat.type);
      if (key == 'random' || key == 'random_material') {
        const mats = ['attackCrystal', 'defenseCore', 'speedChip'];
        final chosen = mats[_rng.nextInt(mats.length)];
        state.materials[chosen] = (state.materials[chosen] ?? 0) + amount;
      } else if (state.materials.containsKey(key)) {
        state.materials[key] = (state.materials[key] ?? 0) + amount;
      }
    }

    // Unlock crops for this stage
    final newCrops = GameData.crops.where((c) =>
        c.unlockStage == stage && !state.unlockedCrops.contains(c.id)).toList();
    for (final crop in newCrops) {
      state.unlockedCrops.add(crop.id);
      _notify('새 작물 해금: ${crop.name}');
    }

    if (isFirstClear) {
      state.maxClearedStage = stage;
      state.stats['bossesDefeated'] = (state.stats['bossesDefeated'] ?? 0) + 1;
      if (stage >= state.currentStage && state.currentStage < 20) {
        state.currentStage++;
      }
    }

    _notify('보상 획득! +${(drops.gold * mult).floor()}G');
  }

  // ============================================================
  // FISHING
  // ============================================================
  FishData? getFishData(String fishId) {
    try { return GameData.fish.firstWhere((f) => f.id == fishId); }
    catch (_) { return null; }
  }

  double _getFishingSpeed() => (1.0 + (state.fishingUpgrades['rod'] ?? 0) * 0.08) * 48;
  double _getFishingRareBoost() => 1.0 + (state.fishingUpgrades['bait'] ?? 0) * 0.05;
  int _getFishingMaxStamina() => 100 + (state.fishingUpgrades['boat'] ?? 0) * 5;

  void updateFishingTiles(double dt) {
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        final tile = state.fishingTiles[r][c];
        if (tile.currentFishId == null) {
          // 빈 포인트: 리스폰 대기
          tile.fishTimer -= dt;
          if (tile.fishTimer <= 0) {
            tile.currentFishId = _pickRandomFish();
            tile.fishDuration = 0; // 리스폰 완료
            tile.fishTimer = 0;
          }
        }
      }
    }
  }

  /// 빈 포인트에 리스폰 타이머 설정
  void _startFishRespawn(FishingTile tile) {
    tile.currentFishId = null;
    tile.fishTimer = 45 + _rng.nextDouble() * 45; // 45~90초 후 리스폰
    tile.fishDuration = tile.fishTimer;
  }

  String _pickRandomFish() {
    final rareBoost = _getFishingRareBoost();
    final totalWeight = GameData.fish.fold<double>(0, (s, f) {
      double w = f.rarity;
      if (f.category == 'rare') w *= rareBoost;
      return s + w;
    });
    double roll = _rng.nextDouble() * totalWeight;
    for (final f in GameData.fish) {
      double w = f.rarity;
      if (f.category == 'rare') w *= rareBoost;
      roll -= w;
      if (roll <= 0) return f.id;
    }
    return GameData.fish.last.id;
  }

  void updateFishingRobot(double dt) {
    final robot = state.fishingRobot;
    final tiles = state.fishingTiles;

    robot.maxStamina = _getFishingMaxStamina().toDouble();
    robot.animTimer += dt;
    if (robot.animTimer > 0.3) {
      robot.animTimer = 0;
      robot.animFrame = (robot.animFrame + 1) % 2;
    }

    switch (robot.state) {
      case 'idle':
        _decideFishingAction(robot, tiles);
        break;
      case 'walking':
        final speed = _getFishingSpeed();
        final tx = robot.targetX * 48.0 + 24;
        final ty = robot.targetY * 48.0 + 24;
        final dx = tx - robot.pixelX;
        final dy = ty - robot.pixelY;
        final dist = sqrt(dx * dx + dy * dy);
        final moveAmt = speed * dt;
        if (dist < 2 || moveAmt >= dist) {
          robot.x = robot.targetX; robot.y = robot.targetY;
          robot.pixelX = tx; robot.pixelY = ty;
          robot.state = robot.nextAction ?? 'idle';
          // 등급별 캐스팅 시간
          robot.stateTimer = _getFishCastTime(tiles[robot.y][robot.x].currentFishId);
          robot.stamina -= 0.5;
        } else {
          robot.pixelX += (dx / dist) * moveAmt;
          robot.pixelY += (dy / dist) * moveAmt;
          robot.stamina -= 0.2 * dt;
        }
        break;
      case 'casting': // cast phase
        robot.stateTimer -= dt;
        if (robot.stateTimer <= 0) {
          robot.state = 'waiting';
          // 등급별 대기 시간
          robot.stateTimer = _getFishWaitTime(tiles[robot.y][robot.x].currentFishId);
        }
        break;
      case 'waiting': // wait phase
        robot.stateTimer -= dt;
        if (robot.stateTimer <= 0) {
          robot.state = 'reeling';
          // 등급별 감기 시간
          robot.stateTimer = _getFishReelTime(tiles[robot.y][robot.x].currentFishId);
        }
        break;
      case 'reeling': // reel phase
        robot.stateTimer -= dt;
        if (robot.stateTimer <= 0) {
          _collectFish(robot.y, robot.x);
          robot.stamina -= 3;
          robot.state = 'idle';
        }
        break;
      case 'resting':
        robot.stamina += 8 * dt;
        if (robot.stamina >= robot.maxStamina * 0.8) {
          robot.stamina = robot.stamina.clamp(0, robot.maxStamina);
          robot.state = 'idle';
        }
        break;
    }
    robot.stamina = robot.stamina.clamp(0, robot.maxStamina);
  }

  String _getFishCategory(String? fishId) {
    if (fishId == null) return 'common';
    final fish = getFishData(fishId);
    return fish?.category ?? 'common';
  }

  // common: 보통, mid: 느림, rare: 매우 느림
  double _getFishCastTime(String? fishId) {
    switch (_getFishCategory(fishId)) {
      case 'rare': return 5.0;
      case 'mid': return 3.5;
      default: return 2.5;
    }
  }

  double _getFishWaitTime(String? fishId) {
    switch (_getFishCategory(fishId)) {
      case 'rare': return 12.0;
      case 'mid': return 8.0;
      default: return 5.0;
    }
  }

  double _getFishReelTime(String? fishId) {
    switch (_getFishCategory(fishId)) {
      case 'rare': return 5.0;
      case 'mid': return 3.0;
      default: return 2.0;
    }
  }

  void _decideFishingAction(RobotState robot, List<List<FishingTile>> tiles) {
    if (robot.stamina <= robot.maxStamina * 0.1) {
      robot.state = 'resting';
      return;
    }
    // Find tile with fish
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (tiles[r][c].currentFishId != null) {
          if (robot.x == c && robot.y == r) {
            robot.state = 'casting';
            robot.stateTimer = 1.5;
          } else {
            robot.targetX = c; robot.targetY = r;
            robot.state = 'walking';
            robot.nextAction = 'casting';
          }
          return;
        }
      }
    }
    robot.stamina += 2 * 0.016;
  }

  void _collectFish(int row, int col) {
    final tile = state.fishingTiles[row][col];
    if (tile.currentFishId == null) return;
    final fish = getFishData(tile.currentFishId!);
    if (fish == null) return;

    // 골드 획득
    if (fish.value > 0) {
      state.gold += fish.value;
      state.stats['totalGoldEarned'] = (state.stats['totalGoldEarned'] ?? 0) + fish.value;
    }

    // 물고기 ID 자체가 요리 재료 (50% 확률)
    if (_rng.nextDouble() < 0.5) {
      state.cookingIngredients[fish.id] =
          (state.cookingIngredients[fish.id] ?? 0) + 1;
    }

    // Track total harvests for spice (50회당 1개)
    state.totalHarvestCount++;
    if (state.totalHarvestCount % 50 == 0) {
      state.cookingIngredients['spice'] =
          (state.cookingIngredients['spice'] ?? 0) + 1;
    }

    // 잡은 후 타일 비우고 리스폰 시작
    _startFishRespawn(tile);
  }

  // ============================================================
  // MINING
  // ============================================================
  OreData? getOreData(String oreId) {
    try { return GameData.ores.firstWhere((o) => o.id == oreId); }
    catch (_) { return null; }
  }

  double _getMiningSpeed() => (1.0 + (state.miningUpgradesState['pickaxe'] ?? 0) * 0.08) * 48;
  double _getMiningRareBoost() => 1.0 + (state.miningUpgradesState['drill'] ?? 0) * 0.05;
  int _getMiningMaxStamina() => 100 + (state.miningUpgradesState['cart'] ?? 0) * 5;

  void updateMiningTiles(double dt) {
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        final tile = state.miningTiles[r][c];
        if (tile.depleted) {
          tile.respawnTimer -= dt;
          if (tile.respawnTimer <= 0) {
            tile.depleted = false;
            tile.currentOreId = _pickRandomOre();
            tile.durability = 2 + _rng.nextInt(2); // 2~3
          }
        } else if (tile.currentOreId == null) {
          tile.currentOreId = _pickRandomOre();
          tile.durability = 3 + _rng.nextInt(3);
        }
      }
    }
  }

  String _pickRandomOre() {
    final rareBoost = _getMiningRareBoost();
    final totalWeight = GameData.ores.fold<double>(0, (s, o) {
      double w = o.rarity;
      if (o.category == 'rare') w *= rareBoost;
      return s + w;
    });
    double roll = _rng.nextDouble() * totalWeight;
    for (final o in GameData.ores) {
      double w = o.rarity;
      if (o.category == 'rare') w *= rareBoost;
      roll -= w;
      if (roll <= 0) return o.id;
    }
    return GameData.ores.last.id;
  }

  void updateMiningRobot(double dt) {
    final robot = state.miningRobot;
    final tiles = state.miningTiles;

    robot.maxStamina = _getMiningMaxStamina().toDouble();
    robot.animTimer += dt;
    if (robot.animTimer > 0.3) {
      robot.animTimer = 0;
      robot.animFrame = (robot.animFrame + 1) % 2;
    }

    switch (robot.state) {
      case 'idle':
        _decideMiningAction(robot, tiles);
        break;
      case 'walking':
        final speed = _getMiningSpeed();
        final tx = robot.targetX * 48.0 + 24;
        final ty = robot.targetY * 48.0 + 24;
        final dx = tx - robot.pixelX;
        final dy = ty - robot.pixelY;
        final dist = sqrt(dx * dx + dy * dy);
        final moveAmt = speed * dt;
        if (dist < 2 || moveAmt >= dist) {
          robot.x = robot.targetX; robot.y = robot.targetY;
          robot.pixelX = tx; robot.pixelY = ty;
          robot.state = robot.nextAction ?? 'idle';
          robot.stateTimer = _getOreDigTime(tiles[robot.y][robot.x].currentOreId);
          robot.stamina -= 0.5;
        } else {
          robot.pixelX += (dx / dist) * moveAmt;
          robot.pixelY += (dy / dist) * moveAmt;
          robot.stamina -= 0.2 * dt;
        }
        break;
      case 'digging': // dig phase
        robot.stateTimer -= dt;
        if (robot.stateTimer <= 0) {
          robot.state = 'extracting';
          robot.stateTimer = _getOreExtractTime(tiles[robot.y][robot.x].currentOreId);
        }
        break;
      case 'extracting': // extract phase
        robot.stateTimer -= dt;
        if (robot.stateTimer <= 0) {
          robot.state = 'collecting';
          robot.stateTimer = _getOreCollectTime(tiles[robot.y][robot.x].currentOreId);
        }
        break;
      case 'collecting': // collect phase
        robot.stateTimer -= dt;
        if (robot.stateTimer <= 0) {
          _collectOre(robot.y, robot.x);
          robot.stamina -= 3;
          robot.state = 'idle';
        }
        break;
      case 'resting':
        robot.stamina += 8 * dt;
        if (robot.stamina >= robot.maxStamina * 0.8) {
          robot.stamina = robot.stamina.clamp(0, robot.maxStamina);
          robot.state = 'idle';
        }
        break;
    }
    robot.stamina = robot.stamina.clamp(0, robot.maxStamina);
  }

  String _getOreCategory(String? oreId) {
    if (oreId == null) return 'common';
    final ore = getOreData(oreId);
    return ore?.category ?? 'common';
  }

  double _getOreDigTime(String? oreId) {
    switch (_getOreCategory(oreId)) {
      case 'rare': return 5.0;
      case 'mid': return 3.5;
      default: return 2.5;
    }
  }

  double _getOreExtractTime(String? oreId) {
    switch (_getOreCategory(oreId)) {
      case 'rare': return 8.0;
      case 'mid': return 5.0;
      default: return 3.0;
    }
  }

  double _getOreCollectTime(String? oreId) {
    switch (_getOreCategory(oreId)) {
      case 'rare': return 4.0;
      case 'mid': return 2.5;
      default: return 1.5;
    }
  }

  void _decideMiningAction(RobotState robot, List<List<MiningTile>> tiles) {
    if (robot.stamina <= robot.maxStamina * 0.1) {
      robot.state = 'resting';
      return;
    }
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        final tile = tiles[r][c];
        if (!tile.depleted && tile.currentOreId != null && tile.durability > 0) {
          if (robot.x == c && robot.y == r) {
            robot.state = 'digging';
            robot.stateTimer = 1.0;
          } else {
            robot.targetX = c; robot.targetY = r;
            robot.state = 'walking';
            robot.nextAction = 'digging';
          }
          return;
        }
      }
    }
    robot.stamina += 2 * 0.016;
  }

  void _collectOre(int row, int col) {
    final tile = state.miningTiles[row][col];
    if (tile.currentOreId == null || tile.depleted) return;
    final ore = getOreData(tile.currentOreId!);
    if (ore == null) return;

    // 골드 획득
    if (ore.value > 0) {
      state.gold += ore.value;
      state.stats['totalGoldEarned'] = (state.stats['totalGoldEarned'] ?? 0) + ore.value;
    }

    // 광석 ID 자체가 요리 재료 (50% 확률)
    if (_rng.nextDouble() < 0.5) {
      state.cookingIngredients[ore.id] =
          (state.cookingIngredients[ore.id] ?? 0) + 1;
    }

    tile.durability--;
    if (tile.durability <= 0) {
      tile.depleted = true;
      tile.respawnTimer = 45 + _rng.nextDouble() * 45; // 45~90s
    }

    // Track total harvests for spice (50회당 1개)
    state.totalHarvestCount++;
    if (state.totalHarvestCount % 50 == 0) {
      state.cookingIngredients['spice'] =
          (state.cookingIngredients['spice'] ?? 0) + 1;
    }
  }

  // ============================================================
  // COOKING & MARKET
  // ============================================================
  Recipe? getRecipe(String recipeId) {
    try { return GameData.recipes.firstWhere((r) => r.id == recipeId); }
    catch (_) { return null; }
  }

  bool canCook(Recipe recipe) {
    for (final ing in recipe.ingredients) {
      if ((state.cookingIngredients[ing.ingredientId] ?? 0) < ing.amount) return false;
    }
    return true;
  }

  void startCooking(int slotIndex, String recipeId) {
    if (slotIndex < 0 || slotIndex >= state.cookingSlots.length) return;
    final slot = state.cookingSlots[slotIndex];
    if (slot.recipeId != null) {
      _notify('이미 요리 중입니다!');
      return;
    }
    final recipe = getRecipe(recipeId);
    if (recipe == null) return;
    if (!canCook(recipe)) {
      _notify('재료가 부족합니다!');
      return;
    }
    // Consume ingredients
    for (final ing in recipe.ingredients) {
      state.cookingIngredients[ing.ingredientId] =
          (state.cookingIngredients[ing.ingredientId] ?? 0) - ing.amount;
    }
    slot.recipeId = recipeId;
    slot.totalTime = recipe.cookTime.toDouble();
    slot.timeLeft = recipe.cookTime.toDouble();
    slot.ready = false;
    _notify('${recipe.name} 요리 시작!');
  }

  void updateCooking(double dt) {
    for (final slot in state.cookingSlots) {
      if (slot.recipeId != null && slot.ready) {
        // 구버전 잔류물 또는 이미 완성된 슬롯 자동 판매
        _autoSellDish(slot);
        continue;
      }
      if (slot.recipeId != null && !slot.ready && slot.timeLeft > 0) {
        slot.timeLeft -= dt;
        if (slot.timeLeft <= 0) {
          slot.timeLeft = 0;
          slot.ready = true;
          // 자동 판매
          _autoSellDish(slot);
        }
      }
    }
  }

  void _autoSellDish(CookingSlot slot) {
    if (slot.recipeId == null) return;
    final recipe = getRecipe(slot.recipeId!);
    if (recipe == null) return;
    double mult = 1.0;
    final mp = state.marketPrices.where((p) => p.recipeId == slot.recipeId).firstOrNull;
    if (mp != null) mult = mp.multiplier;
    final price = (recipe.basePrice * mult).floor();
    state.gold += price;
    state.stats['totalGoldEarned'] = (state.stats['totalGoldEarned'] ?? 0) + price;
    _notify('${recipe.name} 자동 판매! +${price}G');
    // 슬롯 비우기
    slot.recipeId = null;
    slot.timeLeft = 0;
    slot.totalTime = 0;
    slot.ready = false;
  }

  void updateMarket(double dt) {
    // Initialize market prices if empty
    if (state.marketPrices.isEmpty) {
      _initMarketPrices();
    }
    state.marketTimer -= dt;
    if (state.marketTimer <= 0) {
      _updateMarketPrices();
      state.marketTimer = state.marketTimerMax;
      _notify('시장 시세 변동!');
    }
  }

  void _initMarketPrices() {
    state.marketPrices = GameData.recipes.map((r) =>
        MarketPrice(recipeId: r.id, multiplier: 1.0)).toList();
  }

  void _updateMarketPrices() {
    for (final mp in state.marketPrices) {
      // Mean-reverting random walk
      final drift = (1.0 - mp.multiplier) * 0.3; // pull toward 1.0
      final noise = (_rng.nextDouble() - 0.5) * 0.4;
      mp.multiplier = (mp.multiplier + drift + noise).clamp(0.5, 2.0);
    }
  }

  // ============================================================
  // FISHING / MINING UPGRADES
  // ============================================================
  void upgradeFishing(String stat) {
    final data = GameData.fishingUpgrades[stat];
    if (data == null) return;
    final level = state.fishingUpgrades[stat] ?? 0;
    final maxLevel = (data['maxLevel'] as num).toInt();
    if (level >= maxLevel) { _notify('최대 레벨!'); return; }
    final cost = ((data['baseCost'] as num) * pow((data['costMult'] as num), level)).floor();
    if (state.gold < cost) { _notify('골드 부족!'); return; }
    state.gold -= cost;
    state.fishingUpgrades[stat] = level + 1;
    _notify('낚시 업그레이드! $stat Lv.${state.fishingUpgrades[stat]}');
    advanceMission('upgrade', 1);
  }

  void upgradeMining(String stat) {
    final data = GameData.miningUpgrades[stat];
    if (data == null) return;
    final level = state.miningUpgradesState[stat] ?? 0;
    final maxLevel = (data['maxLevel'] as num).toInt();
    if (level >= maxLevel) { _notify('최대 레벨!'); return; }
    final cost = ((data['baseCost'] as num) * pow((data['costMult'] as num), level)).floor();
    if (state.gold < cost) { _notify('골드 부족!'); return; }
    state.gold -= cost;
    state.miningUpgradesState[stat] = level + 1;
    _notify('채광 업그레이드! $stat Lv.${state.miningUpgradesState[stat]}');
    advanceMission('upgrade', 1);
  }

  // ============================================================
  // ALLY UPGRADES
  // ============================================================
  void upgradeAlly(int allyIndex, String stat) {
    if (allyIndex < 0 || allyIndex >= state.allies.length) return;
    final ally = state.allies[allyIndex];

    final level = ally.level;
    final cost = (100 * pow(1.5, level - 1)).floor();
    final matCost = (3 * pow(1.3, level - 1)).floor();

    if (state.gold < cost) {
      _notify('골드 부족!');
      return;
    }

    String matType;
    String matName;
    switch (stat) {
      case 'atk': matType = 'attackCrystal'; matName = '공격 크리스탈'; break;
      case 'def': matType = 'defenseCore'; matName = '방어 코어'; break;
      case 'spd': matType = 'speedChip'; matName = '속도 칩'; break;
      case 'hp': matType = 'mutagen'; matName = '뮤타젠'; break;
      default: return;
    }

    if ((state.materials[matType] ?? 0) < matCost) {
      _notify('$matName 부족!');
      return;
    }

    state.gold -= cost;
    state.materials[matType] = (state.materials[matType] ?? 0) - matCost;
    ally.level++;

    // Increase base stats
    if (stat == 'atk') {
      ally.baseAtk += 3;
    } else if (stat == 'def') {
      ally.baseDef += 2;
    } else if (stat == 'spd') {
      ally.baseSpd += 1;
    } else if (stat == 'hp') {
      ally.baseHp += 15;
    }
    ally.baseHp += 5;

    _notify('${ally.name} Lv.${ally.level}!');
    advanceMission('upgrade', 1);
  }

  // ============================================================
  // ROBOT UPGRADES
  // ============================================================
  int getRobotMaxLevel(String stat) {
    final data = GameData.robotUpgrades[stat];
    if (data == null) return 20;
    final base = (data['maxLevel'] as num).toInt();
    return state.maxClearedStage >= 10 ? 100 : base;
  }

  void upgradeRobot(String stat) {
    final data = GameData.robotUpgrades[stat];
    if (data == null) return;
    final level = state.robotUpgrades[stat] ?? 0;
    final maxLevel = getRobotMaxLevel(stat);
    if (level >= maxLevel) {
      _notify('최대 레벨!');
      return;
    }
    final cost = ((data['baseCost'] as num) * pow((data['costMult'] as num), level)).floor();
    if (state.gold < cost) {
      _notify('골드 부족!');
      return;
    }
    state.gold -= cost;
    state.robotUpgrades[stat] = level + 1;
    _notify('로봇 업그레이드! $stat Lv.${state.robotUpgrades[stat]}');
    advanceMission('upgrade', 1);
  }

  // ============================================================
  // SKILLS
  // ============================================================
  void buySkill(String id) {
    final skill = skillDefs.firstWhere((s) => s['id'] == id, orElse: () => {});
    if (skill.isEmpty) return;
    if (hasSkill(id)) { _notify('이미 해금!'); return; }
    if (skill['requires'] != null && !hasSkill(skill['requires'] as String)) {
      _notify('선행 스킬 필요!');
      return;
    }
    if (state.gold < (skill['cost'] as int)) { _notify('골드 부족!'); return; }

    state.gold -= skill['cost'] as int;
    state.skills.add(id);

    if (id == 'egg_slot_3') state.maxEggSlots = max(state.maxEggSlots, 3);
    if (id == 'egg_slot_4') state.maxEggSlots = max(state.maxEggSlots, 4);

    _notify('${skill['name']} 해금!');
  }

  // ============================================================
  // FLOATING TEXTS
  // ============================================================
  void _updateFloatingTexts(double dt) {
    for (final ft in state.floatingTexts) {
      ft.timer -= dt;
    }
    state.floatingTexts.removeWhere((ft) => ft.timer <= 0);
  }

  // CODEX
  // ============================================================
  void syncCodex() {
    // Allies: all owned ally IDs (unique)
    state.codexAllies = state.allies.map((a) => a.id).toSet().toList();

    // Crops: keep existing + all planted/assigned crops
    final cropSet = <String>{...state.codexCrops};
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        final tile = state.farmTiles[r][c];
        if (tile.crop != null) cropSet.add(tile.crop!);
        if (tile.assignedCrop != null) cropSet.add(tile.assignedCrop!);
      }
    }
    state.codexCrops = cropSet.toList();

    // Bosses: all cleared stages
    final bossSet = <String>{...state.codexBosses};
    for (int s = 1; s <= state.maxClearedStage; s++) {
      final bd = getBossData(s);
      if (bd != null) bossSet.add(bd.id);
    }
    state.codexBosses = bossSet.toList();
  }

  Map<String, double> getCodexBonus() {
    final allyCount = state.codexAllies.length;
    final cropCount = state.codexCrops.length;
    final bossCount = state.codexBosses.length;
    return {
      'goldMult': (allyCount ~/ 5) * 0.03,      // +3% per 5 allies
      'growthMult': (cropCount ~/ 3) * 0.02,     // +2% per 3 crops
      'atkMult': (bossCount ~/ 2) * 0.05,        // +5% per 2 bosses
    };
  }

  // ============================================================
  // FARM EVENTS
  // ============================================================
  void updateFarmEvents(double dt) {
    state.nextEventCountdown -= dt;
    if (state.nextEventCountdown <= 0) {
      _triggerRandomEvent();
      state.nextEventCountdown = 300 + _rng.nextDouble() * 600;
    }

    if (state.farmEvent != null) {
      state.farmEventTimer -= dt;
      if (state.farmEventTimer <= 0) {
        state.farmEvent = null;
      }
    }
  }

  void _triggerRandomEvent() {
    const events = [
      {'name': '로봇 오버드라이브!', 'effect': 'overdrive', 'duration': 30},
      {'name': '비옥한 토양!', 'effect': 'fertile', 'duration': 60},
      {'name': '돌연변이 비!', 'effect': 'mutagen_rain', 'duration': 45},
      {'name': '유성 충돌!', 'effect': 'meteor', 'duration': 0},
    ];
    final event = events[_rng.nextInt(events.length)];

    if (event['effect'] == 'meteor') {
      // Destroy random crop, give crystal
      final occupied = <Map<String, int>>[];
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          if (state.farmTiles[r][c].crop != null) {
            occupied.add({'r': r, 'c': c});
          }
        }
      }
      if (occupied.isNotEmpty) {
        final target = occupied[_rng.nextInt(occupied.length)];
        state.farmTiles[target['r']!][target['c']!].crop = null;
        state.farmTiles[target['r']!][target['c']!].growthProgress = 0;
        state.materials['attackCrystal'] = (state.materials['attackCrystal'] ?? 0) + 3;
        state.materials['defenseCore'] = (state.materials['defenseCore'] ?? 0) + 3;
        _notify('유성 충돌! 크리스탈 획득!');
      }
      return;
    }

    state.farmEvent = event['effect'] as String;
    state.farmEventTimer = (event['duration'] as int).toDouble();
    _notify(event['name'] as String);
  }

  // ============================================================
  // MISSIONS
  // ============================================================
  void generateMissions() {
    final shuffled = List<Map<String, dynamic>>.from(_missionTemplates)
      ..shuffle(_rng);
    final picked = shuffled.take(3).toList();
    state.missions = picked.map((tmpl) {
      final targets = tmpl['targets'] as List<int>;
      final tier = _rng.nextInt(targets.length);
      final target = targets[tier];
      final rewardAmounts = tmpl['rewardAmounts'] as List<int>;
      return Mission(
        id: tmpl['id'] as String,
        desc: (tmpl['desc'] as String).replaceAll('{n}', target.toString()),
        target: target,
        reward: {'type': tmpl['rewardType'], 'amount': rewardAmounts[tier]},
      );
    }).toList();
  }

  void advanceMission(String id, int amount) {
    for (final m in state.missions) {
      if (m.id == id && !m.completed) {
        m.progress += amount;
        if (m.progress >= m.target) {
          m.progress = m.target;
          m.completed = true;
          _notify('미션 완료!');
        }
      }
    }
  }

  void claimMission(int index) {
    if (index < 0 || index >= state.missions.length) return;
    final m = state.missions[index];
    if (!m.completed || m.claimed) return;
    m.claimed = true;

    final rewardType = m.reward['type'] as String;
    final rewardAmount = m.reward['amount'] as int;

    if (rewardType == 'gold') {
      state.gold += rewardAmount;
      _notify('+${rewardAmount}G 보상!');
    } else if (rewardType == 'eggFragment') {
      state.materials['eggFragment'] = (state.materials['eggFragment'] ?? 0) + rewardAmount;
      _notify('+$rewardAmount 알 조각 보상!');
    } else if (rewardType == 'material') {
      state.materials['attackCrystal'] = (state.materials['attackCrystal'] ?? 0) + rewardAmount;
      state.materials['defenseCore'] = (state.materials['defenseCore'] ?? 0) + rewardAmount;
      state.materials['speedChip'] = (state.materials['speedChip'] ?? 0) + rewardAmount;
      _notify('+$rewardAmount 재료 보상!');
    }
  }

  // ============================================================
  // CATCH-UP (simulate elapsed time in 200ms steps)
  // ============================================================
  void catchUp(double elapsedSec) {
    const step = 0.2;
    double remaining = elapsedSec;
    while (remaining > 0) {
      final s = min(remaining, step);
      update(s);
      remaining -= s;
    }
  }

  // ============================================================
  // SAVE / LOAD
  // ============================================================
  Future<void> saveGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('traymonster_save', json.encode(state.toJson()));
    } catch (e) {
      // Save failed silently
    }
  }

  Future<void> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('traymonster_save');
      if (raw == null) return;
      final data = json.decode(raw) as Map<String, dynamic>;
      state.loadFromJson(data);
    } catch (e) {
      // Load failed silently
    }
  }
}
