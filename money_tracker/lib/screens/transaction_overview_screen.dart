import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/transaction_model.dart';
import '../widgets/monthly_transaction_calendar.dart';
import '../services/pdf_service.dart';
import '../widgets/statement_export_dialog.dart';
import '../widgets/bounce_button.dart';

class TransactionOverviewScreen extends StatefulWidget {
  const TransactionOverviewScreen({super.key});

  @override
  State<TransactionOverviewScreen> createState() => _TransactionOverviewScreenState();
}

class _TransactionOverviewScreenState extends State<TransactionOverviewScreen> {
  late int _selectedYear;
  late int _selectedMonth;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_selectedYear == now.year && _selectedMonth == now.month) {
      return;
    }

    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
    });
  }

  void _prevMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
    });
  }

  bool _isFutureMonth(int year, int month) {
    final now = DateTime.now();
    if (year > now.year) return true;
    if (year == now.year && month > now.month) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          BounceButton(
            onTap: () => _showExportOptions(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.picture_as_pdf),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Selector<FinanceProvider, List<int>>(
                  selector: (_, finance) => finance.getAvailableYears(),
                  builder: (context, availableYears, _) => _buildCalendarHeader(availableYears),
                ),
                const SizedBox(height: 8),
                // 📊 Extreme Micro Heatmap Calendar
                Selector<FinanceProvider, Map<int, Map<String, double>>>(
                  selector: (_, finance) => finance.getDailyStatsForMonth(_selectedYear, _selectedMonth),
                  builder: (context, dailyStats, _) => MonthlyTransactionCalendar(
                    dailyStats: dailyStats,
                    year: _selectedYear,
                    month: _selectedMonth,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
              ],
            ),
          ),
          Selector<FinanceProvider, List<TransactionModel>>(
            selector: (_, finance) => finance.getTransactionsByMonth(_selectedYear, _selectedMonth),
            shouldRebuild: (prev, next) {
              if (prev.length != next.length) return true;
              for (int i = 0; i < prev.length; i++) {
                if (prev[i] != next[i]) return true;
              }
              return false;
            },
            builder: (context, transactions, _) {
              if (transactions.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                );
              }
              
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final t = transactions[index];
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 600 + (index * 100).clamp(0, 1000)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: t.isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                child: Icon(
                                  t.isIncome ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down,
                                  color: t.isIncome ? Colors.green : Colors.red,
                                  size: 16,
                                ),
                              ),
                              title: Text(t.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text('${t.date.day} ${_months[t.date.month - 1]} ${t.date.year}', style: const TextStyle(fontSize: 12)),
                              trailing: Text(
                                '${t.isIncome ? "+" : "-"}\$${t.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: t.isIncome ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: transactions.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(List<int> availableYears) {
    final now = DateTime.now();
    final bool isAtCurrentMonth = _selectedYear == now.year && _selectedMonth == now.month;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: _prevMonth,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: _selectedMonth,
                  underline: const SizedBox(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                  items: List.generate(12, (index) {
                    final monthIdx = index + 1;
                    final bool isFuture = _isFutureMonth(_selectedYear, monthIdx);
                    return DropdownMenuItem(
                      value: monthIdx,
                      enabled: !isFuture,
                      child: Text(
                        _months[index],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isFuture ? Colors.grey : null,
                        ),
                      ),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedMonth = val);
                  },
                ),
                const SizedBox(width: 4),
                DropdownButton<int>(
                  value: _selectedYear,
                  underline: const SizedBox(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                  items: availableYears.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedYear = val;
                        if (_isFutureMonth(_selectedYear, _selectedMonth)) {
                          _selectedMonth = 1;
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: isAtCurrentMonth ? null : _nextMonth,
            color: isAtCurrentMonth ? Colors.grey : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No transactions for this period',
            style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const StatementExportDialog(),
    );
  }

}
