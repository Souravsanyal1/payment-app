import 'dart:math';

class PaymentUtils {
  /// Generates a unique amount by adding a small random decimal (e.g., 100 -> 100.37)
  static double generateUniqueAmount(double baseAmount) {
    final random = Random();
    // Generate a random double between 0.01 and 0.99
    double uniquePart = (random.nextInt(98) + 1) / 100.0;
    return double.parse((baseAmount + uniquePart).toStringAsFixed(2));
  }

  static String formatAmount(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
