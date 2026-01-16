import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'transaction_model.dart';
import 'category_model.dart';
import 'category_screen.dart';
import 'transaction_overview_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Tracker',
      debugShowCheckedModeBanner: false,
      home: const MainNavigationScreen(),

    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double moneyHave = 0;
  List<TransactionModel> transactions = [];
  List<CategoryModel> categories = [
    CategoryModel(name: 'Salary', isIncome: true),
    CategoryModel(name: 'Food', isIncome: false),
  ];

  String selectedCategory = 'Salary';
  bool isIncomeSelected = true;

  final TextEditingController amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadMoney();
    loadTransactions();
    loadCategories();
  }

  Future<void> loadMoney() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      moneyHave = prefs.getDouble('money') ?? 0;
    });
  }

  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('categories');
    if (data != null) {
      final List decoded = jsonDecode(data);
      setState(() {
        categories = decoded.map((e) => CategoryModel.fromMap(e)).toList();
        // select first category of the current type
        final filtered = categories.where((c) => c.isIncome == isIncomeSelected);
        if (filtered.isNotEmpty) selectedCategory = filtered.first.name;
      });
    }
  }

  Future<void> saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(categories.map((e) => e.toMap()).toList());
    prefs.setString('categories', encoded);
  }

  Future<void> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('transactions');
    if (data != null) {
      final List decoded = jsonDecode(data);
      setState(() {
        transactions =
            decoded.map((e) => TransactionModel.fromMap(e)).toList();
      });
    }
  }

  Future<void> saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(transactions.map((e) => e.toMap()).toList());
    prefs.setString('transactions', encoded);
  }

  Future<void> saveMoney() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('money', moneyHave);
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void addTransactionFromInput() {
    final value = double.tryParse(amountController.text);
    if (value == null) return;

    final transaction = TransactionModel(
      amount: value,
      date: selectedDate,
      isIncome: isIncomeSelected,
      category: selectedCategory,
    );

    setState(() {
      transactions.add(transaction);
      moneyHave += isIncomeSelected ? value : -value;
    });

    saveMoney();
    saveTransactions();
    amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Money Tracker')),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Balance
                    Text(
                      'Balance: \$${moneyHave.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(height: 20),

                    // Amount input
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter amount',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Date picker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        ),
                        TextButton(
                          onPressed: () => pickDate(context),
                          child: const Text('Change Date'),
                        ),
                      ],
                    ),

                    // Income / Expense toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Income'),
                          selected: isIncomeSelected,
                          onSelected: (val) {
                            setState(() {
                              isIncomeSelected = true;
                              final incomeCats =
                                  categories.where((c) => c.isIncome).toList();
                              if (incomeCats.isNotEmpty) {
                                selectedCategory = incomeCats.first.name;
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text('Expense'),
                          selected: !isIncomeSelected,
                          onSelected: (val) {
                            setState(() {
                              isIncomeSelected = false;
                              final expenseCats =
                                  categories.where((c) => !c.isIncome).toList();
                              if (expenseCats.isNotEmpty) {
                                selectedCategory = expenseCats.first.name;
                              }
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Category dropdown
                    DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      items: categories
                          .where((c) => c.isIncome == isIncomeSelected)
                          
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.name,
                              child: Text(c.name),
                            ),
                          )
                          
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                  if (categories.where((c) => c.isIncome == isIncomeSelected).isEmpty) {
  return const Text('No categories available');
}
  ),

                    const SizedBox(height: 12),

                    // Add / Subtract button
                    ElevatedButton(
                      onPressed: addTransactionFromInput,
                      child: Text(isIncomeSelected ? 'Add Income' : 'Add Expense'),
                    ),

                 const SizedBox(height: 20),
const Divider(),
const Text(
  'Last 15 Days',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

// Transactions list
Builder(
  builder: (context) {
    final recentTransactions = transactions
        .where(
          (t) => t.date.isAfter(
            DateTime.now().subtract(const Duration(days: 15)),
          ),
        )
        .toList();

    // Sort ascending by date
    recentTransactions.sort((a, b) => a.date.compareTo(b.date));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentTransactions.length,
      itemBuilder: (context, index) {
        // Reverse ONLY for UI (newest at top)
        final t =
            recentTransactions[recentTransactions.length - 1 - index];

        return ListTile(
          title: Text(
            t.isIncome ? 'Income' : 'Expense',
            style: TextStyle(
              color: t.isIncome ? Colors.green : Colors.red,
            ),
          ),
          subtitle: Text(
            '${t.category} • ${t.date.day}/${t.date.month}/${t.date.year}',
          ),
          trailing: Text(
            '\$${t.amount}',
            style: TextStyle(
              color: t.isIncome ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  },
),

ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TransactionOverviewScreen()),
    );
  },
  child: const Text('View Full Transactions (Last 365 Days)'),
),

            // Fixed button at bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoryScreen(),
                    ),
                  );
                  
                  loadCategories(); // refresh after coming back
                },
                child: const Text('Manage Categories'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
