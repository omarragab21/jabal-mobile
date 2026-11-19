import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';

/// Parses the API's order JSON into the domain [Order].
abstract final class OrderModel {
  static Order fromJson(Map<String, dynamic> json) {
    final window = JsonReader.integer(json['cancel_window_seconds'], -1);
    return Order(
      id: JsonReader.string(json['id']),
      number: JsonReader.string(json['number']),
      createdAt: _date(json['created_at']),
      status: _status(json['status']),
      items: [
        for (final item in JsonReader.mapList(json['items'])) _item(item),
      ],
      recipient: _recipient(JsonReader.map(json['recipient'])),
      payment: _payment(JsonReader.map(json['payment'])),
      subtotal: JsonReader.decimal(json['subtotal']),
      deliveryFee: JsonReader.decimal(json['delivery_fee']),
      discount: JsonReader.decimal(json['discount']),
      total: JsonReader.decimal(json['total']),
      timeline: [
        for (final step in JsonReader.mapList(json['timeline'])) _step(step),
      ],
      courier: json['courier'] is Map
          ? _courier(JsonReader.map(json['courier']))
          : null,
      cancelledBy: _cancelledBy(json['cancelled_by']),
      cancelWindow: window >= 0 ? Duration(seconds: window) : null,
    );
  }

  static DateTime _date(Object? value) =>
      DateTime.tryParse(JsonReader.string(value)) ??
      DateTime.fromMillisecondsSinceEpoch(0);

  static OrderStatus _status(Object? value) =>
      switch (JsonReader.string(value)) {
        'pending_approval' => OrderStatus.pendingApproval,
        'in_preparation' => OrderStatus.inPreparation,
        'on_the_way' => OrderStatus.onTheWay,
        'delivered' => OrderStatus.delivered,
        'cancelled' => OrderStatus.cancelled,
        _ => OrderStatus.pendingApproval,
      };

  static CancelledBy? _cancelledBy(Object? value) =>
      switch (JsonReader.string(value)) {
        'customer' => CancelledBy.customer,
        'store' => CancelledBy.store,
        _ => null,
      };

  static OrderItem _item(Map<String, dynamic> json) => OrderItem(
    id: JsonReader.string(json['id']),
    name: JsonReader.string(json['name']),
    quantity: JsonReader.integer(json['quantity'], 1),
    price: JsonReader.decimal(json['price']),
    originalPrice: JsonReader.decimalOrNull(json['original_price']),
    imageUrl: JsonReader.stringOrNull(json['image']),
    note: JsonReader.stringOrNull(json['note']),
  );

  static OrderRecipient _recipient(Map<String, dynamic> json) => OrderRecipient(
    name: JsonReader.string(json['name']),
    address: JsonReader.string(json['address']),
  );

  static OrderPayment _payment(Map<String, dynamic> json) => OrderPayment(
    method: JsonReader.string(json['method']) == 'cash'
        ? PaymentMethod.cash
        : PaymentMethod.card,
    paid: JsonReader.boolean(json['paid']),
    cardBrand: JsonReader.stringOrNull(json['card_brand']),
  );

  static OrderCourier _courier(Map<String, dynamic> json) => OrderCourier(
    name: JsonReader.string(json['name']),
    phone: JsonReader.string(json['phone']),
    etaMinutes: json['eta_minutes'] == null
        ? null
        : JsonReader.integer(json['eta_minutes']),
    eta: DateTime.tryParse(JsonReader.string(json['eta'])),
    handoverCode: JsonReader.stringOrNull(json['handover_code']),
  );

  static OrderTimelineStep _step(Map<String, dynamic> json) =>
      OrderTimelineStep(
        kind: switch (JsonReader.string(json['kind'])) {
          'received' => TimelineStepKind.received,
          'awaiting_store' => TimelineStepKind.awaitingStore,
          'accepted' => TimelineStepKind.accepted,
          'preparing' => TimelineStepKind.preparing,
          'handed_to_courier' => TimelineStepKind.handedToCourier,
          'delivered' => TimelineStepKind.delivered,
          'cancelled' => TimelineStepKind.cancelled,
          _ => TimelineStepKind.received,
        },
        state: switch (JsonReader.string(json['state'])) {
          'done' => TimelineStepState.done,
          'current' => TimelineStepState.current,
          _ => TimelineStepState.upcoming,
        },
        time: _date(json['at']),
      );
}
