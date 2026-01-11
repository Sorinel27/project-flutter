import 'package:flutter/material.dart';

import '../models/product.dart';

final List<Product> mockProducts = [
  Product(
    id: '1',
    name: 'Vintage Camera',
    description:
        'Capture life\'s moments with this classic vintage style camera. Features high-resolution lens and retro build.',
    price: 129.99,
    imageUrl:
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
    backgroundColor: Colors.orangeAccent,
    carbonKg: 8.4,
    isSustainable: false,
    category: 'electronics',
  ),
  Product(
    id: '2',
    name: 'Wireless Headphones',
    description:
        'Noise-cancelling over-ear headphones with 30-hour battery life and premium sound quality.',
    price: 199.50,
    imageUrl:
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
    backgroundColor: Colors.lightBlueAccent,
    carbonKg: 6.2,
    isSustainable: false,
    category: 'electronics',
  ),
  Product(
    id: '3',
    name: 'Minimalist Watch',
    description:
        'Elegant timepiece for the modern professional. Genuine leather strap and water resistance.',
    price: 89.00,
    imageUrl:
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
    backgroundColor: Colors.grey,
    carbonKg: 3.1,
    isSustainable: false,
    category: 'accessories',
  ),
  Product(
    id: '4',
    name: 'Sneakers',
    description:
        'Comfortable and stylish sneakers for everyday wear. Breathable mesh and durable sole.',
    price: 75.00,
    imageUrl:
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
    backgroundColor: Colors.redAccent,
    carbonKg: 12.5,
    isSustainable: false,
    category: 'fashion',
  ),
  Product(
    id: '5',
    name: 'Smart Speaker',
    description:
        'Voice-controlled smart speaker with home automation integration.',
    price: 49.99,
    imageUrl:
        'https://images.unsplash.com/photo-1589492477829-5e65395b66cc?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
    backgroundColor: Colors.purpleAccent,
    carbonKg: 4.6,
    isSustainable: false,
    category: 'electronics',
  ),

  // Sustainable alternatives (recommendations)
  Product(
    id: '6',
    name: 'Eco Sneakers',
    description:
        'Low-impact sneakers made with recycled materials and a durable, repair-friendly sole.',
    price: 85.00,
    imageUrl:
        'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
    backgroundColor: Colors.greenAccent,
    carbonKg: 5.2,
    isSustainable: true,
    category: 'fashion',
  ),
  Product(
    id: '7',
    name: 'Refurb Speaker',
    description:
        'Refurbished smart speaker with verified components and reduced manufacturing footprint.',
    price: 39.99,
    imageUrl:
        'https://images.unsplash.com/photo-1545454675-3531b543be5d?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
    backgroundColor: Colors.green,
    carbonKg: 1.6,
    isSustainable: true,
    category: 'electronics',
  ),
];

Product? findProductById(String id) {
  for (final p in mockProducts) {
    if (p.id == id) return p;
  }
  return null;
}
