import '../models/models.dart';

// =========================================================================
// FISH (9 types) - 골드 수입 축소, 요리 재료가 주 목적
// =========================================================================
const List<FishData> fishList = [
  // Common
  FishData(id: 'flatfish', name: '광어', category: 'common', value: 8, rarity: 0.35),
  FishData(id: 'mackerel', name: '고등어', category: 'common', value: 12, rarity: 0.30),
  FishData(id: 'squid', name: '오징어', category: 'common', value: 7, rarity: 0.25),
  // Mid
  FishData(id: 'salmon', name: '연어', category: 'mid', value: 15, rarity: 0.20),
  FishData(id: 'tuna', name: '참치', category: 'mid', value: 18, rarity: 0.18),
  FishData(id: 'eel', name: '장어', category: 'mid', value: 16, rarity: 0.15),
  // Rare
  FishData(id: 'lobster', name: '랍스터', category: 'rare', value: 30, rarity: 0.08),
  FishData(id: 'goldfish', name: '금붕어', category: 'rare', value: 60, rarity: 0.05),
  FishData(id: 'dragonfish', name: '용물고기', category: 'rare', value: 45, rarity: 0.02),
];

// =========================================================================
// FISHING UPGRADES
// =========================================================================
const Map<String, Map<String, num>> fishingUpgrades = {
  'rod': {
    'baseCost': 400,
    'costMult': 1.7,
    'maxLevel': 20,
    'baseValue': 1.0,
    'increment': 0.08,
  },
  'bait': {
    'baseCost': 500,
    'costMult': 1.7,
    'maxLevel': 20,
    'baseValue': 1.0,
    'increment': 0.05,
  },
  'boat': {
    'baseCost': 350,
    'costMult': 1.7,
    'maxLevel': 20,
    'baseValue': 100,
    'increment': 5,
  },
};
