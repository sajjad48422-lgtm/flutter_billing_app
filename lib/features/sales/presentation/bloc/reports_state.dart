part of 'reports_bloc.dart';

enum ReportsStatus { initial, loading, loaded, error }

enum DashboardStatus { initial, loading, loaded, error }

class ReportsState extends Equatable {
  // ── وضعیت تب گزارشات (بر اساس period انتخاب‌شده) ───────────────
  final ReportsStatus status;
  final ReportPeriod period;
  final List<SaleRecord> sales;
  final double totalRevenue;
  final double totalProfit;
  final double totalCost;
  final int orderCount;
  final List<MapEntry<String, double>> topProducts;
  final Map<String, double> productRevenue;
  final Map<String, double> dailyRevenue;
  final String? error;

  // ── وضعیت داشبورد صفحه خانه (همیشه «امروز» + ۷ روز گذشته) ──────
  final DashboardStatus dashboardStatus;
  final double todayRevenue;
  final double todayProfit;
  final int todayOrderCount;
  final double yesterdayRevenue;
  final double yesterdayProfit;
  final int yesterdayOrderCount;
  final Map<String, double> weeklyRevenue;
  final String? dashboardError;

  const ReportsState({
    this.status = ReportsStatus.initial,
    this.period = ReportPeriod.today,
    this.sales = const [],
    this.totalRevenue = 0,
    this.totalProfit = 0,
    this.totalCost = 0,
    this.orderCount = 0,
    this.topProducts = const [],
    this.productRevenue = const {},
    this.dailyRevenue = const {},
    this.error,
    this.dashboardStatus = DashboardStatus.initial,
    this.todayRevenue = 0,
    this.todayProfit = 0,
    this.todayOrderCount = 0,
    this.yesterdayRevenue = 0,
    this.yesterdayProfit = 0,
    this.yesterdayOrderCount = 0,
    this.weeklyRevenue = const {},
    this.dashboardError,
  });

  /// درصد رشد فروش امروز نسبت به دیروز (برای نمایش مثل +۲۵٪)
  double? get revenueGrowthPercent {
    if (yesterdayRevenue <= 0) return null;
    return ((todayRevenue - yesterdayRevenue) / yesterdayRevenue) * 100;
  }

  double? get profitGrowthPercent {
    if (yesterdayProfit <= 0) return null;
    return ((todayProfit - yesterdayProfit) / yesterdayProfit) * 100;
  }

  int get orderCountDelta => todayOrderCount - yesterdayOrderCount;

  ReportsState copyWith({
    ReportsStatus? status,
    ReportPeriod? period,
    List<SaleRecord>? sales,
    double? totalRevenue,
    double? totalProfit,
    double? totalCost,
    int? orderCount,
    List<MapEntry<String, double>>? topProducts,
    Map<String, double>? productRevenue,
    Map<String, double>? dailyRevenue,
    String? error,
    DashboardStatus? dashboardStatus,
    double? todayRevenue,
    double? todayProfit,
    int? todayOrderCount,
    double? yesterdayRevenue,
    double? yesterdayProfit,
    int? yesterdayOrderCount,
    Map<String, double>? weeklyRevenue,
    String? dashboardError,
  }) {
    return ReportsState(
      status: status ?? this.status,
      period: period ?? this.period,
      sales: sales ?? this.sales,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalProfit: totalProfit ?? this.totalProfit,
      totalCost: totalCost ?? this.totalCost,
      orderCount: orderCount ?? this.orderCount,
      topProducts: topProducts ?? this.topProducts,
      productRevenue: productRevenue ?? this.productRevenue,
      dailyRevenue: dailyRevenue ?? this.dailyRevenue,
      error: error ?? this.error,
      dashboardStatus: dashboardStatus ?? this.dashboardStatus,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      todayProfit: todayProfit ?? this.todayProfit,
      todayOrderCount: todayOrderCount ?? this.todayOrderCount,
      yesterdayRevenue: yesterdayRevenue ?? this.yesterdayRevenue,
      yesterdayProfit: yesterdayProfit ?? this.yesterdayProfit,
      yesterdayOrderCount: yesterdayOrderCount ?? this.yesterdayOrderCount,
      weeklyRevenue: weeklyRevenue ?? this.weeklyRevenue,
      dashboardError: dashboardError ?? this.dashboardError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        period,
        sales,
        totalRevenue,
        totalProfit,
        totalCost,
        orderCount,
        topProducts,
        productRevenue,
        dailyRevenue,
        error,
        dashboardStatus,
        todayRevenue,
        todayProfit,
        todayOrderCount,
        yesterdayRevenue,
        yesterdayProfit,
        yesterdayOrderCount,
        weeklyRevenue,
        dashboardError,
      ];
}
