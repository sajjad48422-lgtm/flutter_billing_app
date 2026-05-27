import 'package:telephony/telephony.dart';
import '../utils/currency_formatter.dart';
import '../utils/shamsi_helper.dart';

class SmsService {
  static final Telephony _telephony = Telephony.instance;

  static Future<SmsResult> sendInvoiceViaSim({
    required String customerPhone,
    required String shopName,
    required List<InvoiceItem> items,
    required double subtotal,
    required double vatAmount,
    required double total,
    required String invoiceNumber,
  }) async {
    final bool? permissionGranted =
        await _telephony.requestSmsPermissions;
    if (permissionGranted != true) {
      return SmsResult.permissionDenied;
    }

    final message = _buildMessage(
      shopName: shopName,
      items: items,
      subtotal: subtotal,
      vatAmount: vatAmount,
      total: total,
      invoiceNumber: invoiceNumber,
    );

    try {
      await _telephony.sendSms(
        to: customerPhone,
        message: message,
        statusListener: (SendStatus status) {},
      );
      return SmsResult.success;
    } catch (e) {
      return SmsResult.failed;
    }
  }

  static String _buildMessage({
    required String shopName,
    required List<InvoiceItem> items,
    required double subtotal,
    required double vatAmount,
    required double total,
    required String invoiceNumber,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🧾 فاکتور $shopName');
    buffer.writeln('شماره: $invoiceNumber');
    buffer.writeln('تاریخ: ${ShamsiHelper.today}');
    buffer.writeln('─────────────────');
    for (final item in items) {
      buffer.writeln(
        '${item.name} × ${item.quantity} = '
        '${CurrencyFormatter.format(item.total)}',
      );
    }
    buffer.writeln('─────────────────');
    buffer.writeln(
        'جمع: ${CurrencyFormatter.format(subtotal)}');
    buffer.writeln(
        'مالیات ۹٪: ${CurrencyFormatter.format(vatAmount)}');
    buffer.writeln(
        'مبلغ کل: ${CurrencyFormatter.format(total)}');
    buffer.writeln('با تشکر از خرید شما 🙏');
    return buffer.toString();
  }
}

class InvoiceItem {
  final String name;
  final int quantity;
  final double total;

  const InvoiceItem({
    required this.name,
    required this.quantity,
    required this.total,
  });
}

enum SmsResult { success, failed, permissionDenied }