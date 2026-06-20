import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/billing/presentation/pages/home_page.dart';
import '../../../features/product/presentation/pages/product_list_page.dart';
import '../../../features/product/presentation/bloc/product_bloc.dart';
import '../../../features/reports/presentation/pages/reports_page.dart';
import '../../../features/more/presentation/pages/more_page.dart';
import '../../../features/home/presentation/pages/dashboard_page.dart';
import '../../../features/sales/presentation/bloc/reports_bloc.dart';

/// رنگ آبی برای نمایش وضعیت فعال (هاور) در نوار پایین.
/// طبق درخواست، مستقل از رنگ بنفش اصلی برند (AppTheme.primaryColor) است.
const Color _kNavActiveColor = Color(0xFF2F80ED);

/// ترتیب تب‌ها: فروش، کالاها، خانه، گزارشات، بیشتر
/// تب «خانه» وسط‌چین و پیش‌فرض است؛ یعنی با باز کردن اپ کاربر وارد خانه می‌شود.
const int _kSalesTab = 0;
const int _kProductsTab = 1;
const int _kHomeTab = 2;
const int _kReportsTab = 3;
const int _kMoreTab = 4;

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = _kHomeTab;

  final List<Widget> _pages = const [
    HomePage(),
    ProductListPage(),
    DashboardPage(),
    ReportsPage(),
    MorePage(),
  ];

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    if (index == _kProductsTab) {
      // به‌روزرسانی موجودی کالاها پس از احتمالاً ثبت فروش
      context.read<ProductBloc>().add(LoadProducts());
    }
    if (index == _kHomeTab) {
      // به‌روزرسانی آمار داشبورد هر بار که کاربر به خانه برمی‌گردد
      context.read<ReportsBloc>().add(LoadDashboardEvent());
      context.read<ProductBloc>().add(LoadProducts());
    }
    if (index == _kReportsTab) {
      context.read<ReportsBloc>().add(LoadReportsEvent());
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return DashboardTabController(
      changeTab: _onTabTapped,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: _buildFloatingNavBar(),
      ),
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
              _navItem(_kSalesTab, Icons.qr_code_scanner_outlined,
                  Icons.qr_code_scanner, 'فروش'),
              _navItem(_kProductsTab, Icons.inventory_2_outlined,
                  Icons.inventory_2, 'کالاها'),
              _homeNavItem(),
              _navItem(_kReportsTab, Icons.bar_chart_outlined,
                  Icons.bar_chart, 'گزارشات'),
              _navItem(_kMoreTab, Icons.more_horiz, Icons.more_horiz, 'بیشتر'),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _kNavActiveColor : Colors.transparent,
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

  /// تب «خانه» در وسط نوار پایین، به‌صورت یک دکمه دایره‌ای برآمده.
  Widget _homeNavItem() {
    final isActive = _currentIndex == _kHomeTab;
    return GestureDetector(
      onTap: () => _onTabTapped(_kHomeTab),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isActive ? _kNavActiveColor : Colors.grey[100],
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: _kNavActiveColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.home_rounded,
          color: isActive ? Colors.white : Colors.grey[400],
          size: 26,
        ),
      ),
    );
  }
}
