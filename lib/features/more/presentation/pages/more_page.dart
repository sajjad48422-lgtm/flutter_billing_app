import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_theme.dart';

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
          _buildSection('تنظیمات', [
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
          _buildSection('داده‌ها', [
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
          _buildSection('اطلاعات', [
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

  Widget _buildSection(String title, List<_MoreItem> items) {
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

  Future<void> _exportBackup(BuildContext context) async {
    try {
      final Map<String, dynamic> backupData = {};

      // Export all Hive boxes
      final boxNames = ['products', 'shop', 'sales_box'];
      for (final boxName in boxNames) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            final Map<String, dynamic> boxData = {};
            for (final key in box.keys) {
              boxData[key.toString()] = box.get(key).toString();
            }
            backupData[boxName] = boxData;
          }
        } catch (_) {}
      }

      backupData['backup_date'] = DateTime.now().toIso8601String();
      backupData['version'] = '1.0';

      final jsonStr = jsonEncode(backupData);
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
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
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

      if (context.mounted) {
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
