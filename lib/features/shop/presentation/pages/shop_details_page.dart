import 'dart:io';
import 'package:depir/core/widgets/input_label.dart';
import 'package:depir/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/shop.dart';
import '../bloc/shop_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({super.key});

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _phoneController;
  late TextEditingController _upiController;
  late TextEditingController _footerController;
  String _logoPath = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _address1Controller = TextEditingController();
    _address2Controller = TextEditingController();
    _phoneController = TextEditingController();
    _upiController = TextEditingController();
    _footerController = TextEditingController();
    context.read<ShopBloc>().add(LoadShopEvent());
  }

  void _updateControllers(Shop shop) {
    if (_nameController.text.isEmpty && shop.name.isNotEmpty) {
      _nameController.text = shop.name;
      _address1Controller.text = shop.addressLine1;
      _address2Controller.text = shop.addressLine2;
      _phoneController.text = shop.phoneNumber;
      _upiController.text = shop.upiId;
      _footerController.text = shop.footerText;
      setState(() {
        _logoPath = shop.logoPath;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _phoneController.dispose();
    _upiController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _logoPath = image.path;
      });
    }
  }

  void _saveShop() {
    if (_formKey.currentState!.validate()) {
      final shop = Shop(
        name: _nameController.text,
        addressLine1: _address1Controller.text,
        addressLine2: _address2Controller.text,
        phoneNumber: _phoneController.text,
        upiId: _upiController.text,
        footerText: _footerController.text,
        logoPath: _logoPath,
      );
      context.read<ShopBloc>().add(UpdateShopEvent(shop));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اطلاعات فروشگاه'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_right,
                size: 28, color: Theme.of(context).primaryColor),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocConsumer<ShopBloc, ShopState>(
          listener: (context, state) {
            if (state is ShopLoaded) {
              _updateControllers(state.shop);
            } else if (state is ShopOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('اطلاعات با موفقیت ذخیره شد ✓'),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
            } else if (state is ShopError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          buildWhen: (previous, current) =>
              current is ShopLoading || current is ShopLoaded,
          builder: (context, state) {
            if (state is ShopLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // لوگو فروشگاه
                    Center(
                      child: GestureDetector(
                        onTap: _pickLogo,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryColor
                                  .withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: _logoPath.isNotEmpty &&
                                  File(_logoPath).existsSync()
                              ? ClipOval(
                                  child: Image.file(
                                    File(_logoPath),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      color: AppTheme.primaryColor,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'لوگو فروشگاه',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'برای تغییر لوگو روی تصویر بزنید',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[400]),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'اطلاعات عمومی',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: AppTheme.primaryColor
                            .withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'این اطلاعات روی رسیدهای چاپی و دیجیتال نمایش داده می‌شود.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 24),

                    const InputLabel(text: 'نام فروشگاه'),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'مثلاً: سوپرمارکت ایران',
                      validator: AppValidators.required('الزامی'),
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'آدرس خط ۱'),
                    _buildTextField(
                      controller: _address1Controller,
                      hint: 'خیابان، کوچه',
                      validator: AppValidators.required('الزامی'),
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'آدرس خط ۲ (اختیاری)'),
                    _buildTextField(
                      controller: _address2Controller,
                      hint: 'شهر - کد پستی',
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'شماره تلفن'),
                    _buildTextField(
                      controller: _phoneController,
                      hint: '09123456789',
                      keyboardType: TextInputType.phone,
                      validator: AppValidators.required('الزامی'),
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'شبکه‌های اجتماعی (اختیاری)'),
                    _buildTextField(
                      controller: _upiController,
                      hint: 'مثلاً: @depir.ir',
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const InputLabel(text: 'متن پایین رسید'),
                        Text(
                          'حداکثر ۶۰ کاراکتر',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                    _buildTextField(
                      controller: _footerController,
                      hint: 'مثلاً: با تشکر از خرید شما',
                      maxLines: 2,
                      maxLength: 60,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          child: PrimaryButton(
            onPressed: _saveShop,
            icon: Icons.save,
            label: 'ذخیره اطلاعات',
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
      ),
    );
  }
}
