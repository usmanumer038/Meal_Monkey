import 'dart:math';

/// Generates a deterministic price for a meal based on its ID.
/// Keeps prices stable across app sessions (no random each time).
class PriceService {
  static double priceForMeal(String id, {double min = 8, double max = 22}) {
    if (id.isEmpty) return min;
    // Simple hash to 0..1
    final h = id.codeUnits.fold<int>(0, (a, b) => (a * 31 + b) & 0x7fffffff);
    final t = (h % 1000) / 1000.0; // 0..0.999
    final price = min + (max - min) * t;
    // Round to 0.5 steps (optional)
    return (price * 2).round() / 2.0;
  }
}