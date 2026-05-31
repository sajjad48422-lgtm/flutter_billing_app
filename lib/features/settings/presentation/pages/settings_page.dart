import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_settings/app_settings.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/printer_bloc.dart';
import '../bloc/printer_event.dart';
import '../bloc/printer_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<PrinterBloc>().add(InitPrinterEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تنظیمات',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_right,
                size: 28, color: Theme.of(context).primaryColor),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // پروفایل فروشگاه
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: 32, horizontal: 24),
                child: BlocBuilder<ShopBloc, ShopState>(
                  builder: (context, state) {
                    String shopName = 'فروشگاه من';
                    String initials = 'ف';
                    if (state is ShopLoaded &&
                        state.shop.name.isNotEmpty) {
                      shopName = state.shop.name;
                      final parts = shopName.split(' ');
                      initials = parts
                          .take(2)
                          .map((p) =>
                              p.isNotEmpty ? p[0] : '')
                          .join('');
                      if (initials.isEmpty) initials = 'ف';
                    }

                    return Column(
                      children: [
                 Container(
  width: 96,
  height: 96,
  decoration: BoxDecoration(
    color: AppTheme.primaryColor,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: AppTheme.primaryColor
            .withValues(alpha: 0.2),
        blurRadius: 15,
        spreadRadius: 5,
      )
    ],
  ),
  child: (state is ShopLoaded &&
          state.shop.logoPath.isNotEmpty &&
          File(state.shop.logoPath).existsSync())
      ? ClipOval(
          child: Image.file(
            File(state.shop.logoPath),
            fit: BoxFit.cover,
            width: 96,
            height: 96,
          ),
        )
      : Align(
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
                        const SizedBox(height: 16),
                        Text(
                          shopName,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  },
                ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 48),

              // بخش مدیریت
              _buildSectionHeader('مدیریت'),
              _buildListGroup(
                children: [
                  _buildListItem(
                    icon: Icons.qr_code_scanner,
                    title: 'کالاها',
                    subtitle: 'مدیریت موجودی و بارکدها',
                    onTap: () => context.push('/products'),
                  ),
                  _buildDivider(),
                  _buildListItem(
                    icon: Icons.storefront,
                    title: 'اطلاعات فروشگاه',
                    subtitle: 'ویرایش مشخصات کسب‌وکار',
                    onTap: () => context.push('/shop'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // بخش سخت‌افزار
              _buildSectionHeader('سخت‌افزار'),
              BlocConsumer<PrinterBloc, PrinterState>(
                listener: (context, state) {
                  if (state.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage!),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state.status == PrinterStatus.connected) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('پرینتر متصل شد ✓'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return _buildListGroup(
                    children: [
                      _buildListItem(
                        icon: Icons.print,
                        title: 'پرینتر',
                        subtitleWidget: Row(
                          children: [
                            Text(
                              state.connectedMac != null
                                  ? (state.connectedName ??
                                      'پرینتر متصل است')
                                  : 'پرینتر متصل نیست',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500]),
                            ),
                            if (state.connectedMac != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.teal[100],
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.teal[200]!),
                                ),
                                child: Text(
                                  'متصل',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal[700],
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                        trailingWidget: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (state.status ==
                                    PrinterStatus.scanning ||
                                state.status ==
                                    PrinterStatus.connecting)
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            else
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () => context
                                    .read<PrinterBloc>()
                                    .add(RefreshPrinterEvent()),
                                color: AppTheme.primaryColor,
                              ),
                            IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () {
                                AppSettings.openAppSettings(
                                    type: AppSettingsType.bluetooth);
                              },
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                child: Text(
                  'برای اتصال پرینتر جدید، روی آیکون تنظیمات بزنید و بلوتوث را جفت کنید، سپس برگردید و دکمه رفرش را بزنید.',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[500],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // بخش درباره ما
              _buildSectionHeader('درباره'),
              _buildListGroup(
                children: [
                  _buildListItem(
                    icon: Icons.info_outline,
                    title: 'درباره دپیر',
                    subtitle: 'اطلاعات برنامه و سازنده',
                    onTap: () => context.push('/about'),
                  ),
                  _buildDivider(),
                  _buildListItem(
                    icon: Icons.star_outline,
                    title: 'امتیاز به برنامه',
                    subtitle: 'از دپیر حمایت کنید',
                    onTap: () async {
                      final url = Uri.parse(
                          'https://cafebazaar.ir/app/com.depir.app');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildListGroup({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey[50],
        indent: 64);
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? subtitleWidget,
    Widget? trailingWidget,
    IconData? trailingIcon = Icons.chevron_left,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon,
                  color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500])),
                  ],
                  if (subtitleWidget != null) ...[
                    const SizedBox(height: 4),
                    subtitleWidget,
                  ]
                ],
              ),
            ),
            if (trailingWidget != null)
              trailingWidget
            else if (trailingIcon != null)
              Icon(trailingIcon, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}