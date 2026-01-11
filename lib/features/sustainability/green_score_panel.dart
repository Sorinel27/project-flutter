import 'package:flutter/material.dart';

import '../../data/mock_products.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';

/// Eco-Impact & Sustainability Tracker
///
/// Computes total carbon footprint (kg CO2e) from the cart.
/// If the footprint is "high", suggests a lower-impact alternative from catalog.
class GreenScorePanel extends StatelessWidget {
  final double highFootprintThresholdKg;

  const GreenScorePanel({
    super.key,
    this.highFootprintThresholdKg = 15.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cartModel,
      builder: (context, child) {
        final total = cartModel.totalCarbonKg;
        final score = _greenScore(total);
        final isHigh = total >= highFootprintThresholdKg;

        final suggestion = isHigh ? _findSuggestion() : null;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _ScoreRing(score: score),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Green Score',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${total.toStringAsFixed(1)} kg CO2e estimated',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _scoreLabel(score),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _scoreColor(score),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (suggestion != null) ...[
              const SizedBox(height: 12),
              _SustainableSwapCard(
                suggestion: suggestion,
                onSwap: () {
                  // Swap the highest-carbon item with the suggestion.
                  final target = _highestCarbonProductIdInCart();
                  if (target == null) return;
                  cartModel.swapOne(target, suggestion);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Swapped for ${suggestion.name}'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ]
          ],
        );
      },
    );
  }

  int _greenScore(double totalKg) {
    // Very simple mapping: lower carbon => higher score.
    // 0kg -> 100, 30kg -> ~0
    final score = (100 - (totalKg * 3.3)).clamp(0, 100);
    return score.round();
  }

  String _scoreLabel(int score) {
    if (score >= 80) return 'Great (low impact)';
    if (score >= 55) return 'OK (moderate impact)';
    if (score >= 30) return 'High impact';
    return 'Very high impact';
  }

  Color _scoreColor(int score) {
    if (score >= 80) return Colors.green.shade700;
    if (score >= 55) return Colors.teal.shade700;
    if (score >= 30) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  Product? _findSuggestion() {
    final targetId = _highestCarbonProductIdInCart();
    if (targetId == null) return null;

    final target = findProductById(targetId);
    if (target == null) return null;

    // Prefer same category sustainable items with lower carbon.
    final candidates = mockProducts.where((p) {
      if (!p.isSustainable) return false;
      if (target.category != null && p.category != target.category) return false;
      return p.carbonKg < target.carbonKg;
    }).toList(growable: false);

    if (candidates.isEmpty) {
      // Fallback: any sustainable item with low carbon.
      final any = mockProducts.where((p) => p.isSustainable).toList(growable: false);
      if (any.isEmpty) return null;
      any.sort((a, b) => a.carbonKg.compareTo(b.carbonKg));
      return any.first;
    }

    candidates.sort((a, b) => a.carbonKg.compareTo(b.carbonKg));
    return candidates.first;
  }

  String? _highestCarbonProductIdInCart() {
    if (cartModel.items.isEmpty) return null;

    double best = -1;
    String? bestId;
    for (final item in cartModel.items) {
      final total = item.totalCarbonKg;
      if (total > best) {
        best = total;
        bestId = item.product.id;
      }
    }
    return bestId;
  }
}

class _ScoreRing extends StatelessWidget {
  final int score;

  const _ScoreRing({required this.score});

  @override
  Widget build(BuildContext context) {
    final value = score / 100.0;
    final color = value >= 0.8
        ? Colors.green
        : value >= 0.55
            ? Colors.teal
            : value >= 0.3
                ? Colors.orange
                : Colors.red;

    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Text(
            '$score',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _SustainableSwapCard extends StatelessWidget {
  final Product suggestion;
  final VoidCallback onSwap;

  const _SustainableSwapCard({
    required this.suggestion,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1320),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_outlined, color: Colors.greenAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Swap for a sustainable alternative',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${suggestion.name} • ${suggestion.carbonKg.toStringAsFixed(1)} kg CO2e',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: onSwap,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text('Swap'),
          ),
        ],
      ),
    );
  }
}
