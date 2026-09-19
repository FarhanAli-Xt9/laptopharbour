import 'package:flutter/material.dart';
import 'laptop.dart';
import '../services/cart_service.dart';

class CartItem {
  final Laptop laptop;
  final String selectedCpu;
  final String selectedGpu;
  final String selectedRam;
  final String selectedStorage;
  final double totalPrice;
  int quantity;

  CartItem({
    required this.laptop,
    required this.selectedCpu,
    required this.selectedGpu,
    required this.selectedRam,
    required this.selectedStorage,
    required this.totalPrice,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'laptopId': laptop.id,
      'selectedCpu': selectedCpu,
      'selectedGpu': selectedGpu,
      'selectedRam': selectedRam,
      'selectedStorage': selectedStorage,
      'totalPrice': totalPrice,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json, Laptop laptop) {
    return CartItem(
      laptop: laptop,
      selectedCpu: json['selectedCpu'] as String? ?? laptop.cpu,
      selectedGpu: json['selectedGpu'] as String? ?? laptop.gpu,
      selectedRam: json['selectedRam'] as String? ?? laptop.ram,
      selectedStorage: json['selectedStorage'] as String? ?? laptop.storage,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? laptop.basePrice,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

/// Backward-compatible bridge delegating to [CartService].
class CartManager {
  static ValueNotifier<List<CartItem>> get items => CartService.instance.items;

  static void addToCart(CartItem item) {
    CartService.instance.addToCart(item);
  }

  static void removeFromCart(CartItem item) {
    CartService.instance.removeFromCart(item);
  }

  static void clearCart() {
    CartService.instance.clearCart();
  }

  static void updateQuantity(CartItem item, int delta) {
    CartService.instance.updateQuantity(item, delta);
  }
}
