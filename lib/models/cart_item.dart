import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  /// Unit price at the time it was added (supports discounts/group deals).
  final double unitPrice;

  /// Optional label shown in cart (e.g., "Group deal").
  final String? priceLabel;

  CartItem({
    required this.product,
    this.quantity = 1,
    double? unitPrice,
    this.priceLabel,
  }) : unitPrice = unitPrice ?? product.price;

  double get totalPrice => unitPrice * quantity;
  double get totalCarbonKg => product.carbonKg * quantity;
}
