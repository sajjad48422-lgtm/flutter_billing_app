import 'package:depir/core/utils/currency_formatter.dart';
import 'package:depir/core/utils/tax_calculator.dart';
import 'package:depir/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/billing_bloc.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final ScreenshotController _screenshotController = ScreenshotController();

  String _buildSmsText({
    required String shopName,
    required List cartItems,
    required double subtotal,
    required double vatAmount,
    required double total,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('فاکتور $shopName');
    buffer.writeln('─────────────────');
    for (final item in cartItems) {
      buffer.writeln(
        '${item.product.name} × ${item.displayAmount} = '
        '${CurrencyFormatter.format(item.total)}',
      );
    }
    buffer.writeln('─────────────────');
    buffer.writeln('جمع: ${CurrencyFormatter.format(subtotal)}');
    buffer.writeln('مالیات ۹٪: ${CurrencyFormatter.format(vatAmount)}');
    buffer.writeln('مبلغ کل: ${CurrencyFormatter.format(total)}');
    buffer.writeln('با تشکر از خرید شما 🙏');
    return buffer.toString();
  }

  Future<void> _openSmsApp(BuildContext context, String smsText) async {
    final encoded = Uri.encodeComponent(smsText);
    final uri = Uri.parse('sms:?body=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('اپ پیامک پیدا نشد!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareAsImage({
    required BuildContext context,
    required String shopName,
    required List cartItems,
    required double subtotal,
    required double vatAmount,
    required double total,
  }) async {
    try {
      final image = await _screenshotController.captureFromWidget(
        _buildReceiptWidget(
          shopName: shopName,
          cartItems: cartItems,
          subtotal: subtotal,
          vatAmount: vatAmount,
          total: total,
        ),
        pixelRatio: 3.0,
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/depir_receipt.png');
      await file.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'فاکتور $shopName',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در اشتراک‌گذاری: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildReceiptWidget({
    required String shopName,
    required List cartItems,
    required double subtotal,
    required double vatAmount,
    required double total,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: 400,
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // هدر
            Text(
              shopName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'فاکتور فروش',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const Divider(height: 24),

            // اقلام
            ...cartItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.product.name} × ${item.displayAmount}',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black),
                      ),
                      Text(
                        CurrencyFormatter.format(item.total,
                            showUnit: false),
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black),
                      ),
                    ],
                  ),
                )),

            const Divider(height: 24),

            // جمع
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('جمع کل:',
                    style: TextStyle(fontSize: 13, color: Colors.black54)),
                Text(CurrencyFormatter.format(subtotal),
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('مالیات ۹٪:',
                    style: TextStyle(fontSize: 13, color: Colors.black54)),
                Text(CurrencyFormatter.format(vatAmount),
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black)),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'مبلغ قابل پرداخت:',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Text(
                  CurrencyFormatter.format(total),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'با تشکر از خرید شما 🙏',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'دپیر — سیستم فروشگاهی هوشمند',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                  final vatAmount =
                      TaxCalculator.calculateVat(subtotal);
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
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border:
                                      Border.all(color: borderColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.05),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  child: Table(
                                    border: const TableBorder(
                                      horizontalInside: BorderSide(
                                          color: borderColor),
                                      bottom: BorderSide(
                                          color: borderColor),
                                    ),
                                    children: [
                                      TableRow(
                                        decoration:
                                            const BoxDecoration(
                                          color: Color(0xFFF8FAFC),
                                          border: Border(
                                            bottom: BorderSide(
                                                color: borderColor),
                                          ),
                                        ),
                                        children: [
                                          _buildHeaderCell('نام کالا',
                                              TextAlign.right),
                                          _buildHeaderCell(
                                              'قیمت', TextAlign.center),
                                          _buildHeaderCell(
                                              'جمع', TextAlign.left),
                                        ],
                                      ),
                                      ...billingState.cartItems
                                          .map((item) {
                                        return TableRow(
                                          children: [
                                            _buildDataCell(
                                              '${item.product.name} × ${item.displayAmount}',
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
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border:
                                      Border.all(color: borderColor),
                                ),
                                child: Column(
                                  children: [
                                    _buildSummaryRow(
                                      'جمع کل',
                                      CurrencyFormatter.format(
                                          subtotal),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildSummaryRow(
                                      TaxCalculator.vatLabel,
                                      CurrencyFormatter.format(
                                          vatAmount),
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
                              const SizedBox(height: 16),
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
                              color:
                                  Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              16,
                              12,
                              16,
                              MediaQuery.of(context).padding.bottom +
                                  16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // دکمه پیامک
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    final smsText = _buildSmsText(
                                      shopName: shopName,
                                      cartItems:
                                          billingState.cartItems,
                                      subtotal: subtotal,
                                      vatAmount: vatAmount,
                                      total: total,
                                    );
                                    _openSmsApp(context, smsText);
                                  },
                                  icon:
                                      const Icon(Icons.sms_outlined),
                                  label: const Text(
                                      'ارسال فاکتور با پیامک'),
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
                              const SizedBox(height: 10),

                              // دکمه اشتراک‌گذاری
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => _shareAsImage(
                                    context: context,
                                    shopName: shopName,
                                    cartItems: billingState.cartItems,
                                    subtotal: subtotal,
                                    vatAmount: vatAmount,
                                    total: total,
                                  ),
                                  icon: const Icon(Icons.share_outlined),
                                  label: const Text(
                                      'اشتراک‌گذاری فاکتور'),
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
                              const SizedBox(height: 10),

                              // دکمه چاپ
                              PrimaryButton(
                                onPressed: () {
                                  if (shopState is ShopLoaded) {
                                    context.read<BillingBloc>().add(
                                          PrintReceiptEvent(
                                            shopName:
                                                shopState.shop.name,
                                            address1: shopState
                                                .shop.addressLine1,
                                            address2: shopState
                                                .shop.addressLine2,
                                            phone: shopState
                                                .shop.phoneNumber,
                                            footer: shopState
                                                .shop.footerText,
                                          ),
                                        );
                                  }
                                },
                                label: 'چاپ رسید',
                                icon: Icons.print,
                                isLoading: billingState.isPrinting,
                              ),
                            ],
                          ),
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

  Widget _buildDataCell(String text, TextAlign align,
      {bool isBold = false, bool isSubtitle = false}) {
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

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false,
      bool isSubtitle = false,
      bool isLarge = false}) {
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
