part of 'reports_bloc.dart';

enum ReportPeriod { today, thisMonth, allTime }

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();
  @override
  List<Object> get props => [];
}

class LoadReportsEvent extends ReportsEvent {}

class ChangeReportPeriodEvent extends ReportsEvent {
  final ReportPeriod period;
  const ChangeReportPeriodEvent(this.period);
  @override
  List<Object> get props => [period];
}

/// بارگذاری اطلاعات داشبورد صفحه خانه: آمار «امروز» + نمودار ۷ روز گذشته
/// این event مستقل از period انتخاب‌شده در تب گزارشات عمل می‌کند.
class LoadDashboardEvent extends ReportsEvent {}
