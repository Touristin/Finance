import 'package:flutter/material.dart';
import 'objects.dart';
import 'category_list.dart';

class AddEntryScreen extends StatefulWidget {
  final CategoryList categoryList;
  final Entry? entry;
  final ValueChanged<Entry>? onEntryUpdated;

  const AddEntryScreen(
      {super.key, required this.categoryList, this.entry, this.onEntryUpdated});

  @override
  _AddEntryScreenState createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late Category _selectedCategory;
  String _name = '';
  double _price = 0.0;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categoryList.categories.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить запись'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Название',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                items: widget.categoryList.categories.map((category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Выберите категорию';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Категория',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                initialValue: _price.toString(),
                onChanged: (value) {
                  setState(() {
                    _price = double.tryParse(value) ?? 0.0;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите сумму';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Сумма',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null && pickedDate != _date) {
                    setState(() {
                      _date = pickedDate;
                    });
                  }
                },
                child: Text('Выберите дату',
                    style: TextStyle(color: Colors.black, fontSize: 18.0)),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(
                        context,
                        Entry(
                          id: DateTime.now().toIso8601String(),
                          name: _name,
                          date: _date,
                          category: _selectedCategory,
                          price: _price,
                        ));
                  }
                },
                child: Text('Добавить',
                    style: TextStyle(color: Colors.black, fontSize: 18.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
