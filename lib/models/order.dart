import 'package:flutter/material.dart';
import '../services/order_service.dart';

enum OrderTrackingStatus {
  placed,
  processing,
  inTransit,
  delivered,
}

class OrderItemInfo {
  final String laptopName;
  final String brand;
  final String imageUrl;
  final String cpu;
  final String gpu;
  final String ram;
  final String storage;
  final double singlePrice;
  final int quantity;

  OrderItemInfo({
    required this.laptopName,
    required this.brand,
    required this.imageUrl,
    required this.cpu,
    required this.gpu,
    required this.ram,
    required this.storage,
    required this.singlePrice,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'laptopName': laptopName,
      'brand': brand,
      'imageUrl': imageUrl,
      'cpu': cpu,
      'gpu': gpu,
      'ram': ram,
      'storage': storage,
      'singlePrice': singlePrice,
      'quantity': quantity,
    };
  }

  factory OrderItemInfo.fromJson(Map<String, dynamic> json) {
    return OrderItemInfo(
      laptopName: json['laptopName'] as String? ?? 'Fleet Rig',
      brand: json['brand'] as String? ?? 'Harbour',
      imageUrl: json['imageUrl'] as String? ?? '',
      cpu: json['cpu'] as String? ?? '',
      gpu: json['gpu'] as String? ?? '',
      ram: json['ram'] as String? ?? '',
      storage: json['storage'] as String? ?? '',
      singlePrice: (json['singlePrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

class Order {
  final String id;
  final String date;
  final List<OrderItemInfo> items;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String shippingAddress;
  final String paymentMethod;
  final double subtotal;
  final double tax;
  final double shippingFee;
  final double finalTotal;
  OrderTrackingStatus status;

  Order({
    required this.id,
    required this.date,
    required this.items,
    this.customerName = 'Captain User',
    this.customerEmail = 'captain@harbour.com',
    this.customerPhone = '+1 415-555-0199',
    required this.shippingAddress,
    this.paymentMethod = 'Credit Card (Demo Gateway)',
    required this.subtotal,
    required this.tax,
    required this.shippingFee,
    required this.finalTotal,
    this.status = OrderTrackingStatus.placed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'items': items.map((i) => i.toJson()).toList(),
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'tax': tax,
      'shippingFee': shippingFee,
      'finalTotal': finalTotal,
      'status': status.name,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'placed';
    final status = OrderTrackingStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => OrderTrackingStatus.placed,
    );

    final rawItems = json['items'] as List? ?? [];
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map((i) => OrderItemInfo.fromJson(i))
        .toList();

    return Order(
      id: json['id'] as String? ?? 'LHP-00000-C',
      date: json['date'] as String? ?? '2026-07-10',
      items: items,
      customerName: json['customerName'] as String? ?? 'Captain User',
      customerEmail: json['customerEmail'] as String? ?? 'captain@harbour.com',
      customerPhone: json['customerPhone'] as String? ?? '+1 415-555-0199',
      shippingAddress: json['shippingAddress'] as String? ?? 'Sector-X Cyber Harbour',
      paymentMethod: json['paymentMethod'] as String? ?? 'Credit Card (Demo Gateway)',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      finalTotal: (json['finalTotal'] as num?)?.toDouble() ?? 0.0,
      status: status,
    );
  }
}

/// Backward-compatible bridge delegating to [OrderService].
class OrderHistoryManager {
  static ValueNotifier<List<Order>> get orders => OrderService.instance.orders;

  static void addOrder(Order order) {
    OrderService.instance.addOrder(order);
  }
}
