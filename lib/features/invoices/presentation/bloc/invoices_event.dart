part of 'invoices_bloc.dart';

enum InvoicePeriod { today, lastWeek, lastMonth, thisYear }

abstract class InvoicesEvent extends Equatable {
  const InvoicesEvent();
  @override
  List<Object> get props => [];
}

/// بارگذاری فاکتورها برای یک بازه‌ی زمانی مشخص
class LoadInvoicesEvent extends InvoicesEvent {
  final InvoicePeriod period;
  const LoadInvoicesEvent(this.period);
  @override
  List<Object> get props => [period];
}

/// تغییر تب بازه‌ی زمانی (امروز/هفته گذشته/ماه گذشته/امسال)
class ChangeInvoicePeriodEvent extends InvoicesEvent {
  final InvoicePeriod period;
  const ChangeInvoicePeriodEvent(this.period);
  @override
  List<Object> get props => [period];
}
