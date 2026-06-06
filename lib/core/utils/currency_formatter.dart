import 'package:hive_flutter/hive_flutter.dart';

class CurrencyFormatter {
  /// فرمت‌بندی قیمت به ریال با جداکننده هزارگان
  /// مثال: 1100000 → ۱٬۱۰۰٬۰۰۰ ریال
  static String format(double amount, {bool showUnit = true}) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}٬',
        )
        .toPersianDigit();

    if (!showUnit) return formatted;
    return '$formatted ریال';
  }

  static String get unitName => 'ریال';
}

extension PersianDigit on String {
  String toPersianDigit() {
    const persian = ['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'];
    String result = this;
    for (int i = 0; i <= 9; i++) {
      result = result.replaceAll('$i', persian[i]);
    }
    return result;
  }
}