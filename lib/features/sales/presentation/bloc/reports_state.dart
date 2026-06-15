part of 'reports_bloc.dart';

enum ReportsStatus { initial, loading, loaded, error }

class ReportsState extends Equatable {
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
  });

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
      ];
}
