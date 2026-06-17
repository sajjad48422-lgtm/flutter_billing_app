import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/billing/presentation/pages/home_page.dart';
import '../../../features/product/presentation/pages/product_list_page.dart';
import '../../../features/product/presentation/bloc/product_bloc.dart';
import '../../../features/reports/presentation/pages/reports_page.dart';
import '../../../features/more/presentation/pages/more_page.dart';
import '../../../features/sales/presentation/bloc/reports_bloc.dart';
import '../../../core/theme/app_theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ProductListPage(),
    ReportsPage(),
    MorePage(),
  ];

  void _onTabTapped(int index) {
    if (index == 1 && _currentIndex != 1) {
      // به‌روزرسانی موجودی کالاها پس از احتمالاً ثبت فروش
      context.read<ProductBloc>().add(LoadProducts());
    }
    if (index == 2 && _currentIndex != 2) {
      // Reload reports when switching to reports tab
      context.read<ReportsBloc>().add(LoadReportsEvent());
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.qr_code_scanner_outlined, Icons.qr_code_scanner, 'فروش'),
              _navItem(1, Icons.inventory_2_outlined, Icons.inventory_2, 'کالاها'),
              _navItem(2, Icons.bar_chart_outlined, Icons.bar_chart, 'گزارشات'),
              _navItem(3, Icons.more_horiz, Icons.more_horiz, 'بیشتر'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: isActive
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(activeIcon, color: Colors.white, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              )
            : Icon(icon, color: Colors.grey[400], size: 24),
      ),
    );
  }
}
