import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'category_model.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<CategoryModel> categories = [];

  final TextEditingController nameController = TextEditingController();
  bool isIncome = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('categories');

    if (data != null) {
      final List decoded = jsonDecode(data);
      setState(() {
        categories =
            decoded.map((e) => CategoryModel.fromMap(e)).toList();
      });
    }
  }

  Future<void> saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        jsonEncode(categories.map((e) => e.toMap()).toList());
    prefs.setString('categories', encoded);
  }

  void addCategory() {
    if (nameController.text.isEmpty) return;

    setState(() {
      categories.add(
        CategoryModel(
          name: nameController.text,
          isIncome: isIncome,
        ),
      );
    });

    saveCategories();
    nameController.clear();
  }

  void deleteCategory(CategoryModel category) {
    setState(() {
      categories.remove(category);
    });
    saveCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ADD CATEGORY FORM
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            DropdownButton<bool>(
              value: isIncome,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: true,
                  child: Text('Income'),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text('Expense'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  isIncome = value!;
                });
              },
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: addCategory,
              child: const Text('Add Category'),
            ),

            const Divider(height: 30),

            // CATEGORY LIST
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final c = categories[index];
                  return ListTile(
                    title: Text(c.name),
                    subtitle:
                        Text(c.isIncome ? 'Income' : 'Expense'),
                    trailing: IconButton(
                      icon:
                          const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteCategory(c),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
