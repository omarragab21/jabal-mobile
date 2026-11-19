import 'package:equatable/equatable.dart';

import 'order_status.dart';

/// One product line of an order.
class OrderItem extends Equatable {
  const OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.originalPrice,
    this.imageUrl,
    this.note,
  });

  final String id;
  final String name;
  final int quantity;

  /// Unit price paid.
  final double price;

  /// Unit price before a discount; shown struck through when it is higher.
  final double? originalPrice;
  final String? imageUrl;

  /// What the customer wrote for this product (a gift note).
  final String? note;

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  @override
  List<Object?> get props => [
    id,
    name,
    quantity,
    price,
    originalPrice,
    imageUrl,
    note,
  ];
}

/// Who receives the order and where.
class OrderRecipient extends Equatable {
  const OrderRecipient({required this.name, required this.address});

  final String name;
  final String address;

  @override
  List<Object?> get props => [name, address];
}

enum PaymentMethod { card, cash }

class OrderPayment extends Equatable {
  const OrderPayment({
    required this.method,
    required this.paid,
    this.cardBrand,
  });

  final PaymentMethod method;
  final bool paid;

  /// `visa`, `mastercard`... only for card payments.
  final String? cardBrand;

  @override
  List<Object?> get props => [method, paid, cardBrand];
}

/// The delivery person assigned to an order.
class OrderCourier extends Equatable {
  const OrderCourier({
    required this.name,
    required this.phone,
    this.etaMinutes,
    this.eta,
    this.handoverCode,
  });

  final String name;

  /// International format, digits only, no `+` (`962791234567`).
  final String phone;

  /// Minutes until arrival, when the courier is on the way.
  final int? etaMinutes;
  final DateTime? eta;

  /// The code the customer shares with the courier on receiving the gift.
  final String? handoverCode;

  @override
  List<Object?> get props => [name, phone, etaMinutes, eta, handoverCode];
}

/// A step of the order's journey.
enum TimelineStepKind {
  received,
  awaitingStore,
  accepted,
  preparing,
  handedToCourier,
  delivered,
  cancelled,
}

/// Where a step is: already passed, the one the order is at now, or ahead.
enum TimelineStepState { done, current, upcoming }

class OrderTimelineStep extends Equatable {
  const OrderTimelineStep({
    required this.kind,
    required this.state,
    required this.time,
  });

  final TimelineStepKind kind;
  final TimelineStepState state;

  /// When the step happened, or is expected to.
  final DateTime time;

  @override
  List<Object?> get props => [kind, state, time];
}

/// An order as "my orders" and the details page show it.
class Order extends Equatable {
  const Order({
    required this.id,
    required this.number,
    required this.createdAt,
    required this.status,
    required this.items,
    required this.recipient,
    required this.payment,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.timeline,
    this.courier,
    this.cancelledBy,
    this.cancelWindow,
  });

  final String id;

  /// What the customer sees, `ORD-2026-001`.
  final String number;
  final DateTime createdAt;
  final OrderStatus status;
  final List<OrderItem> items;
  final OrderRecipient recipient;
  final OrderPayment payment;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final List<OrderTimelineStep> timeline;
  final OrderCourier? courier;
  final CancelledBy? cancelledBy;

  /// Time left to cancel with a refund, when cancelling is still possible.
  final Duration? cancelWindow;

  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get canCancel => status.isCancellable;

  /// An order past approval waits for a courier until one is assigned.
  bool get isSearchingCourier =>
      status == OrderStatus.inPreparation && courier == null;

  Order copyWith({
    OrderStatus? status,
    CancelledBy? cancelledBy,
    List<OrderTimelineStep>? timeline,
    Duration? cancelWindow,
    bool clearCancelWindow = false,
  }) => Order(
    id: id,
    number: number,
    createdAt: createdAt,
    status: status ?? this.status,
    items: items,
    recipient: recipient,
    payment: payment,
    subtotal: subtotal,
    deliveryFee: deliveryFee,
    discount: discount,
    total: total,
    timeline: timeline ?? this.timeline,
    courier: courier,
    cancelledBy: cancelledBy ?? this.cancelledBy,
    cancelWindow: clearCancelWindow ? null : cancelWindow ?? this.cancelWindow,
  );

  @override
  List<Object?> get props => [
    id,
    number,
    createdAt,
    status,
    items,
    recipient,
    payment,
    subtotal,
    deliveryFee,
    discount,
    total,
    timeline,
    courier,
    cancelledBy,
    cancelWindow,
  ];
}
