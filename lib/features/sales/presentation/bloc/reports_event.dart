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
