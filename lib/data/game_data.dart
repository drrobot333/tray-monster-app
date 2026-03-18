import '../models/models.dart';
import 'fishing_data.dart' as fishing;
import 'mining_data.dart' as mining;
import 'cooking_data.dart' as cooking;

// =========================================================================
// CROPS (24 total)
// =========================================================================
const List<CropData> _crops = [
  // --- BASIC CROPS ---
  CropData(id: 'tomato', name: '토마토', category: 'basic', growTime: 30, value: 10, unlockStage: 0, drops: []),
  CropData(id: 'potato', name: '감자', category: 'basic', growTime: 40, value: 15, unlockStage: 0, drops: []),
  CropData(id: 'corn', name: '옥수수', category: 'basic', growTime: 50, value: 20, unlockStage: 0, drops: []),
  CropData(id: 'carrot', name: '당근', category: 'basic', growTime: 30, value: 12, unlockStage: 0, drops: []),
  CropData(id: 'wheat', name: '밀', category: 'basic', growTime: 60, value: 30, unlockStage: 1, drops: []),
  CropData(id: 'pumpkin', name: '호박', category: 'basic', growTime: 90, value: 60, unlockStage: 3, drops: []),

  // --- COMBAT CROPS ---
  CropData(id: 'fire_pepper', name: '불고추', category: 'combat', growTime: 50, value: 0, unlockStage: 1, drops: [Drop('Attack Crystal', 1)]),
  CropData(id: 'iron_root', name: '철뿌리', category: 'combat', growTime: 60, value: 0, unlockStage: 1, drops: [Drop('Defense Core', 1)]),
  CropData(id: 'dash_leaf', name: '질풍잎', category: 'combat', growTime: 40, value: 0, unlockStage: 2, drops: [Drop('Speed Chip', 1)]),
  CropData(id: 'cactus', name: '선인장', category: 'combat', growTime: 80, value: 0, unlockStage: 4, drops: [Drop('Defense Core', 2)]),
  CropData(id: 'thunder_wheat', name: '번개밀', category: 'combat', growTime: 70, value: 0, unlockStage: 5, drops: [Drop('Attack Crystal', 2)]),
  CropData(id: 'mana_grape', name: '마나포도', category: 'combat', growTime: 80, value: 0, unlockStage: 6, drops: [Drop('random_material', 2)]),
  CropData(id: 'poison_mushroom', name: '독버섯', category: 'combat', growTime: 60, value: 0, unlockStage: 7, drops: [Drop('Attack Crystal', 1), Drop('Mutagen', 1)]),
  CropData(id: 'crystal_berry', name: '크리스탈베리', category: 'combat', growTime: 100, value: 0, unlockStage: 10, drops: [Drop('random_material', 3)]),

  // --- RARE CROPS ---
  CropData(id: 'lucky_clover', name: '행운클로버', category: 'rare', growTime: 50, value: 5, unlockStage: 3, drops: []),
  CropData(id: 'starfruit', name: '별열매', category: 'rare', growTime: 120, value: 100, unlockStage: 8, drops: [Drop('Egg Fragment', 3)]),
  CropData(id: 'moon_blossom', name: '달꽃', category: 'rare', growTime: 120, value: 80, unlockStage: 10, drops: [Drop('Mutagen', 3)]),
  CropData(id: 'sunstone_fruit', name: '태양석과일', category: 'rare', growTime: 100, value: 120, unlockStage: 12, drops: []),

  // --- MUTATION CROPS ---
  CropData(id: 'giant_tomato', name: '거대토마토', category: 'mutation', growTime: 0, value: 200, unlockStage: 0, drops: []),
  CropData(id: 'inferno_blossom', name: '지옥꽃', category: 'mutation', growTime: 0, value: 0, unlockStage: 0, drops: [Drop('Attack Crystal', 5)]),
  CropData(id: 'arcane_vine', name: '마법덩굴', category: 'mutation', growTime: 0, value: 0, unlockStage: 0, drops: [Drop('Attack Crystal', 3), Drop('Defense Core', 3), Drop('Speed Chip', 3), Drop('Mutagen', 3)]),
  CropData(id: 'rainbow_clover', name: '무지개클로버', category: 'mutation', growTime: 0, value: 500, unlockStage: 0, drops: [Drop('golden_guarantee', 1)]),
  CropData(id: 'harvest_king', name: '수확왕', category: 'mutation', growTime: 0, value: 300, unlockStage: 0, drops: [Drop('Egg Fragment', 5)]),
  CropData(id: 'doom_spore', name: '파멸포자', category: 'mutation', growTime: 0, value: 0, unlockStage: 0, drops: [Drop('Mutagen', 5)]),
];

// =========================================================================
// MUTATIONS (6 total)
// =========================================================================
const List<MutationRecipe> _mutations = [
  MutationRecipe(cropId: 'tomato', resultId: 'giant_tomato', chance: 0.08),
  MutationRecipe(cropId: 'fire_pepper', resultId: 'inferno_blossom', chance: 0.06),
  MutationRecipe(cropId: 'mana_grape', resultId: 'arcane_vine', chance: 0.05),
  MutationRecipe(cropId: 'lucky_clover', resultId: 'rainbow_clover', chance: 0.04),
  MutationRecipe(cropId: 'corn', resultId: 'harvest_king', chance: 0.05),
  MutationRecipe(cropId: 'poison_mushroom', resultId: 'doom_spore', chance: 0.06),
];

// =========================================================================
// ALLIES (40 total)
// =========================================================================
const List<AllyData> _allies = [
  // --- NEWBIE (8) ---
  AllyData(
    id: 'sproutling', name: 'Sproutling', role: 'healer', rarity: 'Newbie',
    baseAtk: 10, baseDef: 8, baseSpd: 7, baseHp: 90,
    ability: AbilityData(name: 'Gentle Bloom', cooldown: 4, effect: {'type': 'heal', 'target': 'lowest_ally', 'amount': 0.15}),
  ),
  AllyData(
    id: 'ember_pup', name: 'Ember Pup', role: 'dps', rarity: 'Newbie',
    baseAtk: 14, baseDef: 8, baseSpd: 9, baseHp: 80,
    ability: AbilityData(name: 'Flame Bite', cooldown: 3, effect: {'type': 'damage', 'target': 'single', 'multiplier': 1.3}),
  ),
  AllyData(
    id: 'puddle_slime', name: 'Puddle Slime', role: 'tank', rarity: 'Newbie',
    baseAtk: 10, baseDef: 12, baseSpd: 5, baseHp: 100,
    ability: AbilityData(name: 'Goo Shield', cooldown: 5, effect: {'type': 'shield', 'target': 'self', 'duration': 1}),
  ),
  AllyData(
    id: 'zap_bug', name: 'Zap Bug', role: 'speed', rarity: 'Newbie',
    baseAtk: 12, baseDef: 8, baseSpd: 10, baseHp: 80,
    ability: AbilityData(name: 'Static Jolt', cooldown: 3, effect: {'type': 'debuff', 'target': 'single_enemy', 'stat': 'spd', 'amount': 0.1, 'duration': 2}),
  ),
  AllyData(
    id: 'pebble_golem', name: 'Pebble Golem', role: 'tank', rarity: 'Newbie',
    baseAtk: 11, baseDef: 12, baseSpd: 5, baseHp: 100,
    ability: AbilityData(name: 'Rock Wall', cooldown: 4, effect: {'type': 'buff', 'target': 'single_ally', 'stat': 'def', 'amount': 0.2, 'duration': 2}),
  ),
  AllyData(
    id: 'seed_shooter', name: 'Seed Shooter', role: 'dps', rarity: 'Newbie',
    baseAtk: 15, baseDef: 8, baseSpd: 8, baseHp: 82,
    ability: AbilityData(name: 'Seed Barrage', cooldown: 4, effect: {'type': 'damage', 'target': 'single', 'multiplier': 1.4}),
  ),
  AllyData(
    id: 'glow_moth', name: 'Glow Moth', role: 'buffer', rarity: 'Newbie',
    baseAtk: 10, baseDef: 9, baseSpd: 9, baseHp: 85,
    ability: AbilityData(name: 'Luminous Dust', cooldown: 5, effect: {'type': 'buff', 'target': 'all_allies', 'stat': 'atk', 'amount': 0.08, 'duration': 2}),
  ),
  AllyData(
    id: 'thorn_rat', name: 'Thorn Rat', role: 'debuffer', rarity: 'Newbie',
    baseAtk: 13, baseDef: 9, baseSpd: 10, baseHp: 84,
    ability: AbilityData(name: 'Poison Scratch', cooldown: 4, effect: {'type': 'dot', 'target': 'single_enemy', 'damagePercent': 0.03, 'duration': 3}),
  ),

  // --- NORMAL (8) ---
  AllyData(
    id: 'iron_beetle', name: 'Iron Beetle', role: 'tank', rarity: 'Normal',
    baseAtk: 16, baseDef: 18, baseSpd: 8, baseHp: 130,
    ability: AbilityData(name: 'Carapace Guard', cooldown: 5, effect: {'type': 'shield', 'target': 'self', 'duration': 2}),
  ),
  AllyData(
    id: 'flame_fox', name: 'Flame Fox', role: 'dps', rarity: 'Normal',
    baseAtk: 22, baseDef: 12, baseSpd: 14, baseHp: 100,
    ability: AbilityData(name: 'Fox Fire', cooldown: 3, effect: {'type': 'damage', 'target': 'single', 'multiplier': 1.5}),
  ),
  AllyData(
    id: 'coral_sprite', name: 'Coral Sprite', role: 'healer', rarity: 'Normal',
    baseAtk: 15, baseDef: 14, baseSpd: 10, baseHp: 110,
    ability: AbilityData(name: 'Tidal Mend', cooldown: 4, effect: {'type': 'heal', 'target': 'lowest_ally', 'amount': 0.20}),
  ),
  AllyData(
    id: 'wind_hawk', name: 'Wind Hawk', role: 'speed', rarity: 'Normal',
    baseAtk: 19, baseDef: 12, baseSpd: 14, baseHp: 105,
    ability: AbilityData(name: 'Gale Strike', cooldown: 4, effect: {'type': 'buff', 'target': 'all_allies', 'stat': 'spd', 'amount': 0.10, 'duration': 2}),
  ),
  AllyData(
    id: 'mushroom_knight', name: 'Mushroom Knight', role: 'tank', rarity: 'Normal',
    baseAtk: 17, baseDef: 17, baseSpd: 9, baseHp: 125,
    ability: AbilityData(name: 'Spore Armor', cooldown: 4, effect: {'type': 'buff', 'target': 'single_ally', 'stat': 'def', 'amount': 0.25, 'duration': 2}),
  ),
  AllyData(
    id: 'bomb_berry', name: 'Bomb Berry', role: 'aoe_dps', rarity: 'Normal',
    baseAtk: 20, baseDef: 13, baseSpd: 10, baseHp: 108,
    ability: AbilityData(name: 'Berry Blast', cooldown: 5, effect: {'type': 'damage', 'target': 'all_enemies', 'multiplier': 1.0}),
  ),
  AllyData(
    id: 'honey_bee', name: 'Honey Bee', role: 'buffer', rarity: 'Normal',
    baseAtk: 16, baseDef: 14, baseSpd: 12, baseHp: 112,
    ability: AbilityData(name: 'Royal Jelly', cooldown: 5, effect: {'type': 'buff', 'target': 'all_allies', 'stat': 'atk', 'amount': 0.12, 'duration': 2}),
  ),
  AllyData(
    id: 'shadow_cat', name: 'Shadow Cat', role: 'debuffer', rarity: 'Normal',
    baseAtk: 21, baseDef: 13, baseSpd: 13, baseHp: 102,
    ability: AbilityData(name: 'Dark Claw', cooldown: 3, effect: {'type': 'debuff', 'target': 'single_enemy', 'stat': 'def', 'amount': 0.15, 'duration': 2}),
  ),

  // --- ROOKIE (8) ---
  AllyData(
    id: 'crystal_guardian', name: 'Crystal Guardian', role: 'tank', rarity: 'Rookie',
    baseAtk: 23, baseDef: 25, baseSpd: 12, baseHp: 170,
    ability: AbilityData(name: 'Prism Barrier', cooldown: 6, effect: {'type': 'shield', 'target': 'all_allies', 'duration': 1}),
  ),
  AllyData(
    id: 'magma_drake', name: 'Magma Drake', role: 'aoe_dps', rarity: 'Rookie',
    baseAtk: 30, baseDef: 18, baseSpd: 14, baseHp: 140,
    ability: AbilityData(name: 'Lava Breath', cooldown: 5, effect: {'type': 'damage', 'target': 'all_enemies', 'multiplier': 1.2}),
  ),
  AllyData(
    id: 'moonwell_fairy', name: 'Moonwell Fairy', role: 'healer', rarity: 'Rookie',
    baseAtk: 22, baseDef: 20, baseSpd: 15, baseHp: 135,
    ability: AbilityData(name: 'Moonlight Heal', cooldown: 5, effect: {'type': 'heal', 'target': 'all_allies', 'amount': 0.12}),
  ),
  AllyData(
    id: 'storm_falcon', name: 'Storm Falcon', role: 'speed', rarity: 'Rookie',
    baseAtk: 27, baseDef: 18, baseSpd: 18, baseHp: 132,
    ability: AbilityData(name: 'Thunder Dive', cooldown: 3, effect: {'type': 'damage', 'target': 'single', 'multiplier': 1.6}),
  ),
  AllyData(
    id: 'granite_titan', name: 'Granite Titan', role: 'tank', rarity: 'Rookie',
    baseAtk: 24, baseDef: 25, baseSpd: 12, baseHp: 170,
    ability: AbilityData(name: 'Earthen Fortify', cooldown: 5, effect: {'type': 'buff', 'target': 'all_allies', 'stat': 'def', 'amount': 0.15, 'duration': 2}),
  ),
  AllyData(
    id: 'vine_whip', name: 'Vine Whip', role: 'dps', rarity: 'Rookie',
    baseAtk: 28, baseDef: 19, baseSpd: 16, baseHp: 138,
    ability: AbilityData(name: 'Lash Flurry', cooldown: 4, effect: {'type': 'multi_hit', 'target': 'random_enemies', 'hits': 3, 'multiplier': 0.7}),
  ),
  AllyData(
    id: 'war_drummer', name: 'War Drummer', role: 'buffer', rarity: 'Rookie',
    baseAtk: 25, baseDef: 20, baseSpd: 14, baseHp: 150,
    ability: AbilityData(name: 'Battle Rhythm', cooldown: 6, effect: {'type': 'buff', 'target': 'all_allies', 'stat': 'atk', 'amount': 0.15, 'duration': 3}),
  ),
  AllyData(
    id: 'plague_rat', name: 'Plague Rat', role: 'debuffer', rarity: 'Rookie',
    baseAtk: 26, baseDef: 19, baseSpd: 17, baseHp: 136,
    ability: AbilityData(name: 'Pestilence', cooldown: 5, effect: {'type': 'dot', 'target': 'single_enemy', 'damagePercent': 0.04, 'duration': 3}),
  ),

  // --- LEGENDARY (8) ---
  AllyData(
    id: 'obsidian_warden', name: 'Obsidian Warden', role: 'tank', rarity: 'Legendary',
    baseAtk: 32, baseDef: 35, baseSpd: 16, baseHp: 220,
    ability: AbilityData(name: 'Obsidian Wall', cooldown: 6, effect: {'type': 'shield', 'target': 'all_allies', 'duration': 2}),
  ),
  AllyData(
    id: 'phoenix_hatchling', name: 'Phoenix Hatchling', role: 'dps', rarity: 'Legendary',
    baseAtk: 40, baseDef: 25, baseSpd: 20, baseHp: 180,
    ability: AbilityData(name: 'Rebirth Flame', cooldown: 4, effect: {'type': 'damage', 'target': 'single', 'multiplier': 1.8}),
  ),
  AllyData(
    id: 'seraph_medic', name: 'Seraph Medic', role: 'healer', rarity: 'Legendary',
    baseAtk: 30, baseDef: 28, baseSpd: 18, baseHp: 190,
    ability: AbilityData(name: 'Divine Grace', cooldown: 5, effect: {'type': 'heal', 'target': 'all_allies', 'amount': 0.18}),
  ),
  AllyData(
    id: 'quicksilver', name: 'Quicksilver', role: 'speed', rarity: 'Legendary',
    baseAtk: 36, baseDef: 26, baseSpd: 22, baseHp: 175,
    ability: AbilityData(name: 'Mercury Rush', cooldown: 3, effect: {'type': 'multi_hit', 'target': 'random_enemies', 'hits': 4, 'multiplier': 0.6}),
  ),
  AllyData(
    id: 'meteor_golem', name: 'Meteor Golem', role: 'aoe_dps', rarity: 'Legendary',
    baseAtk: 38, baseDef: 30, baseSpd: 16, baseHp: 210,
    ability: AbilityData(name: 'Meteor Strike', cooldown: 6, effect: {'type': 'damage', 'target': 'all_enemies', 'multiplier': 1.5}),
  ),
  AllyData(
    id: 'aurora_stag', name: 'Aurora Stag', role: 'buffer', rarity: 'Legendary',
    baseAtk: 33, baseDef: 28, baseSpd: 19, baseHp: 195,
    ability: AbilityData(name: 'Northern Light', cooldown: 6, effect: {'type': 'buff', 'target': 'all_allies', 'stat': 'atk', 'amount': 0.15, 'duration': 3}),
  ),
  AllyData(
    id: 'banshee_queen', name: 'Banshee Queen', role: 'debuffer', rarity: 'Legendary',
    baseAtk: 37, baseDef: 27, baseSpd: 20, baseHp: 185,
    ability: AbilityData(name: 'Wail of Despair', cooldown: 5, effect: {'type': 'debuff', 'target': 'all_enemies', 'stat': 'atk', 'amount': 0.20, 'duration': 2}),
  ),
  AllyData(
    id: 'blade_dancer', name: 'Blade Dancer', role: 'dps', rarity: 'Legendary',
    baseAtk: 40, baseDef: 26, baseSpd: 21, baseHp: 178,
    ability: AbilityData(name: 'Sword Storm', cooldown: 4, effect: {'type': 'multi_hit', 'target': 'random_enemies', 'hits': 5, 'multiplier': 0.5}),
  ),

  // --- MYTHIC (8) ---
  AllyData(
    id: 'world_turtle', name: 'World Turtle', role: 'tank', rarity: 'Mythic',
    baseAtk: 40, baseDef: 45, baseSpd: 20, baseHp: 300,
    ability: AbilityData(name: 'Continental Shield', cooldown: 7, effect: {'type': 'shield', 'target': 'all_allies', 'duration': 2}),
  ),
  AllyData(
    id: 'celestial_dragon', name: 'Celestial Dragon', role: 'aoe_dps', rarity: 'Mythic',
    baseAtk: 55, baseDef: 35, baseSpd: 24, baseHp: 250,
    ability: AbilityData(name: 'Starfall Breath', cooldown: 6, effect: {'type': 'damage', 'target': 'all_enemies', 'multiplier': 2.0}),
  ),
  AllyData(
    id: 'life_tree_spirit', name: 'Life Tree Spirit', role: 'healer', rarity: 'Mythic',
    baseAtk: 42, baseDef: 38, baseSpd: 22, baseHp: 260,
    ability: AbilityData(name: 'World Rejuvenation', cooldown: 6, effect: {'type': 'heal', 'target': 'all_allies', 'amount': 0.25}),
  ),
  AllyData(
    id: 'chrono_rabbit', name: 'Chrono Rabbit', role: 'speed', rarity: 'Mythic',
    baseAtk: 48, baseDef: 36, baseSpd: 28, baseHp: 230,
    ability: AbilityData(name: 'Time Skip', cooldown: 5, effect: {'type': 'buff', 'target': 'all_allies', 'stat': 'spd', 'amount': 0.25, 'duration': 3}),
  ),
  AllyData(
    id: 'supernova', name: 'Supernova', role: 'dps', rarity: 'Mythic',
    baseAtk: 55, baseDef: 35, baseSpd: 23, baseHp: 240,
    ability: AbilityData(name: 'Solar Explosion', cooldown: 5, effect: {'type': 'damage', 'target': 'single', 'multiplier': 2.5}),
  ),
  AllyData(
    id: 'cosmic_bard', name: 'Cosmic Bard', role: 'buffer', rarity: 'Mythic',
    baseAtk: 44, baseDef: 38, baseSpd: 24, baseHp: 255,
    ability: AbilityData(name: 'Harmony of Spheres', cooldown: 7, effect: {'type': 'buff', 'target': 'all_allies', 'stat': 'atk', 'amount': 0.15, 'duration': 3}),
  ),
  AllyData(
    id: 'void_reaper', name: 'Void Reaper', role: 'debuffer', rarity: 'Mythic',
    baseAtk: 52, baseDef: 36, baseSpd: 25, baseHp: 235,
    ability: AbilityData(name: 'Entropy Field', cooldown: 6, effect: {'type': 'debuff', 'target': 'all_enemies', 'stat': 'atk', 'amount': 0.20, 'duration': 3}),
  ),
  AllyData(
    id: 'infinity_golem', name: 'Infinity Golem', role: 'tank', rarity: 'Mythic',
    baseAtk: 45, baseDef: 45, baseSpd: 20, baseHp: 300,
    ability: AbilityData(name: 'Infinite Recursion', cooldown: 7, effect: {'type': 'shield', 'target': 'all_allies', 'duration': 2}),
  ),
];

// =========================================================================
// BOSSES (20 total)
// =========================================================================
const List<BossData> _bosses = [
  BossData(
    id: 'boss_slime_king', name: 'Slime King', stage: 1, hp: 1980, atk: 59, def: 8, spd: 12,
    abilities: [
      BossAbility(name: 'Goo Slam', cooldown: 3, effect: {'type': 'damage', 'target': 'single', 'multiplier': 1.2}),
    ],
    drops: BossDrops(gold: 100, eggFragments: 0, materials: [Drop('Attack Crystal', 1)]),
  ),
  BossData(
    id: 'boss_fungal_horror', name: 'Fungal Horror', stage: 2, hp: 3600, atk: 89, def: 15, spd: 14,
    abilities: [
      BossAbility(name: 'Spore Cloud', cooldown: 5, effect: {'type': 'dot', 'target': 'single_enemy', 'damagePercent': 0.03, 'duration': 3}),
    ],
    drops: BossDrops(gold: 200, eggFragments: 0, materials: [Drop('Mutagen', 1)]),
  ),
  BossData(
    id: 'boss_ember_wolf', name: 'Ember Wolf', stage: 3, hp: 5850, atk: 119, def: 22, spd: 24,
    abilities: [
      BossAbility(name: 'Flame Charge', cooldown: 3, effect: {'type': 'damage', 'target': 'single', 'multiplier': 1.5}),
      BossAbility(name: 'Howl', cooldown: 5, effect: {'type': 'buff', 'target': 'single_ally', 'stat': 'atk', 'amount': 0.15, 'duration': 2}),
    ],
    drops: BossDrops(gold: 350, eggFragments: 1, materials: [Drop('Attack Crystal', 2)]),
  ),
  BossData(
    id: 'boss_stone_sentinel', name: 'Stone Sentinel', stage: 4, hp: 9240, atk: 152, def: 30, spd: 16,
    abilities: [
      BossAbility(name: 'Earthquake', cooldown: 5, effect: {'type': 'damage', 'target': 'all_enemies', 'multiplier': 1.0}),
      BossAbility(name: 'Stone Skin', cooldown: 6, effect: {'type': 'buff', 'target': 'single_ally', 'stat': 'def', 'amount': 0.30, 'duration': 2}),
    ],
    drops: BossDrops(gold: 500, eggFragments: 1, materials: [Drop('Defense Core', 3)]),
  ),
  BossData(
    id: 'boss_frost_serpent', name: 'Frost Serpent', stage: 5, hp: 13500, atk: 188, def: 35, spd: 28,
    abilities: [
      BossAbility(name: 'Ice Fang', cooldown: 3, effect: {'type': 'damage', 'target': 'single', 'multiplier': 1.6}),
      BossAbility(name: 'Blizzard Coil', cooldown: 5, effect: {'type': 'debuff', 'target': 'all_enemies', 'stat': 'spd', 'amount': 0.15, 'duration': 2}),
    ],
    drops: BossDrops(gold: 700, eggFragments: 1, materials: [Drop('Speed Chip', 3)]),
  ),
  BossData(
    id: 'boss_shadow_spider', name: 'Shadow Spider', stage: 6, hp: 19200, atk: 226, def: 40, spd: 32,
    abilities: [
      BossAbility(name: 'Venom Strike', cooldown: 4, effect: {'type': 'dot', 'target': 'single_enemy', 'damagePercent': 0.05, 'duration': 3}),
      BossAbility(name: 'Web Trap', cooldown: 4, effect: {'type': 'debuff', 'target': 'single_enemy', 'stat': 'spd', 'amount': 0.30, 'duration': 2}),
    ],
    drops: BossDrops(gold: 900, eggFragments: 1, materials: [Drop('Attack Crystal', 2), Drop('Mutagen', 2)]),
  ),
  BossData(
    id: 'boss_thunder_bear', name: 'Thunder Bear', stage: 7, hp: 28050, atk: 267, def: 45, spd: 26,
    abilities: [
      BossAbility(name: 'Lightning Maul', cooldown: 3, effect: {'type': 'damage', 'target': 'single', 'multiplier': 1.8}),
      BossAbility(name: 'Thunder Roar', cooldown: 5, effect: {'type': 'debuff', 'target': 'all_enemies', 'stat': 'def', 'amount': 0.15, 'duration': 2}),
    ],
    drops: BossDrops(gold: 1200, eggFragments: 2, materials: [Drop('Attack Crystal', 4)]),
  ),
  BossData(
    id: 'boss_crystal_hydra', name: 'Crystal Hydra', stage: 8, hp: 37800, atk: 309, def: 50, spd: 24,
    abilities: [
      BossAbility(name: 'Triple Head Strike', cooldown: 4, effect: {'type': 'multi_hit', 'target': 'random_enemies', 'hits': 3, 'multiplier': 0.8}),
      BossAbility(name: 'Regenerate', cooldown: 6, effect: {'type': 'heal', 'target': 'lowest_ally', 'amount': 0.10}),
    ],
    drops: BossDrops(gold: 1500, eggFragments: 2, materials: [Drop('Defense Core', 3), Drop('Attack Crystal', 3)]),
  ),
  BossData(
    id: 'boss_sand_worm', name: 'Sand Worm', stage: 9, hp: 51300, atk: 353, def: 55, spd: 20,
    abilities: [
      BossAbility(name: 'Burrow Strike', cooldown: 4, effect: {'type': 'damage', 'target': 'single', 'multiplier': 2.0}),
      BossAbility(name: 'Sand Storm', cooldown: 5, effect: {'type': 'damage', 'target': 'all_enemies', 'multiplier': 0.8}),
    ],
    drops: BossDrops(gold: 1800, eggFragments: 2, materials: [Drop('Speed Chip', 4)]),
  ),
  BossData(
    id: 'boss_necro_bloom', name: 'Necro Bloom', stage: 10, hp: 72000, atk: 402, def: 60, spd: 28,
    abilities: [
      BossAbility(name: 'Death Blossom', cooldown: 5, effect: {'type': 'damage', 'target': 'all_enemies', 'multiplier': 1.3}),
      BossAbility(name: 'Life Drain', cooldown: 4, effect: {'type': 'damage', 'target': 'single', 'multiplier': 1.5}),
    ],
    drops: BossDrops(gold: 2500, eggFragments: 3, materials: [Drop('Mutagen', 5), Drop('Attack Crystal', 3)], special: 'bronze_egg'),
  ),
  BossData(
    id: 'boss_iron_colossus', name: 'Iron Colossus', stage: 11, hp: 94500, atk: 451, def: 65, spd: 18,
    abilities: [
      BossAbility(name: 'Iron Fist', cooldown: 4, effect: {'type': 'damage', 'target': 'single', 'multiplier': 2.2}),
      BossAbility(name: 'Armor Plating', cooldown: 6, effect: {'type': 'buff', 'target': 'single_ally', 'stat': 'def', 'amount': 0.40, 'duration': 2}),
    ],
    drops: BossDrops(gold: 3000, eggFragments: 3, materials: [Drop('Defense Core', 6)]),
  ),
  BossData(
    id: 'boss_plague_wraith', name: 'Plague Wraith', stage: 12, hp: 118800, atk: 504, def: 72, spd: 32,
    abilities: [
      BossAbility(name: 'Pandemic', cooldown: 6, effect: {'type': 'dot', 'target': 'single_enemy', 'damagePercent': 0.04, 'duration': 4}),
      BossAbility(name: 'Soul Rip', cooldown: 3, effect: {'type': 'damage', 'target': 'single', 'multiplier': 1.7}),
    ],
    drops: BossDrops(gold: 3500, eggFragments: 3, materials: [Drop('Mutagen', 5), Drop('Speed Chip', 4)]),
  ),
  BossData(
    id: 'boss_magma_titan', name: 'Magma Titan', stage: 13, hp: 151800, atk: 569, def: 80, spd: 22,
    abilities: [
      BossAbility(name: 'Eruption', cooldown: 5, effect: {'type': 'damage', 'target': 'all_enemies', 'multiplier': 1.4}),
      BossAbility(name: 'Molten Core', cooldown: 6, effect: {'type': 'buff', 'target': 'single_ally', 'stat': 'atk', 'amount': 0.25, 'duration': 3}),
    ],
    drops: BossDrops(gold: 4200, eggFragments: 4, materials: [Drop('Attack Crystal', 6)]),
  ),
  BossData(
    id: 'boss_storm_leviathan', name: 'Storm Leviathan', stage: 14, hp: 194400, atk: 635, def: 88, spd: 36,
    abilities: [
      BossAbility(name: 'Tidal Surge', cooldown: 5, effect: {'type': 'damage', 'target': 'all_enemies', 'multiplier': 1.6}),
      BossAbility(name: 'Lightning Barrage', cooldown: 4, effect: {'type': 'multi_hit', 'target': 'random_enemies', 'hits': 4, 'multiplier': 0.7}),
    ],
    drops: BossDrops(gold: 5000, eggFragments: 4, materials: [Drop('Speed Chip', 5), Drop('Attack Crystal', 5)], special: 'silver_egg'),
  ),
  BossData(
    id: 'boss_void_knight', name: 'Void Knight', stage: 15, hp: 247500, atk: 714, def: 95, spd: 34,
    abilities: [
      BossAbility(name: 'Void Slash', cooldown: 3, effect: {'type': 'damage', 'target': 'single', 'multiplier': 2.0}),
      BossAbility(name: 'Dark Aura', cooldown: 6, effect: {'type': 'debuff', 'target': 'all_enemies', 'stat': 'atk', 'amount': 0.15, 'duration': 3}),
    ],
    drops: BossDrops(gold: 6000, eggFragments: 4, materials: [Drop('Defense Core', 6), Drop('Mutagen', 4)]),
  ),
  BossData(
    id: 'boss_ancient_treant', name: 'Ancient Treant', stage: 16, hp: 312000, atk: 799, def: 105, spd: 20,
    abilities: [
      BossAbility(name: 'Root Prison', cooldown: 6, effect: {'type': 'debuff', 'target': 'all_enemies', 'stat': 'spd', 'amount': 0.25, 'duration': 3}),
      BossAbility(name: 'Nature Wrath', cooldown: 6, effect: {'type': 'damage', 'target': 'all_enemies', 'multiplier': 1.8}),
      BossAbility(name: 'Photosynthesis', cooldown: 5, effect: {'type': 'heal', 'target': 'lowest_ally', 'amount': 0.08}),
    ],
    drops: BossDrops(gold: 7000, eggFragments: 5, materials: [Drop('Attack Crystal', 6), Drop('Defense Core', 6)]),
  ),
  BossData(
    id: 'boss_demon_general', name: 'Demon General', stage: 17, hp: 405000, atk: 908, def: 115, spd: 38,
    abilities: [
      BossAbility(name: 'Hellfire Blade', cooldown: 3, effect: {'type': 'damage', 'target': 'single', 'multiplier': 2.2}),
      BossAbility(name: 'Infernal Command', cooldown: 5, effect: {'type': 'buff', 'target': 'single_ally', 'stat': 'atk', 'amount': 0.30, 'duration': 3}),
      BossAbility(name: 'Cleave', cooldown: 4, effect: {'type': 'damage', 'target': 'all_enemies', 'multiplier': 1.2}),
    ],
    drops: BossDrops(gold: 8500, eggFragments: 5, materials: [Drop('Attack Crystal', 8), Drop('Mutagen', 5)]),
  ),
  BossData(
    id: 'boss_celestial_warden', name: 'Celestial Warden', stage: 18, hp: 520799, atk: 1022, def: 128, spd: 40,
    abilities: [
      BossAbility(name: 'Holy Judgment', cooldown: 6, effect: {'type': 'damage', 'target': 'all_enemies', 'multiplier': 2.0}),
      BossAbility(name: 'Divine Shield', cooldown: 7, effect: {'type': 'shield', 'target': 'self', 'duration': 2}),
      BossAbility(name: 'Purify', cooldown: 5, effect: {'type': 'heal', 'target': 'lowest_ally', 'amount': 0.12}),
    ],
    drops: BossDrops(gold: 10000, eggFragments: 5, materials: [Drop('Defense Core', 8), Drop('Speed Chip', 6)]),
  ),
  BossData(
    id: 'boss_chaos_dragon', name: 'Chaos Dragon', stage: 19, hp: 678600, atk: 1160, def: 142, spd: 44,
    abilities: [
      BossAbility(name: 'Chaos Breath', cooldown: 5, effect: {'type': 'damage', 'target': 'all_enemies', 'multiplier': 1.8}),
      BossAbility(name: 'Tail Sweep', cooldown: 4, effect: {'type': 'multi_hit', 'target': 'random_enemies', 'hits': 5, 'multiplier': 0.6}),
      BossAbility(name: 'Dragon Rage', cooldown: 6, effect: {'type': 'buff', 'target': 'single_ally', 'stat': 'atk', 'amount': 0.35, 'duration': 3}),
    ],
    drops: BossDrops(gold: 12000, eggFragments: 6, materials: [Drop('Attack Crystal', 10), Drop('Defense Core', 8), Drop('Mutagen', 6)], special: 'gold_egg'),
  ),
  BossData(
    id: 'boss_world_ender', name: 'World Ender', stage: 20, hp: 900000, atk: 1310, def: 160, spd: 48,
    abilities: [
      BossAbility(name: 'Apocalypse', cooldown: 6, effect: {'type': 'damage', 'target': 'all_enemies', 'multiplier': 2.0}),
      BossAbility(name: 'Dimensional Rift', cooldown: 4, effect: {'type': 'multi_hit', 'target': 'random_enemies', 'hits': 6, 'multiplier': 0.6}),
      BossAbility(name: 'Entropy', cooldown: 6, effect: {'type': 'debuff', 'target': 'all_enemies', 'stat': 'atk', 'amount': 0.20, 'duration': 3}),
      BossAbility(name: 'World Devour', cooldown: 5, effect: {'type': 'damage', 'target': 'single', 'multiplier': 3.0}),
    ],
    drops: BossDrops(gold: 20000, eggFragments: 8, materials: [Drop('Attack Crystal', 15), Drop('Defense Core', 12), Drop('Speed Chip', 10), Drop('Mutagen', 10)], special: 'gold_egg'),
  ),
];

// =========================================================================
// EGG TIERS (5 total)
// =========================================================================
const Map<String, EggTier> _eggTiers = {
  'bronze': EggTier(
    cost: 500,
    incubationTime: 1800,
    rarityWeights: {'Newbie': 50, 'Normal': 30, 'Rookie': 15, 'Legendary': 4, 'Mythic': 1},
  ),
  'silver': EggTier(
    cost: 2000,
    incubationTime: 3600,
    rarityWeights: {'Newbie': 20, 'Normal': 35, 'Rookie': 30, 'Legendary': 12, 'Mythic': 3},
  ),
  'gold': EggTier(
    cost: 8000,
    incubationTime: 7200,
    rarityWeights: {'Newbie': 0, 'Normal': 15, 'Rookie': 40, 'Legendary': 35, 'Mythic': 10},
  ),
  'ruby': EggTier(
    cost: 25000,
    incubationTime: 14400,
    rarityWeights: {'Newbie': 0, 'Normal': 0, 'Rookie': 20, 'Legendary': 50, 'Mythic': 30},
  ),
  'diamond': EggTier(
    cost: 80000,
    incubationTime: 28800,
    rarityWeights: {'Newbie': 0, 'Normal': 0, 'Rookie': 0, 'Legendary': 40, 'Mythic': 60},
  ),
};

// =========================================================================
// SKILLS (8 total)
// =========================================================================
const List<SkillDef> _skills = [
  SkillDef(id: 'batch_plant', name: '일괄 심기', desc: '같은 작물을 모든 타일에 한번에 심기', cost: 5000),
  SkillDef(id: 'auto_water', name: '자동 물주기', desc: '로봇이 물을 주지 않아도 80% 속도로 성장', cost: 15000),
  SkillDef(id: 'egg_slot_3', name: '알 슬롯 +1', desc: '부화 슬롯 2개 → 3개로 증가', cost: 30000),
  SkillDef(id: 'battle_speed', name: '전투 가속', desc: '전투 턴 간격 50% 감소', cost: 50000),
  SkillDef(id: 'fast_hatch', name: '빠른 부화', desc: '알 부화 시간 30% 감소', cost: 80000),
  SkillDef(id: 'offline_bonus', name: '오프라인 보너스', desc: '백그라운드 수입 효율 50% → 80%', cost: 120000),
  SkillDef(id: 'egg_slot_4', name: '알 슬롯 +2', desc: '부화 슬롯 3개 → 4개로 증가', cost: 200000, requires: 'egg_slot_3'),
  SkillDef(id: 'double_harvest', name: '이중 수확', desc: '수확 보상 2배 확률 20%', cost: 500000),
  SkillDef(id: 'artifact_slot_3', name: '유물 슬롯 +1', desc: '유물 장착 슬롯 2개 → 3개', cost: 300000),
  SkillDef(id: 'artifact_slot_4', name: '유물 슬롯 +2', desc: '유물 장착 슬롯 3개 → 4개', cost: 800000, requires: 'artifact_slot_3'),
];

// =========================================================================
// ROBOT UPGRADES
// =========================================================================
const Map<String, Map<String, num>> _robotUpgrades = {
  'moveSpeed': {
    'baseCost': 300,
    'costMult': 1.7,
    'maxLevel': 20,
    'baseValue': 1.0,
    'increment': 0.08,
  },
  'growthBoost': {
    'baseCost': 400,
    'costMult': 1.7,
    'maxLevel': 20,
    'baseValue': 0,
    'increment': 0.03,
  },
  'stamina': {
    'baseCost': 350,
    'costMult': 1.7,
    'maxLevel': 20,
    'baseValue': 100,
    'increment': 5,
  },
};

// =========================================================================
// GameData static accessor (used by GameEngine)
// =========================================================================
class GameData {
  GameData._();
  static const List<CropData> crops = _crops;
  static const List<MutationRecipe> mutations = _mutations;
  static const List<AllyData> allies = _allies;
  static const List<BossData> bosses = _bosses;
  static const Map<String, EggTier> eggTiers = _eggTiers;
  static const List<SkillDef> skills = _skills;
  static const Map<String, Map<String, num>> robotUpgrades = _robotUpgrades;
  // New workstations
  static const List<FishData> fish = fishing.fishList;
  static const Map<String, Map<String, num>> fishingUpgrades = fishing.fishingUpgrades;
  static const List<OreData> ores = mining.oreList;
  static const Map<String, Map<String, num>> miningUpgrades = mining.miningUpgrades;
  static const Map<String, String> ingredientNames = cooking.ingredientNames;
  static const List<Recipe> recipes = cooking.recipes;

  // Artifacts
  static const List<ArtifactData> artifacts = [
    ArtifactData(id: 'gold_charm', name: '황금 부적', emoji: '💰', effectType: 'goldMult'),
    ArtifactData(id: 'war_sigil', name: '전사의 인장', emoji: '⚔', effectType: 'atkMult'),
    ArtifactData(id: 'guardian_crest', name: '수호의 문장', emoji: '🛡', effectType: 'defMult'),
    ArtifactData(id: 'gale_feather', name: '질풍의 깃털', emoji: '⚡', effectType: 'spdMult'),
    ArtifactData(id: 'life_orb', name: '생명의 오브', emoji: '❤', effectType: 'hpMult'),
    ArtifactData(id: 'growth_seed', name: '풍요의 씨앗', emoji: '🌱', effectType: 'growthMult'),
    ArtifactData(id: 'hatch_charm', name: '번식의 부적', emoji: '🥚', effectType: 'hatchMult'),
    ArtifactData(id: 'luck_crystal', name: '행운의 수정', emoji: '🔮', effectType: 'goldenMult'),
  ];

  static const List<ArtifactChestTier> chestTiers = [
    ArtifactChestTier(id: 'wood', name: '나무 상자', goldCost: 1000, keyCost: 10,
      goldW: 50, matW: 30, artifactW: 20,
      rarityWeights: {'Newbie': 70, 'Normal': 25, 'Rookie': 5}),
    ArtifactChestTier(id: 'iron', name: '철 상자', goldCost: 5000, keyCost: 30,
      goldW: 40, matW: 30, artifactW: 30,
      rarityWeights: {'Normal': 50, 'Rookie': 35, 'Legendary': 15}),
    ArtifactChestTier(id: 'gold_chest', name: '황금 상자', goldCost: 20000, keyCost: 80,
      goldW: 30, matW: 25, artifactW: 45,
      rarityWeights: {'Rookie': 45, 'Legendary': 45, 'Mythic': 10}),
    ArtifactChestTier(id: 'platinum', name: '백금 상자', goldCost: 60000, keyCost: 200,
      goldW: 25, matW: 20, artifactW: 55,
      rarityWeights: {'Rookie': 20, 'Legendary': 55, 'Mythic': 25}),
    ArtifactChestTier(id: 'diamond_chest', name: '다이아 상자', goldCost: 150000, keyCost: 500,
      goldW: 20, matW: 15, artifactW: 65,
      rarityWeights: {'Legendary': 55, 'Mythic': 45}),
  ];
}
