import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/shamsi_helper.dart' hide PersianString;
import '../../../sales/domain/entities/sale_record.dart';
import '../bloc/invoices_bloc.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<InvoicePeriod> _periods = [
    InvoicePeriod.today,
    InvoicePeriod.lastWeek,
    InvoicePeriod.lastMonth,
    InvoicePeriod.thisYear,
  ];

  static const List<String> _periodLabels = [
    'امروز',
    'هفته گذشته',
    'ماه گذشته',
    'امسال',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _periods.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    // بارگذاری اولیه برای تب «امروز»
    context.read<InvoicesBloc>().add(LoadInvoicesEvent(_periods.first));
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    context
        .read<InvoicesBloc>()
        .add(ChangeInvoicePeriodEvent(_periods[_tabController.index]));
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'فاکتورها',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _periodLabels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: BlocBuilder<InvoicesBloc, InvoicesState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildSummaryBar(state),
              Expanded(child: _buildBody(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryBar(InvoicesState state) {
    if (state.status != InvoicesStatus.loaded) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryItem(
              label: 'تعداد فاکتور',
              value: '${state.invoiceCount}'.toPersianDigit(),
            ),
          ),
          Container(width: 1, height: 32, color: Colors.grey[200]),
          Expanded(
            child: _summaryItem(
              label: 'جمع فروش',
              value: CurrencyFormatter.formatCompact(state.totalRevenue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildBody(InvoicesState state) {
    switch (state.status) {
      case InvoicesStatus.initial:
      case InvoicesStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case InvoicesStatus.error:
        return Center(
          child: Text(
            state.error ?? 'خطا در بارگذاری فاکتورها',
            style: const TextStyle(color: Colors.red),
          ),
        );
      case InvoicesStatus.loaded:
        if (state.invoices.isEmpty) {
          return _buildEmptyState();
        }
        return RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: () async {
            context
                .read<InvoicesBloc>()
                .add(LoadInvoicesEvent(state.period));
          },
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: state.invoices.length,
            itemBuilder: (context, index) {
              return _invoiceCard(context, state.invoices[index]);
            },
          ),
        );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'فاکتوری در این بازه ثبت نشده است',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _invoiceCard(BuildContext context, SaleRecord invoice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/invoices/detail', extra: invoice),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.receipt_long,
                    color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${invoice.items.length} قلم'.toPersianDigit(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ShamsiHelper.toShamsiWithTime(invoice.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(invoice.finalAmount,
                        showUnit: false),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    CurrencyFormatter.unitName,
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_left, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
