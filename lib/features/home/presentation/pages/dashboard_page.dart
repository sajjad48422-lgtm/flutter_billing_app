import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../sales/presentation/bloc/reports_bloc.dart';

/// صفحه خانه (داشبورد اصلی اپ).
/// اولین صفحه‌ای که کاربر با باز کردن اپ می‌بیند.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(LoadDashboardEvent());
  }

  Future<void> _onRefresh() async {
    context.read<ProductBloc>().add(LoadProducts());
    context.read<ReportsBloc>().add(LoadDashboardEvent());
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: _onRefresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildStatsGrid(context),
              const SizedBox(height: 20),
              _buildAlerts(context),
              const SizedBox(height: 20),
              _buildWeeklyChart(context),
              const SizedBox(height: 24),
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── سربرگ: سلام + نام فروشگاه ───────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        final shopName = state is ShopLoaded && state.shop.name.isNotEmpty
            ? state.shop.name
            : 'دپیر';
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سلام، 👋 $shopName',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'به فروشگاه خود خوش آمدید',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => context.push('/shop'),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.storefront_outlined,
                    color: AppTheme.primaryColor, size: 26),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── ۴ کارت آماری ────────────────────────────────────────────────
  Widget _buildStatsGrid(BuildContext context) {
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, reportsState) {
        return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, productState) {
            final products = productState.products;
            final outOfStockCount = products.where((p) => p.isOutOfStock).length;
            final isLoading =
                reportsState.dashboardStatus == DashboardStatus.loading ||
                    reportsState.dashboardStatus == DashboardStatus.initial;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.account_balance_wallet_outlined,
                        iconBg: const Color(0xFFD9F5EA),
                        iconColor: const Color(0xFF00B377),
                        title: 'فروش امروز',
                        value: isLoading
                            ? '...'
                            : CurrencyFormatter.format(
                                reportsState.todayRevenue,
                                showUnit: false),
                        unit: CurrencyFormatter.unitName,
                        growthPercent: reportsState.revenueGrowthPercent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        icon: Icons.show_chart,
                        iconBg: AppTheme.primaryColor.withValues(alpha: 0.12),
                        iconColor: AppTheme.primaryColor,
                        title: 'سود امروز',
                        value: isLoading
                            ? '...'
                            : CurrencyFormatter.format(
                                reportsState.todayProfit,
                                showUnit: false),
                        unit: CurrencyFormatter.unitName,
                        growthPercent: reportsState.profitGrowthPercent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.receipt_long_outlined,
                        iconBg: const Color(0xFFFFEAD2),
                        iconColor: const Color(0xFFFF9F40),
                        title: 'تعداد فاکتور امروز',
                        value: isLoading
                            ? '...'
                            : '${reportsState.todayOrderCount}'
                                .toPersianDigit(),
                        unit: 'فاکتور',
                        deltaCount: reportsState.orderCountDelta,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        icon: Icons.inventory_2_outlined,
                        iconBg: const Color(0xFFDCE6FF),
                        iconColor: const Color(0xFF3D6BFF),
                        title: 'تعداد کالاها',
                        value: '${products.length}'.toPersianDigit(),
                        unit: 'کالا',
                        footerText: outOfStockCount > 0
                            ? '$outOfStockCount کالا ناموجود'
                                .toPersianDigit()
                            : null,
                        footerDotColor:
                            outOfStockCount > 0 ? Colors.red : null,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    required String unit,
    double? growthPercent,
    int? deltaCount,
    String? footerText,
    Color? footerDotColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          if (growthPercent != null)
            _growthBadge(growthPercent)
          else if (deltaCount != null && deltaCount != 0)
            _deltaBadge(deltaCount)
          else if (footerText != null)
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: footerDotColor ?? Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    footerText,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _growthBadge(double percent) {
    final isUp = percent >= 0;
    final color = isUp ? const Color(0xFF00B377) : Colors.red;
    final sign = isUp ? '+' : '';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12, color: color),
        const SizedBox(width: 2),
        Text(
          '$sign${percent.toStringAsFixed(0)}٪ نسبت به دیروز'
              .toPersianDigit(),
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _deltaBadge(int delta) {
    final isUp = delta >= 0;
    final color = isUp ? const Color(0xFF00B377) : Colors.red;
    final sign = isUp ? '+' : '';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12, color: color),
        const SizedBox(width: 2),
        Text(
          '$sign$delta فاکتور نسبت به دیروز'.toPersianDigit(),
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ── هشدارها (موجودی کم / ناموجود) ───────────────────────────────
  Widget _buildAlerts(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final lowStockCount =
            state.products.where((p) => p.isLowStock).length;
        final outOfStockCount =
            state.products.where((p) => p.isOutOfStock).length;

        if (lowStockCount == 0 && outOfStockCount == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'هشدارها',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              if (lowStockCount > 0)
                _alertRow(
                  context: context,
                  color: Colors.orange,
                  bgColor: const Color(0xFFFFF6E5),
                  title:
                      '$lowStockCount کالا در آستانه اتمام موجودی'
                          .toPersianDigit(),
                  subtitle: 'برای مشاهده کالاها کلیک کنید',
                ),
              if (lowStockCount > 0 && outOfStockCount > 0)
                const SizedBox(height: 8),
              if (outOfStockCount > 0)
                _alertRow(
                  context: context,
                  color: Colors.red,
                  bgColor: const Color(0xFFFFEAEA),
                  title: '$outOfStockCount کالا ناموجود'
                      .toPersianDigit(),
                  subtitle: 'برای مشاهده کالاها کلیک کنید',
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _alertRow({
    required BuildContext context,
    required Color color,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => DashboardTabRequest.goToProducts(context),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.chevron_left, color: Colors.grey[500], size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.warning_amber_rounded, color: color, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ── نمودار ۷ روز گذشته ─────────────────────────────────────────
  Widget _buildWeeklyChart(BuildContext context) {
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        final entries = state.weeklyRevenue.entries.toList();
        final maxVal = entries.isEmpty
            ? 0.0
            : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'فروش ۷ روز گذشته',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 16),
              if (entries.isEmpty)
                const SizedBox(
                  height: 140,
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                SizedBox(
                  height: 150,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: entries.map((entry) {
                      final ratio = maxVal > 0 ? entry.value / maxVal : 0.0;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                height: (ratio * 100).clamp(4, 100),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                entry.key,
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => DashboardTabRequest.goToReports(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chevron_left,
                          size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'مشاهده گزارش کامل',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── عملیات سریع ──────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 4, bottom: 12),
          child: Text(
            'عملیات سریع',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _quickAction(
                icon: Icons.point_of_sale_outlined,
                bg: AppTheme.primaryColor.withValues(alpha: 0.12),
                color: AppTheme.primaryColor,
                label: 'فروش جدید',
                onTap: () => DashboardTabRequest.goToSales(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _quickAction(
                icon: Icons.add_box_outlined,
                bg: const Color(0xFFFFEAD2),
                color: const Color(0xFFFF9F40),
                label: 'افزودن کالا',
                onTap: () => context.push('/products/add'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _quickAction(
                icon: Icons.inventory_2_outlined,
                bg: const Color(0xFFDCE6FF),
                color: const Color(0xFF3D6BFF),
                label: 'کالاها',
                onTap: () => DashboardTabRequest.goToProducts(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _quickAction(
                icon: Icons.bar_chart_outlined,
                bg: const Color(0xFFD9F5EA),
                color: const Color(0xFF00B377),
                label: 'گزارشات',
                onTap: () => DashboardTabRequest.goToReports(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required Color bg,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// کلاسی برای ارسال درخواست تغییر تب از داشبورد به MainShell.
/// چون MainShell با IndexedStack مدیریت می‌شود، اینجا یک InheritedWidget
/// سبک برای دسترسی به تابع تغییر تب فراهم می‌کنیم.
class DashboardTabRequest {
  static void goToSales(BuildContext context) =>
      DashboardTabController.of(context)?.changeTab(0);
  static void goToProducts(BuildContext context) =>
      DashboardTabController.of(context)?.changeTab(1);
  static void goToReports(BuildContext context) =>
      DashboardTabController.of(context)?.changeTab(3);
}

class DashboardTabController extends InheritedWidget {
  final void Function(int index) changeTab;

  const DashboardTabController({
    super.key,
    required this.changeTab,
    required super.child,
  });

  static DashboardTabController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DashboardTabController>();
  }

  @override
  bool updateShouldNotify(DashboardTabController oldWidget) => false;
}
