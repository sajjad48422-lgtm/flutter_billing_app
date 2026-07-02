import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../sales/presentation/bloc/reports_bloc.dart';
import '../../../../core/utils/currency_formatter.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'گزارشات',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: Column(
            children: [
              _buildPeriodSelector(context, state),
              Expanded(
                child: state.status == ReportsStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : state.status == ReportsStatus.error
                        ? Center(child: Text(state.error ?? 'خطا'))
                        : _buildContent(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodSelector(BuildContext context, ReportsState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          _periodBtn(context, state, ReportPeriod.today, 'امروز'),
          _periodBtn(context, state, ReportPeriod.thisMonth, 'این ماه'),
          _periodBtn(context, state, ReportPeriod.allTime, 'همه'),
        ],
      ),
    );
  }

  Widget _periodBtn(BuildContext context, ReportsState state,
      ReportPeriod period, String label) {
    final isSelected = state.period == period;
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            context.read<ReportsBloc>().add(ChangeReportPeriodEvent(period)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReportsState state) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _buildSummaryCards(state),
        const SizedBox(height: 16),
        _buildRevenueChart(state),
        const SizedBox(height: 16),
        _buildProfitCard(state),
        const SizedBox(height: 16),
        if (state.topProducts.isNotEmpty) ...[
          _buildTopProducts(state),
          const SizedBox(height: 16),
        ],
        _buildInventoryHint(),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSummaryCards(ReportsState state) {
    return Row(
      children: [
        _summaryCard(
          icon: Icons.receipt_long,
          title: 'تعداد فروش',
          value: '${state.orderCount}',
          color: const Color(0xFF6C63FF),
        ),
        const SizedBox(width: 12),
        _summaryCard(
          icon: Icons.payments,
          title: 'درآمد کل',
          value: CurrencyFormatter.formatCompact(state.totalRevenue),
          color: const Color(0xFF00C48C),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(ReportsState state) {
    if (state.dailyRevenue.isEmpty) return const SizedBox.shrink();

    final entries = state.dailyRevenue.entries.toList();
    final maxVal =
        entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
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
          SizedBox(
            height: 140,
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
                        if (entry.value > 0)
                          Text(
                            CurrencyFormatter.formatCompact(entry.value),
                            style: const TextStyle(
                                fontSize: 8, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: (ratio * 100).clamp(4, 100),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.key,
                          style: const TextStyle(
                              fontSize: 9, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitCard(ReportsState state) {
    final profitColor =
        state.totalProfit >= 0 ? const Color(0xFF00C48C) : Colors.red;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'سود و زیان',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 16),
          _profitRow('درآمد', state.totalRevenue, const Color(0xFF00C48C)),
          const SizedBox(height: 8),
          _profitRow(
              'بهای تمام شده', state.totalCost, Colors.orange),
          const Divider(height: 24),
          _profitRow('سود خالص', state.totalProfit, profitColor,
              isBold: true),
        ],
      ),
    );
  }

  Widget _profitRow(String label, double amount, Color color,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isBold ? Colors.black : Colors.grey[600],
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTopProducts(ReportsState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'پرفروش‌ترین کالاها',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ...state.topProducts.asMap().entries.map((entry) {
            final i = entry.key;
            final product = entry.value;
            final colors = [
              const Color(0xFF6C63FF),
              const Color(0xFF00C48C),
              Colors.orange,
              Colors.blue,
              Colors.pink,
            ];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length]
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: colors[i % colors.length],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      product.key,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    '${product.value.toStringAsFixed(1)}x',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors[i % colors.length],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInventoryHint() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.inventory_2_outlined,
              color: Color(0xFF6C63FF), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'برای مشاهده موجودی کالاها، به بخش کالاها بروید',
              style:
                  TextStyle(fontSize: 12, color: Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),
    );
  }
}
