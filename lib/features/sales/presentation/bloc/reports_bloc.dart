import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/sale_record.dart';
import '../../domain/usecases/sale_usecases.dart';

part 'reports_event.dart';
part 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetAllSalesUseCase getAllSalesUseCase;
  final GetSalesByDateRangeUseCase getSalesByDateRangeUseCase;

  ReportsBloc({
    required this.getAllSalesUseCase,
    required this.getSalesByDateRangeUseCase,
  }) : super(const ReportsState()) {
    on<LoadReportsEvent>(_onLoadReports);
    on<ChangeReportPeriodEvent>(_onChangePeriod);
  }

  Future<void> _onLoadReports(
      LoadReportsEvent event, Emitter<ReportsState> emit) async {
    emit(state.copyWith(status: ReportsStatus.loading));
    await _loadForPeriod(state.period, emit);
  }

  Future<void> _onChangePeriod(
      ChangeReportPeriodEvent event, Emitter<ReportsState> emit) async {
    emit(state.copyWith(status: ReportsStatus.loading, period: event.period));
    await _loadForPeriod(event.period, emit);
  }

  Future<void> _loadForPeriod(
      ReportPeriod period, Emitter<ReportsState> emit) async {
    final now = DateTime.now();
    late DateTime from;

    switch (period) {
      case ReportPeriod.today:
        from = DateTime(now.year, now.month, now.day);
        break;
      case ReportPeriod.thisMonth:
        from = DateTime(now.year, now.month, 1);
        break;
      case ReportPeriod.allTime:
        from = DateTime(2000);
        break;
    }

    final result =
        await getSalesByDateRangeUseCase(from, now);

    result.fold(
      (failure) => emit(state.copyWith(
          status: ReportsStatus.error, error: failure.message)),
      (sales) {
        final totalRevenue =
            sales.fold<double>(0, (sum, s) => sum + s.totalAmount);
        final totalProfit =
            sales.fold<double>(0, (sum, s) => sum + s.totalProfit);
        final totalCost =
            sales.fold<double>(0, (sum, s) => sum + s.totalPurchaseAmount);

        // top selling products
        final Map<String, double> productQty = {};
        final Map<String, double> productRevenue = {};
        for (final sale in sales) {
          for (final item in sale.items) {
            productQty[item.productName] =
                (productQty[item.productName] ?? 0) + item.quantity;
            productRevenue[item.productName] =
                (productRevenue[item.productName] ?? 0) + item.total;
          }
        }

        final topProducts = productQty.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // daily chart data (last 7 days)
        final Map<String, double> dailyRevenue = {};
        for (int i = 6; i >= 0; i--) {
          final day = now.subtract(Duration(days: i));
          final key =
              '${day.month}/${day.day}';
          dailyRevenue[key] = 0;
        }
        for (final sale in sales) {
          final key =
              '${sale.createdAt.month}/${sale.createdAt.day}';
          if (dailyRevenue.containsKey(key)) {
            dailyRevenue[key] = (dailyRevenue[key] ?? 0) + sale.totalAmount;
          }
        }

        emit(state.copyWith(
          status: ReportsStatus.loaded,
          sales: sales,
          totalRevenue: totalRevenue,
          totalProfit: totalProfit,
          totalCost: totalCost,
          orderCount: sales.length,
          topProducts: topProducts.take(5).toList(),
          productRevenue: productRevenue,
          dailyRevenue: dailyRevenue,
        ));
      },
    );
  }
}
