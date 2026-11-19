import '../../domain/entities/legal_document.dart';

/// Where the legal texts come from.
abstract interface class LegalDataSource {
  Future<LegalDocument> fetch(LegalDocumentType type, String languageCode);
}

/// Texts bundled with the app. TEMPORARY: written as a starting point for a
/// pharmacy store in Jordan and must be reviewed by a lawyer before launch.
class StaticLegalDataSource implements LegalDataSource {
  const StaticLegalDataSource();

  @override
  Future<LegalDocument> fetch(
    LegalDocumentType type,
    String languageCode,
  ) async {
    final ar = languageCode == 'ar';
    return switch (type) {
      LegalDocumentType.terms => ar ? _termsAr : _termsEn,
      LegalDocumentType.privacy => ar ? _privacyAr : _privacyEn,
    };
  }

  static const LegalDocument _termsAr = LegalDocument(
    type: LegalDocumentType.terms,
    title: 'الشروط والأحكام',
    intro:
        'مرحباً بك في تطبيق دكتور جبل. باستخدامك التطبيق فإنك توافق على الشروط التالية، فيرجى قراءتها بعناية.',
    sections: [
      LegalSection(
        heading: 'التعريفات',
        body:
            'يقصد بـ«التطبيق» تطبيق دكتور جبل، وبـ«الصيدلية» صيدليات جبل، وبـ«العميل» كل من يستخدم التطبيق لطلب المنتجات.',
      ),
      LegalSection(
        heading: 'إنشاء الحساب',
        body:
            'يجب أن تكون بالغاً وأن تقدّم بيانات صحيحة ومحدّثة. أنت مسؤول عن سرية بيانات دخولك وعن كل نشاط يتم من خلال حسابك.',
      ),
      LegalSection(
        heading: 'المنتجات والأدوية',
        body:
            'المنتجات المعروضة أصلية ومرخّصة من الجهات الصحية المختصة. بعض الأدوية لا تُصرف إلا بوصفة طبية معتمدة، وللصيدلي الحق في رفض الطلب أو طلب الوصفة قبل التسليم. المعلومات في التطبيق إرشادية ولا تغني عن استشارة الطبيب أو الصيدلي.',
      ),
      LegalSection(
        heading: 'الأسعار والدفع',
        body:
            'الأسعار بالدينار الأردني وتشمل الضرائب المطبّقة ما لم يُذكر غير ذلك. قد تتغير الأسعار والعروض دون إشعار مسبق، ويُعتمد السعر المعروض وقت تأكيد الطلب.',
      ),
      LegalSection(
        heading: 'التوصيل',
        body:
            'يتم التوصيل إلى العناوين الواقعة ضمن مناطق الخدمة المعلنة. المواعيد المذكورة تقديرية وقد تتأثر بالظروف الخارجة عن إرادتنا. عليك التأكد من صحة العنوان ورقم الهاتف لتسهيل التسليم.',
      ),
      LegalSection(
        heading: 'الإلغاء والاسترجاع',
        body:
            'يمكنك إلغاء الطلب قبل تجهيزه. لا تُسترجع الأدوية والمنتجات الصحية المفتوحة أو المستخدمة حفاظاً على سلامة العملاء، ويُقبل استرجاع المنتج غير المفتوح خلال المدة المعلنة في سياسة الاسترجاع، أو عند وجود عيب أو خطأ في المنتج المُسلَّم.',
      ),
      LegalSection(
        heading: 'الاستخدام المقبول',
        body:
            'يُمنع استخدام التطبيق لأي غرض مخالف للقانون أو لانتحال شخصية الآخرين أو لمحاولة الإضرار بالتطبيق أو بخدماته.',
      ),
      LegalSection(
        heading: 'حدود المسؤولية',
        body:
            'نبذل كل جهد لتقديم خدمة دقيقة وآمنة، ولا نتحمل المسؤولية عن أي ضرر ناتج عن استخدام المنتجات بخلاف الإرشادات أو التعليمات الطبية.',
      ),
      LegalSection(
        heading: 'التعديلات',
        body:
            'يجوز لنا تعديل هذه الشروط في أي وقت، ويُعدّ استمرارك في استخدام التطبيق بعد النشر موافقة على التعديلات.',
      ),
      LegalSection(
        heading: 'التواصل',
        body:
            'لأي استفسار حول هذه الشروط يمكنك التواصل معنا عبر صفحة «الدعم والمساعدة» في التطبيق.',
      ),
    ],
  );

  static const LegalDocument _termsEn = LegalDocument(
    type: LegalDocumentType.terms,
    title: 'Terms and conditions',
    intro:
        'Welcome to the Dr Jabal app. By using the app you agree to the following terms, so please read them carefully.',
    sections: [
      LegalSection(
        heading: 'Definitions',
        body:
            '"The app" means the Dr Jabal app, "the pharmacy" means Jabel Pharmacies, and "the customer" means anyone who uses the app to order products.',
      ),
      LegalSection(
        heading: 'Your account',
        body:
            'You must be an adult and give correct, up-to-date details. You are responsible for keeping your sign-in details secret and for all activity through your account.',
      ),
      LegalSection(
        heading: 'Products and medicines',
        body:
            'The products shown are genuine and licensed by the relevant health authorities. Some medicines are only dispensed with a valid prescription, and the pharmacist may refuse an order or ask for the prescription before delivery. The information in the app is for guidance and does not replace advice from your doctor or pharmacist.',
      ),
      LegalSection(
        heading: 'Prices and payment',
        body:
            'Prices are in Jordanian dinars and include the applicable taxes unless stated otherwise. Prices and offers may change without notice; the price shown when you confirm the order applies.',
      ),
      LegalSection(
        heading: 'Delivery',
        body:
            'We deliver to addresses inside the announced service areas. The times given are estimates and may be affected by things outside our control. Please make sure the address and phone number are correct so delivery goes smoothly.',
      ),
      LegalSection(
        heading: 'Cancellation and returns',
        body:
            'You can cancel an order before it is prepared. To protect customers, opened or used medicines and health products cannot be returned. An unopened product can be returned within the period stated in the returns policy, or if the product delivered is faulty or wrong.',
      ),
      LegalSection(
        heading: 'Acceptable use',
        body:
            'You may not use the app for anything unlawful, to pretend to be someone else, or to try to harm the app or its services.',
      ),
      LegalSection(
        heading: 'Limits of liability',
        body:
            'We do our best to provide an accurate and safe service. We are not liable for harm caused by using products against the instructions or medical advice.',
      ),
      LegalSection(
        heading: 'Changes',
        body:
            'We may change these terms at any time. Continuing to use the app after they are published means you accept the changes.',
      ),
      LegalSection(
        heading: 'Contact',
        body:
            'For any question about these terms, contact us through "Support and assistance" in the app.',
      ),
    ],
  );

  static const LegalDocument _privacyAr = LegalDocument(
    type: LegalDocumentType.privacy,
    title: 'سياسة الخصوصية',
    intro:
        'نحترم خصوصيتك. توضح هذه السياسة البيانات التي نجمعها في تطبيق دكتور جبل وكيف نستخدمها ونحميها.',
    sections: [
      LegalSection(
        heading: 'البيانات التي نجمعها',
        body:
            'نجمع اسمك ورقم جوالك وبريدك الإلكتروني وعناوين التوصيل التي تضيفها، وسجل طلباتك، وبيانات الجهاز اللازمة لتشغيل التطبيق. لا نحتفظ برقم بطاقتك الكامل ولا برمز الأمان.',
      ),
      LegalSection(
        heading: 'الموقع الجغرافي',
        body:
            'نطلب إذن الموقع لتحديد عنوان التوصيل وعرض أقرب صيدلية. يمكنك رفض الإذن وإدخال العنوان يدوياً، ويمكنك إيقافه من إعدادات جهازك في أي وقت.',
      ),
      LegalSection(
        heading: 'كيف نستخدم بياناتك',
        body:
            'نستخدمها لإنشاء حسابك وتجهيز طلباتك وتوصيلها، والتواصل معك بشأن الطلب، وتحسين خدماتنا، والالتزام بالمتطلبات النظامية.',
      ),
      LegalSection(
        heading: 'البيانات الصحية',
        body:
            'قد تحتوي الوصفات الطبية أو الاستشارات على معلومات صحية، وهي بيانات حساسة نستخدمها فقط لتقديم الخدمة المطلوبة ولا نشاركها إلا مع الصيدلي المختص.',
      ),
      LegalSection(
        heading: 'مشاركة البيانات',
        body:
            'لا نبيع بياناتك. قد نشاركها مع مزودي التوصيل والدفع بالقدر اللازم لتنفيذ طلبك، أو مع الجهات الرسمية عندما يوجبه القانون.',
      ),
      LegalSection(
        heading: 'حماية البيانات وحفظها',
        body:
            'نطبّق إجراءات تقنية وتنظيمية لحماية بياناتك، ونحتفظ بها للمدة اللازمة لتقديم الخدمة أو التي يفرضها القانون.',
      ),
      LegalSection(
        heading: 'حقوقك',
        body:
            'يمكنك الاطلاع على بياناتك وتعديلها من «المعلومات الشخصية»، وحذف حسابك وبياناتك من «الإعدادات».',
      ),
      LegalSection(
        heading: 'التعديلات والتواصل',
        body:
            'قد نحدّث هذه السياسة وننشر النسخة الجديدة في التطبيق. لأي استفسار تواصل معنا عبر «الدعم والمساعدة».',
      ),
    ],
  );

  static const LegalDocument _privacyEn = LegalDocument(
    type: LegalDocumentType.privacy,
    title: 'Privacy policy',
    intro:
        'We respect your privacy. This policy explains what data we collect in the Dr Jabal app and how we use and protect it.',
    sections: [
      LegalSection(
        heading: 'What we collect',
        body:
            'We collect your name, mobile number, e-mail, the delivery addresses you add, your order history and the device data needed to run the app. We never keep your full card number or security code.',
      ),
      LegalSection(
        heading: 'Location',
        body:
            'We ask for location permission to set your delivery address and show the nearest pharmacy. You can refuse and type the address instead, and you can turn it off in your device settings at any time.',
      ),
      LegalSection(
        heading: 'How we use your data',
        body:
            'To create your account, prepare and deliver your orders, contact you about them, improve our services and meet legal requirements.',
      ),
      LegalSection(
        heading: 'Health data',
        body:
            'Prescriptions or consultations may contain health information. It is sensitive, so we use it only to provide the service you asked for and share it only with the pharmacist concerned.',
      ),
      LegalSection(
        heading: 'Sharing',
        body:
            'We do not sell your data. We may share it with delivery and payment providers as far as needed to fulfil your order, or with the authorities when the law requires it.',
      ),
      LegalSection(
        heading: 'Protection and retention',
        body:
            'We apply technical and organisational measures to protect your data, and keep it for as long as needed to provide the service or as the law requires.',
      ),
      LegalSection(
        heading: 'Your rights',
        body:
            'You can see and change your data in "Personal information", and delete your account and data in "Settings".',
      ),
      LegalSection(
        heading: 'Changes and contact',
        body:
            'We may update this policy and publish the new version in the app. For any question, contact us through "Support and assistance".',
      ),
    ],
  );
}
