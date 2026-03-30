import '../models/models.dart';

// =========================================================================
// ORES (9 types) - 골드 수입 축소, 요리 재료가 주 목적
// =========================================================================
const List<OreData> oreList = [
  // Common
  OreData(id: 'iron', name: '철', category: 'common', value: 20, rarity: 0.35),
  OreData(id: 'copper', name: '구리', category: 'common', value: 30, rarity: 0.30),
  OreData(id: 'coal', name: '석탄', category: 'common', value: 25, rarity: 0.20),
  // Mid
  OreData(id: 'goldOre', name: '금', category: 'mid', value: 55, rarity: 0.20),
  OreData(id: 'silver', name: '은', category: 'mid', value: 45, rarity: 0.18),
  OreData(id: 'emerald', name: '에메랄드', category: 'mid', value: 65, rarity: 0.15),
  // Rare
  OreData(id: 'ruby', name: '루비', category: 'rare', value: 120, rarity: 0.08),
  OreData(id: 'diamond', name: '다이아', category: 'rare', value: 300, rarity: 0.04),
  OreData(id: 'mithril', name: '미스릴', category: 'rare', value: 200, rarity: 0.02),
];

// =========================================================================
// MINING UPGRADES
// =========================================================================
const Map<String, Map<String, num>> miningUpgrades = {
  'pickaxe': {
    'baseCost': 400,
    'costMult': 1.7,
    'maxLevel': 20,
    'baseValue': 1.0,
    'increment': 0.08,
  },
  'drill': {
    'baseCost': 500,
    'costMult': 1.7,
    'maxLevel': 20,
    'baseValue': 1.0,
    'increment': 0.05,
  },
  'cart': {
    'baseCost': 350,
    'costMult': 1.7,
    'maxLevel': 20,
    'baseValue': 100,
    'increment': 5,
  },
};
