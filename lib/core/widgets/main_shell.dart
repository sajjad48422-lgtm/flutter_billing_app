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
const Color _kNavActiveColor = Color(0xFF2F80ED);
const Color _kNavPillColor = Color(0xFFEAF2FE);

/// ترتیب تب‌ها: فروش، کالاها، خانه، گزارشات، بیشتر
const int _kSalesTab = 0;
const int _kProductsTab = 1;
const int _kHomeTab = 2;
const int _kReportsTab = 3;
const int _kMoreTab = 4;
const int _kTabCount = 5;

const Duration _kAnimDuration = Duration(milliseconds: 320);
const Curve _kAnimCurve = Curves.easeOutCubic;

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = _kHomeTab;

  // توجه: دیگر const نیست، چون باید در هر build بر اساس تب فعلی به
  // HomePage بگوییم آیا تب فروش الان فعال است یا نه (برای مدیریت دوربین).
  // این یک getter سبک است؛ چون IndexedStack فرزندان را بر اساس type و
  // موقعیت در لیست تطبیق می‌دهد، State هر صفحه (از جمله HomePage) حتی
  // با ساخت نمونه‌ی جدید ویجت در هر build حفظ می‌شود.
  List<Widget> get _pages => [
        HomePage(isActive: _currentIndex == _kSalesTab),
        const ProductListPage(),
        const DashboardPage(),
        const ReportsPage(),
        const MorePage(),
      ];

  final List<_NavTabData> _tabs = const [
    _NavTabData(icon: Icons.qr_code_scanner_outlined, activeIcon: Icons.qr_code_scanner, label: 'فروش'),
    _NavTabData(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: 'کالاها'),
    _NavTabData(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'خانه'),
    _NavTabData(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'گزارشات'),
    _NavTabData(icon: Icons.more_horiz, activeIcon: Icons.more_horiz, label: 'بیشتر'),
  ];

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    if (index == _kProductsTab) {
      context.read<ProductBloc>().add(LoadProducts());
    }
    if (index == _kHomeTab) {
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
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: _SlidingPillNavBar(
              tabs: _tabs,
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTabData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavTabData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// نوار پایین با یک «بیضی» پس‌زمینه که زیر آیتم فعال، با انیمیشن نرم
/// به موقعیت تب جدید می‌لغزد. به‌جای محاسبه‌ی دستی پیکسل، هر آیتم با
/// Expanded عرض مساوی می‌گیرد و موقعیت بیضی هم با AnimatedAlign بر
/// اساس کسری از عرض (fraction بین -1 و 1) تعیین می‌شود — این یعنی
/// منطق همیشه با چیدمان واقعی Row هماهنگ است و امکان «جابه‌جا بودن
/// دایره با آیکون واقعی» وجود ندارد.
class _SlidingPillNavBar extends StatelessWidget {
  final List<_NavTabData> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SlidingPillNavBar({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int count = tabs.length;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // بیضی پس‌زمینه‌ی متحرک
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            child: AnimatedAlign(
              duration: _kAnimDuration,
              curve: _kAnimCurve,
              alignment: _alignmentForIndex(currentIndex, count),
              child: FractionallySizedBox(
                widthFactor: 1 / count,
                heightFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: _kNavPillColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),

          // آیتم‌های نوار
          Row(
            children: List.generate(count, (index) {
              final tab = tabs[index];
              final bool isActive = index == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: SizedBox(
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          duration: _kAnimDuration,
                          curve: _kAnimCurve,
                          scale: isActive ? 1.0 : 0.92,
                          child: Icon(
                            isActive ? tab.activeIcon : tab.icon,
                            size: 22,
                            color: isActive ? _kNavActiveColor : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedDefaultTextStyle(
                          duration: _kAnimDuration,
                          curve: _kAnimCurve,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                            color: isActive ? _kNavActiveColor : Colors.grey[400],
                          ),
                          child: Text(tab.label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// تبدیل ایندکس تب به Alignment افقی بین -1.0 تا 1.0.
  ///
  /// نکته‌ی مهم: Alignment همیشه بر اساس محور فیزیکی مطلق صفحه است
  /// (x=-1 یعنی چپِ فیزیکی صفحه، x=+1 یعنی راستِ فیزیکی صفحه) و خودش
  /// با Directionality جابه‌جا نمی‌شود. اما چون کل اپ RTL است، Row این
  /// نوار فرزندانش (یعنی آیتم‌های تب) را از راست به چپ می‌چیند — یعنی
  /// index=0 («فروش») در راست‌ترین موقعیت فیزیکی رندر می‌شود، نه چپ‌ترین.
  /// پس باید همان index را در محاسبه‌ی Alignment معکوس کنیم تا بیضی با
  /// موقعیت واقعی رندرشده‌ی هر آیتم (نه با شماره‌ی index خامش) منطبق شود.
  Alignment _alignmentForIndex(int index, int count) {
    if (count <= 1) return Alignment.center;
    final int reversedIndex = (count - 1) - index;
    final double step = 2.0 / (count - 1);
    final double x = -1.0 + (reversedIndex * step);
    return Alignment(x, 0);
  }
}
