// Demo data in the shape the product API is expected to return. The products
// are the home page's own demo catalogue, so a product opens with the same
// name, price and picture the customer tapped.

import '../../../../core/error/exceptions.dart';
import '../../../home/data/datasources/mock_home_payloads.dart';

const Map<int, ({String ar, String en})> _descriptions = {
  104: (
    ar: 'فيتامين سي 1000 ملغ - 30 قرص. يحتوي على فيتامين سي لتعزيز المناعة. يُفضل تناوله مع الطعام لتحسين الامتصاص، ويُستخدم وفقًا لتوجيهات الطبيب أو الصيدلي.',
    en: 'Vitamin C 1000 mg - 30 tablets. Contains vitamin C to support immunity. Best taken with food for better absorption, and used as directed by your doctor or pharmacist.',
  ),
  105: (
    ar: 'فيتامين د3 لدعم صحة العظام والمناعة. يُؤخذ كبسولة واحدة يوميًا مع وجبة تحتوي على دهون.',
    en: 'Vitamin D3 to support bone health and immunity. Take one capsule daily with a meal that contains fat.',
  ),
  201: (
    ar: 'باراسيتامول لتسكين الألم وخفض الحرارة. لا تتجاوز الجرعة الموصى بها واستشر الصيدلي عند الحاجة.',
    en: 'Paracetamol for pain relief and fever. Do not exceed the recommended dose and ask your pharmacist when in doubt.',
  ),
};

/// `GET /v1/site/products/{id}`: the catalogue product plus its pictures,
/// description and live viewers. Throws [NotFoundException] for an unknown id.
Map<String, dynamic> mockProductPayload(int id, String languageCode) {
  final catalogue = mockProducts(languageCode);
  final product = catalogue.firstWhere(
    (p) => p['id'] == id,
    orElse: () => throw const NotFoundException(),
  );

  String firstImage(Map<String, dynamic> p) =>
      ((p['images'] as List).first as Map)['image_url'] as String;

  // The catalogue has one picture per product; the page shows a few, so the
  // gallery borrows pictures of other products until the API has real ones.
  final own = firstImage(product);
  final images = <String>{own};
  for (final other in catalogue) {
    if (images.length == 3) break;
    images.add(firstImage(other));
  }

  final name = product['name'] as String;
  final nameTranslations = product['translations'] as Map<String, dynamic>;
  String describe(String lang, String fallbackName) {
    final custom = _descriptions[id];
    if (custom != null) return lang == 'ar' ? custom.ar : custom.en;
    return lang == 'ar'
        ? '$fallbackName. يُستخدم وفقًا لتوجيهات الطبيب أو الصيدلي.'
        : '$fallbackName. Use as directed by your doctor or pharmacist.';
  }

  return {
    ...product,
    'images': [
      for (final url in images) {'image_url': url},
    ],
    'description': describe(languageCode, name),
    'translations': {
      for (final lang in const ['ar', 'en'])
        lang: {
          ...((nameTranslations[lang] as Map<String, dynamic>?) ?? const {}),
          'description': describe(
            lang,
            ((nameTranslations[lang] as Map?)?['name'] as String?) ?? name,
          ),
        },
    },
    'viewers_now': 40 + (id * 37) % 260,
  };
}
