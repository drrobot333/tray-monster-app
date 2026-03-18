class Drop {
  final String type;
  final int amount;
  const Drop(this.type, this.amount);
  Map<String, dynamic> toJson() => {'type': type, 'amount': amount};
  factory Drop.fromJson(Map<String, dynamic> j) => Drop(j['type'] as String, j['amount'] as int);
}

class CropData {
  final String id, name, category;
  final int growTime, value, unlockStage;
  final List<Drop> drops;
  const CropData({required this.id, required this.name, required this.category,
    required this.growTime, required this.value, this.unlockStage = 0, this.drops = const []});
}

class MutationRecipe {
  final String cropId, resultId;
  final double chance;
  const MutationRecipe({required this.cropId, required this.resultId, required this.chance});
}

class AbilityData {
  final String name;
  final int cooldown;
  final Map<String, dynamic> effect;
  const AbilityData({required this.name, this.cooldown = 2, this.effect = const {}});
}

class AllyData {
  final String id, name, role, rarity;
  final int baseAtk, baseDef, baseSpd, baseHp;
  final AbilityData ability;
  const AllyData({required this.id, required this.name, required this.role,
    required this.rarity, required this.baseAtk, required this.baseDef,
    required this.baseSpd, required this.baseHp, required this.ability});
}

class BossAbility {
  final String name;
  final int cooldown;
  final Map<String, dynamic> effect;
  const BossAbility({required this.name, this.cooldown = 3, this.effect = const {}});
}

class BossDrops {
  final int gold, eggFragments;
  final List<Drop> materials;
  final String? special;
  const BossDrops({required this.gold, required this.eggFragments,
    this.materials = const [], this.special});
}

class BossData {
  final String id, name;
  final int stage, hp, atk, def, spd;
  final List<BossAbility> abilities;
  final BossDrops drops;
  const BossData({required this.id, required this.name, required this.stage,
    required this.hp, required this.atk, required this.def, required this.spd,
    required this.abilities, required this.drops});
}

class EggTier {
  final int cost, incubationTime;
  final Map<String, int> rarityWeights;
  const EggTier({required this.cost, required this.incubationTime, required this.rarityWeights});
}

class SkillDef {
  final String id, name, desc;
  final int cost;
  final String? requires;
  const SkillDef({required this.id, required this.name, required this.desc,
    required this.cost, this.requires});
}

class FarmTile {
  String? crop;
  String? assignedCrop;
  double growthProgress = 0;
  bool watered = false;
  bool golden = false;
  FarmTile();
  Map<String, dynamic> toJson() => {
    'crop': crop, 'assignedCrop': assignedCrop,
    'growthProgress': growthProgress, 'watered': watered, 'golden': golden,
  };
  factory FarmTile.fromJson(Map<String, dynamic> j) => FarmTile()
    ..crop = j['crop'] as String? ..assignedCrop = j['assignedCrop'] as String?
    ..growthProgress = (j['growthProgress'] ?? 0).toDouble()
    ..watered = j['watered'] ?? false ..golden = j['golden'] ?? false;
}

class RobotState {
  String name;
  int x = 1, y = 1, targetX = 1, targetY = 1;
  double pixelX = 72, pixelY = 72;
  String state = 'idle';
  String? nextAction;
  double stamina = 100, maxStamina = 100;
  double stateTimer = 0, animTimer = 0;
  int animFrame = 0;
  // Offline/sleepwalk system
  double awakeSince = 0;     // game time when last clicked
  bool sleepwalking = false;  // true = 50% efficiency
  int pendingGold = 0;        // accumulated gold while sleepwalking
  int pendingItems = 0;       // accumulated items while sleepwalking
  RobotState({this.name = '농장봇'});
}

class OwnedAlly {
  final String id, name, role, rarity;
  final int baseAtk, baseDef, baseSpd, baseHp; // original from game_data, never changes
  final AbilityData ability;
  int level;
  int atkLevel, defLevel, spdLevel, hpLevel;

  // Rarity multipliers: [atk, def, spd, hp]
  static const _rarityMult = {
    'Newbie':    [1.0, 1.0, 0.5, 5.0],
    'Normal':    [2.0, 1.5, 0.5, 8.0],
    'Rookie':    [3.0, 2.0, 1.0, 12.0],
    'Legendary': [4.0, 3.0, 1.0, 18.0],
    'Mythic':    [5.0, 4.0, 2.0, 25.0],
  };
  List<double> get _mult => _rarityMult[rarity] ?? [1.0, 1.0, 0.5, 5.0];

  // Computed stats: base + level * rarity_multiplier
  int get atk => baseAtk + (atkLevel * _mult[0]).floor();
  int get def => baseDef + (defLevel * _mult[1]).floor();
  int get spd => baseSpd + (spdLevel * _mult[2]).floor();
  int get hp => baseHp + (hpLevel * _mult[3]).floor();
  int get totalLevel => 1 + atkLevel + defLevel + spdLevel + hpLevel;

  OwnedAlly({required this.id, required this.name, required this.role,
    required this.rarity, required this.baseAtk, required this.baseDef,
    required this.baseSpd, required this.baseHp, required this.ability,
    this.level = 1, this.atkLevel = 0, this.defLevel = 0, this.spdLevel = 0, this.hpLevel = 0});
  factory OwnedAlly.fromAllyData(AllyData a) => OwnedAlly(
    id: a.id, name: a.name, role: a.role, rarity: a.rarity,
    baseAtk: a.baseAtk, baseDef: a.baseDef, baseSpd: a.baseSpd,
    baseHp: a.baseHp, ability: a.ability);
  int statLevel(String stat) {
    switch (stat) { case 'atk': return atkLevel; case 'def': return defLevel;
      case 'spd': return spdLevel; case 'hp': return hpLevel; default: return 0; }
  }
  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'role': role, 'rarity': rarity,
    'baseAtk': baseAtk, 'baseDef': baseDef, 'baseSpd': baseSpd, 'baseHp': baseHp,
    'level': totalLevel, 'atkLevel': atkLevel, 'defLevel': defLevel, 'spdLevel': spdLevel, 'hpLevel': hpLevel,
    'ability': {'name': ability.name, 'cooldown': ability.cooldown, 'effect': ability.effect},
  };
  factory OwnedAlly.fromJson(Map<String, dynamic> j) {
    final oldLevel = (j['level'] ?? 1) as int;
    final hasStatLevels = j.containsKey('atkLevel');
    final fallback = hasStatLevels ? 0 : ((oldLevel - 1) ~/ 4);
    return OwnedAlly(
    id: j['id'] as String, name: j['name'] as String, role: j['role'] as String, rarity: j['rarity'] as String,
    baseAtk: j['baseAtk'] as int, baseDef: j['baseDef'] as int, baseSpd: j['baseSpd'] as int, baseHp: j['baseHp'] as int,
    ability: AbilityData(name: (j['ability']?['name'] ?? '') as String, cooldown: (j['ability']?['cooldown'] ?? 2) as int,
      effect: Map<String, dynamic>.from(j['ability']?['effect'] ?? {})),
    level: oldLevel,
    atkLevel: j['atkLevel'] ?? fallback, defLevel: j['defLevel'] ?? fallback,
    spdLevel: j['spdLevel'] ?? fallback, hpLevel: j['hpLevel'] ?? fallback);
  }
}

class IncubatingEgg {
  String tier, rarity;
  double timeLeft, totalTime;
  bool ready;
  IncubatingEgg({required this.tier, required this.rarity,
    required this.timeLeft, required this.totalTime, this.ready = false});
  Map<String, dynamic> toJson() => {'tier': tier, 'rarity': rarity, 'timeLeft': timeLeft, 'totalTime': totalTime, 'ready': ready};
  factory IncubatingEgg.fromJson(Map<String, dynamic> j) => IncubatingEgg(
    tier: j['tier'] as String, rarity: j['rarity'] as String,
    timeLeft: (j['timeLeft'] ?? 0).toDouble(), totalTime: (j['totalTime'] ?? 0).toDouble(),
    ready: j['ready'] ?? false);
}

class BattleAllyState {
  String id, name, role;
  int hp, maxHp, atk, def, spd, cooldown;
  double actionTimer; // time until next action (lower spd = longer wait)
  int abilityCharges; // counts basic attacks before ability fires
  List<Map<String, dynamic>> buffs = [];
  List<Map<String, dynamic>> debuffs = [];
  bool alive;
  AbilityData ability;
  BattleAllyState({required this.id, required this.name, required this.role,
    required this.hp, required this.maxHp, required this.atk, required this.def,
    required this.spd, this.cooldown = 0, this.alive = true, required this.ability,
    this.actionTimer = 0, this.abilityCharges = 0});
}

class BattleState {
  bool active = false;
  String? bossId;
  int stage = 1;
  int bossHp = 0, bossMaxHp = 0;
  double timer = 60;
  List<String> log = [];
  double turnTimer = 0, turnInterval = 2.0;
  String? result;
  double resultTimer = 0;
  List<BattleAllyState> allyStates = [];
  Map<String, dynamic> bossState = {};
}

class Mission {
  String id, desc;
  int target, progress;
  Map<String, dynamic> reward;
  bool completed, claimed;
  Mission({required this.id, required this.desc, required this.target,
    this.progress = 0, required this.reward, this.completed = false, this.claimed = false});
  Map<String, dynamic> toJson() => {
    'id': id, 'desc': desc, 'target': target, 'progress': progress,
    'reward': reward, 'completed': completed, 'claimed': claimed};
  factory Mission.fromJson(Map<String, dynamic> j) => Mission(
    id: j['id'] as String, desc: j['desc'] as String, target: j['target'] as int,
    progress: j['progress'] ?? 0, reward: Map<String, dynamic>.from(j['reward'] ?? {}),
    completed: j['completed'] ?? false, claimed: j['claimed'] ?? false);
}

class FloatingText {
  final String text;
  final int col, row; // grid position
  final int color;
  double timer; // seconds remaining
  FloatingText({required this.text, required this.col, required this.row,
    this.color = 0xFFFFD700, this.timer = 1.5});
}

// =========================================================================
// FISHING
// =========================================================================
class FishData {
  final String id, name, category;
  final int value;
  final double rarity;
  const FishData({required this.id, required this.name, required this.category,
    required this.value, required this.rarity});
}

class FishingTile {
  String? currentFishId;
  double fishTimer = 0; // time until fish type changes
  double fishDuration = 90; // total cycle
  FishingTile();
  Map<String, dynamic> toJson() => {
    'currentFishId': currentFishId, 'fishTimer': fishTimer, 'fishDuration': fishDuration,
  };
  factory FishingTile.fromJson(Map<String, dynamic> j) => FishingTile()
    ..currentFishId = j['currentFishId'] as String?
    ..fishTimer = (j['fishTimer'] ?? 0).toDouble()
    ..fishDuration = (j['fishDuration'] ?? 90).toDouble();
}

// =========================================================================
// MINING
// =========================================================================
class OreData {
  final String id, name, category;
  final int value;
  final double rarity;
  const OreData({required this.id, required this.name, required this.category,
    required this.value, required this.rarity});
}

class MiningTile {
  String? currentOreId;
  int durability = 0; // hits remaining (3~5)
  double respawnTimer = 0; // time until respawn after depletion
  bool depleted = false;
  MiningTile();
  Map<String, dynamic> toJson() => {
    'currentOreId': currentOreId, 'durability': durability,
    'respawnTimer': respawnTimer, 'depleted': depleted,
  };
  factory MiningTile.fromJson(Map<String, dynamic> j) => MiningTile()
    ..currentOreId = j['currentOreId'] as String?
    ..durability = (j['durability'] as num?)?.toInt() ?? 0
    ..respawnTimer = (j['respawnTimer'] ?? 0).toDouble()
    ..depleted = j['depleted'] ?? false;
}

// =========================================================================
// COOKING
// =========================================================================
class RecipeIngredient {
  final String ingredientId;
  final int amount;
  const RecipeIngredient(this.ingredientId, this.amount);
}

class Recipe {
  final String id, name, emoji;
  final int tier, cookTime, basePrice;
  final List<RecipeIngredient> ingredients;
  const Recipe({required this.id, required this.name, required this.tier,
    required this.cookTime, required this.basePrice, required this.ingredients,
    this.emoji = '🍽️'});
}

class CookingSlot {
  String? recipeId;
  double timeLeft = 0;
  double totalTime = 0;
  bool ready = false;
  CookingSlot();
  Map<String, dynamic> toJson() => {
    'recipeId': recipeId, 'timeLeft': timeLeft, 'totalTime': totalTime, 'ready': ready,
  };
  factory CookingSlot.fromJson(Map<String, dynamic> j) => CookingSlot()
    ..recipeId = j['recipeId'] as String?
    ..timeLeft = (j['timeLeft'] ?? 0).toDouble()
    ..totalTime = (j['totalTime'] ?? 0).toDouble()
    ..ready = j['ready'] ?? false;
}

class MarketPrice {
  String recipeId;
  double multiplier; // 0.5x ~ 2.0x
  MarketPrice({required this.recipeId, this.multiplier = 1.0});
  Map<String, dynamic> toJson() => {'recipeId': recipeId, 'multiplier': multiplier};
  factory MarketPrice.fromJson(Map<String, dynamic> j) => MarketPrice(
    recipeId: j['recipeId'] as String,
    multiplier: (j['multiplier'] ?? 1.0).toDouble());
}

// =========================================================================
// ARTIFACTS
// =========================================================================
class ArtifactData {
  final String id, name, emoji;
  final String effectType; // goldMult, atkMult, defMult, spdMult, hpMult, growthMult, hatchMult, goldenMult
  const ArtifactData({required this.id, required this.name, required this.emoji, required this.effectType});
}

class OwnedArtifact {
  final String artifactId;
  String rarity;
  int level;
  int duplicates; // collected for promotion

  OwnedArtifact({required this.artifactId, this.rarity = 'Newbie', this.level = 1, this.duplicates = 0});

  // Rarity-based effect per level
  static const _effectPerLevel = {
    'Newbie': 0.02, 'Normal': 0.03, 'Rookie': 0.05, 'Legendary': 0.08, 'Mythic': 0.12,
  };
  static const _maxLevel = {
    'Newbie': 5, 'Normal': 8, 'Rookie': 12, 'Legendary': 15, 'Mythic': 20,
  };
  static const _promotionCost = {
    'Newbie': 2, 'Normal': 3, 'Rookie': 4, 'Legendary': 5,
  };

  double get effectValue => level * (_effectPerLevel[rarity] ?? 0.02);
  int get maxLevel => _maxLevel[rarity] ?? 5;
  int? get promotionDuplicatesNeeded => _promotionCost[rarity]; // null = can't promote (Mythic)
  String? get nextRarity {
    const order = ['Newbie', 'Normal', 'Rookie', 'Legendary', 'Mythic'];
    final idx = order.indexOf(rarity);
    return idx < order.length - 1 ? order[idx + 1] : null;
  }

  Map<String, dynamic> toJson() => {
    'artifactId': artifactId, 'rarity': rarity, 'level': level, 'duplicates': duplicates,
  };
  factory OwnedArtifact.fromJson(Map<String, dynamic> j) => OwnedArtifact(
    artifactId: j['artifactId'] as String,
    rarity: j['rarity'] as String? ?? 'Newbie',
    level: (j['level'] as num?)?.toInt() ?? 1,
    duplicates: (j['duplicates'] as num?)?.toInt() ?? 0,
  );
}

// =========================================================================
// ABILITY SYSTEM
// =========================================================================
class AbilityLine {
  String grade;   // Common/Rare/Epic/Legendary
  String optionId; // e.g. 'atk', 'gold', 'allStat'
  int value;       // rolled value within range
  bool locked;

  AbilityLine({this.grade = 'Common', this.optionId = 'atk', this.value = 0, this.locked = false});

  Map<String, dynamic> toJson() => {'grade': grade, 'optionId': optionId, 'value': value, 'locked': locked};
  factory AbilityLine.fromJson(Map<String, dynamic> j) => AbilityLine(
    grade: j['grade'] as String? ?? 'Common',
    optionId: j['optionId'] as String? ?? 'atk',
    value: (j['value'] as num?)?.toInt() ?? 0,
    locked: j['locked'] ?? false,
  );
}

class AbilityState {
  String tier;  // Shared grade: Common/Rare/Epic/Legendary
  int rerollCount; // shared rerolls at current tier
  List<List<AbilityLine>> slots; // 5 slots, each with 3 lines
  int activeSlot; // which slot is currently applied (0~4)
  int viewingSlot; // which slot is being edited in UI (0~4)

  static const int maxSlots = 5;

  AbilityState({this.tier = 'Common', this.rerollCount = 0, List<List<AbilityLine>>? slots, this.activeSlot = 0, this.viewingSlot = 0})
    : slots = slots ?? List.generate(maxSlots, (_) => [AbilityLine(), AbilityLine(), AbilityLine()]);

  // Active slot's lines (for applying bonuses)
  List<AbilityLine> get activeLines => slots[activeSlot];
  // Currently viewed slot's lines (for UI/rerolling)
  List<AbilityLine> get viewingLines => slots[viewingSlot];

  static const tierOrder = ['Common', 'Rare', 'Epic', 'Legendary'];
  static const promotionCost = {'Common': 100, 'Rare': 250, 'Epic': 500};
  static const rerollCost = {'Common': 500, 'Rare': 2000, 'Epic': 8000, 'Legendary': 30000};

  int get rerollGoldCost {
    final base = rerollCost[tier] ?? 500;
    final lockedCount = viewingLines.where((l) => l.locked).length;
    if (lockedCount == 2) return base * 5;
    if (lockedCount == 1) return base * 2;
    return base;
  }

  int? get promotionRerollsNeeded => promotionCost[tier];
  bool get canPromote {
    final needed = promotionRerollsNeeded;
    return needed != null && rerollCount >= needed;
  }
  String? get nextTier {
    final idx = tierOrder.indexOf(tier);
    return idx < tierOrder.length - 1 ? tierOrder[idx + 1] : null;
  }

  Map<String, dynamic> toJson() => {
    'tier': tier, 'rerollCount': rerollCount, 'activeSlot': activeSlot,
    'slots': slots.map((s) => s.map((l) => l.toJson()).toList()).toList(),
  };
  factory AbilityState.fromJson(Map<String, dynamic> j) {
    // Migration: old format had 'lines', new has 'slots'
    if (j.containsKey('slots') && j['slots'] is List) {
      return AbilityState(
        tier: j['tier'] as String? ?? 'Common',
        rerollCount: (j['rerollCount'] as num?)?.toInt() ?? 0,
        activeSlot: (j['activeSlot'] as num?)?.toInt() ?? 0,
        slots: (j['slots'] as List<dynamic>).map((slot) =>
          (slot as List<dynamic>).map((l) =>
            AbilityLine.fromJson(Map<String, dynamic>.from(l as Map))).toList()).toList(),
      );
    }
    // Old format migration
    final oldLines = (j['lines'] as List<dynamic>?)
      ?.map((l) => AbilityLine.fromJson(Map<String, dynamic>.from(l as Map)))
      .toList() ?? [AbilityLine(), AbilityLine(), AbilityLine()];
    final allSlots = List.generate(maxSlots, (i) =>
      i == 0 ? oldLines : [AbilityLine(), AbilityLine(), AbilityLine()]);
    return AbilityState(
      tier: j['tier'] as String? ?? 'Common',
      rerollCount: (j['rerollCount'] as num?)?.toInt() ?? 0,
      slots: allSlots,
    );
  }
}

class ArtifactChestTier {
  final String id, name;
  final int goldCost, keyCost;
  final int goldW, matW, artifactW; // weights
  final Map<String, int> rarityWeights;
  const ArtifactChestTier({required this.id, required this.name,
    required this.goldCost, required this.keyCost,
    required this.goldW, required this.matW, required this.artifactW,
    required this.rarityWeights});
}
