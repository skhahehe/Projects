import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/transaction_model.dart';
import '../widgets/add_transaction_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              // Navigation to settings/user profile could go here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Section
            Row(
              children: [
                Expanded(
                  child: Selector<FinanceProvider, double>(
                    selector: (_, finance) => finance.currentBalance,
                    builder: (context, balance, _) => _SummaryCard(
                      title: 'Balance',
                      amount: balance,
                      color: Colors.blue,
                      icon: Icons.account_balance_wallet,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Selector<FinanceProvider, double>(
                    selector: (_, finance) => finance.savings,
                    builder: (context, savings, _) => _SummaryCard(
                      title: 'Savings',
                      amount: savings,
                      color: Colors.green,
                      icon: Icons.savings,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Selector<FinanceProvider, double>(
              selector: (_, finance) => finance.spentThisMonth,
              builder: (context, spent, _) => _SummaryCard(
                title: 'Spent This Month',
                amount: spent,
                color: Colors.red,
                icon: Icons.shopping_cart,
                isWide: true,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Transactions Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // This could be used to trigger a tab switch in the parent
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Recent Transactions List
            Selector<FinanceProvider, List<TransactionModel>>(
              selector: (_, finance) => finance.getRecentTransactions(5),
              shouldRebuild: (prev, next) {
                if (prev.length != next.length) return true;
                for (int i = 0; i < prev.length; i++) {
                  if (prev[i] != next[i]) return true;
                }
                return false;
              },
              builder: (context, recentTransactions, _) {
                if (recentTransactions.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text('No recent transactions', style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }
                
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final t = recentTransactions[index];
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 800 + (index * 150)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 40 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: t.isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          child: Icon(
                            t.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                            color: t.isIncome ? Colors.green : Colors.red,
                            size: 18,
                          ),
                        ),
                        title: Text(t.category, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${t.date.day}/${t.date.month}/${t.date.year}'),
                        trailing: Text(
                          '${t.isIncome ? '+' : '-'}\$${t.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: t.isIncome ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final bool isWide;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
