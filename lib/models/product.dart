import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final Color backgroundColor;

  /// Rough estimate per unit (kg CO2e). In a real app this comes from backend.
  final double carbonKg;

  /// Marks products that are intended as low-impact alternatives.
  final bool isSustainable;

  /// Optional grouping to find alternatives.
  final String? category;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.backgroundColor,
    required this.carbonKg,
    required this.isSustainable,
    this.category,
  });
}
