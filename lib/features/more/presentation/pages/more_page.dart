import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/hive_database.dart';
import '../../../product/data/models/product_model.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../shop/data/models/shop_model.dart';
import '../../../shop/data/repositories/shop_repository_impl.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../sales/data/models/sale_record_hive_model.dart';
import '../../../sales/presentation/bloc/reports_bloc.dart';

const int _backupFormatVersion = 2;

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'بیشتر',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildSection(context, 'فروش', [
            _MoreItem(
              icon: Icons.receipt_long_outlined,
              label: 'فاکتورها',
              subtitle: 'مشاهده تاریخچه فروش',
              onTap: () => context.push('/invoices'),
            ),
          ]),
          const SizedBox(height: 12),
          _buildSection(context, 'تنظیمات', [
            _MoreItem(
              icon: Icons.store_outlined,
              label: 'اطلاعات فروشگاه',
              onTap: () => context.push('/shop'),
            ),
            _MoreItem(
              icon: Icons.print_outlined,
              label: 'پرینتر',
              onTap: () => context.push('/settings'),
            ),
            _MoreItem(
              icon: Icons.security_outlined,
              label: 'امنیت',
              onTap: () => context.push('/pin-setup'),
            ),
          ]),
          const SizedBox(height: 12),
          _buildSection(context, 'داده‌ها', [
            _MoreItem(
              icon: Icons.backup_outlined,
              label: 'پشتیبان‌گیری',
              subtitle: 'ذخیره اطلاعات روی گوشی',
              onTap: () => _exportBackup(context),
            ),
            _MoreItem(
              icon: Icons.restore_outlined,
              label: 'بازگردانی',
              subtitle: 'بازگردانی از فایل پشتیبان',
              onTap: () => _importBackup(context),
            ),
          ]),
          const SizedBox(height: 12),
          _buildSection(context, 'اطلاعات', [
            _MoreItem(
              icon: Icons.info_outline,
              label: 'درباره برنامه',
              onTap: () => context.push('/about'),
            ),
          ]),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<_MoreItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2))
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.icon,
                          color: AppTheme.primaryColor, size: 20),
                    ),
                    title: Text(
                      item.label,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    subtitle: item.subtitle != null
                        ? Text(
                            item.subtitle!,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          )
                        : null,
                    trailing: const Icon(Icons.chevron_left,
                        color: Colors.grey, size: 20),
                    onTap: item.onTap,
                  ),
                  if (i < items.length - 1)
                    const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── پشتیبان‌گیری ──────────────────────────────────────────────
  // داده‌ها به شکل JSON ساختاریافته (نه toString) ذخیره می‌شوند تا
  // بازگردانی واقعاً امکان‌پذیر باشد.
  Future<void> _exportBackup(BuildContext context) async {
    try {
      final productBox = HiveDatabase.productBox;
      final products = productBox.values
          .map((p) => {
                'id': p.id,
                'name': p.name,
                'barcode': p.barcode,
                'price': p.price,
                'purchasePrice': p.purchasePrice,
                'stock': p.stock,
                'lowStockThreshold': p.lowStockThreshold,
                'unitIndex': p.unit.index,
              })
          .toList();

      Map<String, dynamic>? shopData;
      final shopBox = HiveDatabase.shopBox;
      final shop = shopBox.get(ShopRepositoryImpl.shopKey);
      if (shop != null) {
        shopData = {
          'name': shop.name,
          'addressLine1': shop.addressLine1,
          'addressLine2': shop.addressLine2,
          'phoneNumber': shop.phoneNumber,
          'upiId': shop.upiId,
          'footerText': shop.footerText,
          'logoPath': shop.logoPath,
        };
      }

      final salesBox = HiveDatabase.salesBox;
      final sales = salesBox.values
          .map((s) => {
                'id': s.id,
                'createdAt': s.createdAt.toIso8601String(),
                'totalAmount': s.totalAmount,
                'totalPurchaseAmount': s.totalPurchaseAmount,
                'taxAmount': s.taxAmount,
                'finalAmount': s.finalAmount,
                'items': s.items
                    .map((i) => {
                          'productId': i.productId,
                          'productName': i.productName,
                          'price': i.price,
                          'purchasePrice': i.purchasePrice,
                          'quantity': i.quantity,
                          'total': i.total,
                        })
                    .toList(),
              })
          .toList();

      final settingsBox = HiveDatabase.settingsBox;
      final settings = {
        'printer_mac': settingsBox.get('printer_mac'),
        'printer_name': settingsBox.get('printer_name'),
      };

      final backupData = {
        'version': _backupFormatVersion,
        'backup_date': DateTime.now().toIso8601String(),
        'products': products,
        'shop': shopData,
        'sales': sales,
        'settings': settings,
      };

      final jsonStr = const JsonEncoder.withIndent('  ').convert(backupData);
      final dir = await getTemporaryDirectory();
      final fileName =
          'depir_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(jsonStr);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'پشتیبان اپ دپیر',
        text: 'فایل پشتیبان اپ دپیر',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در تهیه پشتیبان: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('بازگردانی اطلاعات'),
        content: const Text(
          'اطلاعات فعلی با فایل پشتیبان جایگزین می‌شوند.\nمطمئنید؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('بازگردانی',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.first.path;
      if (filePath == null) return;

      final file = File(filePath);
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      if (!data.containsKey('version')) {
        throw Exception('فایل پشتیبان معتبر نیست');
      }

      // ── محصولات ──────────────────────────────────────────────
      final productBox = HiveDatabase.productBox;
      await productBox.clear();
      final productsList = (data['products'] as List?) ?? [];
      for (final raw in productsList) {
        final map = raw as Map<String, dynamic>;
        final model = ProductModel(
          id: map['id'] as String,
          name: map['name'] as String,
          barcode: map['barcode'] as String,
          price: (map['price'] as num).toDouble(),
          stock: map['stock'] as int,
          lowStockThreshold: (map['lowStockThreshold'] as int?) ?? 2,
          unitIndex: (map['unitIndex'] as int?) ?? 0,
          purchasePrice: (map['purchasePrice'] as num?)?.toDouble() ?? 0.0,
        );
        await productBox.put(model.id, model);
      }

      // ── اطلاعات فروشگاه ─────────────────────────────────────
      final shopMap = data['shop'] as Map<String, dynamic>?;
      if (shopMap != null) {
        final shopBox = HiveDatabase.shopBox;
        final model = ShopModel(
          name: shopMap['name'] as String,
          addressLine1: shopMap['addressLine1'] as String,
          addressLine2: shopMap['addressLine2'] as String,
          phoneNumber: shopMap['phoneNumber'] as String,
          upiId: shopMap['upiId'] as String,
          footerText: shopMap['footerText'] as String,
          logoPath: (shopMap['logoPath'] as String?) ?? '',
        );
        await shopBox.put(ShopRepositoryImpl.shopKey, model);
      }

      // ── تاریخچه فروش ─────────────────────────────────────────
      final salesBox = HiveDatabase.salesBox;
      await salesBox.clear();
      final salesList = (data['sales'] as List?) ?? [];
      for (final raw in salesList) {
        final map = raw as Map<String, dynamic>;
        final itemsList = ((map['items'] as List?) ?? []).map((rawItem) {
          final itemMap = rawItem as Map<String, dynamic>;
          final item = SaleItemHiveModel();
          item.productId = itemMap['productId'] as String;
          item.productName = itemMap['productName'] as String;
          item.price = (itemMap['price'] as num).toDouble();
          item.purchasePrice = (itemMap['purchasePrice'] as num).toDouble();
          item.quantity = (itemMap['quantity'] as num).toDouble();
          item.total = (itemMap['total'] as num).toDouble();
          return item;
        }).toList();

        final record = SaleRecordHiveModel();
        record.id = map['id'] as String;
        record.createdAt = DateTime.parse(map['createdAt'] as String);
        record.items = itemsList;
        record.totalAmount = (map['totalAmount'] as num).toDouble();
        record.totalPurchaseAmount =
            (map['totalPurchaseAmount'] as num).toDouble();
        record.taxAmount = (map['taxAmount'] as num).toDouble();
        record.finalAmount = (map['finalAmount'] as num).toDouble();
        await salesBox.put(record.id, record);
      }

      // ── تنظیمات پرینتر ───────────────────────────────────────
      final settingsMap = data['settings'] as Map<String, dynamic>?;
      if (settingsMap != null) {
        final settingsBox = HiveDatabase.settingsBox;
        if (settingsMap['printer_mac'] != null) {
          await settingsBox.put('printer_mac', settingsMap['printer_mac']);
        }
        if (settingsMap['printer_name'] != null) {
          await settingsBox.put('printer_name', settingsMap['printer_name']);
        }
      }

      // ── به‌روزرسانی blocهای فعال با داده‌ی تازه ────────────────
      if (context.mounted) {
        context.read<ProductBloc>().add(LoadProducts());
        context.read<ShopBloc>().add(LoadShopEvent());
        context.read<ReportsBloc>().add(LoadReportsEvent());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('بازگردانی با موفقیت انجام شد ✓'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در بازگردانی: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _MoreItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _MoreItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });
}
