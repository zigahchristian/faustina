import 'package:flutter/material.dart';
import '../services/database_helper.dart'; // Fixed import path

class SalesPage extends StatefulWidget {
  const SalesPage({Key? key}) : super(key: key);

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Product Sales';

  final List<String> _saleCategories = ['Product Sales', 'Service', 'Other'];
  List<Map<String, dynamic>> _sales = [];

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    try {
      final dbHelper = DatabaseHelper();
      List<Map<String, dynamic>> sales = await dbHelper.getSales();

      setState(() {
        _sales = sales;
      });
    } catch (e) {
      print('Error loading sales: $e');
    }
  }

  // ----------------------------
  // SELECT DATE
  // ----------------------------
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

  // ----------------------------
  // ADD SALE
  // ----------------------------
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final dbHelper = DatabaseHelper();
        final sale = {
          'date': _selectedDate.toIso8601String(),
          'description': _descriptionController.text,
          'amount': double.parse(_amountController.text),
          'category': _selectedCategory,
        };

        await dbHelper.insertSale(sale);

        _clearForm();

        await _loadSales();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sale added successfully!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding sale: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _clearForm() {
    _descriptionController.clear();
    _amountController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedCategory = 'Product Sales';
    });
  }

  // ----------------------------
  // EDIT SALE
  // ----------------------------
  void _showEditDialog(Map<String, dynamic> sale) {
    final descController = TextEditingController(text: sale['description']);
    final amountController = TextEditingController(text: sale['amount'].toString());
    String category = sale['category'];
    DateTime date = DateTime.parse(sale['date']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Sale'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: category,
                  items: _saleCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => category = v!,
                  decoration: InputDecoration(labelText: 'Category'),
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
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Save"),
              onPressed: () async {
                final dbHelper = DatabaseHelper();
                await dbHelper.updateSale({
                  'id':sale['id'],
                  'description': descController.text,
                  'amount': double.parse(amountController.text),
                  'category': category,
                  'date': date.toIso8601String(),
                });

                Navigator.pop(context);
                await _loadSales();
              },
            ),
          ],
        );
      },
    );
  }

  // ----------------------------
  // DELETE SALE
  // ----------------------------
  void _deleteSale(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete"),
        content: Text("Are you sure you want to delete this sale?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Delete"),
            onPressed: () async {
              final dbHelper = DatabaseHelper();
              await dbHelper.deleteSale(id);
              Navigator.pop(context);
              await _loadSales();
            },
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // UI
  // ----------------------------
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text('Add Sale', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(labelText: 'Amount', prefixText: '¢', border: OutlineInputBorder()),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => double.tryParse(value ?? '') == null ? 'Enter valid amount' : null,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _saleCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value!),
                      decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Date: ${_selectedDate.toString().split(' ')[0]}'),
                        Spacer(),
                        TextButton(
                          child: Text('Select Date'),
                          onPressed: () => _selectDate(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Add Sale'),
                      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), backgroundColor: Colors.green, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: _sales.isEmpty
                ? Center(child: Text('No sales recorded'))
                : ListView.builder(
                    itemCount: _sales.length,
                    itemBuilder: (context, index) {
                      final sale = _sales[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.trending_up, color: Colors.green),
                          title: Text(sale['description']),
                          subtitle: Text('${sale['category']} • ${sale['date'].toString().split(' ')[0]}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('¢${sale['amount'].toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEditDialog(sale),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteSale(sale['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
