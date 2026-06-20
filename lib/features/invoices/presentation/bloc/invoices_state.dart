part of 'invoices_bloc.dart';

enum InvoicesStatus { initial, loading, loaded, error }

class InvoicesState extends Equatable {
  final InvoicesStatus status;
  final InvoicePeriod period;
  final List<SaleRecord> invoices;
  final String? error;

  const InvoicesState({
    this.status = InvoicesStatus.initial,
    this.period = InvoicePeriod.today,
    this.invoices = const [],
    this.error,
  });

  int get invoiceCount => invoices.length;

  double get totalRevenue =>
      invoices.fold<double>(0, (sum, s) => sum + s.totalAmount);

  InvoicesState copyWith({
    InvoicesStatus? status,
    InvoicePeriod? period,
    List<SaleRecord>? invoices,
    String? error,
  }) {
    return InvoicesState(
      status: status ?? this.status,
      period: period ?? this.period,
      invoices: invoices ?? this.invoices,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, period, invoices, error];
}
