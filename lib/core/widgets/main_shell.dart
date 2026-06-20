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
const int _kTabCount = 5;

/// ارتفاع کل ناحیه‌ی نوار (شامل فاصله‌ی بالای نوار برای جا‌دادن حباب برآمده)
const double _kNavAreaHeight = 78;

/// ارتفاع خودِ نوار سفید
const double _kBarHeight = 64;

/// قطر دایره‌ی شناور فعال
const double _kBubbleSize = 56;

const Duration _kAnimDuration = Duration(milliseconds: 300);
const Curve _kAnimCurve = Curves.easeOutCubic;

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

  final List<IconData> _icons = const [
    Icons.qr_code_scanner_outlined,
    Icons.inventory_2_outlined,
    Icons.home_rounded,
    Icons.bar_chart_outlined,
    Icons.more_horiz,
  ];

  final List<IconData> _activeIcons = const [
    Icons.qr_code_scanner,
    Icons.inventory_2,
    Icons.home_rounded,
    Icons.bar_chart,
    Icons.more_horiz,
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
        top: false,
        child: SizedBox(
          height: _kNavAreaHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double barWidth = constraints.maxWidth;
              final double slotWidth = barWidth / _kTabCount;
              final double centerX =
                  slotWidth * _currentIndex + slotWidth / 2;
              // فاصله‌ی بالای نوار سفید تا بالای کادر (جا برای برآمدگی حباب)
              const double barTop = _kNavAreaHeight - _kBarHeight;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // نوار سفید با فرورفتگی (notch) متحرک بالای آیتم فعال
                  Positioned(
                    top: barTop,
                    left: 0,
                    right: 0,
                    height: _kBarHeight,
                    child: AnimatedNotchedBar(
                      notchCenterX: centerX,
                      duration: _kAnimDuration,
                      curve: _kAnimCurve,
                    ),
                  ),

                  // آیکون‌های ثابت (غیر فعال) روی نوار
                  Positioned(
                    top: barTop,
                    left: 0,
                    right: 0,
                    height: _kBarHeight,
                    child: Row(
                      children: List.generate(_kTabCount, (index) {
                        final isActive = index == _currentIndex;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _onTabTapped(index),
                            behavior: HitTestBehavior.opaque,
                            child: Center(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 180),
                                opacity: isActive ? 0.0 : 1.0,
                                child: Icon(
                                  _icons[index],
                                  color: Colors.grey[400],
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // دایره‌ی آبی شناور که بین تب‌ها اسلاید می‌کند
                  AnimatedPositioned(
                    duration: _kAnimDuration,
                    curve: _kAnimCurve,
                    top: barTop - _kBubbleSize / 2 + 10,
                    left: centerX - _kBubbleSize / 2,
                    width: _kBubbleSize,
                    height: _kBubbleSize,
                    child: GestureDetector(
                      onTap: () => _onTabTapped(_currentIndex),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _kNavActiveColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: _kNavActiveColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            _activeIcons[_currentIndex],
                            key: ValueKey<int>(_currentIndex),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// نوار پایین سفید با یک فرورفتگی (notch) نیم‌دایره‌ای که موقعیتش
/// با انیمیشن نرم به مرکز آیتم فعال جدید جا‌به‌جا می‌شود.
///
/// هر بار که notchCenterX عوض شود، didUpdateWidget مقدار قبلی را
/// به‌عنوان نقطه‌ی شروعِ یک Tween تازه ذخیره می‌کند، بنابراین حتی اگر
/// کاربر سریع و پشت‌سرهم چند تب را بزند، حرکتِ notch پیوسته و طبیعی
/// باقی می‌ماند (نه این‌که هر بار از صفر شروع شود).
class AnimatedNotchedBar extends StatefulWidget {
  final double notchCenterX;
  final Duration duration;
  final Curve curve;

  const AnimatedNotchedBar({
    super.key,
    required this.notchCenterX,
    required this.duration,
    required this.curve,
  });

  @override
  State<AnimatedNotchedBar> createState() => _AnimatedNotchedBarState();
}

class _AnimatedNotchedBarState extends State<AnimatedNotchedBar> {
  late double _previousX = widget.notchCenterX;

  @override
  void didUpdateWidget(AnimatedNotchedBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _previousX = oldWidget.notchCenterX;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: widget.duration,
      curve: widget.curve,
      tween: Tween<double>(begin: _previousX, end: widget.notchCenterX),
      builder: (context, value, child) {
        return CustomPaint(
          painter: _NotchedBarPainter(notchCenterX: value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _NotchedBarPainter extends CustomPainter {
  final double notchCenterX;

  // شعاع فرورفتگی کمی بزرگ‌تر از نیم‌قطر حباب تا حلقه‌ی سفید دور آن دیده شود
  static const double _notchRadius = _kBubbleSize / 2 + 10;
  static const double _barRadius = 28;

  _NotchedBarPainter({required this.notchCenterX});

  @override
  void paint(Canvas canvas, Size size) {
    final RRect barRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(_barRadius),
    );
    final Path barPath = Path()..addRRect(barRRect);

    // دایره‌ی فرورفتگی، مرکزش روی خط بالایی نوار قرار دارد تا یک
    // نیم‌هلال فرورفته در بالای نوار ایجاد شود.
    final Path notchPath = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(notchCenterX, 0),
          radius: _notchRadius,
        ),
      );

    final Path finalPath = Path.combine(
      PathOperation.difference,
      barPath,
      notchPath,
    );

    canvas.drawShadow(
      Path()..addRRect(barRRect),
      Colors.black.withValues(alpha: 0.12),
      10,
      false,
    );

    canvas.drawPath(finalPath, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _NotchedBarPainter oldDelegate) {
    return oldDelegate.notchCenterX != notchCenterX;
  }
}
