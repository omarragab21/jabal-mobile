import 'package:flutter/material.dart';

import '../domain/entities/order_status.dart';

/// Colors of a status chip, taken from the design.
class OrderStatusStyle {
  const OrderStatusStyle({required this.background, required this.foreground});

  final Color background;
  final Color foreground;

  static OrderStatusStyle of(OrderStatus status) => switch (status) {
    OrderStatus.pendingApproval => const OrderStatusStyle(
      background: Color(0xFFEAECF0),
      foreground: Color(0xFF1D2939),
    ),
    OrderStatus.inPreparation => const OrderStatusStyle(
      background: Color(0xFFFFF9E3),
      foreground: Color(0xFFB88814),
    ),
    OrderStatus.onTheWay => const OrderStatusStyle(
      background: Color(0xFFE3EDFF),
      foreground: Color(0xFF1447B8),
    ),
    OrderStatus.delivered => const OrderStatusStyle(
      background: Color(0xFFE3F6E3),
      foreground: Color(0xFF146914),
    ),
    OrderStatus.cancelled => const OrderStatusStyle(
      background: Color(0xFFFFE3E3),
      foreground: Color(0xFFB81515),
    ),
  };
}

/// Translation key suffixes of a status (`orders.status.<key>`).
extension OrderStatusKeys on OrderStatus {
  String get labelKey => switch (this) {
    OrderStatus.pendingApproval => 'orders.status.pending_approval',
    OrderStatus.inPreparation => 'orders.status.in_preparation',
    OrderStatus.onTheWay => 'orders.status.on_the_way',
    OrderStatus.delivered => 'orders.status.delivered',
    OrderStatus.cancelled => 'orders.status.cancelled',
  };
}
