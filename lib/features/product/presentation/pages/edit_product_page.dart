import 'package:depir/core/widgets/input_label.dart';
import 'package:depir/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late double _price;
  late double _purchasePrice;
  late int _stock;
  late int _lowStockThreshold;
  late ProductUnit _unit;

  final _priceFormatter = NumberFormat('#,###', 'en_US');
  late final TextEditingController _priceController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _price = widget.product.price;
    _purchasePrice = widget.product.purchasePrice;
    _stock = widget.product.stock;
    _lowStockThreshold = widget.product.lowStockThreshold;
    _unit = widget.product.unit;

    _priceController =
        TextEditingController(text: _price.toStringAsFixed(0));
    _purchasePriceController = TextEditingController(
        text: _purchasePrice > 0 ? _purchasePrice.toStringAsFixed(0) : '');
    _stockController = TextEditingController(text: _stock.toString());

    _priceController.addListener(() => _formatPriceField(_priceController));
    _purchasePriceController
        .addListener(() => _formatPriceField(_purchasePriceController));
  }

  void _formatPriceField(TextEditingController controller) {
    final text = controller.text.replaceAll(',', '');
    if (text.isEmpty) return;
    final number = int.tryParse(text);
    if (number == null) return;
    final formatted = _priceFormatter.format(number);
    if (controller.text != formatted) {
      controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _purchasePriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedProduct = Product(
        id: widget.product.id,
        name: _name,
        barcode: widget.product.barcode,
        price: _price,
        purchasePrice: _purchasePrice,
        stock: _stock,
        lowStockThreshold: _lowStockThreshold,
        unit: _unit,
      );

      context.read<ProductBloc>().add(UpdateProduct(updatedProduct));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeightBased = _unit == ProductUnit.kg ||
        _unit == ProductUnit.gram ||
        _unit == ProductUnit.liter ||
        _unit == ProductUnit.meter;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_right,
                size: 32, color: Theme.of(context).primaryColor),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'ویرایش کالا',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_scanner,
                            color: AppTheme.primaryColor, size: 28),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'بارکد',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.product.barcode,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── نام کالا ───────────────────────────────────
                  const InputLabel(text: 'نام کالا'),
                  TextFormField(
                    initialValue: _name,
                    validator:
                        AppValidators.required('لطفاً نام کالا را وارد کنید'),
                    onSaved: (value) => _name = value!,
                  ),

                  // ── واحد سنجش ──────────────────────────────────
                  const SizedBox(height: 24),
                  const InputLabel(text: 'واحد سنجش'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ProductUnit>(
                        value: _unit,
                        isExpanded: true,
                        items: ProductUnit.values.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit.label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _unit = value);
                          }
                        },
                      ),
                    ),
                  ),

                  // ── قیمت فروش ──────────────────────────────────
                  const SizedBox(height: 24),
                  const InputLabel(text: 'قیمت فروش (ریال)'),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لطفاً قیمت فروش را وارد کنید';
                      }
                      final clean = value.replaceAll(',', '');
                      if (double.tryParse(clean) == null) {
                        return 'عدد معتبر وارد کنید';
                      }
                      return null;
                    },
                    onSaved: (value) =>
                        _price = double.parse(value!.replaceAll(',', '')),
                  ),

                  // ── قیمت خرید ──────────────────────────────────
                  const SizedBox(height: 24),
                  const InputLabel(text: 'قیمت خرید (ریال)'),
                  TextFormField(
                    controller: _purchasePriceController,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      hintText: '0',
                      helperText: 'برای محاسبه سود و زیان استفاده می‌شود',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      final clean = value.replaceAll(',', '');
                      if (double.tryParse(clean) == null) {
                        return 'عدد معتبر وارد کنید';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      if (value == null || value.isEmpty) {
                        _purchasePrice = 0;
                      } else {
                        _purchasePrice =
                            double.parse(value.replaceAll(',', ''));
                      }
                    },
                  ),

                  // ── موجودی ─────────────────────────────────────
                  const SizedBox(height: 24),
                  InputLabel(text: _unit.stockLabel),
                  TextFormField(
                    controller: _stockController,
                    keyboardType: isWeightBased
                        ? const TextInputType.numberWithOptions(decimal: true)
                        : TextInputType.number,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: _unit.stockHint,
                      suffixText: isWeightBased ? _unit.label : null,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لطفاً موجودی را وارد کنید';
                      }
                      if (isWeightBased) {
                        if (double.tryParse(value) == null) {
                          return 'عدد معتبر وارد کنید';
                        }
                      } else {
                        if (int.tryParse(value) == null) {
                          return 'عدد صحیح وارد کنید';
                        }
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _stock = isWeightBased
                          ? (double.tryParse(value ?? '0') ?? 0).round()
                          : int.tryParse(value ?? '0') ?? 0;
                    },
                  ),

                  // ── هشدار کمبود ────────────────────────────────
                  const SizedBox(height: 24),
                  const InputLabel(text: 'هشدار کمبود موجودی'),
                  TextFormField(
                    initialValue: _lowStockThreshold.toString(),
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      helperText:
                          'وقتی موجودی به این عدد رسید هشدار داده می‌شود',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      if (int.tryParse(value) == null) {
                        return 'عدد صحیح وارد کنید';
                      }
                      return null;
                    },
                    onSaved: (value) =>
                        _lowStockThreshold = int.tryParse(value ?? '2') ?? 2,
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: PrimaryButton(
            onPressed: _submit,
            icon: Icons.save,
            label: 'ذخیره تغییرات',
          ),
        ),
      ),
    );
  }
}
