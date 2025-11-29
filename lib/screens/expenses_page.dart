import 'package:flutter/material.dart';
import 'package:faustina/services/database_helper.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Supplies';

  final List<String> _expenseCategories = [
    'Supplies',
    'Utilities',
    'Rent',
    'Salaries',
    'Other'
  ];

  List<Map<String, dynamic>> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> expenses = await dbHelper.getExpenses();

    setState(() {
      _expenses = expenses;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final dbHelper = DatabaseHelper();

      final expense = {
        'date': _selectedDate.toIso8601String(),
        'description': _descriptionController.text,
        'amount': double.parse(_amountController.text),
        'category': _selectedCategory,
      };

      try {
        await dbHelper.insertExpense(expense);

        _descriptionController.clear();
        _amountController.clear();

        setState(() {
          _selectedDate = DateTime.now();
          _selectedCategory = 'Supplies';
        });

        await _loadExpenses();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Expense added successfully!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding expense'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ----------------------------------------------------
  // EDIT EXPENSE
  // ----------------------------------------------------
  void _showEditDialog(Map<String, dynamic> expense) {
    final descCtrl = TextEditingController(text: expense['description']);
    final amountCtrl = TextEditingController(text: expense['amount'].toString());

    String category = expense['category'];
    DateTime date = DateTime.parse(expense['date']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Expense"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: descCtrl,
                  decoration: InputDecoration(labelText: "Description"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: amountCtrl,
                  decoration: InputDecoration(labelText: "Amount"),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField(
                  value: category,
                  items: _expenseCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => category = v!,
                  decoration: InputDecoration(labelText: "Category"),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text("Date: ${date.toString().split(' ')[0]}"),
                    Spacer(),
                    TextButton(
                      child: Text("Pick"),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() => date = picked);
                        }
                      },
                    )
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              child: Text("Save"),
              onPressed: () async {
                final dbHelper = DatabaseHelper();
                await dbHelper.updateExpense({
                  'id': expense['id'],
                  'description': descCtrl.text,
                  'amount': double.parse(amountCtrl.text),
                  'category': category,
                  'date': date.toIso8601String(),
                });

                Navigator.pop(context);
                await _loadExpenses();
              },
            )
          ],
        );
      },
    );
  }

  // ----------------------------------------------------
  // DELETE EXPENSE
  // ----------------------------------------------------
  void _deleteExpense(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete"),
          content: Text("Are you sure you want to delete this expense?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Delete"),
              onPressed: () async {
                final dbHelper = DatabaseHelper();
                await dbHelper.deleteExpense(id);

                Navigator.pop(context);
                await _loadExpenses();
              },
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------
  // UI
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // ------------------ Add expense form ------------------
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text("Add Expense", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(labelText: 'Amount', border: OutlineInputBorder(), prefixText: '¢'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => double.tryParse(value ?? '') == null ? 'Please enter a valid number' : null,
                    ),
                    SizedBox(height: 16),

                    DropdownButtonFormField(
                      value: _selectedCategory,
                      decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      items: _expenseCategories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value!),
                    ),
                    SizedBox(height: 16),

                    Row(
                      children: [
                        Text("Date: ${_selectedDate.toString().split(' ')[0]}"),
                        Spacer(),
                        TextButton(onPressed: () => _selectDate(context), child: Text("Select Date")),
                      ],
                    ),
                    SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text("Add Expense"),
                      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), backgroundColor: Colors.red, foregroundColor: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          // ------------------ Expense list ------------------
          Expanded(
            child: _expenses.isEmpty
                ? Center(child: Text("No expenses recorded"))
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(Icons.trending_down, color: Colors.red),
                          title: Text(expense['description']),
                          subtitle: Text("${expense['category']} • ${expense['date'].toString().split(' ')[0]}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "¢${expense['amount'].toStringAsFixed(2)}",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEditDialog(expense),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteExpense(expense['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
