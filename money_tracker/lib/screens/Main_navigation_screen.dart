import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'transaction_overview_screen.dart';
import 'category_screen.dart';
import 'settings_screen.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/bounce_button.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    TransactionOverviewScreen(),
    CategoryScreen(),
    SettingsScreen(),
  ];

  void _openAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BounceButton(
              onTap: () => setState(() => _currentIndex = 0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.home, color: _currentIndex == 0 ? Colors.blue : Colors.grey),
              ),
            ),
            BounceButton(
              onTap: () => setState(() => _currentIndex = 1),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.list_alt, color: _currentIndex == 1 ? Colors.blue : Colors.grey),
              ),
            ),
            const SizedBox(width: 48), // Space for floating button
            BounceButton(
              onTap: () => setState(() => _currentIndex = 2),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.category, color: _currentIndex == 2 ? Colors.blue : Colors.grey),
              ),
            ),
            BounceButton(
              onTap: () => setState(() => _currentIndex = 3),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.settings, color: _currentIndex == 3 ? Colors.blue : Colors.grey),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: BounceButton(
        onTap: _openAddTransactionSheet,
        child: FloatingActionButton(
          onPressed: null, // Handled by BounceButton
          heroTag: 'main_nav_fab',
          shape: const CircleBorder(),
          tooltip: 'Add Transaction',
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
