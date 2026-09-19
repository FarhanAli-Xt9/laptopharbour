import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

/// Centralized service handling order creation, historical retrieval,
/// and local storage persistence.
class OrderService {
  static final OrderService instance = OrderService._();
  OrderService._();

  final ValueNotifier<List<Order>> orders = ValueNotifier<List<Order>>([]);

  /// Restores saved orders from local storage or sets default starter history
  Future<void> init() async {
    try {
      final jsonList = StorageService.instance.getJsonList(AppConstants.keyOrders);
      if (jsonList != null && jsonList.isNotEmpty) {
        orders.value = jsonList.map((j) => Order.fromJson(j)).toList();
        return;
      }
    } catch (e) {
      debugPrint('[OrderService] Error loading orders from storage: $e');
    }

    // Default starter history if none saved
    orders.value = [
      Order(
        id: 'LHP-88712-C',
        date: '2026-07-10',
        customerName: 'Captain User',
        customerEmail: 'captain@harbour.com',
        customerPhone: '+1 415-555-0199',
        shippingAddress: '72 sector-X, Cyber Harbour, SF 94103',
        paymentMethod: 'Credit Card (Demo Gateway)',
        subtotal: 1999.0,
        tax: 159.92,
        shippingFee: 0.0,
        finalTotal: 2158.92,
        status: OrderTrackingStatus.inTransit,
        items: [
          OrderItemInfo(
            laptopName: 'Blade Nebula 14',
            brand: 'Razer',
            imageUrl: 'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=800&auto=format&fit=crop&q=80',
            cpu: 'AMD Ryzen 9 8945HS',
            gpu: 'NVIDIA RTX 4070 (8GB)',
            ram: '16GB DDR5',
            storage: '1TB PCIe Gen4 SSD',
            singlePrice: 1999.0,
            quantity: 1,
          )
        ],
      )
    ];
  }

  /// Adds a newly placed order to the top of history and persists
  void addOrder(Order order) {
    final list = List<Order>.from(orders.value);
    list.insert(0, order);
    orders.value = list;
    _persist();
  }

  /// Creates and records a new order from checkout details
  Order createOrder({
    required List<OrderItemInfo> items,
    required String shippingAddress,
    required double subtotal,
    required double tax,
    required double shippingFee,
    required double finalTotal,
    String customerName = 'Captain User',
    String customerEmail = 'captain@harbour.com',
    String customerPhone = '+1 415-555-0199',
    String paymentMethod = 'Credit Card (Demo Gateway)',
  }) {
    final orderId = 'LHP-${10000 + (DateTime.now().millisecondsSinceEpoch % 90000)}-C';
    final dateStr = DateTime.now().toString().substring(0, 10);

    final order = Order(
      id: orderId,
      date: dateStr,
      items: items,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      subtotal: subtotal,
      tax: tax,
      shippingFee: shippingFee,
      finalTotal: finalTotal,
      status: OrderTrackingStatus.placed,
    );

    addOrder(order);
    return order;
  }

  void _persist() {
    try {
      final jsonList = orders.value.map((o) => o.toJson()).toList();
      StorageService.instance.setJsonList(AppConstants.keyOrders, jsonList);
    } catch (e) {
      debugPrint('[OrderService] Error persisting orders: $e');
    }
  }
}
