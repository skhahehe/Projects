import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'transaction_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

class TransactionOverviewScreen extends StatefulWidget {
  const TransactionOverviewScreen({super.key});

  @override
  State<TransactionOverviewScreen> createState() =>
      _TransactionOverviewScreenState();
}

class _TransactionOverviewScreenState
    extends State<TransactionOverviewScreen> {
  List<TransactionModel> transactions = [];

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('transactions');
    if (data != null) {
      final List decoded = jsonDecode(data);
      setState(() {
        transactions =
            decoded.map((e) => TransactionModel.fromMap(e)).toList();

        // Filter last 365 days
        transactions = transactions
            .where((t) =>
                t.date.isAfter(DateTime.now().subtract(const Duration(days: 365))))
            .toList();

        // Sort ascending by date
        transactions.sort((a, b) => a.date.compareTo(b.date));
      });
    }
  }

  Future<void> exportPDF() async {
  final pdf = pw.Document();

  // Load Unicode font
  final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  final ttf = pw.Font.ttf(fontData);

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text(
          'Transactions (Last 365 Days)',
          style: pw.TextStyle(
            font: ttf,
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headers: ['Date', 'Type', 'Category', 'Amount'],
          headerStyle: pw.TextStyle(
            font: ttf,
            fontWeight: pw.FontWeight.bold,
          ),
          cellStyle: pw.TextStyle(font: ttf),
          data: transactions.map((t) {
            return [
              '${t.date.day}/${t.date.month}/${t.date.year}',
              t.isIncome ? 'Income' : 'Expense',
              t.category,
              t.amount.toStringAsFixed(2),
            ];
          }).toList(),
        ),
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: exportPDF,
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body: transactions.isEmpty
          ? const Center(child: Text('No transactions in last 365 days'))
          :ListView.builder(
  padding: const EdgeInsets.all(16),
  itemCount: transactions.length,
  itemBuilder: (context, index) {
    final t = transactions[transactions.length - 1 - index];

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
        '\$${t.amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: t.isIncome ? Colors.green : Colors.red,
        ),
      ),
    );
  },
),

    );
  }
}
