import '../models/models.dart';

// =========================================================================
// 재료 이름 매핑 (ID → 한국어 이름)
// =========================================================================
const Map<String, String> ingredientNames = {
  // 농장 작물
  'tomato': '토마토', 'potato': '감자', 'corn': '옥수수', 'carrot': '당근',
  'wheat': '밀', 'pumpkin': '호박',
  'fire_pepper': '불고추', 'iron_root': '철뿌리', 'dash_leaf': '대시잎',
  'cactus': '선인장', 'thunder_wheat': '번개밀', 'mana_grape': '마나포도',
  'poison_mushroom': '독버섯', 'crystal_berry': '수정열매',
  'lucky_clover': '행운클로버', 'starfruit': '별과일', 'moon_blossom': '달꽃',
  'sunstone_fruit': '태양석과일',
  // 물고기
  'flatfish': '광어', 'mackerel': '고등어', 'squid': '오징어',
  'salmon': '연어', 'tuna': '참치', 'eel': '장어',
  'lobster': '랍스터', 'goldfish': '금붕어', 'dragonfish': '용물고기',
  // 광석
  'iron': '철', 'copper': '구리', 'coal': '석탄',
  'goldOre': '금', 'silver': '은', 'emerald': '에메랄드',
  'ruby': '루비', 'diamond': '다이아', 'mithril': '미스릴',
  // 특수
  'spice': '향신료',
  // 레거시 (구버전 호환)
  'produce': '농산물', 'combatHerb': '전투허브', 'rareSeed': '희귀씨앗',
  'fishMeat': '생선살', 'fishOil': '어유', 'premiumSeafood': '고급해산물',
  'refinedMineral': '정제광물', 'gem': '보석', 'rareGem': '희귀보석',
  'dragonScale': '용비늘', 'mithrilShard': '미스릴조각',
};

// =========================================================================
// RECIPES (12 total, 4 tiers × 3)
// 요리가 주력 수입원. 3작업장 재료를 모아 큰 골드 획득.
//
// 시간당 수입 설계 (2슬롯 기준):
//   T1: 60요리/hr × 180G = ~10,800G/hr
//   T2: 24요리/hr × 1,200G = ~28,800G/hr
//   T3: 12요리/hr × 5,000G = ~60,000G/hr
//   T4:  6요리/hr × 17,000G = ~102,000G/hr
// =========================================================================
const List<Recipe> recipes = [
  // ── Tier 1 (120초, ~180G) ──
  Recipe(
    id: 'veggie_soup', name: '야채 수프', tier: 1, rationRestore: 1, cookTime: 120,
    basePrice: 180, emoji: '🥣',
    ingredients: [RecipeIngredient('tomato', 5), RecipeIngredient('potato', 3), RecipeIngredient('carrot', 2)],
  ),
  Recipe(
    id: 'grilled_fish', name: '생선구이', tier: 1, rationRestore: 1, cookTime: 120,
    basePrice: 190, emoji: '🐟',
    ingredients: [RecipeIngredient('mackerel', 4), RecipeIngredient('flatfish', 3), RecipeIngredient('coal', 3)],
  ),
  Recipe(
    id: 'iron_stew', name: '철광 스튜', tier: 1, rationRestore: 1, cookTime: 120,
    basePrice: 170, emoji: '⚙️',
    ingredients: [RecipeIngredient('iron', 5), RecipeIngredient('copper', 3), RecipeIngredient('carrot', 2)],
  ),

  // ── Tier 2 (300초, ~1,200G) ──
  Recipe(
    id: 'seafood_stew', name: '해산물 스튜', tier: 2, rationRestore: 2, cookTime: 300,
    basePrice: 1200, emoji: '🍲',
    ingredients: [RecipeIngredient('salmon', 5), RecipeIngredient('squid', 3), RecipeIngredient('tomato', 4), RecipeIngredient('corn', 3)],
  ),
  Recipe(
    id: 'gem_salad', name: '보석 샐러드', tier: 2, rationRestore: 2, cookTime: 300,
    basePrice: 1250, emoji: '🥗',
    ingredients: [RecipeIngredient('emerald', 3), RecipeIngredient('silver', 2), RecipeIngredient('carrot', 4), RecipeIngredient('wheat', 3)],
  ),
  Recipe(
    id: 'herb_tonic', name: '약초 강장제', tier: 2, rationRestore: 2, cookTime: 300,
    basePrice: 1300, emoji: '🧪',
    ingredients: [RecipeIngredient('fire_pepper', 5), RecipeIngredient('iron_root', 3), RecipeIngredient('tuna', 4), RecipeIngredient('copper', 2)],
  ),

  // ── Tier 3 (600초, ~5,000G) ──
  Recipe(
    id: 'dragon_sashimi', name: '용 회', tier: 3, rationRestore: 3, cookTime: 600,
    basePrice: 5000, emoji: '🐉',
    ingredients: [RecipeIngredient('lobster', 4), RecipeIngredient('eel', 5), RecipeIngredient('wheat', 5), RecipeIngredient('spice', 5)],
  ),
  Recipe(
    id: 'mithril_feast', name: '미스릴 만찬', tier: 3, rationRestore: 3, cookTime: 600,
    basePrice: 4800, emoji: '⚔️',
    ingredients: [RecipeIngredient('silver', 5), RecipeIngredient('goldOre', 3), RecipeIngredient('salmon', 4), RecipeIngredient('fire_pepper', 5), RecipeIngredient('coal', 3)],
  ),
  Recipe(
    id: 'royal_cuisine', name: '왕실 요리', tier: 3, rationRestore: 3, cookTime: 600,
    basePrice: 5200, emoji: '👑',
    ingredients: [RecipeIngredient('starfruit', 3), RecipeIngredient('lobster', 3), RecipeIngredient('ruby', 2), RecipeIngredient('spice', 3)],
  ),

  // ── Tier 4 (1200초, ~17,000G) ──
  Recipe(
    id: 'legendary_elixir', name: '전설의 엘릭서', tier: 4, rationRestore: 5, cookTime: 1200,
    basePrice: 17000, emoji: '🧙',
    ingredients: [RecipeIngredient('moon_blossom', 3), RecipeIngredient('lobster', 5), RecipeIngredient('ruby', 3), RecipeIngredient('spice', 8), RecipeIngredient('goldOre', 5)],
  ),
  Recipe(
    id: 'cosmic_banquet', name: '우주의 연회', tier: 4, rationRestore: 5, cookTime: 1200,
    basePrice: 18000, emoji: '🌌',
    ingredients: [RecipeIngredient('dragonfish', 3), RecipeIngredient('mithril', 3), RecipeIngredient('fire_pepper', 8), RecipeIngredient('pumpkin', 5), RecipeIngredient('diamond', 2)],
  ),
  Recipe(
    id: 'sage_meal', name: '현자의 식사', tier: 4, rationRestore: 5, cookTime: 1200,
    basePrice: 16000, emoji: '📜',
    ingredients: [RecipeIngredient('diamond', 2), RecipeIngredient('eel', 5), RecipeIngredient('starfruit', 3), RecipeIngredient('spice', 10), RecipeIngredient('emerald', 3)],
  ),
];
