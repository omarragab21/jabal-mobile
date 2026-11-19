import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../app_button.dart';
import '../app_page_header.dart';
import '../app_text_field.dart';
import '../loading_overlay.dart';
import 'preview_wrapper.dart';

// Run with:  flutter widget-preview start

@Preview(group: 'Core / Button', name: 'Primary (AR)', wrapper: rtlWrapper)
Widget appButtonPrimary() => AppButton(label: 'تسجيل الدخول', onPressed: () {});

@Preview(group: 'Core / Button', name: 'Secondary (AR)', wrapper: rtlWrapper)
Widget appButtonSecondary() => AppButton(
  label: 'التالي',
  variant: AppButtonVariant.secondary,
  onPressed: () {},
);

@Preview(group: 'Core / Button', name: 'Disabled (AR)', wrapper: rtlWrapper)
Widget appButtonDisabled() =>
    const AppButton(label: 'إرسال رمز التحقق', onPressed: null);

@Preview(group: 'Core / Text field', name: 'Empty (AR)', wrapper: rtlWrapper)
Widget textFieldEmpty() =>
    const AppTextField(label: 'الاسم الكامل', hint: 'أكتب هنا ...');

@Preview(group: 'Core / Text field', name: 'Error (AR)', wrapper: rtlWrapper)
Widget textFieldError() => const AppTextField(
  label: 'البريد الالكتروني',
  hint: 'أكتب هنا ...',
  errorText: 'البريد الإلكتروني غير صالح',
);

@Preview(group: 'Core / Text field', name: 'Empty (EN)', wrapper: ltrWrapper)
Widget textFieldEnglish() =>
    const AppTextField(label: 'Full name', hint: 'Type here ...');

@Preview(group: 'Core / Header', name: 'Arabic (RTL)', wrapper: rtlWrapper)
Widget headerArabic() => const AppPageHeader(title: 'تسجيل الدخول');

@Preview(group: 'Core / Header', name: 'English (LTR)', wrapper: ltrWrapper)
Widget headerEnglish() => const AppPageHeader(title: 'Log in');

@Preview(
  group: 'Core / Loading',
  name: 'Overlay',
  size: Size(375, 300),
  wrapper: rtlWrapper,
)
Widget loadingOverlay() => const SizedBox(height: 260, child: LoadingOverlay());
