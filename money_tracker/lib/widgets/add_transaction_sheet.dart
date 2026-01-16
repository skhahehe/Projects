import 'package:flutter/material.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  bool isExpense = true;

  final List<String> expenseCategories = [
    'Food',
    'Transport',
    'Rent',
    'Shopping',
  ];

  final List<String> incomeCategories = [
    'Salary',
    'Bonus',
    'Freelance',
  ];

  @override
  Widget build(BuildContext context) {
    final categories = isExpense ? expenseCategories : incomeCategories;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Add Transaction',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 12),

          // Expense / Income toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Expense'),
                selected: isExpense,
                onSelected: (_) => setState(() => isExpense = true),
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Income'),
                selected: !isExpense,
                onSelected: (_) => setState(() => isExpense = false),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Categories
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.9,
            ),
            itemCount: categories.length,
            itemBuilder: (_, index) {
              return Column(
                children: [
                  CircleAvatar(
                    child: Text(categories[index][0]),
                  ),
                  const SizedBox(height: 4),
                  Text(categories[index]),
                ],
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
