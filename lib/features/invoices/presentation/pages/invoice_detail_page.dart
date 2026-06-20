import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/shamsi_helper.dart' hide PersianString;
import '../../../sales/domain/entities/sale_record.dart';

/// صفحه جزئیات کامل یک فاکتور: تاریخ و ساعت شمسی، تمام اقلام، جمع کل،
/// مالیات و سود. فیلد نام مشتری فعلاً اضافه نشده (در انتظار فیچر مشتری).
class InvoiceDetailPage extends StatelessWidget {
  final SaleRecord invoice;

  const InvoiceDetailPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'جزئیات فاکتور',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildItemsCard(),
          const SizedBox(height: 16),
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildCustomerPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.receipt_long, color: Colors.white, size: 28),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${invoice.items.length} قلم'.toPersianDigit(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            CurrencyFormatter.format(invoice.finalAmount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time,
                  color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                ShamsiHelper.toShamsiWithTime(invoice.createdAt),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.confirmation_number_outlined,
                  color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'شماره فاکتور: ${invoice.id}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'اقلام فاکتور',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          ...invoice.items.asMap().entries.map((entry) {
            final isLast = entry.key == invoice.items.length - 1;
            return Column(
              children: [
                _itemRow(entry.value),
                if (!isLast)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _itemRow(SaleItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_formatQuantity(item.quantity)} × '
                  '${CurrencyFormatter.format(item.price, showUnit: false)}'
                      .toPersianDigit(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(item.total, showUnit: false),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toInt().toString();
    }
    return quantity.toString();
  }

  Widget _buildSummaryCard() {
    final subtotal = invoice.totalAmount;
    final tax = invoice.taxAmount;
    final total = invoice.finalAmount;
    final profit = invoice.totalProfit;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _summaryRow('جمع کل اقلام', CurrencyFormatter.format(subtotal)),
          const SizedBox(height: 10),
          _summaryRow('مالیات بر ارزش افزوده (۹٪)',
              CurrencyFormatter.format(tax),
              isSubtitle: true),
          const Divider(height: 24),
          _summaryRow('مبلغ نهایی', CurrencyFormatter.format(total),
              isBold: true, isLarge: true),
          const SizedBox(height: 10),
          _summaryRow('سود این فاکتور', CurrencyFormatter.format(profit),
              isSubtitle: true, valueColor: const Color(0xFF00B377)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isBold = false, bool isSubtitle = false, bool isLarge = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isSubtitle ? Colors.grey[500] : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ??
                (isLarge ? AppTheme.primaryColor : Colors.black87),
          ),
        ),
      ],
    );
  }

  /// بخش مشتری — فعلاً غیرفعال، در انتظار فیچر مشتری در آینده
  Widget _buildCustomerPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Icon(Icons.person_outline, color: Colors.grey[400], size: 20),
          const SizedBox(width: 10),
          Text(
            'این فاکتور به مشتری خاصی نسبت داده نشده است',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
