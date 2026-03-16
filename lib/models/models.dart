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
  RobotState({this.name = '농장봇'});
}

class OwnedAlly {
  final String id, name, role, rarity;
  int baseAtk, baseDef, baseSpd, baseHp;
  final AbilityData ability;
  int level;
  OwnedAlly({required this.id, required this.name, required this.role,
    required this.rarity, required this.baseAtk, required this.baseDef,
    required this.baseSpd, required this.baseHp, required this.ability, this.level = 1});
  factory OwnedAlly.fromAllyData(AllyData a) => OwnedAlly(
    id: a.id, name: a.name, role: a.role, rarity: a.rarity,
    baseAtk: a.baseAtk, baseDef: a.baseDef, baseSpd: a.baseSpd,
    baseHp: a.baseHp, ability: a.ability);
  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'role': role, 'rarity': rarity,
    'baseAtk': baseAtk, 'baseDef': baseDef, 'baseSpd': baseSpd, 'baseHp': baseHp,
    'level': level, 'ability': {'name': ability.name, 'cooldown': ability.cooldown, 'effect': ability.effect},
  };
  factory OwnedAlly.fromJson(Map<String, dynamic> j) => OwnedAlly(
    id: j['id'] as String, name: j['name'] as String, role: j['role'] as String, rarity: j['rarity'] as String,
    baseAtk: j['baseAtk'] as int, baseDef: j['baseDef'] as int, baseSpd: j['baseSpd'] as int, baseHp: j['baseHp'] as int,
    ability: AbilityData(name: (j['ability']?['name'] ?? '') as String, cooldown: (j['ability']?['cooldown'] ?? 2) as int,
      effect: Map<String, dynamic>.from(j['ability']?['effect'] ?? {})),
    level: j['level'] ?? 1);
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
  List<Map<String, dynamic>> buffs = [];
  List<Map<String, dynamic>> debuffs = [];
  bool alive;
  AbilityData ability;
  BattleAllyState({required this.id, required this.name, required this.role,
    required this.hp, required this.maxHp, required this.atk, required this.def,
    required this.spd, this.cooldown = 0, this.alive = true, required this.ability});
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
