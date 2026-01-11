import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_products.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartModel extends ChangeNotifier {
  static const String _prefKey = 'cart_items_v1';

  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get totalCarbonKg => _items.fold(0.0, (sum, item) => sum + item.totalCarbonKg);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      _items.clear();
      for (final entry in decoded) {
        if (entry is! Map) continue;
        final productId = entry['productId'];
        final quantity = entry['quantity'];
        final unitPrice = entry['unitPrice'];

        if (productId is! String || quantity is! int || unitPrice is! num) continue;
        final product = findProductById(productId);
        if (product == null) continue;

        final priceLabel = entry['priceLabel'];
        _items.add(
          CartItem(
            product: product,
            quantity: quantity,
            unitPrice: unitPrice.toDouble(),
            priceLabel: priceLabel is String ? priceLabel : null,
          ),
        );
      }
    } catch (_) {
      // If storage is corrupted, ignore and start clean.
      _items.clear();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _items
        .map(
          (e) => <String, Object?>{
            'productId': e.product.id,
            'quantity': e.quantity,
            'unitPrice': e.unitPrice,
            'priceLabel': e.priceLabel,
          },
        )
        .toList(growable: false);
    await prefs.setString(_prefKey, jsonEncode(payload));
  }

  void addItem(Product product, {double? unitPrice, String? priceLabel}) {
    addItems(product, quantity: 1, unitPrice: unitPrice, priceLabel: priceLabel);
  }

  void addItems(
    Product product, {
    required int quantity,
    double? unitPrice,
    String? priceLabel,
  }) {
    if (quantity <= 0) return;

    final effectiveUnitPrice = unitPrice ?? product.price;
    final index = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.unitPrice == effectiveUnitPrice &&
          item.priceLabel == priceLabel,
    );

    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          product: product,
          quantity: quantity,
          unitPrice: effectiveUnitPrice,
          priceLabel: priceLabel,
        ),
      );
    }

    notifyListeners();
    unawaited(_save());
  }

  void removeSingleItem(
    String productId, {
    double? unitPrice,
    String? priceLabel,
  }) {
    final index = _items.indexWhere(
      (item) =>
          item.product.id == productId &&
          (unitPrice == null || item.unitPrice == unitPrice) &&
          (priceLabel == null || item.priceLabel == priceLabel),
    );
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
      unawaited(_save());
    }
  }

  /// Replaces one unit of a product with a different product.
  /// If the old product has quantity > 1, decrement it and add the new product.
  void swapOne(String fromProductId, Product toProduct) {
    final index = _items.indexWhere((item) => item.product.id == fromProductId);
    if (index < 0) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    addItem(toProduct);
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    unawaited(_save());
  }
}
