import 'dart:math';
import 'package:flutter/material.dart';

/// Procedural pixel-art sprite renderer at 64x64
/// Draws cute characters using canvas primitives with a pixel-art aesthetic

class PixelSprite extends StatelessWidget {
  final String spriteId;
  final double size;
  final bool flipX;
  final double animPhase; // 0.0~1.0 for animation

  const PixelSprite({
    super.key,
    required this.spriteId,
    this.size = 64,
    this.flipX = false,
    this.animPhase = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SpritePainter(spriteId, flipX, animPhase),
    );
  }
}

// Pixel helper: draws a filled rectangle snapped to pixel grid
void _px(Canvas c, Paint p, double x, double y, double w, double h, int color) {
  p.color = Color(color);
  c.drawRect(Rect.fromLTWH(x, y, w, h), p);
}

// Scale factor for 64px canvas
// Sprites drawn in 64x64 coordinate space

class _SpritePainter extends CustomPainter {
  final String id;
  final bool flipX;
  final double anim;

  _SpritePainter(this.id, this.flipX, this.anim);

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 64;
    final sy = size.height / 64;
    canvas.scale(sx, sy);
    if (flipX) {
      canvas.translate(64, 0);
      canvas.scale(-1, 1);
    }

    final p = Paint()..isAntiAlias = false;

    switch (id) {
      case 'robot_idle': _drawRobot(canvas, p, 0); break;
      case 'robot_walk1': _drawRobot(canvas, p, 1); break;
      case 'robot_walk2': _drawRobot(canvas, p, 2); break;
      case 'robot_rest': _drawRobot(canvas, p, 3); break;
      case 'robot_water': _drawRobot(canvas, p, 4); break;
      case 'robot_harvest': _drawRobot(canvas, p, 5); break;
      case 'robot_plant': _drawRobot(canvas, p, 6); break;

      // Crops
      case 'crop_seed': _drawCropSeed(canvas, p); break;
      case 'crop_growing': _drawCropGrowing(canvas, p); break;
      case 'tomato': _drawTomato(canvas, p); break;
      case 'potato': _drawPotato(canvas, p); break;
      case 'corn': _drawCorn(canvas, p); break;
      case 'carrot': _drawCarrot(canvas, p); break;
      case 'wheat': _drawWheat(canvas, p); break;
      case 'pumpkin': _drawPumpkin(canvas, p); break;
      case 'fire_pepper': _drawFirePepper(canvas, p); break;
      case 'cactus': _drawCactus(canvas, p); break;
      case 'mana_grape': _drawGrape(canvas, p); break;
      case 'poison_mushroom': _drawMushroom(canvas, p); break;
      case 'lucky_clover': _drawClover(canvas, p); break;
      case 'crystal_berry': _drawCrystal(canvas, p); break;
      case 'starfruit': _drawStarfruit(canvas, p); break;

      // Allies
      case 'ally_sproutling': _drawSproutling(canvas, p); break;
      case 'ally_ember_pup': _drawEmberPup(canvas, p); break;
      case 'ally_puddle_slime': _drawPuddleSlime(canvas, p); break;
      case 'ally_zap_bug': _drawZapBug(canvas, p); break;
      case 'ally_flame_fox': _drawFlameFox(canvas, p); break;
      case 'ally_phoenix': _drawPhoenix(canvas, p); break;
      case 'ally_crystal_guard': _drawCrystalGuard(canvas, p); break;
      case 'ally_celestial_dragon': _drawCelestialDragon(canvas, p); break;
      case 'ally_generic_tank': _drawGenericAlly(canvas, p, 0xFF4A90D9); break;
      case 'ally_generic_dps': _drawGenericAlly(canvas, p, 0xFFD94A4A); break;
      case 'ally_generic_healer': _drawGenericAlly(canvas, p, 0xFF4AD98A); break;
      case 'ally_generic_buffer': _drawGenericAlly(canvas, p, 0xFFD9D04A); break;
      case 'ally_generic_debuffer': _drawGenericAlly(canvas, p, 0xFF8A4AD9); break;
      case 'ally_generic_speed': _drawGenericAlly(canvas, p, 0xFF4AD9D9); break;

      // Bosses
      case 'boss_slime': _drawBossSlime(canvas, p); break;
      case 'boss_wolf': _drawBossWolf(canvas, p); break;
      case 'boss_serpent': _drawBossSerpent(canvas, p); break;
      case 'boss_necro': _drawBossNecro(canvas, p); break;
      case 'boss_dragon': _drawBossDragon(canvas, p); break;
      case 'boss_ender': _drawBossEnder(canvas, p); break;
      case 'boss_generic': _drawBossGeneric(canvas, p, 0xFF8B0000); break;

      // Fish
      case 'fish_flatfish': _drawFishFlat(canvas, p); break;
      case 'fish_mackerel': _drawFishMackerel(canvas, p); break;
      case 'fish_squid': _drawFishSquid(canvas, p); break;
      case 'fish_salmon': _drawFishSalmon(canvas, p); break;
      case 'fish_tuna': _drawFishTuna(canvas, p); break;
      case 'fish_eel': _drawFishEel(canvas, p); break;
      case 'fish_lobster': _drawFishLobster(canvas, p); break;
      case 'fish_goldfish': _drawFishGold(canvas, p); break;
      case 'fish_dragonfish': _drawFishDragon(canvas, p); break;

      // Ores
      case 'ore_iron': _drawOreIron(canvas, p); break;
      case 'ore_copper': _drawOreCopper(canvas, p); break;
      case 'ore_coal': _drawOreCoal(canvas, p); break;
      case 'ore_goldOre': _drawOreGold(canvas, p); break;
      case 'ore_silver': _drawOreSilver(canvas, p); break;
      case 'ore_emerald': _drawOreEmerald(canvas, p); break;
      case 'ore_ruby': _drawOreRuby(canvas, p); break;
      case 'ore_diamond': _drawOreDiamond(canvas, p); break;
      case 'ore_mithril': _drawOreMithril(canvas, p); break;

      default: _drawDefault(canvas, p); break;
    }
  }

  // ============================================================
  // ROBOT — cute round robot with antenna, big eyes, pink cheeks
  // ============================================================
  void _drawRobot(Canvas c, Paint p, int frame) {
    final bob = frame == 3 ? 0.0 : sin(anim * pi * 2) * 2;
    final legL = (frame == 1) ? 4.0 : (frame == 2) ? -2.0 : 0.0;
    final legR = (frame == 1) ? -2.0 : (frame == 2) ? 4.0 : 0.0;

    // Shadow
    _px(c, p, 16, 58, 32, 4, 0x33000000);

    // Antenna
    _px(c, p, 29, 4 + bob, 6, 4, 0xFFFF4444);
    _px(c, p, 31, 8 + bob, 2, 8, 0xFF667788);

    // Head (round-ish)
    _px(c, p, 16, 14 + bob, 32, 20, 0xFFA8C8D8);
    _px(c, p, 20, 12 + bob, 24, 4, 0xFFA8C8D8);
    _px(c, p, 14, 18 + bob, 4, 12, 0xFFA8C8D8);
    _px(c, p, 46, 18 + bob, 4, 12, 0xFFA8C8D8);
    // Head outline
    _px(c, p, 16, 12 + bob, 32, 2, 0xFF5B6E7A);
    _px(c, p, 14, 14 + bob, 2, 20, 0xFF5B6E7A);
    _px(c, p, 48, 14 + bob, 2, 20, 0xFF5B6E7A);
    _px(c, p, 16, 34 + bob, 32, 2, 0xFF5B6E7A);

    // Eyes (big, cute)
    _px(c, p, 20, 20 + bob, 8, 8, 0xFF3A5C7A);
    _px(c, p, 36, 20 + bob, 8, 8, 0xFF3A5C7A);
    if (frame == 3) {
      // Sleeping — closed eyes
      _px(c, p, 20, 24 + bob, 8, 2, 0xFF3A5C7A);
      _px(c, p, 36, 24 + bob, 8, 2, 0xFF3A5C7A);
    } else {
      // Pupils (white highlight)
      _px(c, p, 22, 22 + bob, 4, 4, 0xFFFFFFFF);
      _px(c, p, 38, 22 + bob, 4, 4, 0xFFFFFFFF);
      _px(c, p, 22, 22 + bob, 2, 2, 0xFF3A5C7A);
      _px(c, p, 38, 22 + bob, 2, 2, 0xFF3A5C7A);
    }

    // Pink cheeks
    _px(c, p, 16, 26 + bob, 6, 4, 0x66FF8899);
    _px(c, p, 42, 26 + bob, 6, 4, 0x66FF8899);

    // Mouth
    _px(c, p, 28, 30 + bob, 8, 2, 0xFF5B6E7A);

    // Body
    _px(c, p, 20, 36 + bob, 24, 16, 0xFF8AB4C8);
    _px(c, p, 18, 38 + bob, 4, 12, 0xFF8AB4C8);
    _px(c, p, 42, 38 + bob, 4, 12, 0xFF8AB4C8);
    // Body outline
    _px(c, p, 18, 36 + bob, 28, 2, 0xFF5B6E7A);
    _px(c, p, 16, 38 + bob, 2, 14, 0xFF5B6E7A);
    _px(c, p, 46, 38 + bob, 2, 14, 0xFF5B6E7A);

    // Belly button / detail
    _px(c, p, 28, 42 + bob, 8, 4, 0xFF6A9AB4);
    _px(c, p, 30, 44 + bob, 4, 2, 0xFF5B8AA4);

    // Arms
    if (frame == 4) {
      // Watering
      _px(c, p, 6, 38 + bob, 10, 6, 0xFF667788);
      _px(c, p, 2, 36 + bob, 8, 8, 0xFF4488FF); // watering can
    } else if (frame == 5) {
      // Harvesting
      _px(c, p, 6, 36 + bob, 10, 6, 0xFF667788);
      _px(c, p, 48, 36 + bob, 10, 6, 0xFF667788);
    } else if (frame == 6) {
      // Planting
      _px(c, p, 24, 52 + bob, 6, 6, 0xFF667788);
      _px(c, p, 34, 52 + bob, 6, 6, 0xFF667788);
    } else {
      _px(c, p, 8, 40 + bob, 8, 6, 0xFF667788);
      _px(c, p, 48, 40 + bob, 8, 6, 0xFF667788);
    }

    // Legs
    _px(c, p, 22, 52 + bob + legL, 8, 8, 0xFF556677);
    _px(c, p, 34, 52 + bob + legR, 8, 8, 0xFF556677);
    // Feet
    _px(c, p, 20, 58 + bob + legL, 12, 4, 0xFF445566);
    _px(c, p, 32, 58 + bob + legR, 12, 4, 0xFF445566);

    // Sleeping Zzz
    if (frame == 3) {
      final zOff = sin(anim * pi * 2) * 3;
      _px(c, p, 50, (8 + zOff).toDouble(), 6, 6, 0xFF88AAFF);
      _px(c, p, 54, (2 + zOff).toDouble(), 4, 4, 0xFF88AAFF);
    }

    // Action tool indicators
    if (frame == 4) {
      // Water drops
      _px(c, p, 4, 46, 4, 6, 0xFF4488FF);
      _px(c, p, 8, 48, 4, 4, 0xFF4488FF);
    }
    if (frame == 6) {
      // Seed
      _px(c, p, 28, 58, 8, 4, 0xFF44AA44);
    }
  }

  // ============================================================
  // CROPS
  // ============================================================
  void _drawSoil(Canvas c, Paint p) {
    _px(c, p, 0, 52, 64, 12, 0xFF5C3A1E);
    _px(c, p, 4, 54, 56, 2, 0xFF4A2D15);
    _px(c, p, 8, 58, 48, 2, 0xFF4A2D15);
  }

  void _drawCropSeed(Canvas c, Paint p) {
    _drawSoil(c, p);
    _px(c, p, 30, 48, 4, 6, 0xFF4A7C3F);
    _px(c, p, 26, 46, 12, 4, 0xFF5A9C4F);
  }

  void _drawCropGrowing(Canvas c, Paint p) {
    _drawSoil(c, p);
    _px(c, p, 30, 36, 4, 16, 0xFF3A6C2F);
    _px(c, p, 22, 38, 12, 6, 0xFF5A9C4F);
    _px(c, p, 34, 42, 10, 6, 0xFF5A9C4F);
  }

  void _drawTomato(Canvas c, Paint p) {
    _drawSoil(c, p);
    _px(c, p, 30, 30, 4, 22, 0xFF3A6C2F);
    _px(c, p, 22, 36, 8, 6, 0xFF4A8C3F);
    _px(c, p, 36, 40, 8, 6, 0xFF4A8C3F);
    // Tomato fruit
    _px(c, p, 20, 18, 24, 20, 0xFFE84444);
    _px(c, p, 24, 16, 16, 4, 0xFFE84444);
    _px(c, p, 16, 22, 4, 12, 0xFFCC3333);
    _px(c, p, 44, 22, 4, 12, 0xFFCC3333);
    // Highlight
    _px(c, p, 24, 20, 6, 4, 0xFFFF8888);
    // Stem
    _px(c, p, 28, 12, 8, 6, 0xFF4A8C3F);
    _px(c, p, 30, 8, 4, 6, 0xFF3A6C2F);
  }

  void _drawPotato(Canvas c, Paint p) {
    _drawSoil(c, p);
    _px(c, p, 28, 30, 4, 22, 0xFF3A6C2F);
    _px(c, p, 24, 28, 16, 4, 0xFF5A9C4F);
    // Potato
    _px(c, p, 16, 34, 32, 16, 0xFFC4A035);
    _px(c, p, 20, 32, 24, 4, 0xFFC4A035);
    _px(c, p, 20, 48, 24, 4, 0xFFB08A28);
    _px(c, p, 24, 38, 4, 4, 0xFFB08A28);
    _px(c, p, 36, 42, 4, 4, 0xFFB08A28);
  }

  void _drawCorn(Canvas c, Paint p) {
    _drawSoil(c, p);
    _px(c, p, 30, 8, 4, 44, 0xFF3A6C2F);
    // Leaves
    _px(c, p, 16, 30, 14, 4, 0xFF5A9C4F);
    _px(c, p, 34, 24, 14, 4, 0xFF5A9C4F);
    // Corn cob
    _px(c, p, 24, 14, 16, 22, 0xFFFFD700);
    _px(c, p, 28, 12, 8, 4, 0xFFDAA520);
    // Husk
    _px(c, p, 20, 18, 4, 14, 0xFF8B7355);
    _px(c, p, 40, 18, 4, 14, 0xFF8B7355);
  }

  void _drawCarrot(Canvas c, Paint p) {
    _drawSoil(c, p);
    // Green top
    _px(c, p, 24, 16, 16, 8, 0xFF5A9C4F);
    _px(c, p, 28, 12, 8, 6, 0xFF4A8C3F);
    _px(c, p, 20, 20, 8, 4, 0xFF3A6C2F);
    _px(c, p, 36, 18, 8, 4, 0xFF3A6C2F);
    // Carrot body
    _px(c, p, 24, 24, 16, 8, 0xFFFF8C00);
    _px(c, p, 26, 32, 12, 8, 0xFFFF7700);
    _px(c, p, 28, 40, 8, 6, 0xFFEE6600);
    _px(c, p, 30, 46, 4, 6, 0xFFDD5500);
  }

  void _drawWheat(Canvas c, Paint p) {
    _drawSoil(c, p);
    // Stalks
    _px(c, p, 18, 20, 4, 32, 0xFF8B7355);
    _px(c, p, 30, 16, 4, 36, 0xFF8B7355);
    _px(c, p, 42, 22, 4, 30, 0xFF8B7355);
    // Wheat heads
    _px(c, p, 14, 10, 12, 12, 0xFFDAA520);
    _px(c, p, 26, 6, 12, 12, 0xFFDAA520);
    _px(c, p, 38, 12, 12, 12, 0xFFDAA520);
    // Golden highlights
    _px(c, p, 16, 12, 4, 4, 0xFFFFD700);
    _px(c, p, 28, 8, 4, 4, 0xFFFFD700);
    _px(c, p, 40, 14, 4, 4, 0xFFFFD700);
  }

  void _drawPumpkin(Canvas c, Paint p) {
    _drawSoil(c, p);
    // Vine
    _px(c, p, 30, 8, 4, 8, 0xFF3A6C2F);
    _px(c, p, 34, 6, 8, 4, 0xFF4A8C3F);
    // Pumpkin body
    _px(c, p, 12, 20, 40, 28, 0xFFFF6600);
    _px(c, p, 16, 16, 32, 4, 0xFFFF7711);
    _px(c, p, 16, 48, 32, 4, 0xFFCC5500);
    // Segments
    _px(c, p, 30, 18, 4, 32, 0xFFEE5500);
    _px(c, p, 8, 28, 4, 12, 0xFFEE5500);
    _px(c, p, 52, 28, 4, 12, 0xFFEE5500);
    // Highlight
    _px(c, p, 18, 22, 8, 6, 0xFFFF9944);
  }

  void _drawFirePepper(Canvas c, Paint p) {
    _drawSoil(c, p);
    _px(c, p, 30, 24, 4, 28, 0xFF3A6C2F);
    // Pepper body
    _px(c, p, 22, 12, 20, 16, 0xFFFF2200);
    _px(c, p, 26, 28, 12, 8, 0xFFFF2200);
    _px(c, p, 28, 36, 8, 6, 0xFFEE1100);
    // Tip
    _px(c, p, 30, 42, 4, 6, 0xFFCC0000);
    // Stem
    _px(c, p, 28, 8, 8, 6, 0xFF4A8C3F);
    // Flame highlight
    _px(c, p, 24, 14, 6, 4, 0xFFFF6644);
    _px(c, p, 36, 18, 4, 4, 0xFFFFAA00);
  }

  void _drawCactus(Canvas c, Paint p) {
    _drawSoil(c, p);
    // Main body
    _px(c, p, 24, 16, 16, 36, 0xFF2E8B57);
    // Left arm
    _px(c, p, 12, 24, 12, 8, 0xFF2E8B57);
    _px(c, p, 12, 16, 8, 12, 0xFF2E8B57);
    // Right arm
    _px(c, p, 40, 28, 12, 8, 0xFF2E8B57);
    _px(c, p, 44, 20, 8, 12, 0xFF2E8B57);
    // Darker details
    _px(c, p, 30, 18, 4, 30, 0xFF267A4A);
    // Spines
    _px(c, p, 22, 20, 2, 2, 0xFFAACC88);
    _px(c, p, 22, 32, 2, 2, 0xFFAACC88);
    _px(c, p, 40, 24, 2, 2, 0xFFAACC88);
    _px(c, p, 10, 20, 2, 2, 0xFFAACC88);
    // Flower
    _px(c, p, 28, 10, 8, 8, 0xFFFF69B4);
    _px(c, p, 30, 12, 4, 4, 0xFFFFDD44);
  }

  void _drawGrape(Canvas c, Paint p) {
    _drawSoil(c, p);
    _px(c, p, 30, 20, 4, 32, 0xFF3A6C2F);
    _px(c, p, 22, 18, 20, 4, 0xFF4A8C3F);
    // Grape cluster
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j <= i; j++) {
        _px(c, p, 22.0 + j * 10 - i * 4, 10.0 + i * 10, 10, 10, 0xFF9B59B6);
        _px(c, p, 24.0 + j * 10 - i * 4, 12.0 + i * 10, 4, 4, 0xFFBB77DD);
      }
    }
  }

  void _drawMushroom(Canvas c, Paint p) {
    _drawSoil(c, p);
    // Stem
    _px(c, p, 26, 32, 12, 20, 0xFFEEDDCC);
    _px(c, p, 28, 34, 8, 16, 0xFFDDCCBB);
    // Cap
    _px(c, p, 12, 14, 40, 20, 0xFF8B008B);
    _px(c, p, 16, 10, 32, 6, 0xFF9B119B);
    _px(c, p, 8, 20, 4, 8, 0xFF7A007A);
    _px(c, p, 52, 20, 4, 8, 0xFF7A007A);
    // White spots
    _px(c, p, 18, 16, 6, 6, 0xFFFFFFFF);
    _px(c, p, 38, 18, 8, 6, 0xFFFFFFFF);
    _px(c, p, 26, 22, 4, 4, 0xFFFFFFFF);
  }

  void _drawClover(Canvas c, Paint p) {
    _drawSoil(c, p);
    _px(c, p, 30, 28, 4, 24, 0xFF3A6C2F);
    // 4 leaves
    _px(c, p, 18, 10, 12, 12, 0xFF00CC44);
    _px(c, p, 34, 10, 12, 12, 0xFF00CC44);
    _px(c, p, 18, 22, 12, 12, 0xFF00CC44);
    _px(c, p, 34, 22, 12, 12, 0xFF00CC44);
    // Highlights
    _px(c, p, 22, 14, 4, 4, 0xFF44FF88);
    _px(c, p, 38, 14, 4, 4, 0xFF44FF88);
    _px(c, p, 22, 26, 4, 4, 0xFF44FF88);
    _px(c, p, 38, 26, 4, 4, 0xFF44FF88);
  }

  void _drawCrystal(Canvas c, Paint p) {
    _drawSoil(c, p);
    // Crystal shape
    _px(c, p, 28, 8, 8, 8, 0xFF00BFFF);
    _px(c, p, 24, 16, 16, 16, 0xFF00AAEE);
    _px(c, p, 20, 24, 24, 12, 0xFF0088CC);
    _px(c, p, 28, 36, 8, 16, 0xFF0077BB);
    // Highlights
    _px(c, p, 26, 18, 6, 6, 0xFF88DDFF);
    _px(c, p, 22, 28, 4, 4, 0xFF66CCFF);
  }

  void _drawStarfruit(Canvas c, Paint p) {
    _drawSoil(c, p);
    _px(c, p, 30, 28, 4, 24, 0xFF3A6C2F);
    // Star shape (simplified)
    _px(c, p, 26, 8, 12, 8, 0xFFFFFF00);
    _px(c, p, 18, 16, 28, 8, 0xFFFFDD00);
    _px(c, p, 22, 24, 20, 8, 0xFFFFCC00);
    _px(c, p, 14, 12, 8, 12, 0xFFFFDD00);
    _px(c, p, 42, 12, 8, 12, 0xFFFFDD00);
    // Center
    _px(c, p, 28, 16, 8, 8, 0xFFFFFF88);
  }

  // ============================================================
  // ALLIES
  // ============================================================
  void _drawSproutling(Canvas c, Paint p) {
    // Leaf on head
    _px(c, p, 26, 4, 12, 10, 0xFF4CAF50);
    _px(c, p, 30, 0, 4, 6, 0xFF388E3C);
    // Body
    _px(c, p, 18, 14, 28, 28, 0xFF66BB6A);
    _px(c, p, 22, 12, 20, 4, 0xFF66BB6A);
    _px(c, p, 22, 42, 20, 4, 0xFF66BB6A);
    // Eyes
    _px(c, p, 24, 22, 6, 6, 0xFF1B5E20);
    _px(c, p, 38, 22, 6, 6, 0xFF1B5E20);
    _px(c, p, 26, 24, 2, 2, 0xFFFFFFFF);
    _px(c, p, 40, 24, 2, 2, 0xFFFFFFFF);
    // Smile
    _px(c, p, 28, 32, 12, 2, 0xFF2E7D32);
    _px(c, p, 26, 34, 4, 2, 0xFF2E7D32);
    _px(c, p, 38, 34, 4, 2, 0xFF2E7D32);
    // Feet
    _px(c, p, 20, 46, 10, 8, 0xFF4CAF50);
    _px(c, p, 34, 46, 10, 8, 0xFF4CAF50);
  }

  void _drawEmberPup(Canvas c, Paint p) {
    // Body
    _px(c, p, 14, 28, 28, 20, 0xFFE65100);
    _px(c, p, 18, 26, 20, 4, 0xFFE65100);
    // Head
    _px(c, p, 20, 12, 24, 18, 0xFFFF6D00);
    _px(c, p, 24, 10, 16, 4, 0xFFFF6D00);
    // Ears
    _px(c, p, 16, 6, 8, 10, 0xFFFF8F00);
    _px(c, p, 40, 6, 8, 10, 0xFFFF8F00);
    // Eyes
    _px(c, p, 26, 18, 6, 6, 0xFF212121);
    _px(c, p, 38, 18, 6, 6, 0xFF212121);
    _px(c, p, 28, 20, 2, 2, 0xFFFFFFFF);
    _px(c, p, 40, 20, 2, 2, 0xFFFFFFFF);
    // Nose
    _px(c, p, 32, 24, 4, 4, 0xFF333333);
    // Fire tail
    _px(c, p, 42, 30, 12, 8, 0xFFFF6D00);
    _px(c, p, 46, 26, 8, 6, 0xFFFFAB00);
    _px(c, p, 50, 22, 6, 6, 0xFFFFD600);
    // Legs
    _px(c, p, 16, 48, 8, 10, 0xFFBF360C);
    _px(c, p, 32, 48, 8, 10, 0xFFBF360C);
  }

  void _drawPuddleSlime(Canvas c, Paint p) {
    // Body (blob)
    _px(c, p, 12, 20, 40, 30, 0xFF42A5F5);
    _px(c, p, 16, 16, 32, 8, 0xFF42A5F5);
    _px(c, p, 8, 28, 8, 16, 0xFF42A5F5);
    _px(c, p, 48, 28, 8, 16, 0xFF42A5F5);
    _px(c, p, 16, 50, 32, 8, 0xFF1E88E5);
    // Highlight
    _px(c, p, 18, 20, 10, 8, 0xFF90CAF9);
    // Eyes
    _px(c, p, 22, 28, 8, 8, 0xFFFFFFFF);
    _px(c, p, 38, 28, 8, 8, 0xFFFFFFFF);
    _px(c, p, 26, 30, 4, 4, 0xFF1565C0);
    _px(c, p, 42, 30, 4, 4, 0xFF1565C0);
    // Smile
    _px(c, p, 28, 40, 12, 2, 0xFF1565C0);
    _px(c, p, 26, 42, 4, 2, 0xFF1565C0);
    _px(c, p, 38, 42, 4, 2, 0xFF1565C0);
  }

  void _drawZapBug(Canvas c, Paint p) {
    // Wings
    _px(c, p, 8, 12, 16, 20, 0x88FFFF88);
    _px(c, p, 40, 12, 16, 20, 0x88FFFF88);
    // Body
    _px(c, p, 22, 16, 20, 32, 0xFFFDD835);
    _px(c, p, 26, 14, 12, 4, 0xFFFDD835);
    // Stripes
    _px(c, p, 22, 26, 20, 4, 0xFF333333);
    _px(c, p, 22, 36, 20, 4, 0xFF333333);
    // Eyes
    _px(c, p, 26, 18, 4, 4, 0xFFFF0000);
    _px(c, p, 36, 18, 4, 4, 0xFFFF0000);
    // Antenna with lightning
    _px(c, p, 28, 4, 2, 12, 0xFF333333);
    _px(c, p, 36, 4, 2, 12, 0xFF333333);
    _px(c, p, 24, 0, 6, 6, 0xFFFFFF00);
    _px(c, p, 34, 0, 6, 6, 0xFFFFFF00);
    // Legs
    _px(c, p, 22, 48, 6, 8, 0xFF333333);
    _px(c, p, 36, 48, 6, 8, 0xFF333333);
  }

  void _drawFlameFox(Canvas c, Paint p) {
    // Body
    _px(c, p, 12, 26, 32, 22, 0xFFFF8F00);
    // Head
    _px(c, p, 16, 10, 28, 20, 0xFFFFAB40);
    _px(c, p, 20, 8, 20, 4, 0xFFFFAB40);
    // Ears (pointed)
    _px(c, p, 14, 2, 10, 12, 0xFFFF8F00);
    _px(c, p, 40, 2, 10, 12, 0xFFFF8F00);
    _px(c, p, 18, 6, 4, 4, 0xFFFFCC80);
    _px(c, p, 42, 6, 4, 4, 0xFFFFCC80);
    // Eyes (sly)
    _px(c, p, 22, 16, 8, 6, 0xFF212121);
    _px(c, p, 38, 16, 8, 6, 0xFF212121);
    _px(c, p, 26, 18, 2, 2, 0xFF00E676);
    _px(c, p, 42, 18, 2, 2, 0xFF00E676);
    // Nose
    _px(c, p, 32, 22, 4, 2, 0xFF333333);
    // White chest
    _px(c, p, 24, 30, 16, 12, 0xFFFFECB3);
    // Fire tail
    _px(c, p, 44, 28, 12, 8, 0xFFFF6D00);
    _px(c, p, 48, 24, 10, 8, 0xFFFFAB00);
    _px(c, p, 52, 20, 8, 8, 0xFFFFD600);
    _px(c, p, 56, 16, 6, 6, 0xFFFFFF00);
    // Legs
    _px(c, p, 16, 48, 8, 10, 0xFFE65100);
    _px(c, p, 34, 48, 8, 10, 0xFFE65100);
  }

  void _drawPhoenix(Canvas c, Paint p) {
    // Wings
    _px(c, p, 2, 14, 16, 24, 0xFFFFAB00);
    _px(c, p, 46, 14, 16, 24, 0xFFFFAB00);
    _px(c, p, 6, 10, 8, 8, 0xFFFFD600);
    _px(c, p, 50, 10, 8, 8, 0xFFFFD600);
    // Body
    _px(c, p, 20, 16, 24, 28, 0xFFFF6D00);
    _px(c, p, 24, 14, 16, 4, 0xFFFF8F00);
    // Head
    _px(c, p, 24, 4, 16, 14, 0xFFFFAB40);
    _px(c, p, 28, 2, 8, 4, 0xFFFFAB40);
    // Crown/crest
    _px(c, p, 28, 0, 4, 4, 0xFFFFD600);
    _px(c, p, 34, 0, 4, 4, 0xFFFF6D00);
    _px(c, p, 22, 2, 4, 4, 0xFFFFD600);
    // Eyes
    _px(c, p, 28, 8, 4, 4, 0xFFB71C1C);
    _px(c, p, 36, 8, 4, 4, 0xFFB71C1C);
    _px(c, p, 28, 8, 2, 2, 0xFFFFFFFF);
    _px(c, p, 36, 8, 2, 2, 0xFFFFFFFF);
    // Tail
    _px(c, p, 26, 44, 12, 8, 0xFFFF6D00);
    _px(c, p, 28, 52, 8, 8, 0xFFFFAB00);
    _px(c, p, 30, 58, 4, 6, 0xFFFFD600);
    // Chest
    _px(c, p, 26, 24, 12, 8, 0xFFFFECB3);
  }

  void _drawCrystalGuard(Canvas c, Paint p) {
    // Body (crystal golem)
    _px(c, p, 16, 18, 32, 32, 0xFF0288D1);
    _px(c, p, 20, 14, 24, 6, 0xFF0288D1);
    // Crystal facets
    _px(c, p, 22, 20, 8, 12, 0xFF4FC3F7);
    _px(c, p, 38, 22, 8, 8, 0xFF4FC3F7);
    _px(c, p, 26, 36, 12, 8, 0xFF039BE5);
    // Head
    _px(c, p, 22, 4, 20, 14, 0xFF29B6F6);
    _px(c, p, 26, 2, 12, 4, 0xFF29B6F6);
    // Eyes
    _px(c, p, 26, 8, 6, 6, 0xFFFFFFFF);
    _px(c, p, 38, 8, 6, 6, 0xFFFFFFFF);
    _px(c, p, 28, 10, 2, 2, 0xFF01579B);
    _px(c, p, 40, 10, 2, 2, 0xFF01579B);
    // Arms
    _px(c, p, 6, 22, 10, 10, 0xFF0277BD);
    _px(c, p, 48, 22, 10, 10, 0xFF0277BD);
    // Legs
    _px(c, p, 20, 50, 10, 10, 0xFF01579B);
    _px(c, p, 36, 50, 10, 10, 0xFF01579B);
    // Glow
    _px(c, p, 28, 26, 8, 8, 0x4400FFFF);
  }

  void _drawCelestialDragon(Canvas c, Paint p) {
    // Long body (serpentine)
    _px(c, p, 8, 28, 48, 16, 0xFFFFD700);
    _px(c, p, 12, 24, 12, 6, 0xFFFFD700);
    _px(c, p, 40, 24, 12, 6, 0xFFFFD700);
    // Head
    _px(c, p, 4, 8, 24, 20, 0xFFFFAB40);
    _px(c, p, 8, 6, 16, 4, 0xFFFFAB40);
    // Horns
    _px(c, p, 6, 0, 6, 8, 0xFFFFD600);
    _px(c, p, 18, 0, 6, 8, 0xFFFFD600);
    // Eyes
    _px(c, p, 10, 12, 6, 6, 0xFFB71C1C);
    _px(c, p, 20, 12, 6, 6, 0xFFB71C1C);
    _px(c, p, 12, 14, 2, 2, 0xFFFFFFFF);
    _px(c, p, 22, 14, 2, 2, 0xFFFFFFFF);
    // Belly
    _px(c, p, 14, 32, 36, 8, 0xFFFFECB3);
    // Tail
    _px(c, p, 52, 26, 8, 8, 0xFFFFAB00);
    _px(c, p, 56, 22, 6, 8, 0xFFFF8F00);
    // Claws
    _px(c, p, 14, 44, 8, 8, 0xFFE65100);
    _px(c, p, 38, 44, 8, 8, 0xFFE65100);
    // Whiskers
    _px(c, p, 0, 16, 6, 2, 0xFFFFD700);
    _px(c, p, 0, 22, 6, 2, 0xFFFFD700);
  }

  void _drawGenericAlly(Canvas c, Paint p, int bodyColor) {
    // Simple cute creature
    _px(c, p, 16, 10, 28, 28, bodyColor);
    _px(c, p, 20, 8, 20, 4, bodyColor);
    _px(c, p, 20, 38, 20, 4, bodyColor);
    // Eyes
    _px(c, p, 22, 18, 6, 6, 0xFFFFFFFF);
    _px(c, p, 36, 18, 6, 6, 0xFFFFFFFF);
    _px(c, p, 24, 20, 3, 3, 0xFF111111);
    _px(c, p, 38, 20, 3, 3, 0xFF111111);
    // Mouth
    _px(c, p, 28, 28, 8, 2, 0xFF333333);
    // Feet
    _px(c, p, 18, 42, 10, 8, bodyColor ~/ 2 + 0xFF000000);
    _px(c, p, 34, 42, 10, 8, bodyColor ~/ 2 + 0xFF000000);
  }

  // ============================================================
  // BOSSES
  // ============================================================
  void _drawBossSlime(Canvas c, Paint p) {
    // Big slime body
    _px(c, p, 4, 20, 56, 36, 0xFF4CAF50);
    _px(c, p, 8, 16, 48, 8, 0xFF4CAF50);
    _px(c, p, 0, 32, 8, 16, 0xFF388E3C);
    _px(c, p, 56, 32, 8, 16, 0xFF388E3C);
    _px(c, p, 12, 56, 40, 8, 0xFF2E7D32);
    // Highlight
    _px(c, p, 12, 22, 12, 8, 0xFF81C784);
    // Crown
    _px(c, p, 16, 4, 32, 14, 0xFFFFD700);
    _px(c, p, 18, 0, 8, 8, 0xFFFFD700);
    _px(c, p, 28, 0, 8, 6, 0xFFFFD700);
    _px(c, p, 38, 0, 8, 8, 0xFFFFD700);
    _px(c, p, 20, 2, 4, 4, 0xFFFF4444);
    _px(c, p, 30, 2, 4, 2, 0xFF4444FF);
    _px(c, p, 40, 2, 4, 4, 0xFFFF4444);
    // Eyes
    _px(c, p, 18, 28, 10, 10, 0xFFFFFFFF);
    _px(c, p, 38, 28, 10, 10, 0xFFFFFFFF);
    _px(c, p, 22, 32, 4, 4, 0xFF1B5E20);
    _px(c, p, 42, 32, 4, 4, 0xFF1B5E20);
    // Evil smile
    _px(c, p, 24, 44, 16, 2, 0xFF1B5E20);
    _px(c, p, 22, 42, 4, 2, 0xFF1B5E20);
    _px(c, p, 40, 42, 4, 2, 0xFF1B5E20);
  }

  void _drawBossWolf(Canvas c, Paint p) {
    // Body
    _px(c, p, 8, 24, 40, 28, 0xFF424242);
    _px(c, p, 4, 32, 8, 16, 0xFF424242);
    // Head
    _px(c, p, 12, 8, 32, 20, 0xFF616161);
    _px(c, p, 16, 6, 24, 4, 0xFF616161);
    // Ears
    _px(c, p, 10, 0, 10, 12, 0xFF424242);
    _px(c, p, 38, 0, 10, 12, 0xFF424242);
    // Eyes (glowing)
    _px(c, p, 18, 14, 8, 6, 0xFFFF6D00);
    _px(c, p, 36, 14, 8, 6, 0xFFFF6D00);
    _px(c, p, 20, 16, 4, 2, 0xFFFFFF00);
    _px(c, p, 38, 16, 4, 2, 0xFFFFFF00);
    // Snout
    _px(c, p, 22, 22, 16, 6, 0xFF757575);
    _px(c, p, 28, 20, 6, 4, 0xFF333333);
    // Fangs
    _px(c, p, 24, 26, 4, 4, 0xFFFFFFFF);
    _px(c, p, 34, 26, 4, 4, 0xFFFFFFFF);
    // Fire mane
    _px(c, p, 44, 14, 12, 12, 0xFFFF6D00);
    _px(c, p, 48, 10, 8, 8, 0xFFFFAB00);
    _px(c, p, 52, 6, 6, 6, 0xFFFFD600);
    // Legs
    _px(c, p, 10, 52, 8, 10, 0xFF333333);
    _px(c, p, 34, 52, 8, 10, 0xFF333333);
    // Tail
    _px(c, p, 46, 28, 14, 6, 0xFF616161);
    _px(c, p, 54, 24, 8, 8, 0xFFFF6D00);
  }

  void _drawBossSerpent(Canvas c, Paint p) {
    // Coiled body
    _px(c, p, 8, 32, 48, 12, 0xFF4FC3F7);
    _px(c, p, 4, 24, 16, 12, 0xFF4FC3F7);
    _px(c, p, 40, 20, 16, 16, 0xFF4FC3F7);
    _px(c, p, 20, 40, 32, 12, 0xFF29B6F6);
    _px(c, p, 8, 48, 16, 8, 0xFF29B6F6);
    // Head (raised)
    _px(c, p, 8, 4, 24, 22, 0xFF0288D1);
    _px(c, p, 12, 2, 16, 4, 0xFF0288D1);
    // Eyes
    _px(c, p, 12, 8, 6, 6, 0xFFFFFFFF);
    _px(c, p, 22, 8, 6, 6, 0xFFFFFFFF);
    _px(c, p, 14, 10, 2, 2, 0xFF01579B);
    _px(c, p, 24, 10, 2, 2, 0xFF01579B);
    // Fangs
    _px(c, p, 14, 20, 4, 6, 0xFFE1F5FE);
    _px(c, p, 22, 20, 4, 6, 0xFFE1F5FE);
    // Ice crystals
    _px(c, p, 0, 8, 6, 6, 0xFFE1F5FE);
    _px(c, p, 34, 4, 6, 6, 0xFFE1F5FE);
    // Belly pattern
    _px(c, p, 12, 34, 36, 4, 0xFFB3E5FC);
    _px(c, p, 24, 44, 24, 4, 0xFFB3E5FC);
  }

  void _drawBossNecro(Canvas c, Paint p) {
    // Dark flower body
    _px(c, p, 12, 20, 40, 32, 0xFF4A148C);
    _px(c, p, 8, 28, 8, 16, 0xFF4A148C);
    _px(c, p, 48, 28, 8, 16, 0xFF4A148C);
    // Petals
    _px(c, p, 4, 4, 16, 20, 0xFF7B1FA2);
    _px(c, p, 44, 4, 16, 20, 0xFF7B1FA2);
    _px(c, p, 20, 0, 24, 16, 0xFF9C27B0);
    _px(c, p, 16, 48, 32, 12, 0xFF6A1B9A);
    // Center (eye)
    _px(c, p, 22, 24, 20, 16, 0xFF212121);
    _px(c, p, 28, 28, 8, 8, 0xFFFF1744);
    _px(c, p, 30, 30, 4, 4, 0xFFFFFFFF);
    // Vines
    _px(c, p, 0, 44, 12, 4, 0xFF1B5E20);
    _px(c, p, 52, 44, 12, 4, 0xFF1B5E20);
    _px(c, p, 28, 52, 8, 12, 0xFF2E7D32);
  }

  void _drawBossDragon(Canvas c, Paint p) {
    // Body
    _px(c, p, 8, 20, 40, 28, 0xFFC62828);
    _px(c, p, 4, 28, 8, 16, 0xFFC62828);
    // Head
    _px(c, p, 4, 2, 28, 22, 0xFFD32F2F);
    _px(c, p, 8, 0, 20, 4, 0xFFD32F2F);
    // Horns
    _px(c, p, 2, 0, 8, 6, 0xFF212121);
    _px(c, p, 26, 0, 8, 6, 0xFF212121);
    // Eyes
    _px(c, p, 10, 8, 8, 6, 0xFFFFD600);
    _px(c, p, 22, 8, 8, 6, 0xFFFFD600);
    _px(c, p, 14, 10, 2, 2, 0xFF212121);
    _px(c, p, 26, 10, 2, 2, 0xFF212121);
    // Nostrils + fire breath
    _px(c, p, 14, 18, 4, 4, 0xFF212121);
    _px(c, p, 22, 18, 4, 4, 0xFF212121);
    // Wings
    _px(c, p, 44, 8, 16, 24, 0xFFB71C1C);
    _px(c, p, 48, 4, 12, 8, 0xFF880E4F);
    _px(c, p, 52, 0, 8, 8, 0xFF880E4F);
    // Belly
    _px(c, p, 16, 32, 24, 12, 0xFFFFCC80);
    // Tail
    _px(c, p, 40, 40, 16, 8, 0xFFC62828);
    _px(c, p, 48, 36, 12, 8, 0xFFB71C1C);
    _px(c, p, 56, 32, 8, 8, 0xFFD32F2F);
    // Claws
    _px(c, p, 12, 48, 10, 10, 0xFF8D6E63);
    _px(c, p, 30, 48, 10, 10, 0xFF8D6E63);
  }

  void _drawBossEnder(Canvas c, Paint p) {
    // Dark cosmic body
    _px(c, p, 8, 8, 48, 48, 0xFF1A0033);
    _px(c, p, 12, 4, 40, 8, 0xFF1A0033);
    _px(c, p, 4, 16, 8, 32, 0xFF0D001A);
    _px(c, p, 52, 16, 8, 32, 0xFF0D001A);
    // Glowing cracks
    _px(c, p, 20, 16, 4, 32, 0xFF7C4DFF);
    _px(c, p, 40, 12, 4, 36, 0xFF7C4DFF);
    _px(c, p, 12, 30, 40, 4, 0xFF7C4DFF);
    // Eyes (multiple, glowing)
    _px(c, p, 16, 20, 8, 6, 0xFFFF1744);
    _px(c, p, 40, 20, 8, 6, 0xFFFF1744);
    _px(c, p, 28, 14, 6, 4, 0xFFFF1744);
    // Glowing core
    _px(c, p, 24, 32, 16, 12, 0xFF6200EA);
    _px(c, p, 28, 36, 8, 4, 0xFFFFFFFF);
    // Tendrils
    _px(c, p, 0, 40, 10, 6, 0xFF4A148C);
    _px(c, p, 54, 36, 10, 6, 0xFF4A148C);
    _px(c, p, 4, 52, 8, 8, 0xFF4A148C);
    _px(c, p, 52, 48, 8, 8, 0xFF4A148C);
    // Crown
    _px(c, p, 18, 0, 28, 8, 0xFF7C4DFF);
    _px(c, p, 22, 0, 4, 4, 0xFFFF1744);
    _px(c, p, 30, 0, 4, 2, 0xFFFF1744);
    _px(c, p, 38, 0, 4, 4, 0xFFFF1744);
  }

  void _drawBossGeneric(Canvas c, Paint p, int color) {
    _px(c, p, 8, 8, 48, 48, color);
    _px(c, p, 12, 4, 40, 8, color);
    _px(c, p, 18, 18, 10, 10, 0xFFFFFF00);
    _px(c, p, 38, 18, 10, 10, 0xFFFFFF00);
    _px(c, p, 20, 20, 6, 6, 0xFF000000);
    _px(c, p, 40, 20, 6, 6, 0xFF000000);
    _px(c, p, 24, 40, 16, 4, 0xFF000000);
  }

  // ============================================================
  // FISH
  // ============================================================
  void _drawWater(Canvas c, Paint p) {
    _px(c, p, 0, 52, 64, 12, 0xFF1A3A5E);
    _px(c, p, 4, 54, 14, 2, 0xFF2196F3);
    _px(c, p, 28, 56, 18, 2, 0xFF2196F3);
    _px(c, p, 50, 54, 10, 2, 0xFF2196F3);
  }

  void _drawFishBody(Canvas c, Paint p, int bodyColor, int bellyColor, int eyeColor) {
    _drawWater(c, p);
    // Body
    _px(c, p, 14, 18, 32, 20, bodyColor);
    _px(c, p, 18, 14, 24, 6, bodyColor);
    _px(c, p, 18, 38, 24, 6, bodyColor);
    // Belly
    _px(c, p, 18, 30, 24, 10, bellyColor);
    // Eye
    _px(c, p, 36, 20, 6, 6, 0xFFFFFFFF);
    _px(c, p, 38, 22, 3, 3, eyeColor);
    // Tail
    _px(c, p, 4, 14, 12, 8, bodyColor);
    _px(c, p, 0, 10, 8, 8, bodyColor);
    _px(c, p, 4, 34, 12, 8, bodyColor);
    _px(c, p, 0, 38, 8, 8, bodyColor);
    // Mouth
    _px(c, p, 46, 26, 4, 4, 0xFF333333);
    // Dorsal fin
    _px(c, p, 24, 8, 10, 8, bodyColor);
    _px(c, p, 26, 6, 6, 4, bodyColor);
  }

  void _drawFishFlat(Canvas c, Paint p) {
    _drawWater(c, p);
    // 광어 - 넙적한 체형
    _px(c, p, 10, 24, 40, 16, 0xFF8B7355);
    _px(c, p, 14, 20, 32, 6, 0xFF8B7355);
    _px(c, p, 14, 40, 32, 4, 0xFFA0896B);
    // Belly (하얀 배)
    _px(c, p, 18, 32, 24, 8, 0xFFE8D8C0);
    // Eyes
    _px(c, p, 40, 22, 5, 5, 0xFFFFFFFF);
    _px(c, p, 42, 24, 2, 2, 0xFF333333);
    // Tail
    _px(c, p, 4, 26, 8, 10, 0xFF7A6548);
    // Spots
    _px(c, p, 22, 26, 4, 4, 0xFF6B5638);
    _px(c, p, 34, 28, 4, 4, 0xFF6B5638);
  }

  void _drawFishMackerel(Canvas c, Paint p) {
    _drawFishBody(c, p, 0xFF4169E1, 0xFFC0C0C0, 0xFF000033);
    // Blue stripes
    _px(c, p, 18, 20, 24, 3, 0xFF1E3A6E);
    _px(c, p, 20, 26, 20, 3, 0xFF1E3A6E);
  }

  void _drawFishSquid(Canvas c, Paint p) {
    _drawWater(c, p);
    // 오징어 body (삼각형)
    _px(c, p, 20, 6, 24, 24, 0xFFE8C0A0);
    _px(c, p, 24, 4, 16, 4, 0xFFE8C0A0);
    _px(c, p, 28, 2, 8, 4, 0xFFD4A888);
    // Eyes (big)
    _px(c, p, 24, 12, 6, 6, 0xFF000000);
    _px(c, p, 36, 12, 6, 6, 0xFF000000);
    _px(c, p, 26, 14, 2, 2, 0xFFFFFFFF);
    _px(c, p, 38, 14, 2, 2, 0xFFFFFFFF);
    // Tentacles
    for (int i = 0; i < 5; i++) {
      _px(c, p, 16.0 + i * 7, 30, 4, 14, 0xFFD4A888);
      _px(c, p, 17.0 + i * 7, 42, 3, 8, 0xFFC09878);
    }
    // Spots
    _px(c, p, 28, 18, 4, 4, 0xFFBB8866);
    _px(c, p, 36, 22, 3, 3, 0xFFBB8866);
  }

  void _drawFishSalmon(Canvas c, Paint p) {
    _drawFishBody(c, p, 0xFFFA8072, 0xFFFFE4E1, 0xFF333333);
    // Orange spots
    _px(c, p, 22, 22, 3, 3, 0xFFFF6347);
    _px(c, p, 30, 26, 3, 3, 0xFFFF6347);
  }

  void _drawFishTuna(Canvas c, Paint p) {
    _drawFishBody(c, p, 0xFF2C3E50, 0xFFC0C0C0, 0xFF000000);
    // Tuna is bigger
    _px(c, p, 12, 16, 36, 24, 0xFF34495E);
    // Dorsal fin
    _px(c, p, 26, 6, 12, 10, 0xFF2C3E50);
  }

  void _drawFishEel(Canvas c, Paint p) {
    _drawWater(c, p);
    // 장어 - long serpentine
    _px(c, p, 4, 24, 52, 10, 0xFF4A6741);
    _px(c, p, 8, 22, 8, 4, 0xFF4A6741);
    _px(c, p, 48, 22, 8, 4, 0xFF4A6741);
    // Belly
    _px(c, p, 10, 30, 40, 4, 0xFFD4C880);
    // Head
    _px(c, p, 48, 20, 14, 14, 0xFF5A7A51);
    // Eye
    _px(c, p, 54, 22, 4, 4, 0xFFFFFFFF);
    _px(c, p, 56, 24, 2, 2, 0xFF000000);
    // Mouth
    _px(c, p, 60, 28, 4, 2, 0xFF333333);
  }

  void _drawFishLobster(Canvas c, Paint p) {
    _drawWater(c, p);
    // 랍스터 body
    _px(c, p, 18, 20, 28, 20, 0xFFCC3333);
    _px(c, p, 22, 16, 20, 6, 0xFFCC3333);
    // Tail
    _px(c, p, 10, 28, 10, 8, 0xFFAA2222);
    _px(c, p, 4, 30, 8, 6, 0xFFBB3333);
    // Claws
    _px(c, p, 42, 10, 12, 10, 0xFFDD4444);
    _px(c, p, 42, 32, 12, 10, 0xFFDD4444);
    _px(c, p, 52, 12, 8, 6, 0xFFCC3333);
    _px(c, p, 52, 34, 8, 6, 0xFFCC3333);
    // Eyes (stalks)
    _px(c, p, 36, 14, 4, 4, 0xFF000000);
    _px(c, p, 36, 22, 4, 4, 0xFF000000);
    // Legs
    _px(c, p, 20, 40, 4, 6, 0xFF992222);
    _px(c, p, 28, 40, 4, 6, 0xFF992222);
    _px(c, p, 36, 40, 4, 6, 0xFF992222);
  }

  void _drawFishGold(Canvas c, Paint p) {
    _drawWater(c, p);
    // 금붕어
    _px(c, p, 16, 16, 28, 22, 0xFFFF8C00);
    _px(c, p, 20, 12, 20, 6, 0xFFFF8C00);
    _px(c, p, 20, 38, 20, 6, 0xFFFFa000);
    // Big fancy tail
    _px(c, p, 2, 8, 16, 14, 0xFFFFAB40);
    _px(c, p, 2, 32, 16, 14, 0xFFFFAB40);
    _px(c, p, 0, 12, 8, 8, 0xFFFFCC80);
    _px(c, p, 0, 34, 8, 8, 0xFFFFCC80);
    // Dorsal fin
    _px(c, p, 24, 6, 10, 10, 0xFFFFAB40);
    // Eye (big, cute)
    _px(c, p, 36, 18, 8, 8, 0xFFFFFFFF);
    _px(c, p, 38, 20, 4, 4, 0xFF000000);
    _px(c, p, 38, 20, 2, 2, 0xFFFFFFFF);
    // Belly sparkle
    _px(c, p, 22, 28, 16, 6, 0xFFFFD700);
    _px(c, p, 26, 30, 4, 2, 0xFFFFFF88);
  }

  void _drawFishDragon(Canvas c, Paint p) {
    _drawWater(c, p);
    // 용물고기 - 신비로운 모습
    _px(c, p, 14, 16, 32, 22, 0xFF6A0DAD);
    _px(c, p, 18, 12, 24, 6, 0xFF6A0DAD);
    _px(c, p, 18, 38, 24, 6, 0xFF7B1FA2);
    // Dragon fins (wing-like)
    _px(c, p, 22, 4, 14, 12, 0xFF9C27B0);
    _px(c, p, 26, 2, 8, 4, 0xFFAB47BC);
    // Belly (glowing)
    _px(c, p, 20, 28, 20, 8, 0xFFCE93D8);
    // Eye (glowing)
    _px(c, p, 38, 18, 6, 6, 0xFFFF1744);
    _px(c, p, 40, 20, 2, 2, 0xFFFFFFFF);
    // Tail
    _px(c, p, 4, 18, 12, 6, 0xFF6A0DAD);
    _px(c, p, 0, 14, 8, 8, 0xFF9C27B0);
    _px(c, p, 4, 32, 12, 6, 0xFF6A0DAD);
    _px(c, p, 0, 34, 8, 8, 0xFF9C27B0);
    // Whiskers
    _px(c, p, 46, 22, 10, 2, 0xFFFFD700);
    _px(c, p, 46, 30, 10, 2, 0xFFFFD700);
    // Sparkles
    _px(c, p, 24, 20, 3, 3, 0xFFFFFF88);
    _px(c, p, 34, 24, 3, 3, 0xFFFFFF88);
  }

  // ============================================================
  // ORES
  // ============================================================
  void _drawOreBase(Canvas c, Paint p, int rockColor, int oreColor, int sparkColor) {
    // Rock base
    _px(c, p, 8, 20, 48, 36, rockColor);
    _px(c, p, 12, 16, 40, 6, rockColor);
    _px(c, p, 16, 56, 32, 6, rockColor);
    _px(c, p, 4, 28, 8, 20, rockColor);
    _px(c, p, 52, 28, 8, 20, rockColor);
    // Ore veins
    _px(c, p, 18, 24, 12, 10, oreColor);
    _px(c, p, 36, 30, 10, 12, oreColor);
    _px(c, p, 24, 42, 8, 8, oreColor);
    // Sparkle
    _px(c, p, 22, 26, 3, 3, sparkColor);
    _px(c, p, 40, 34, 3, 3, sparkColor);
  }

  void _drawOreIron(Canvas c, Paint p) {
    _drawOreBase(c, p, 0xFF696969, 0xFF808080, 0xFFC0C0C0);
    // Rust spots
    _px(c, p, 14, 32, 4, 4, 0xFF8B4513);
    _px(c, p, 44, 24, 4, 4, 0xFF8B4513);
  }

  void _drawOreCopper(Canvas c, Paint p) {
    _drawOreBase(c, p, 0xFF696969, 0xFFB87333, 0xFFE8A860);
    // Green patina
    _px(c, p, 16, 28, 4, 4, 0xFF2E8B57);
    _px(c, p, 42, 36, 4, 4, 0xFF2E8B57);
  }

  void _drawOreCoal(Canvas c, Paint p) {
    _drawOreBase(c, p, 0xFF4A4A4A, 0xFF1A1A1A, 0xFF333333);
    // Dark body
    _px(c, p, 16, 22, 32, 28, 0xFF0D0D0D);
    // Slight sheen
    _px(c, p, 20, 26, 6, 4, 0xFF2A2A2A);
    _px(c, p, 34, 38, 6, 4, 0xFF2A2A2A);
  }

  void _drawOreGold(Canvas c, Paint p) {
    _drawOreBase(c, p, 0xFF696969, 0xFFFFD700, 0xFFFFFF88);
    // Extra gold
    _px(c, p, 28, 18, 8, 6, 0xFFFFD700);
    _px(c, p, 16, 38, 6, 6, 0xFFDAA520);
  }

  void _drawOreSilver(Canvas c, Paint p) {
    _drawOreBase(c, p, 0xFF696969, 0xFFC0C0C0, 0xFFFFFFFF);
    // Extra silver shine
    _px(c, p, 22, 28, 4, 2, 0xFFFFFFFF);
    _px(c, p, 38, 36, 4, 2, 0xFFFFFFFF);
  }

  void _drawOreEmerald(Canvas c, Paint p) {
    _drawOreBase(c, p, 0xFF696969, 0xFF50C878, 0xFF88FFAA);
    // Crystal facets
    _px(c, p, 20, 22, 8, 14, 0xFF3CB371);
    _px(c, p, 24, 20, 4, 4, 0xFF88FFCC);
    _px(c, p, 38, 28, 6, 10, 0xFF3CB371);
  }

  void _drawOreRuby(Canvas c, Paint p) {
    _drawOreBase(c, p, 0xFF696969, 0xFFDC143C, 0xFFFF6688);
    // Red glow
    _px(c, p, 22, 26, 10, 8, 0xFFCC1133);
    _px(c, p, 26, 24, 4, 4, 0xFFFF4466);
    _px(c, p, 38, 32, 8, 8, 0xFFCC1133);
    _px(c, p, 40, 34, 3, 3, 0xFFFF88AA);
  }

  void _drawOreDiamond(Canvas c, Paint p) {
    _drawOreBase(c, p, 0xFF696969, 0xFF88CCFF, 0xFFFFFFFF);
    // Diamond shape
    _px(c, p, 24, 16, 16, 4, 0xFFB0E0FF);
    _px(c, p, 20, 20, 24, 12, 0xFF88CCFF);
    _px(c, p, 24, 32, 16, 4, 0xFF66AADD);
    // Brilliant sparkles
    _px(c, p, 28, 22, 4, 2, 0xFFFFFFFF);
    _px(c, p, 36, 26, 3, 3, 0xFFFFFFFF);
    _px(c, p, 22, 28, 2, 2, 0xFFFFFFFF);
  }

  void _drawOreMithril(Canvas c, Paint p) {
    _drawOreBase(c, p, 0xFF4A4A6A, 0xFF4488CC, 0xFFAADDFF);
    // Glowing blue veins
    _px(c, p, 18, 22, 14, 12, 0xFF3366BB);
    _px(c, p, 34, 28, 12, 14, 0xFF3366BB);
    // Glow effect
    _px(c, p, 22, 26, 4, 4, 0xFF88CCFF);
    _px(c, p, 38, 34, 4, 4, 0xFF88CCFF);
    // Mystical sparkle
    _px(c, p, 26, 30, 2, 2, 0xFFFFFFFF);
    _px(c, p, 42, 38, 2, 2, 0xFFFFFFFF);
    _px(c, p, 30, 20, 2, 2, 0xFFFFFFFF);
  }

  void _drawDefault(Canvas c, Paint p) {
    _px(c, p, 16, 16, 32, 32, 0xFFFF00FF);
    _px(c, p, 24, 24, 6, 6, 0xFFFFFFFF);
    _px(c, p, 36, 24, 6, 6, 0xFFFFFFFF);
  }

  @override
  bool shouldRepaint(_SpritePainter old) =>
    old.id != id || old.flipX != flipX || old.anim != anim;
}

/// Helper to get sprite ID for a crop
String cropSpriteId(String? cropId, double progress) {
  if (cropId == null) return 'crop_seed';
  if (progress < 0.33) return 'crop_seed';
  if (progress < 0.66) return 'crop_growing';
  return cropId; // full crop sprite
}

/// Helper to get sprite ID for an ally by role
String allySpriteId(String allyId) {
  const map = {
    'sproutling': 'ally_sproutling',
    'ember_pup': 'ally_ember_pup',
    'puddle_slime': 'ally_puddle_slime',
    'zap_bug': 'ally_zap_bug',
    'flame_fox': 'ally_flame_fox',
    'phoenix_hatchling': 'ally_phoenix',
    'crystal_guardian': 'ally_crystal_guard',
    'celestial_dragon': 'ally_celestial_dragon',
  };
  return map[allyId] ?? 'ally_generic_dps';
}

/// Helper to get sprite ID for a fish
String fishSpriteId(String? fishId) {
  if (fishId == null) return 'crop_seed';
  return 'fish_$fishId';
}

/// Helper to get sprite ID for an ore
String oreSpriteId(String? oreId) {
  if (oreId == null) return 'crop_seed';
  return 'ore_$oreId';
}

/// Helper to get sprite ID for a boss by stage
String bossSpriteId(int stage) {
  if (stage <= 2) return 'boss_slime';
  if (stage <= 5) return 'boss_wolf';
  if (stage <= 8) return 'boss_serpent';
  if (stage <= 12) return 'boss_necro';
  if (stage <= 17) return 'boss_dragon';
  return 'boss_ender';
}
