// Demo payloads in the exact shape of the website's `/v1/site` API, so the
// mock data source runs them through the same models as the real backend.
// Category ids, image URLs and the news bar texts are the live ones.

const String _storage = 'https://backend-jabal.be-kite.com/public/storage';

/// `GET /v1/site/settings` -> `data.news_bar_items`
const List<Map<String, dynamic>> mockNewsBarItems = [
  {
    'id': 'news-1',
    'text_ar': 'صيدليات الجبل.. النصيحة بجبل، صحتكم أولويتنا دائماً.',
    'text_en':
        'Al-Jabal Pharmacies: advice you can lean on, your health always comes first.',
    'is_active': true,
  },
  {
    'id': 'news-2',
    'text_ar': 'اكتشفوا مجموعة واسعة من منتجات العناية بالبشرة والشعر.',
    'text_en': 'Discover a wide range of skin and hair care products.',
    'is_active': true,
  },
  {
    'id': 'news-3',
    'text_ar': 'توصيل سريع لجميع المحافظات خلال ساعات من تأكيد طلبكم.',
    'text_en':
        'Fast delivery to all governorates within hours of confirming your order.',
    'is_active': true,
  },
  {
    'id': 'news-4',
    'text_ar': 'جميع منتجاتنا أصلية ومرخصة من الجهات الصحية المختصة.',
    'text_en':
        'All our products are genuine and licensed by the relevant health authorities.',
    'is_active': true,
  },
  {
    'id': 'news-5',
    'text_ar': 'عروض أسبوعية على مستحضرات العناية بالأم والطفل.',
    'text_en': 'Weekly offers on mother and baby care products.',
    'is_active': true,
  },
  {
    'id': 'news-6',
    'text_ar': 'خبر متوقف لا يظهر في الشريط.',
    'text_en': 'A switched-off item that never shows.',
    'is_active': false,
  },
];

/// `GET /v1/site/settings` -> `data` (only the support contact). The value is
/// the store's live `whatsapp` setting.
const Map<String, dynamic> mockSettings = {
  'whatsapp': 'https://wa.me/966500000000',
};

/// `GET /v1/site/sliders` -> `data`
const List<Map<String, dynamic>> mockSliders = [
  {
    'id': 1,
    'link': null,
    'order': 1,
    'status': true,
    'title': 'صيدليتك الرقمية المتكاملة',
    'description': 'منتجات صحية أصلية، توصيل سريع، وأسعار تنافسية',
    'translations': {
      'en': {
        'title': 'Your comprehensive digital pharmacy',
        'description':
            'Authentic health products, fast delivery, and competitive prices',
      },
      'ar': {
        'title': 'صيدليتك الرقمية المتكاملة',
        'description': 'منتجات صحية أصلية، توصيل سريع، وأسعار تنافسية',
      },
    },
    'image':
        '$_storage/sliders/slider_3b8cb414-18db-452e-8fc3-b0085befb7f2_1793801245.png',
  },
  {
    'id': 2,
    'link': null,
    'order': 2,
    'status': true,
    'title': 'لماذا نحن الخيار الأول؟',
    'description': 'أفضل المنتجات الصحية بأعلى معايير الجودة والموثوقية',
    'translations': {
      'en': {
        'title': 'Why are we the number one choice?',
        'description':
            'The finest health products that meet the highest standards',
      },
      'ar': {
        'title': 'لماذا نحن الخيار الأول؟',
        'description': 'أفضل المنتجات الصحية بأعلى معايير الجودة والموثوقية',
      },
    },
    'image':
        '$_storage/sliders/slider_ab990ba2-3fe0-4a04-97da-ba57108cbdb3_1793803064.png',
  },
];

/// Pictures of the eight sections, bundled with the app (from the design).
abstract final class MockSectionImages {
  static const String vitamins = 'assets/images/sections/vitamins.jpg';
  static const String medicines = 'assets/images/sections/medicines.jpg';
  static const String hair = 'assets/images/sections/hair.jpg';
  static const String skin = 'assets/images/sections/skin.jpg';
  static const String devices = 'assets/images/sections/devices.jpg';
  static const String motherBaby = 'assets/images/sections/mother_baby.jpg';
  static const String elderly = 'assets/images/sections/elderly.jpg';
  static const String firstAid = 'assets/images/sections/first_aid.jpg';
}

Map<String, dynamic> _category(
  int id,
  String ar,
  String en,
  String image, {
  int sortOrder = 0,
  int? parentId,
  List<Map<String, dynamic>> subs = const [],
}) => {
  'id': id,
  'parent_id': parentId,
  'sort_order': sortOrder,
  'name': ar,
  'translations': {
    'ar': {'name': ar},
    'en': {'name': en},
  },
  'image_url': image,
  'is_active': true,
  'sub_categories_count': subs.length,
  'sub_categories': subs,
};

/// A root section and its sub-sections (ids `<root><n>`), each sub-section
/// wearing the picture of its section.
Map<String, dynamic> _section(
  int id,
  String ar,
  String en,
  String image,
  List<(String, String)> subs,
) => _category(
  id,
  ar,
  en,
  image,
  subs: [
    for (var i = 0; i < subs.length; i++)
      _category(
        id * 10 + i + 1,
        subs[i].$1,
        subs[i].$2,
        image,
        parentId: id,
        sortOrder: i + 1,
      ),
  ],
);

/// `GET /v1/site/categories` -> `data`, in the order the design shows them.
final List<Map<String, dynamic>> mockCategories = [
  _section(
    64,
    'الفيتامينات والمكملات',
    'Vitamins & supplements',
    MockSectionImages.vitamins,
    [
      ('أوميغا 3', 'Omega-3'),
      ('فيتامين سي', 'Vitamin C'),
      ('فيتامينات ومناعة', 'Vitamins & immunity'),
      ('معادن ومكملات', 'Minerals'),
    ],
  ),
  _section(69, 'الأدوية العلاجية', 'Medicines', MockSectionImages.medicines, [
    ('مسكنات وخافضات حرارة', 'Pain & fever'),
    ('البرد والسعال', 'Cold & cough'),
    ('المعدة والهضم', 'Stomach & digestion'),
  ]),
  _section(63, 'العناية بالشعر', 'Hair care', MockSectionImages.hair, [
    ('شامبو وبلسم', 'Shampoo & conditioner'),
    ('زيوت وعلاجات', 'Oils & treatments'),
  ]),
  _section(12, 'العناية بالبشرة', 'Skin care', MockSectionImages.skin, [
    ('غسول الوجه', 'Face wash'),
    ('المرطبات', 'Moisturisers'),
    ('واقيات الشمس', 'Sunscreen'),
  ]),
  _section(
    70,
    'الأجهزة والمستلزمات',
    'Devices & supplies',
    MockSectionImages.devices,
    [('أجهزة القياس', 'Measuring devices'), ('موازين الحرارة', 'Thermometers')],
  ),
  _section(66, 'الأم والطفل', 'Mother & baby', MockSectionImages.motherBaby, [
    ('العناية بالطفل', 'Baby care'),
    ('مستلزمات الرضاعة', 'Feeding supplies'),
    ('صحة الطفل', 'Baby health'),
  ]),
  _section(71, 'رعاية كبار السن', 'Elderly care', MockSectionImages.elderly, [
    ('مستلزمات الحركة', 'Mobility aids'),
    ('العناية اليومية', 'Daily care'),
  ]),
  _section(72, 'الإسعافات الأولية', 'First aid', MockSectionImages.firstAid, [
    ('ضمادات وشاش', 'Bandages & gauze'),
    ('مطهرات', 'Antiseptics'),
  ]),
];

const _images = [
  '270ef5f4-5334-4eeb-bd44-fae607b6efa3.jpg',
  '85d893eb-d82d-4659-ad8e-2a1ab668d10d.png',
  '8de55c42-af0a-4c41-99aa-fe70f1e6c4cf.png',
  '78fd870f-49e6-44f9-a832-b4116f9a3af6.png',
  'b4e3cb27-0dba-48ef-8842-5f3e0024ca7a.png',
  '5c582858-e1e2-4946-aab8-a0e2c832ff56.png',
];

Map<String, dynamic> _findCategory(int id) {
  for (final root in mockCategories) {
    if (root['id'] == id) return root;
    for (final child in root['sub_categories'] as List) {
      if ((child as Map<String, dynamic>)['id'] == id) return child;
    }
  }
  throw StateError('Unknown mock category $id');
}

/// `GET /v1/site/products/all_products` -> `data`, in [languageCode] (the
/// API localizes attribute names by the request language).
List<Map<String, dynamic>> mockProducts(String languageCode) {
  final ar = languageCode == 'ar';
  Map<String, dynamic> product(
    int id,
    int categoryId,
    String nameAr,
    String nameEn,
    num price, {
    num? discountPrice,
    required String sizeAr,
    required String sizeEn,
    int stock = 100,
    bool featured = false,
  }) {
    final category = _findCategory(categoryId);
    return {
      'id': id,
      'category_id': categoryId,
      'price': price,
      'discount_price': discountPrice,
      'final_price': discountPrice ?? price,
      'has_discount': discountPrice != null,
      'number': stock,
      'is_active': true,
      'is_featured': featured,
      'attributes': {
        (ar ? 'الحجم' : 'Size'): [
          {'id': id * 10, 'name': ar ? sizeAr : sizeEn, 'value_code': null},
        ],
      },
      'name': ar ? nameAr : nameEn,
      'translations': {
        'ar': {'name': nameAr},
        'en': {'name': nameEn},
      },
      'images': [
        {
          'id': id,
          'image_url': '$_storage/products/${_images[id % _images.length]}',
          'thumb_url': '$_storage/products/${_images[id % _images.length]}',
        },
      ],
      'category': category,
    };
  }

  return [
    // Vitamins & supplements (64): 641 omega-3, 642 vitamin C, 643 immunity, 644 minerals
    product(
      104,
      642,
      'فيتامين سي 1000 مجم أقراص فوارة بنكهة البرتقال',
      'Vitamin C 1000 mg effervescent tablets, orange flavour',
      6.50,
      sizeAr: '20 قرصًا',
      sizeEn: '20 tablets',
      featured: true,
    ),
    product(
      105,
      643,
      'فيتامين د3 5000 وحدة',
      'Vitamin D3 5000 IU',
      9.75,
      discountPrice: 8.25,
      sizeAr: '60 كبسولة',
      sizeEn: '60 capsules',
    ),
    product(
      106,
      641,
      'أوميغا 3 زيت السمك',
      'Omega-3 fish oil',
      14.00,
      discountPrice: 11.25,
      sizeAr: '90 كبسولة',
      sizeEn: '90 softgels',
    ),
    product(
      119,
      644,
      'مغنيسيوم 400 مجم',
      'Magnesium 400 mg',
      11.50,
      sizeAr: '60 قرصًا',
      sizeEn: '60 tablets',
    ),
    product(
      120,
      643,
      'مكمل متعدد الفيتامينات',
      'Multivitamin complex',
      13.25,
      discountPrice: 10.60,
      sizeAr: '30 كبسولة',
      sizeEn: '30 capsules',
    ),
    // Medicines (69): 691 pain & fever, 692 cold & cough, 693 stomach
    product(
      201,
      691,
      'باراسيتامول 500 مجم',
      'Paracetamol 500 mg',
      2.20,
      sizeAr: '24 قرصًا',
      sizeEn: '24 tablets',
    ),
    product(
      202,
      691,
      'إيبوبروفين 400 مجم',
      'Ibuprofen 400 mg',
      3.10,
      discountPrice: 2.60,
      sizeAr: '20 قرصًا',
      sizeEn: '20 tablets',
    ),
    product(
      101,
      692,
      'بخاخ محلول ملحي',
      'Saline nasal spray',
      5.00,
      discountPrice: 4.25,
      sizeAr: '30 مل',
      sizeEn: '30 ml',
      featured: true,
    ),
    product(
      102,
      692,
      'قطرة أنف مرطبة للأطفال',
      'Moisturising nasal drops for kids',
      3.50,
      sizeAr: '15 مل',
      sizeEn: '15 ml',
    ),
    product(
      103,
      692,
      'بخاخ ماء البحر للأنف',
      'Sea water nasal spray',
      7.90,
      discountPrice: 6.50,
      sizeAr: '100 مل',
      sizeEn: '100 ml',
    ),
    product(
      203,
      693,
      'مضاد للحموضة أقراص مضغ',
      'Antacid chewable tablets',
      4.40,
      sizeAr: '36 قرصًا',
      sizeEn: '36 tablets',
    ),
    // Hair care (63): 631 shampoo, 632 oils
    product(
      112,
      631,
      'شامبو ضد القشرة',
      'Anti-dandruff shampoo',
      8.40,
      sizeAr: '250 مل',
      sizeEn: '250 ml',
    ),
    product(
      113,
      632,
      'زيت الأرغان للشعر',
      'Argan hair oil',
      10.00,
      discountPrice: 7.50,
      sizeAr: '100 مل',
      sizeEn: '100 ml',
    ),
    // Skin care (12): 121 face wash, 122 moisturisers, 123 sunscreen
    product(
      107,
      121,
      'غسول منقٍّ للبشرة الدهنية',
      'Purifying face wash for oily skin',
      11.00,
      discountPrice: 8.80,
      sizeAr: '200 مل',
      sizeEn: '200 ml',
    ),
    product(
      108,
      122,
      'مرطب يومي للبشرة',
      'Daily skin moisturiser',
      12.50,
      sizeAr: '50 مل',
      sizeEn: '50 ml',
    ),
    product(
      109,
      123,
      'واقي شمس SPF 50',
      'Sunscreen SPF 50',
      16.00,
      discountPrice: 13.60,
      sizeAr: '50 مل',
      sizeEn: '50 ml',
      featured: true,
    ),
    // Devices & supplies (70): 701 measuring, 702 thermometers
    product(
      204,
      701,
      'جهاز قياس ضغط الدم',
      'Blood pressure monitor',
      29.00,
      discountPrice: 24.50,
      sizeAr: 'قطعة واحدة',
      sizeEn: '1 piece',
    ),
    product(
      205,
      701,
      'جهاز قياس الأكسجين',
      'Pulse oximeter',
      18.00,
      sizeAr: 'قطعة واحدة',
      sizeEn: '1 piece',
    ),
    product(
      206,
      702,
      'ميزان حرارة رقمي',
      'Digital thermometer',
      6.00,
      sizeAr: 'قطعة واحدة',
      sizeEn: '1 piece',
    ),
    // Mother & baby (66): 661 baby care, 662 feeding, 663 baby health
    product(
      110,
      661,
      'كريم الحفاض للأطفال',
      'Baby nappy cream',
      4.75,
      sizeAr: '100 غ',
      sizeEn: '100 g',
    ),
    product(
      111,
      661,
      'شامبو أطفال بدون دموع',
      'Tear-free baby shampoo',
      5.90,
      discountPrice: 4.90,
      sizeAr: '300 مل',
      sizeEn: '300 ml',
    ),
    product(
      116,
      662,
      'رضّاعة مضادة للمغص',
      'Anti-colic baby bottle',
      12.00,
      discountPrice: 9.75,
      sizeAr: '240 مل',
      sizeEn: '240 ml',
    ),
    product(
      117,
      662,
      'سدّادة رضاعة سيليكون',
      'Silicone bottle teat',
      3.20,
      sizeAr: 'قطعتان',
      sizeEn: '2 pieces',
    ),
    product(
      118,
      663,
      'ميزان حرارة رقمي للأطفال',
      'Digital baby thermometer',
      14.00,
      discountPrice: 11.90,
      sizeAr: 'قطعة واحدة',
      sizeEn: '1 piece',
    ),
    // Elderly care (71): 711 mobility, 712 daily care
    product(
      207,
      711,
      'عكاز طبي قابل للتعديل',
      'Adjustable walking cane',
      15.00,
      sizeAr: 'قطعة واحدة',
      sizeEn: '1 piece',
    ),
    product(
      208,
      712,
      'حفاضات للبالغين',
      'Adult diapers',
      13.50,
      discountPrice: 11.50,
      sizeAr: '30 حفاضة',
      sizeEn: '30 pieces',
    ),
    // First aid (72): 721 bandages, 722 antiseptics
    product(
      209,
      721,
      'ضمادات لاصقة',
      'Adhesive bandages',
      2.50,
      sizeAr: '40 قطعة',
      sizeEn: '40 pieces',
    ),
    product(
      210,
      721,
      'حقيبة إسعافات أولية',
      'First aid kit',
      19.00,
      discountPrice: 16.00,
      sizeAr: 'قطعة واحدة',
      sizeEn: '1 kit',
    ),
    product(
      211,
      722,
      'محلول مطهر للجروح',
      'Wound antiseptic solution',
      3.80,
      sizeAr: '100 مل',
      sizeEn: '100 ml',
    ),
  ];
}
