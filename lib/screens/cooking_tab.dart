import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/models.dart';
import '../data/game_data.dart';
import '../services/game_engine.dart';

class CookingTab extends StatelessWidget {
  final GameEngine engine;
  const CookingTab({super.key, required this.engine});

  String _ingName(String id) => GameData.ingredientNames[id] ?? id;

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();

    // 보유 재료 중 0개 이상만 표시, 소스별 분류
    final farmIngs = <String, int>{};
    final fishIngs = <String, int>{};
    final mineIngs = <String, int>{};
    final specialIngs = <String, int>{};

    for (final entry in gs.cookingIngredients.entries) {
      if (entry.value <= 0) continue;
      final id = entry.key;
      if (id == 'spice') {
        specialIngs[id] = entry.value;
      } else if (GameData.fish.any((f) => f.id == id)) {
        fishIngs[id] = entry.value;
      } else if (GameData.ores.any((o) => o.id == id)) {
        mineIngs[id] = entry.value;
      } else {
        farmIngs[id] = entry.value;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('\uD83C\uDF73 \uC694\uB9AC & \uC2DC\uC7A5',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('\uC694\uB9AC \uC644\uC131 \uC2DC \uC790\uB3D9 \uD310\uB9E4\uB429\uB2C8\uB2E4',
              style: TextStyle(color: Color(0xFF4CAF50), fontSize: 11)),
          const SizedBox(height: 10),

          // Ingredient inventory
          _sectionHeader('\uD83E\uDDC2 \uBCF4\uC720 \uC7AC\uB8CC'),
          const SizedBox(height: 6),
          if (farmIngs.isNotEmpty) ...[
            const Text('\uD83C\uDF3E \uB18D\uC7A5', style: TextStyle(color: Colors.white54, fontSize: 10)),
            const SizedBox(height: 2),
            _ingredientRow(farmIngs),
            const SizedBox(height: 6),
          ],
          if (fishIngs.isNotEmpty) ...[
            const Text('\uD83C\uDFA3 \uB09A\uC2DC', style: TextStyle(color: Colors.white54, fontSize: 10)),
            const SizedBox(height: 2),
            _ingredientRow(fishIngs),
            const SizedBox(height: 6),
          ],
          if (mineIngs.isNotEmpty) ...[
            const Text('\u26CF \uCC44\uAD11', style: TextStyle(color: Colors.white54, fontSize: 10)),
            const SizedBox(height: 2),
            _ingredientRow(mineIngs),
            const SizedBox(height: 6),
          ],
          if (specialIngs.isNotEmpty) ...[
            const Text('\u2B50 \uD2B9\uC218', style: TextStyle(color: Colors.white54, fontSize: 10)),
            const SizedBox(height: 2),
            _ingredientRow(specialIngs),
            const SizedBox(height: 6),
          ],
          if (farmIngs.isEmpty && fishIngs.isEmpty && mineIngs.isEmpty && specialIngs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('\uC7AC\uB8CC\uAC00 \uC5C6\uC2B5\uB2C8\uB2E4. \uC791\uC5C5\uC7A5\uC5D0\uC11C \uC218\uD655\uD558\uC138\uC694!',
                  style: TextStyle(color: Colors.white38, fontSize: 11)),
            ),
          const SizedBox(height: 12),

          // Cooking slots
          _sectionHeader('\uD83C\uDF72 \uC694\uB9AC \uC2AC\uB86F'),
          const SizedBox(height: 6),
          ...gs.cookingSlots.asMap().entries.map((entry) {
            final i = entry.key;
            final slot = entry.value;
            return _cookingSlotWidget(context, gs, i, slot);
          }),
          const SizedBox(height: 12),

          // Market prices
          _sectionHeader('\uD83D\uDCB0 \uC2DC\uC7A5 \uC2DC\uC138 (\uB2E4\uC74C \uBCC0\uB3D9: ${_formatTime(gs.marketTimer)})'),
          const SizedBox(height: 6),
          ...GameData.recipes.map((recipe) {
            final mp = gs.marketPrices.where((p) => p.recipeId == recipe.id).firstOrNull;
            final mult = mp?.multiplier ?? 1.0;
            final price = (recipe.basePrice * mult).floor();
            final color = mult >= 1.5 ? const Color(0xFFFF5252)
                : mult >= 1.0 ? const Color(0xFF4CAF50)
                : const Color(0xFF2196F3);
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0d1117),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: Row(
                children: [
                  Text(recipe.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(recipe.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${price}G', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('x${mult.toStringAsFixed(2)}',
                          style: TextStyle(color: color, fontSize: 9)),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),

          // Recipes
          _sectionHeader('\uD83D\uDCD6 \uB808\uC2DC\uD53C'),
          const SizedBox(height: 6),
          ...GameData.recipes.map((recipe) => _recipeCard(context, gs, recipe)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _ingredientRow(Map<String, int> ings) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: ings.entries.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF0d1117),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.5)),
          ),
          child: Text('${_ingName(e.key)} x${e.value}',
              style: const TextStyle(color: Colors.white, fontSize: 10)),
        );
      }).toList(),
    );
  }

  Widget _cookingSlotWidget(BuildContext context, GameState gs, int index, CookingSlot slot) {
    if (slot.recipeId == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0d1117),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Center(
          child: Text('\uC2AC\uB86F ${index + 1} - \uBE44\uC5B4\uC788\uC74C',
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ),
      );
    }

    final recipe = engine.getRecipe(slot.recipeId!);
    final name = recipe?.name ?? slot.recipeId!;
    final progress = slot.totalTime > 0 ? (1.0 - slot.timeLeft / slot.totalTime).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF9800)),
      ),
      child: Row(
        children: [
          Text(recipe?.emoji ?? '\uD83C\uDF72', style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFF333333),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFF9800)),
                  ),
                ),
                Text('\uC694\uB9AC \uC911... ${_formatTime(slot.timeLeft)}',
                    style: const TextStyle(color: Color(0xFFFF9800), fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recipeCard(BuildContext context, GameState gs, Recipe recipe) {
    final canMake = engine.canCook(recipe);
    final emptySlot = gs.cookingSlots.indexWhere((s) => s.recipeId == null);

    return Card(
      color: const Color(0xFF0d1117),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: canMake ? const Color(0xFF4CAF50) : const Color(0xFF333333)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(recipe.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recipe.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('⏱ ${recipe.cookTime}초 | 🍖+${recipe.rationRestore}',
                          style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: canMake && emptySlot >= 0
                      ? () => engine.startCooking(emptySlot, recipe.id)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canMake && emptySlot >= 0 ? const Color(0xFF4CAF50) : const Color(0xFF333333),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  child: Text(emptySlot < 0 ? '\uC2AC\uB86F\uC5C6\uC74C' : '\uC694\uB9AC',
                      style: const TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 2,
              children: recipe.ingredients.map((ing) {
                final have = gs.cookingIngredients[ing.ingredientId] ?? 0;
                final enough = have >= ing.amount;
                return Text(
                  '${_ingName(ing.ingredientId)} $have/${ing.amount}',
                  style: TextStyle(
                    color: enough ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
                    fontSize: 10,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
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
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  String _formatTime(double seconds) {
    final h = (seconds / 3600).floor();
    final m = ((seconds % 3600) / 60).floor();
    final s = (seconds % 60).floor();
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }
}
