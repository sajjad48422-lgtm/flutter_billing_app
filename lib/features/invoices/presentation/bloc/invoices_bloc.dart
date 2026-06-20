import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../sales/domain/entities/sale_record.dart';
import '../../../sales/domain/usecases/sale_usecases.dart';
import '../../../../core/utils/shamsi_helper.dart';

part 'invoices_event.dart';
part 'invoices_state.dart';

class InvoicesBloc extends Bloc<InvoicesEvent, InvoicesState> {
  final GetSalesByDateRangeUseCase getSalesByDateRangeUseCase;

  InvoicesBloc({required this.getSalesByDateRangeUseCase})
      : super(const InvoicesState()) {
    on<LoadInvoicesEvent>(_onLoad);
    on<ChangeInvoicePeriodEvent>(_onChangePeriod);
  }

  Future<void> _onLoad(
      LoadInvoicesEvent event, Emitter<InvoicesState> emit) async {
    emit(state.copyWith(status: InvoicesStatus.loading, period: event.period));
    await _loadForPeriod(event.period, emit);
  }

  Future<void> _onChangePeriod(
      ChangeInvoicePeriodEvent event, Emitter<InvoicesState> emit) async {
    emit(state.copyWith(status: InvoicesStatus.loading, period: event.period));
    await _loadForPeriod(event.period, emit);
  }

  Future<void> _loadForPeriod(
      InvoicePeriod period, Emitter<InvoicesState> emit) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    late DateTime from;

    switch (period) {
      case InvoicePeriod.today:
        from = todayStart;
        break;
      case InvoicePeriod.lastWeek:
        from = todayStart.subtract(const Duration(days: 6));
        break;
      case InvoicePeriod.lastMonth:
        from = todayStart.subtract(const Duration(days: 29));
        break;
      case InvoicePeriod.thisYear:
        // از ۱ فروردین سال شمسی جاری
        from = ShamsiHelper.startOfShamsiYear(now);
        break;
    }

    final result = await getSalesByDateRangeUseCase(from, now);

    result.fold(
      (failure) => emit(state.copyWith(
        status: InvoicesStatus.error,
        error: failure.message,
      )),
      (sales) => emit(state.copyWith(
        status: InvoicesStatus.loaded,
        invoices: sales,
      )),
    );
  }
}
