import 'package:depir/core/widgets/input_label.dart';
import 'package:depir/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
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
  final ScreenshotController _screenshotController = ScreenshotController();
  String _name = '';
  String _barcode = '';
  double _price = 0.0;
  int _stock = 0;
  int _lowStockThreshold = 2;
  ProductUnit _unit = ProductUnit.piece;
  bool _barcodeGenerated = false;
  final _priceController = TextEditingController();
final _priceFormatter = NumberFormat('#,###', 'en_US');
final _nameController = TextEditingController();
  @override
void initState() {
  super.initState();
  _priceController.addListener(() {
    final text = _priceController.text.replaceAll(',', '');
    if (text.isEmpty) return;
    final number = int.tryParse(text);
    if (number == null) return;
    final formatted = _priceFormatter.format(number);
    if (_priceController.text != formatted) {
      _priceController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  });
}

@override
void dispose() {
  _priceController.dispose();
  _nameController.dispose();
  super.dispose();
}
  void _scanBarcode() async {
    final result = await context.push<String>('/scanner');
    if (result != null && result.isNotEmpty) {
      setState(() {
        _barcode = result;
        _barcodeGenerated = false;
    }
  }

  void _generateBarcode() {
    final generated = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _barcode = generated;
      _barcodeGenerated = true;
    });
  }

  Future<void> _saveBarcodeToGallery() async {
    if (_barcode.isEmpty) return;

    final status = await Permission.storage.request();
    if (!status.isGranted) {
      final photos = await Permission.photos.request();
      if (!photos.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('دسترسی به گالری داده نشد!'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    try {
      final image = await _screenshotController.captureFromWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _name.isNotEmpty ? _name : 'کالا',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: _barcode,
                  width: 280,
                  height: 100,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _barcode,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
        pixelRatio: 3.0,
      );

      await Gal.putImageBytes(image, album: 'دپیر');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('بارکد در گالری ذخیره شد ✓'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        unit: _unit,
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
          title: const Text(
            'افزودن کالا',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.qr_code_scanner,
                              color: AppTheme.primaryColor),
                          onPressed: _scanBarcode,
                          padding: const EdgeInsets.all(14),
                          tooltip: 'اسکن بارکد',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.auto_awesome,
                              color: Colors.green),
                          onPressed: _nameController.text.trim().isEmpty ? null : _generateBarcode,
                          padding: const EdgeInsets.all(14),
                          tooltip: 'ساخت بارکد خودکار',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'برای کالای بدون بارکد روی ✨ بزنید',
                    style: TextStyle(fontSize: 12, color: Color(0xFF4C669A)),
                  ),

                  if (_barcodeGenerated && _barcode.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'بارکد ساخته شد',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Screenshot(
                            controller: _screenshotController,
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(12),
                              child: BarcodeWidget(
                                barcode: Barcode.code128(),
                                data: _barcode,
                                width: 250,
                                height: 80,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _saveBarcodeToGallery,
                              icon: const Icon(Icons.save_alt),
                              label: const Text('ذخیره در گالری'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green,
                                side: const BorderSide(color: Colors.green),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
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
                  const SizedBox(height: 24),

                  
const InputLabel(text: 'قیمت (ریال)'),
TextFormField(
  controller: _priceController,
  keyboardType: TextInputType.number,
  textDirection: TextDirection.ltr,
  decoration: const InputDecoration(hintText: '0'),
  validator: (value) {
    if (value == null || value.isEmpty) return 'لطفاً قیمت را وارد کنید';
    final clean = value.replaceAll(',', '');
    if (double.tryParse(clean) == null) return 'عدد معتبر وارد کنید';
    return null;
  },
  onSaved: (value) => _price = double.parse(value!.replaceAll(',', '')),
),
                  const SizedBox(height: 24),

                  const InputLabel(text: 'تعداد موجودی'),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(hintText: '0'),
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
            icon: Icons.add_circle,
            label: 'افزودن کالا',
          ),
        ),
      ),
    );
  }
}
