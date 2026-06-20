import 'package:shamsi_date/shamsi_date.dart';

class ShamsiHelper {
  static String toShamsi(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    final y = jalali.year.toString().toPersianDigit();
    final m = jalali.month.toString().padLeft(2, '0').toPersianDigit();
    final d = jalali.day.toString().padLeft(2, '0').toPersianDigit();
    return '$y/$m/$d';
  }

  /// تاریخ کوتاه شمسی فقط ماه/روز (مثلاً ۶/۱۱) — برای محورهای نمودار
  static String toShamsiShort(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    final m = jalali.month.toString().toPersianDigit();
    final d = jalali.day.toString().toPersianDigit();
    return '$m/$d';
  }

  static String toShamsiWithTime(DateTime date) {
    final dateStr = toShamsi(date);
    final h = date.hour.toString().padLeft(2, '0').toPersianDigit();
    final min = date.minute.toString().padLeft(2, '0').toPersianDigit();
    return '$dateStr  $h:$min';
  }

  static String get today => toShamsi(DateTime.now());

  /// تاریخ شروع سال شمسی جاری (۱ فروردین) به‌صورت DateTime میلادی.
  /// برای فیلتر کردن «فاکتورهای امسال» استفاده می‌شود.
  static DateTime startOfShamsiYear([DateTime? reference]) {
    final jalali = Jalali.fromDateTime(reference ?? DateTime.now());
    final firstOfYear = Jalali(jalali.year, 1, 1);
    return firstOfYear.toDateTime();
  }
}

extension PersianString on String {
  String toPersianDigit() {
    const persian = ['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'];
    String result = this;
    for (int i = 0; i <= 9; i++) {
      result = result.replaceAll('$i', persian[i]);
    }
    return result;
  }
}
