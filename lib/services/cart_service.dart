import 'package:flutter/foundation.dart';
import '../models/cart.dart';
import '../utils/constants.dart';
import 'laptop_service.dart';
import 'storage_service.dart';

/// Centralized shopping cart service managing item configurations,
/// quantities, price calculations, and local persistence across app restarts.
class CartService {
  static final CartService instance = CartService._();
  CartService._();

  final ValueNotifier<List<CartItem>> items = ValueNotifier<List<CartItem>>([]);

  /// Restores saved cart items from local storage on startup
  Future<void> init() async {
    try {
      final jsonList = StorageService.instance.getJsonList(AppConstants.keyCartItems);
      if (jsonList != null && jsonList.isNotEmpty) {
        final laptopService = LaptopService();
        final restored = <CartItem>[];

        for (final jsonItem in jsonList) {
          final laptopId = jsonItem['laptopId'] as String?;
          if (laptopId != null) {
            final laptop = laptopService.getLaptopById(laptopId);
            if (laptop != null) {
              restored.add(CartItem.fromJson(jsonItem, laptop));
            }
          }
        }
        items.value = restored;
      }
    } catch (e) {
      debugPrint('[CartService] Error restoring cart from storage: $e');
    }
  }

  /// Adds an item to the cart or increments its quantity if the exact hardware configuration matches
  void addToCart(CartItem item) {
    final list = List<CartItem>.from(items.value);
    bool found = false;

    for (final existing in list) {
      if (existing.laptop.id == item.laptop.id &&
          existing.selectedCpu == item.selectedCpu &&
          existing.selectedGpu == item.selectedGpu &&
          existing.selectedRam == item.selectedRam &&
          existing.selectedStorage == item.selectedStorage) {
        final newQuantity = existing.quantity + item.quantity;
        existing.quantity = newQuantity.clamp(
          AppConstants.minCartQuantity,
          AppConstants.maxCartQuantity,
        );
        found = true;
        break;
      }
    }

    if (!found) {
      item.quantity = item.quantity.clamp(
        AppConstants.minCartQuantity,
        AppConstants.maxCartQuantity,
      );
      list.add(item);
    }

    items.value = list;
    _persist();
  }

  /// Removes a specific cart item
  void removeFromCart(CartItem item) {
    final list = List<CartItem>.from(items.value);
    list.removeWhere((i) =>
        i.laptop.id == item.laptop.id &&
        i.selectedCpu == item.selectedCpu &&
        i.selectedGpu == item.selectedGpu &&
        i.selectedRam == item.selectedRam &&
        i.selectedStorage == item.selectedStorage);
    items.value = list;
    _persist();
  }

  /// Adjusts quantity with boundary clamping
  void updateQuantity(CartItem item, int delta) {
    final list = List<CartItem>.from(items.value);
    for (final existing in list) {
      if (existing.laptop.id == item.laptop.id &&
          existing.selectedCpu == item.selectedCpu &&
          existing.selectedGpu == item.selectedGpu &&
          existing.selectedRam == item.selectedRam &&
          existing.selectedStorage == item.selectedStorage) {
        final newQuantity = existing.quantity + delta;
        if (newQuantity <= 0) {
          list.remove(existing);
        } else {
          existing.quantity = newQuantity.clamp(
            AppConstants.minCartQuantity,
            AppConstants.maxCartQuantity,
          );
        }
        break;
      }
    }
    items.value = list;
    _persist();
  }

  /// Clears all cart items (e.g., after checkout)
  void clearCart() {
    items.value = [];
    _persist();
  }

  /// Calculates items subtotal
  double get subtotal {
    double sum = 0.0;
    for (final item in items.value) {
      sum += item.totalPrice * item.quantity;
    }
    return sum;
  }

  /// Total count of units across all line items
  int get totalItemCount {
    int count = 0;
    for (final item in items.value) {
      count += item.quantity;
    }
    return count;
  }

  /// Standard tax computation
  double calculateTax(double subtotalAmount) {
    return subtotalAmount * AppConstants.taxRate;
  }

  /// Shipping fee calculation with free shipping over threshold
  double calculateShipping(double subtotalAmount) {
    if (subtotalAmount == 0) return 0.0;
    return subtotalAmount >= AppConstants.freeShippingThreshold
        ? 0.0
        : AppConstants.standardShippingFee;
  }

  /// Calculates promo discount
  double calculateDiscount(double subtotalAmount, double discountPercentage) {
    if (discountPercentage <= 0) return 0.0;
    return subtotalAmount * discountPercentage;
  }

  /// Computes final order total
  double calculateFinalTotal({
    required double subtotalAmount,
    required double taxAmount,
    required double shippingAmount,
    required double discountAmount,
  }) {
    final total = subtotalAmount - discountAmount + taxAmount + shippingAmount;
    return total < 0 ? 0.0 : total;
  }

  void _persist() {
    try {
      final jsonList = items.value.map((i) => i.toJson()).toList();
      StorageService.instance.setJsonList(AppConstants.keyCartItems, jsonList);
    } catch (e) {
      debugPrint('[CartService] Error saving cart to local storage: $e');
    }
  }
}
