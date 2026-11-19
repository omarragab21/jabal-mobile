import 'package:intl/intl.dart';

/// Text formats of the orders screens. Arabic names are written out here so
/// the digits stay Latin like the design (intl's `ar` pattern would switch
/// them to Arabic-Indic).
abstract final class OrdersFormatters {
  static const _arDays = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static const _arMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  static bool _ar(String lang) => lang == 'ar';

  /// `12.50`
  static String amount(double value, {int decimals = 2}) =>
      value.toStringAsFixed(decimals);

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _clock(DateTime d, String lang, {bool padHour = false}) {
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final period = d.hour < 12
        ? (_ar(lang) ? 'ص' : 'AM')
        : (_ar(lang) ? 'م' : 'PM');
    return '${padHour ? _two(hour) : hour}:${_two(d.minute)} $period';
  }

  /// List card: `2026-09-23 - 10:30 ص`
  static String listDate(DateTime d, String lang) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)} - ${_clock(d, lang, padHour: true)}';

  /// Details banner and timeline: `الأربعاء 31 ديسمبر , 4:00 م`
  static String longDate(DateTime d, String lang) {
    if (_ar(lang)) {
      return '${_arDays[d.weekday - 1]} ${d.day} ${_arMonths[d.month - 1]} , ${_clock(d, lang)}';
    }
    return '${DateFormat('EEEE d MMMM', lang).format(d)} , ${_clock(d, lang)}';
  }

  /// Day only: `31 ديسمبر 2025`
  static String shortDate(DateTime d, String lang) => _ar(lang)
      ? '${d.day} ${_arMonths[d.month - 1]} ${d.year}'
      : DateFormat('d MMMM y', lang).format(d);

  /// Invoice stamp: `19/07/2025 03:22`
  static String invoiceDate(DateTime d) =>
      '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';

  /// Cancel countdown: `00:45`
  static String countdown(Duration d) {
    final seconds = d.isNegative ? 0 : d.inSeconds;
    return '${_two(seconds ~/ 60)}:${_two(seconds % 60)}';
  }
}
