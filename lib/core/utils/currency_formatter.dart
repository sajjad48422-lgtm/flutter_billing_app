import 'package:hive_flutter/hive_flutter.dart';

enum CurrencyUnit { toman, rial }

class CurrencyFormatter {
  static const String _boxName = 'settings';
  static const String _currencyKey = 'currency_unit';

  static CurrencyUnit get currentUnit {
    try {
      final box = Hive.box(_boxName);
      final value = box.get(_currencyKey, defaultValue: 'toman');
      return value == 'rial' ? CurrencyUnit.rial : CurrencyUnit.toman;
    } catch (_) {
      return CurrencyUnit.toman;
    }
  }

  static Future<void> setUnit(CurrencyUnit unit) async {
    final box = Hive.box(_boxName);
    await box.put(
      _currencyKey,
      unit == CurrencyUnit.rial ? 'rial' : 'toman',
    );
  }

  static String format(double amount, {bool showUnit = true}) {
    double displayAmount = amount;
    if (currentUnit == CurrencyUnit.toman) {
      displayAmount = amount / 10;
    }

    final formatted = displayAmount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}،',
        )
        .toPersianDigit();

    if (!showUnit) return formatted;
    final unit = currentUnit == CurrencyUnit.toman ? 'تومان' : 'ریال';
    return '$formatted $unit';
  }

  static String get unitName =>
      currentUnit == CurrencyUnit.toman ? 'تومان' : 'ریال';
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