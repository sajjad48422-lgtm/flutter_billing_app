import 'package:billing_app/core/utils/currency_formatter.dart';
import 'package:billing_app/core/utils/tax_calculator.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/billing_bloc.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showSmsDialog(BuildContext context, String shopName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ارسال فاکتور با پیامک',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: 'شماره موبایل مشتری',
                  hintText: '09123456789',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final phone = _phoneController.text.trim();
                    if (phone.isEmpty || phone.length < 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('شماره موبایل معتبر نیست'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    context.read<BillingBloc>().add(
                          SendSmsReceiptEvent(
                            customerPhone: phone,
                            shopName: shopName,
                          ),
                        );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('ارسال پیامک'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE5E5EA);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        context.read<BillingBloc>().add(ClearCartEvent());
        context.go('/');
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'صندوق پرداخت',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.chevron_right,
                size: 28,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                context.read<BillingBloc>().add(ClearCartEvent());
                context.go('/');
              },
            ),
          ),
          body: BlocConsumer<BillingBloc, BillingState>(
            listener: (context, state) {
              if (state.printSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('رسید با موفقیت چاپ شد ✓'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              if (state.smsSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('فاکتور با موفقیت ارسال شد ✓'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, billingState) {
              return BlocBuilder<ShopBloc, ShopState>(
                builder: (context, shopState) {
                  String shopName = 'فروشگاه';
                  if (shopState is ShopLoaded) {
                    shopName = shopState.shop.name;
                  }

                  final subtotal = billingState.subtotal;
                  final vatAmount = TaxCalculator.calculateVat(subtotal);
                  final total = TaxCalculator.totalWithVat(subtotal);

                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Column(
                            children: [
                              // جدول اقلام
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                          alpha: 0.05),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Table(
                                    border: const TableBorder(
                                      horizontalInside:
                                          BorderSide(color: borderColor),
                                      bottom: BorderSide(color: borderColor),
                                    ),
                                    children: [
                                      // هدر
                                      TableRow(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF8FAFC),
                                          border: Border(
                                            bottom:
                                                BorderSide(color: borderColor),
                                          ),
                                        ),
                                        children: [
                                          _buildHeaderCell(
                                              'نام کالا', TextAlign.right),
                                          _buildHeaderCell(
                                              'قیمت', TextAlign.center),
                                          _buildHeaderCell(
                                              'جمع', TextAlign.left),
                                        ],
                                      ),
                                      // ردیف‌های کالا
                                      ...billingState.cartItems.map((item) {
                                        return TableRow(
                                          children: [
                                            _buildDataCell(
                                              '${item.product.name} × ${item.quantity}',
                                              TextAlign.right,
                                            ),
                                            _buildDataCell(
                                              CurrencyFormatter.format(
                                                item.product.price,
                                                showUnit: false,
                                              ),
                                              TextAlign.center,
                                              isSubtitle: true,
                                            ),
                                            _buildDataCell(
                                              CurrencyFormatter.format(
                                                item.total,
                                                showUnit: false,
                                              ),
                                              TextAlign.left,
                                              isBold: true,
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // خلاصه مبالغ
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  children: [
                                    _buildSummaryRow(
                                      'جمع کل',
                                      CurrencyFormatter.format(subtotal),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildSummaryRow(
                                      TaxCalculator.vatLabel,
                                      CurrencyFormatter.format(vatAmount),
                                      isSubtitle: true,
                                    ),
                                    const Divider(height: 20),
                                    _buildSummaryRow(
                                      'مبلغ قابل پرداخت',
                                      CurrencyFormatter.format(total),
                                      isBold: true,
                                      isLarge: true,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ),

                      // نوار پایین
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 8),
                            // دکمه چاپ
                            PrimaryButton(
                              onPressed: () {
                                if (shopState is ShopLoaded) {
                                  context.read<BillingBloc>().add(
                                        PrintReceiptEvent(
                                          shopName: shopState.shop.name,
                                          address1:
                                              shopState.shop.addressLine1,
                                          address2:
                                              shopState.shop.addressLine2,
                                          phone: shopState.shop.phoneNumber,
                                          footer: shopState.shop.footerText,
                                        ),
                                      );
                                }
                              },
                              label: 'چاپ رسید',
                              icon: Icons.print,
                              isLoading: billingState.isPrinting,
                            ),
                            // دکمه پیامک
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 0, 16, 16),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: billingState.isSendingSms
                                      ? null
                                      : () => _showSmsDialog(
                                            context,
                                            shopName,
                                          ),
                                  icon: billingState.isSendingSms
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Icon(Icons.sms_outlined),
                                  label: Text(
                                    billingState.isSendingSms
                                        ? 'در حال ارسال...'
                                        : 'ارسال فاکتور با پیامک',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDataCell(
    String text,
    TextAlign align, {
    bool isBold = false,
    bool isSubtitle = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isSubtitle ? 12 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color: isSubtitle ? Colors.grey[500] : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    bool isSubtitle = false,
    bool isLarge = false,
  }) {
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
            color: isLarge
                ? Theme.of(context).primaryColor
                : Colors.black87,
          ),
        ),
      ],
    );
  }
}