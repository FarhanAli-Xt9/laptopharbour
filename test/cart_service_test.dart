// Laptop Harbour – CartService Unit Tests
//
// Tests price calculations, quantity management, and cart logic in CartService.
// Note: init() and _persist() require SharedPreferences which is not available
// in plain unit tests, so those are tested implicitly via integration or
// excluded here. Pure calculation methods have no Flutter dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:laptopharbour/services/cart_service.dart';
import 'package:laptopharbour/utils/constants.dart';

void main() {
  final cart = CartService.instance;

  // ─── Tax Calculation ─────────────────────────────────────────────────────
  group('CartService.calculateTax', () {
    test('calculates 8% tax on a given subtotal', () {
      expect(cart.calculateTax(1000.0), closeTo(80.0, 0.01));
    });

    test('returns 0 tax for zero subtotal', () {
      expect(cart.calculateTax(0.0), closeTo(0.0, 0.001));
    });

    test('tax rate matches AppConstants.taxRate', () {
      const subtotal = 500.0;
      expect(
        cart.calculateTax(subtotal),
        closeTo(subtotal * AppConstants.taxRate, 0.001),
      );
    });
  });

  // ─── Shipping Calculation ────────────────────────────────────────────────
  group('CartService.calculateShipping', () {
    test('charges standard shipping fee below threshold', () {
      expect(
        cart.calculateShipping(AppConstants.freeShippingThreshold - 1),
        closeTo(AppConstants.standardShippingFee, 0.001),
      );
    });

    test('grants free shipping at exactly the threshold', () {
      expect(cart.calculateShipping(AppConstants.freeShippingThreshold), closeTo(0.0, 0.001));
    });

    test('grants free shipping above the threshold', () {
      expect(cart.calculateShipping(3000.0), closeTo(0.0, 0.001));
    });

    test('returns 0 shipping on empty cart (subtotal = 0)', () {
      expect(cart.calculateShipping(0.0), closeTo(0.0, 0.001));
    });
  });

  // ─── Discount Calculation ────────────────────────────────────────────────
  group('CartService.calculateDiscount', () {
    test('HARBOUR20 promo gives 20% discount', () {
      const subtotal = 1000.0;
      const discountPct = 0.20; // HARBOUR20
      expect(cart.calculateDiscount(subtotal, discountPct), closeTo(200.0, 0.001));
    });

    test('PILOT10 promo gives 10% discount', () {
      const subtotal = 500.0;
      const discountPct = 0.10; // PILOT10
      expect(cart.calculateDiscount(subtotal, discountPct), closeTo(50.0, 0.001));
    });

    test('zero discount percentage returns 0', () {
      expect(cart.calculateDiscount(800.0, 0.0), closeTo(0.0, 0.001));
    });

    test('negative discount percentage returns 0', () {
      expect(cart.calculateDiscount(800.0, -0.1), closeTo(0.0, 0.001));
    });
  });

  // ─── Final Total ─────────────────────────────────────────────────────────
  group('CartService.calculateFinalTotal', () {
    test('correct total with standard shipping and no discount', () {
      // subtotal=1500, tax=120, shipping=49, discount=0 → 1669
      final total = cart.calculateFinalTotal(
        subtotalAmount: 1500.0,
        taxAmount: 120.0,
        shippingAmount: 49.0,
        discountAmount: 0.0,
      );
      expect(total, closeTo(1669.0, 0.01));
    });

    test('correct total with free shipping and HARBOUR20 discount', () {
      // subtotal=2500, tax=200, shipping=0, discount=500 → 2200
      final total = cart.calculateFinalTotal(
        subtotalAmount: 2500.0,
        taxAmount: 200.0,
        shippingAmount: 0.0,
        discountAmount: 500.0,
      );
      expect(total, closeTo(2200.0, 0.01));
    });

    test('total never goes below 0 even with large discount', () {
      final total = cart.calculateFinalTotal(
        subtotalAmount: 100.0,
        taxAmount: 8.0,
        shippingAmount: 49.0,
        discountAmount: 5000.0, // huge discount
      );
      expect(total, greaterThanOrEqualTo(0.0));
    });
  });

  // ─── AppConstants Promo Codes ────────────────────────────────────────────
  group('AppConstants.promoCodes', () {
    test('HARBOUR20 promo code exists and gives 20% off', () {
      expect(AppConstants.promoCodes.containsKey('HARBOUR20'), isTrue);
      expect(AppConstants.promoCodes['HARBOUR20'], closeTo(0.20, 0.001));
    });

    test('PILOT10 promo code exists and gives 10% off', () {
      expect(AppConstants.promoCodes.containsKey('PILOT10'), isTrue);
      expect(AppConstants.promoCodes['PILOT10'], closeTo(0.10, 0.001));
    });

    test('invalid promo code returns null', () {
      expect(AppConstants.promoCodes['FAKECODE'], isNull);
    });
  });
}
