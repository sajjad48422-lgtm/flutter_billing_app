class AppValidators {
  static String? Function(String?) required(String message) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'لطفاً قیمت را وارد کنید';
    }
    // حذف جداکننده‌های هزارگان قبل از parse
    final cleaned = value.replaceAll(',', '').replaceAll('٬', '');
    if (double.tryParse(cleaned) == null) {
      return 'لطفاً یک عدد معتبر وارد کنید';
    }
    if (double.parse(cleaned) < 0) {
      return 'قیمت نمی‌تواند منفی باشد';
    }
    return null;
  }
}