import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _barcode = '';
  double _price = 0.0;
  int _stock = 0;
  int _lowStockThreshold = 2;

  void _scanBarcode() async {
    final result = await context.push<String>('/scanner');
    if (result != null && result.isNotEmpty) {
      setState(() {
        _barcode = result;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final productState = context.read<ProductBloc>().state;
      final existingProduct = productState.products
          .where((p) => p.barcode == _barcode)
          .firstOrNull;

      if (existingProduct != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('کالا با بارکد "$_barcode" قبلاً ثبت شده!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final product = Product(
        id: const Uuid().v4(),
        name: _name,
        barcode: _barcode,
        price: _price,
        stock: _stock,
        lowStockThreshold: _lowStockThreshold,
      );

      context.read<ProductBloc>().add(AddProduct(product));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_right,
                size: 28, color: Theme.of(context).primaryColor),
            onPressed: () => context.pop(),
          ),
          title: const Text('افزودن کالا',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // بارکد
                  const InputLabel(text: 'بارکد'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: ValueKey(_barcode),
                          initialValue: _barcode,
                          textDirection: TextDirection.ltr,
                          decoration: const InputDecoration(
                            hintText: 'اسکن یا وارد کنید',
                          ),
                          validator: AppValidators.required(
                              'لطفاً بارکد را وارد کنید'),
                          onSaved: (value) => _barcode = value!,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.qr_code_scanner,
                              color: AppTheme.primaryColor),
                          onPressed: _scanBarcode,
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'برای اسکن بارکد روی آیکون بزنید',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF4C669A)),
                  ),
                  const SizedBox(height: 24),

                  // نام کالا
                  const InputLabel(text: 'نام کالا'),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'مثلاً: برنج ایرانی',
                    ),
                    validator:
                        AppValidators.required('لطفاً نام کالا را وارد کنید'),
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 24),

                  // قیمت
                  const InputLabel(text: 'قیمت (تومان)'),
                  TextFormField(
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      hintText: '0',
                    ),
                    validator: AppValidators.price,
                    onSaved: (value) => _price = double.parse(value!),
                  ),
                  const SizedBox(height: 24),

                  // موجودی
                  const InputLabel(text: 'تعداد موجودی'),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      hintText: '0',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لطفاً موجودی را وارد کنید';
                      }
                      if (int.tryParse(value) == null) {
                        return 'عدد صحیح وارد کنید';
                      }
                      return null;
                    },
                    onSaved: (value) => _stock = int.parse(value!),
                  ),
                  const SizedBox(height: 24),

                  // حد هشدار موجودی
                  const InputLabel(text: 'هشدار کمبود موجودی'),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    initialValue: '2',
                    decoration: const InputDecoration(
                      hintText: '2',
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
                    onSaved: (value) => _lowStockThreshold =
                        int.tryParse(value ?? '2') ?? 2,
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: PrimaryButton(
          onPressed: _submit,
          icon: Icons.add_circle,
          label: 'افزودن کالا',
        ),
      ),
    );
  }
}