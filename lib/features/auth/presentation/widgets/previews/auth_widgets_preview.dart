import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../../core/countries/countries.dart';
import '../../../../../core/widgets/previews/preview_wrapper.dart';
import '../account_blocked_dialog.dart';
import '../auth_footer_link.dart';
import '../country_flag.dart';
import '../country_picker_sheet.dart';
import '../forgot_password_link.dart';
import '../otp_error_message.dart';
import '../otp_input.dart';
import '../password_field.dart';
import '../phone_field.dart';
import '../resend_code_text.dart';

// Run with:  flutter widget-preview start

final _jordan = Countries.byIso('JO');
final _saudi = Countries.byIso('SA');

@Preview(group: 'Auth / Phone field', name: 'Jordan (AR)', wrapper: rtlWrapper)
Widget phoneJordanArabic() => PhoneField(
  label: 'رقم الجوال',
  hint: 'أدخل رقم الجوال ...',
  country: _jordan,
  onCountryTap: () {},
);

@Preview(group: 'Auth / Phone field', name: 'Saudi (EN)', wrapper: ltrWrapper)
Widget phoneSaudiEnglish() => PhoneField(
  label: 'Phone number',
  hint: 'Enter your phone number ...',
  country: _saudi,
  onCountryTap: () {},
);

@Preview(group: 'Auth / Phone field', name: 'Error (AR)', wrapper: rtlWrapper)
Widget phoneError() => PhoneField(
  label: 'رقم الجوال',
  hint: 'أدخل رقم الجوال ...',
  country: _jordan,
  errorText: 'رقم الجوال غير صالح',
  onCountryTap: () {},
);

@Preview(group: 'Auth / Password field', name: 'Arabic', wrapper: rtlWrapper)
Widget passwordArabic() =>
    const PasswordField(label: 'كلمة المرور', hint: 'ادخل كلمة المرور');

@Preview(group: 'Auth / Password field', name: 'English', wrapper: ltrWrapper)
Widget passwordEnglish() =>
    const PasswordField(label: 'Password', hint: 'Enter your password');

@Preview(
  group: 'Auth / Links',
  name: 'Forgot password (AR)',
  wrapper: rtlWrapper,
)
Widget forgotPassword() => const ForgotPasswordLink(label: 'نسيت كلمة المرور');

@Preview(
  group: 'Auth / Links',
  name: 'Footer: no account (AR)',
  wrapper: rtlWrapper,
)
Widget footerNoAccount() => AuthFooterLink(
  question: 'ليس لديك حساب؟',
  action: 'إنشاء حساب',
  onTap: () {},
);

@Preview(
  group: 'Auth / Links',
  name: 'Footer: have account (EN)',
  wrapper: ltrWrapper,
)
Widget footerHaveAccount() => AuthFooterLink(
  question: 'Already have an account?',
  action: 'Log in',
  onTap: () {},
);

@Preview(group: 'Auth / OTP', name: 'Empty', wrapper: rtlWrapper)
Widget otpEmpty() => const OtpInput();

@Preview(group: 'Auth / OTP', name: 'Error', wrapper: rtlWrapper)
Widget otpError() => const Column(
  children: [
    OtpInput(status: OtpStatus.error),
    SizedBox(height: 16),
    OtpErrorMessage(message: 'ولايهمك، يمكن في رقم غلط. جرّب كمان مرة 😊'),
  ],
);

@Preview(group: 'Auth / OTP', name: 'Success', wrapper: rtlWrapper)
Widget otpSuccess() => const OtpInput(status: OtpStatus.success);

@Preview(
  group: 'Auth / OTP',
  name: 'Resend: counting (AR)',
  wrapper: rtlWrapper,
)
Widget resendCounting() => ResendCodeText(
  prompt: 'ما وصلك الرمز؟',
  waitLabel: 'إعادة الإرسال بعد',
  resendLabel: 'إعادة الإرسال',
  secondsLeft: 43,
  onResend: () {},
);

@Preview(group: 'Auth / OTP', name: 'Resend: ready (AR)', wrapper: rtlWrapper)
Widget resendReady() => ResendCodeText(
  prompt: 'ما وصلك الرمز؟',
  waitLabel: 'إعادة الإرسال بعد',
  resendLabel: 'إعادة الإرسال',
  secondsLeft: 0,
  onResend: () {},
);

@Preview(group: 'Auth / Country', name: 'Flags', wrapper: rtlWrapper)
Widget flags() => const Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: [
    CountryFlag(isoCode: 'JO'),
    CountryFlag(isoCode: 'SA'),
    CountryFlag(isoCode: 'EG'),
    CountryFlag(isoCode: 'US'),
  ],
);

@Preview(
  group: 'Auth / Country',
  name: 'Picker sheet (AR)',
  size: Size(375, 600),
  wrapper: rtlWrapper,
)
Widget countryPicker() => SizedBox(
  height: 560,
  child: CountryPickerSheet(
    title: 'اختر الدولة',
    searchHint: 'ابحث عن دولة أو رمز',
    emptyLabel: 'لا توجد نتائج',
    languageCode: 'ar',
    selected: _jordan,
    onSelected: (_) {},
  ),
);

@Preview(
  group: 'Auth / Dialog',
  name: 'Account blocked (AR)',
  size: Size(375, 260),
  wrapper: rtlWrapper,
)
Widget accountBlockedArabic() => Center(
  child: AccountBlockedDialog(
    title: 'لا يمكن إكمال تسجيل الدخول',
    message: 'لا يمكن تسجيل الدخول باستخدام هذا الرقم في الوقت الحالي.',
    contactLabel: 'تواصل مع الدعم',
    onClose: () {},
    onContactSupport: () {},
  ),
);

@Preview(
  group: 'Auth / Dialog',
  name: 'Account blocked (EN)',
  size: Size(375, 260),
  wrapper: ltrWrapper,
)
Widget accountBlockedEnglish() => Center(
  child: AccountBlockedDialog(
    title: "Can't complete login",
    message: "Login isn't available for this number right now.",
    contactLabel: 'Contact support',
    onClose: () {},
    onContactSupport: () {},
  ),
);
