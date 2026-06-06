class TaxCalculator {
  /// نرخ مالیات بر ارزش افزوده ایران ۹٪
  static const double vatRate = 0.09;

  /// محاسبه مبلغ مالیات
  static double calculateVat(double subtotal) {
    return subtotal * vatRate;
  }

  /// مبلغ کل با مالیات
  static double totalWithVat(double subtotal) {
    return subtotal + calculateVat(subtotal);
  }

  /// درصد نمایشی
  static String get vatPercent => '۹%';

  /// نام کامل
  static String get vatLabel => 'مالیات بر ارزش افزوده (۹٪)';
}