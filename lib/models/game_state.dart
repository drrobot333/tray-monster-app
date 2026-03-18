import 'package:flutter/foundation.dart';
import 'models.dart';

class GameState extends ChangeNotifier {
  // ── Currency & resources ──
  int gold = 100;
  Map<String, int> materials = {
    'attackCrystal': 0,
    'defenseCore': 0,
    'speedChip': 0,
    'mutagen': 0,
    'eggFragment': 0,
    'starDust': 0,
  };

  // ── Stage progression ──
  int currentStage = 1;
  int maxClearedStage = 0;

  // ── Farm ──
  List<List<FarmTile>> farmTiles = [];
  RobotState robot = RobotState(name: '농장봇');
  Map<String, int> robotUpgrades = {
    'moveSpeed': 0,
    'growthBoost': 0,
    'stamina': 0,
  };

  // ── Fishing ──
  List<List<FishingTile>> fishingTiles = [];
  RobotState fishingRobot = RobotState(name: '낚시봇');
  Map<String, int> fishingUpgrades = {
    'rod': 0,
    'bait': 0,
    'boat': 0,
  };

  // ── Mining ──
  List<List<MiningTile>> miningTiles = [];
  RobotState miningRobot = RobotState(name: '채광봇');
  Map<String, int> miningUpgradesState = {
    'pickaxe': 0,
    'drill': 0,
    'cart': 0,
  };

  // ── Cooking ──
  Map<String, int> cookingIngredients = {};
  List<CookingSlot> cookingSlots = [CookingSlot(), CookingSlot()];
  int totalHarvestCount = 0; // for spice generation

  // ── Market ──
  List<MarketPrice> marketPrices = [];
  double marketTimer = 21600; // 6 hours in seconds
  double marketTimerMax = 21600;

  // ── Allies & team ──
  List<OwnedAlly> allies = [];
  List<int> team = []; // indices into allies (max 5)

  // ── Eggs ──
  List<IncubatingEgg> eggs = [];
  int maxEggSlots = 2;

  // ── Weather ──
  String currentWeather = 'sunny';
  String nextWeather = 'rain';
  double weatherTimer = 180;
  double weatherDuration = 180;

  // ── Battle ──
  BattleState battle = BattleState();

  // ── Skills ──
  Set<String> skills = {};

  // ── Codex ──
  List<String> codexAllies = [];
  List<String> codexCrops = [];
  List<String> codexBosses = [];

  // ── Missions ──
  List<Mission> missions = [];
  String lastMissionResetDay = '';

  // ── Unlocked crops ──
  List<String> unlockedCrops = ['tomato', 'potato', 'corn', 'carrot'];

  // ── Stats ──
  Map<String, int> stats = {
    'totalGoldEarned': 0,
    'cropsHarvested': 0,
    'bossesDefeated': 0,
    'eggsHatched': 0,
    'goldenCrops': 0,
  };

  // ── Farm events ──
  String? farmEvent;
  double farmEventTimer = 0;
  double nextEventCountdown = 600;

  // ── Time ──
  double time = 0;

  // ── Notification (for UI) ──
  String? notification;
  double notificationTimer = 0;

  // ── Floating texts (gold earned, etc.) ──
  List<FloatingText> floatingTexts = [];

  // ── Workstation tab index ──
  int workstationTab = 0;

  GameState() {
    _initFarm();
    _initFishing();
    _initMining();
  }

  void _initFarm() {
    farmTiles = List.generate(3, (_) => List.generate(3, (_) => FarmTile()));
  }

  void _initFishing() {
    fishingTiles = List.generate(3, (_) => List.generate(3, (_) => FishingTile()));
  }

  void _initMining() {
    miningTiles = List.generate(3, (_) => List.generate(3, (_) => MiningTile()));
  }

  /// Call this instead of notifyListeners() from the engine.
  void notify() {
    notifyListeners();
  }

  /// 구버전 일반화된 재료를 세부 아이템으로 분배 (해금된 것만)
  void _migrateLegacyIngredients() {
    // 농장 재료는 해금된 작물만 대상
    final farmMigrations = {
      'produce': ['tomato', 'potato', 'corn', 'carrot', 'wheat', 'pumpkin'],
      'combatHerb': ['fire_pepper', 'iron_root', 'dash_leaf', 'cactus', 'thunder_wheat', 'mana_grape'],
      'rareSeed': ['lucky_clover', 'starfruit', 'moon_blossom', 'sunstone_fruit'],
    };
    // 낚시/채광 재료는 전부 대상
    const otherMigrations = {
      'fishMeat': ['salmon', 'eel', 'mackerel'],
      'fishOil': ['tuna'],
      'premiumSeafood': ['lobster'],
      'dragonScale': ['dragonfish'],
      'refinedMineral': ['iron', 'copper', 'coal'],
      'gem': ['goldOre', 'silver', 'emerald'],
      'rareGem': ['ruby'],
      'mithrilShard': ['mithril'],
    };

    for (final entry in farmMigrations.entries) {
      final amount = cookingIngredients[entry.key] ?? 0;
      if (amount <= 0) continue;
      final targets = entry.value.where((c) => unlockedCrops.contains(c)).toList();
      if (targets.isEmpty) { cookingIngredients.remove(entry.key); continue; }
      final perItem = amount ~/ targets.length;
      var remainder = amount % targets.length;
      for (final target in targets) {
        final extra = remainder > 0 ? 1 : 0;
        if (remainder > 0) remainder--;
        cookingIngredients[target] = (cookingIngredients[target] ?? 0) + perItem + extra;
      }
      cookingIngredients.remove(entry.key);
    }
    for (final entry in otherMigrations.entries) {
      final amount = cookingIngredients[entry.key] ?? 0;
      if (amount <= 0) continue;
      final targets = entry.value;
      final perItem = amount ~/ targets.length;
      var remainder = amount % targets.length;
      for (final target in targets) {
        final extra = remainder > 0 ? 1 : 0;
        if (remainder > 0) remainder--;
        cookingIngredients[target] = (cookingIngredients[target] ?? 0) + perItem + extra;
      }
      cookingIngredients.remove(entry.key);
    }
  }

  // ── JSON serialization ──

  Map<String, dynamic> toJson() => {
        'gold': gold,
        'materials': materials,
        'currentStage': currentStage,
        'maxClearedStage': maxClearedStage,
        'allies': allies.map((a) => a.toJson()).toList(),
        'team': team,
        'eggs': eggs.map((e) => e.toJson()).toList(),
        'maxEggSlots': maxEggSlots,
        'farm': {
          'tiles': farmTiles
              .map((row) => row.map((t) => t.toJson()).toList())
              .toList(),
          'robotUpgrades': robotUpgrades,
          'robot': {
            'x': robot.x,
            'y': robot.y,
            'stamina': robot.stamina,
            'name': robot.name,
            'awakeSince': robot.awakeSince,
            'sleepwalking': robot.sleepwalking,
            'pendingGold': robot.pendingGold,
            'pendingItems': robot.pendingItems,
          },
        },
        'fishing': {
          'tiles': fishingTiles
              .map((row) => row.map((t) => t.toJson()).toList())
              .toList(),
          'upgrades': fishingUpgrades,
          'robot': {
            'x': fishingRobot.x,
            'y': fishingRobot.y,
            'stamina': fishingRobot.stamina,
            'name': fishingRobot.name,
          },
        },
        'mining': {
          'tiles': miningTiles
              .map((row) => row.map((t) => t.toJson()).toList())
              .toList(),
          'upgrades': miningUpgradesState,
          'robot': {
            'x': miningRobot.x,
            'y': miningRobot.y,
            'stamina': miningRobot.stamina,
            'name': miningRobot.name,
          },
        },
        'cooking': {
          'ingredients': cookingIngredients,
          'slots': cookingSlots.map((s) => s.toJson()).toList(),
          'totalHarvestCount': totalHarvestCount,
        },
        'market': {
          'prices': marketPrices.map((p) => p.toJson()).toList(),
          'timer': marketTimer,
        },
        'weather': {
          'current': currentWeather,
          'next': nextWeather,
          'timer': weatherTimer,
          'duration': weatherDuration,
        },
        'unlockedCrops': unlockedCrops,
        'stats': stats,
        'codex': {
          'allies': codexAllies,
          'crops': codexCrops,
          'bosses': codexBosses,
        },
        'missions': {
          'list': missions.map((m) => m.toJson()).toList(),
          'lastResetDay': lastMissionResetDay,
        },
        'skills': skills.toList(),
        'time': time,
      };

  void loadFromJson(Map<String, dynamic> data) {
    gold = data['gold'] as int? ?? 100;

    if (data['materials'] is Map) {
      final m = Map<String, dynamic>.from(data['materials'] as Map);
      for (final key in materials.keys) {
        materials[key] = (m[key] as num?)?.toInt() ?? 0;
      }
    }

    currentStage = data['currentStage'] as int? ?? 1;
    maxClearedStage = data['maxClearedStage'] as int? ?? 0;

    allies = (data['allies'] as List<dynamic>?)
            ?.map((e) => OwnedAlly.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    team =
        (data['team'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? [];

    eggs = (data['eggs'] as List<dynamic>?)
            ?.map((e) => IncubatingEgg.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    maxEggSlots = data['maxEggSlots'] as int? ?? 2;

    if (data['farm'] is Map) {
      final farm = Map<String, dynamic>.from(data['farm'] as Map);
      if (farm['tiles'] is List) {
        final tileData = farm['tiles'] as List<dynamic>;
        farmTiles = tileData
            .map((row) => (row as List<dynamic>)
                .map((t) => FarmTile.fromJson(Map<String, dynamic>.from(t as Map)))
                .toList())
            .toList();
      }
      if (farm['robotUpgrades'] is Map) {
        final ru = Map<String, dynamic>.from(farm['robotUpgrades'] as Map);
        for (final key in robotUpgrades.keys) {
          robotUpgrades[key] = (ru[key] as num?)?.toInt() ?? 0;
        }
      }
      if (farm['robot'] is Map) {
        final r = Map<String, dynamic>.from(farm['robot'] as Map);
        final rx = (r['x'] as num?)?.toInt() ?? 1;
        final ry = (r['y'] as num?)?.toInt() ?? 1;
        robot = RobotState(name: r['name'] as String? ?? '농장봇')
          ..x = rx
          ..y = ry
          ..targetX = rx
          ..targetY = ry
          ..pixelX = rx * 48.0 + 24.0
          ..pixelY = ry * 48.0 + 24.0
          ..stamina = (r['stamina'] as num?)?.toDouble() ?? 100.0
          ..state = 'idle'
          ..awakeSince = (r['awakeSince'] as num?)?.toDouble() ?? 0
          ..sleepwalking = r['sleepwalking'] ?? false
          ..pendingGold = (r['pendingGold'] as num?)?.toInt() ?? 0
          ..pendingItems = (r['pendingItems'] as num?)?.toInt() ?? 0;
      }
    }

    // ── Fishing ──
    if (data['fishing'] is Map) {
      final f = Map<String, dynamic>.from(data['fishing'] as Map);
      if (f['tiles'] is List) {
        final tileData = f['tiles'] as List<dynamic>;
        fishingTiles = tileData
            .map((row) => (row as List<dynamic>)
                .map((t) => FishingTile.fromJson(Map<String, dynamic>.from(t as Map)))
                .toList())
            .toList();
      }
      if (f['upgrades'] is Map) {
        final fu = Map<String, dynamic>.from(f['upgrades'] as Map);
        for (final key in fishingUpgrades.keys) {
          fishingUpgrades[key] = (fu[key] as num?)?.toInt() ?? 0;
        }
      }
      if (f['robot'] is Map) {
        final r = Map<String, dynamic>.from(f['robot'] as Map);
        final rx = (r['x'] as num?)?.toInt() ?? 1;
        final ry = (r['y'] as num?)?.toInt() ?? 1;
        fishingRobot = RobotState(name: r['name'] as String? ?? '낚시봇')
          ..x = rx ..y = ry ..targetX = rx ..targetY = ry
          ..pixelX = rx * 48.0 + 24.0 ..pixelY = ry * 48.0 + 24.0
          ..stamina = (r['stamina'] as num?)?.toDouble() ?? 100.0
          ..state = 'idle';
      }
    } else {
      _initFishing();
    }

    // ── Mining ──
    if (data['mining'] is Map) {
      final m = Map<String, dynamic>.from(data['mining'] as Map);
      if (m['tiles'] is List) {
        final tileData = m['tiles'] as List<dynamic>;
        miningTiles = tileData
            .map((row) => (row as List<dynamic>)
                .map((t) => MiningTile.fromJson(Map<String, dynamic>.from(t as Map)))
                .toList())
            .toList();
      }
      if (m['upgrades'] is Map) {
        final mu = Map<String, dynamic>.from(m['upgrades'] as Map);
        for (final key in miningUpgradesState.keys) {
          miningUpgradesState[key] = (mu[key] as num?)?.toInt() ?? 0;
        }
      }
      if (m['robot'] is Map) {
        final r = Map<String, dynamic>.from(m['robot'] as Map);
        final rx = (r['x'] as num?)?.toInt() ?? 1;
        final ry = (r['y'] as num?)?.toInt() ?? 1;
        miningRobot = RobotState(name: r['name'] as String? ?? '채광봇')
          ..x = rx ..y = ry ..targetX = rx ..targetY = ry
          ..pixelX = rx * 48.0 + 24.0 ..pixelY = ry * 48.0 + 24.0
          ..stamina = (r['stamina'] as num?)?.toDouble() ?? 100.0
          ..state = 'idle';
      }
    } else {
      _initMining();
    }

    // ── Cooking ──
    if (data['cooking'] is Map) {
      final c = Map<String, dynamic>.from(data['cooking'] as Map);
      if (c['ingredients'] is Map) {
        cookingIngredients = Map<String, int>.from(
          (c['ingredients'] as Map).map((k, v) => MapEntry(k as String, (v as num).toInt())));
      }
      if (c['slots'] is List) {
        cookingSlots = (c['slots'] as List<dynamic>)
            .map((s) => CookingSlot.fromJson(Map<String, dynamic>.from(s as Map)))
            .toList();
      }
      totalHarvestCount = (c['totalHarvestCount'] as num?)?.toInt() ?? 0;
    }
    // 레거시 재료 키 마이그레이션 (구버전 → 세부 아이템)
    _migrateLegacyIngredients();

    // ── Market ──
    if (data['market'] is Map) {
      final mk = Map<String, dynamic>.from(data['market'] as Map);
      if (mk['prices'] is List) {
        marketPrices = (mk['prices'] as List<dynamic>)
            .map((p) => MarketPrice.fromJson(Map<String, dynamic>.from(p as Map)))
            .toList();
      }
      marketTimer = (mk['timer'] as num?)?.toDouble() ?? 21600;
    }

    if (data['weather'] is Map) {
      final w = Map<String, dynamic>.from(data['weather'] as Map);
      currentWeather = w['current'] as String? ?? 'sunny';
      nextWeather = w['next'] as String? ?? 'rain';
      weatherTimer = (w['timer'] as num?)?.toDouble() ?? 180.0;
      weatherDuration = (w['duration'] as num?)?.toDouble() ?? 180.0;
    }

    unlockedCrops = (data['unlockedCrops'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        ['tomato', 'potato', 'corn', 'carrot'];

    if (data['stats'] is Map) {
      final s = Map<String, dynamic>.from(data['stats'] as Map);
      for (final key in stats.keys) {
        stats[key] = (s[key] as num?)?.toInt() ?? 0;
      }
    }

    if (data['codex'] is Map) {
      final c = Map<String, dynamic>.from(data['codex'] as Map);
      codexAllies =
          (c['allies'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];
      codexCrops =
          (c['crops'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];
      codexBosses =
          (c['bosses'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];
    }

    if (data['missions'] is Map) {
      final m = Map<String, dynamic>.from(data['missions'] as Map);
      missions = (m['list'] as List<dynamic>?)
              ?.map((e) => Mission.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [];
      lastMissionResetDay = m['lastResetDay'] as String? ?? '';
    }

    skills = {};
    if (data['skills'] is List) {
      for (final s in (data['skills'] as List<dynamic>)) {
        skills.add(s as String);
      }
    } else if (data['skills'] is Map) {
      final sk = Map<String, dynamic>.from(data['skills'] as Map);
      for (final entry in sk.entries) {
        if (entry.value == true) skills.add(entry.key);
      }
    }

    // Re-apply egg slot skills
    if (skills.contains('egg_slot_3')) {
      maxEggSlots = maxEggSlots < 3 ? 3 : maxEggSlots;
    }
    if (skills.contains('egg_slot_4')) {
      maxEggSlots = maxEggSlots < 4 ? 4 : maxEggSlots;
    }

    time = (data['time'] as num?)?.toDouble() ?? 0.0;

    notifyListeners();
  }
}
