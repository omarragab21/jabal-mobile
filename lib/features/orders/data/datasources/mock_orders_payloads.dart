// Demo data in the shape the orders API is expected to return. Replace the
// mock data source with a real one and none of this is used.
//
// The products are the pharmacy catalogue's own demo products (same names,
// prices and pictures as the home page), so an order looks like something
// bought from this store.

import '../../../home/data/datasources/mock_home_payloads.dart';

Map<String, dynamic> _step(String kind, String state, String at) => {
  'kind': kind,
  'state': state,
  'at': at,
};

final Map<int, Map<String, dynamic>> _catalogue = {
  for (final product in mockProducts('ar')) product['id'] as int: product,
};

/// An order line for catalogue product [productId]: name, picture and prices
/// come from the catalogue, so they match what the customer saw in the shop.
Map<String, dynamic> _line(int productId, int quantity, {String? note}) {
  final product = _catalogue[productId]!;
  final price = (product['price'] as num).toDouble();
  final paid = (product['final_price'] as num).toDouble();
  final images = product['images'] as List;
  return {
    'id': '$productId',
    'name': product['name'],
    'quantity': quantity,
    'price': paid,
    if (paid < price) 'original_price': price,
    'image': (images.first as Map)['thumb_url'],
    'note': ?note,
  };
}

const _recipient = {
  'name': 'سارة أحمد',
  'address': 'عمّان، الدوار السابع، شارع الأميرة بسمة، عمارة 12، الطابق 3',
};

const _courier = {
  'name': 'محمد العلي',
  'phone': '962791234567',
  'handover_code': '1986',
};

const _cardPaid = {'method': 'card', 'paid': true, 'card_brand': 'visa'};

const double _deliveryFee = 2;

/// An order whose amounts add up from its [lines]: subtotal at list prices,
/// the discount as the savings, plus the delivery fee.
Map<String, dynamic> _order({
  required String id,
  required String createdAt,
  required String status,
  required List<Map<String, dynamic>> lines,
  required List<Map<String, dynamic>> timeline,
  Map<String, dynamic> payment = _cardPaid,
  Map<String, dynamic>? courier,
  String? cancelledBy,
  int? cancelWindowSeconds,
}) {
  var subtotal = 0.0;
  var discount = 0.0;
  for (final line in lines) {
    final quantity = line['quantity'] as int;
    final paid = (line['price'] as num).toDouble();
    final list = ((line['original_price'] ?? paid) as num).toDouble();
    subtotal += list * quantity;
    discount += (list - paid) * quantity;
  }
  return {
    'id': id,
    'number': 'ORD-2026-${id.padLeft(3, '0')}',
    'created_at': createdAt,
    'status': status,
    'items': lines,
    'recipient': _recipient,
    'payment': payment,
    'subtotal': subtotal,
    'delivery_fee': _deliveryFee,
    'discount': discount,
    'total': subtotal - discount + _deliveryFee,
    'timeline': timeline,
    'courier': ?courier,
    'cancelled_by': ?cancelledBy,
    'cancel_window_seconds': ?cancelWindowSeconds,
  };
}

final List<Map<String, dynamic>> mockOrders = [
  // Pending approval: can still be cancelled for a short while.
  _order(
    id: '1',
    createdAt: '2025-12-31T16:00:00',
    status: 'pending_approval',
    cancelWindowSeconds: 45,
    lines: [
      _line(104, 2), // Vitamin C
      _line(105, 1, note: 'يرجى التأكد من تاريخ الصلاحية'),
      _line(109, 1), // Sunscreen
    ],
    timeline: [
      _step('received', 'done', '2025-12-31T16:00:00'),
      _step('awaiting_store', 'current', '2025-12-31T16:15:00'),
      _step('accepted', 'upcoming', '2025-12-31T17:00:00'),
      _step('preparing', 'upcoming', '2025-12-31T18:30:00'),
      _step('handed_to_courier', 'upcoming', '2025-12-31T19:00:00'),
      _step('delivered', 'upcoming', '2025-12-31T19:30:00'),
    ],
  ),
  // In preparation, no courier yet.
  _order(
    id: '2',
    createdAt: '2025-12-31T15:00:00',
    status: 'in_preparation',
    lines: [
      _line(204, 1), // Blood pressure monitor
      _line(206, 1), // Thermometer
    ],
    timeline: [
      _step('received', 'done', '2025-12-31T15:00:00'),
      _step('awaiting_store', 'done', '2025-12-31T15:15:00'),
      _step('accepted', 'done', '2025-12-31T15:30:00'),
      _step('preparing', 'current', '2025-12-31T16:30:00'),
      _step('handed_to_courier', 'upcoming', '2025-12-31T17:30:00'),
      _step('delivered', 'upcoming', '2025-12-31T18:00:00'),
    ],
  ),
  // In preparation, courier assigned.
  _order(
    id: '3',
    createdAt: '2025-12-30T12:00:00',
    status: 'in_preparation',
    payment: {'method': 'cash', 'paid': false},
    courier: {..._courier, 'eta_minutes': 35, 'eta': '2025-12-31T19:30:00'},
    lines: [
      _line(110, 2), // Nappy cream
      _line(111, 1), // Baby shampoo
      _line(209, 3), // Bandages
    ],
    timeline: [
      _step('received', 'done', '2025-12-30T12:00:00'),
      _step('awaiting_store', 'done', '2025-12-30T12:15:00'),
      _step('accepted', 'done', '2025-12-30T12:30:00'),
      _step('preparing', 'current', '2025-12-30T13:30:00'),
      _step('handed_to_courier', 'upcoming', '2025-12-30T14:30:00'),
      _step('delivered', 'upcoming', '2025-12-30T15:00:00'),
    ],
  ),
  // On the way.
  _order(
    id: '4',
    createdAt: '2025-12-29T10:30:00',
    status: 'on_the_way',
    courier: {..._courier, 'eta_minutes': 12, 'eta': '2025-12-31T19:12:00'},
    lines: [
      _line(116, 1), // Anti-colic bottle
      _line(117, 2), // Bottle teats
      _line(118, 1), // Baby thermometer
    ],
    timeline: [
      _step('received', 'done', '2025-12-29T10:30:00'),
      _step('awaiting_store', 'done', '2025-12-29T10:45:00'),
      _step('accepted', 'done', '2025-12-29T11:00:00'),
      _step('preparing', 'done', '2025-12-29T12:00:00'),
      _step('handed_to_courier', 'current', '2025-12-29T13:00:00'),
      _step('delivered', 'upcoming', '2025-12-29T13:30:00'),
    ],
  ),
  // Delivered.
  _order(
    id: '5',
    createdAt: '2026-09-23T10:30:00',
    status: 'delivered',
    courier: _courier,
    lines: [
      _line(106, 1), // Omega-3
      _line(120, 1), // Multivitamin
      _line(201, 2), // Paracetamol
    ],
    timeline: [
      _step('received', 'done', '2026-09-23T10:30:00'),
      _step('awaiting_store', 'done', '2026-09-23T10:45:00'),
      _step('accepted', 'done', '2026-09-23T11:00:00'),
      _step('preparing', 'done', '2026-09-23T12:00:00'),
      _step('handed_to_courier', 'done', '2026-09-23T13:00:00'),
      _step('delivered', 'current', '2026-09-23T13:30:00'),
    ],
  ),
  // Cancelled by the customer.
  _order(
    id: '6',
    createdAt: '2026-09-20T09:00:00',
    status: 'cancelled',
    cancelledBy: 'customer',
    lines: [
      _line(107, 1), // Face wash
      _line(108, 1), // Moisturiser
    ],
    timeline: [
      _step('received', 'done', '2026-09-20T09:00:00'),
      _step('awaiting_store', 'done', '2026-09-20T09:15:00'),
      _step('cancelled', 'current', '2026-09-20T09:20:00'),
    ],
  ),
  // Cancelled by the store.
  _order(
    id: '7',
    createdAt: '2026-09-18T18:10:00',
    status: 'cancelled',
    cancelledBy: 'store',
    payment: {'method': 'card', 'paid': true, 'card_brand': 'mastercard'},
    lines: [
      _line(208, 2), // Adult diapers
      _line(207, 1), // Walking cane
    ],
    timeline: [
      _step('received', 'done', '2026-09-18T18:10:00'),
      _step('awaiting_store', 'done', '2026-09-18T18:25:00'),
      _step('cancelled', 'current', '2026-09-18T18:40:00'),
    ],
  ),
];

/// The tax invoice of any order (the amounts are the same demo ones).
const Map<String, dynamic> mockTaxInvoice = {
  'merchant_name': 'Hussein Zarour',
  'merchant_address':
      'Building 32 Floor 1 الأول Judda Phone 796520924 (Area Tabarbour / طبربور) شارع سهيل بن عمرو Street',
  'currency': 'JOD',
  'lines': [
    {'label': 'Delivery Fee / رسوم خدمة التوصيل', 'amount': 0.862},
    {'label': 'Service Fee / رسوم الخدمة', 'amount': 0.440},
    {'label': 'Sales Tax / ضريبة المبيعات', 'amount': 0.208, 'rate': '16%'},
  ],
  'total': 1.510,
  'registered_address':
      'Qatari Jordanian Investment & Real estate Development Co. Abdullah Ghousheh St. B#44 Al Rawabi 155 Amman 11732 Jordan',
  'company_details': [
    'Paid up capital: 283200 JOD',
    'Trade Registration Number: 1019',
  ],
  'sales_tax_number': '16672771',
  'issue_date': '2025-07-19T03:22:00',
  'invoice_number': 'JTGO82053093',
  'order_number': '3048608812',
};
