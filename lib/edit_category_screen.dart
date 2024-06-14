import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'objects.dart';

class EditCategoryScreen extends StatefulWidget {
  final Category category;
  final ValueChanged<Category> onCategoryUpdated;

  const EditCategoryScreen(
      {super.key, required this.category, required this.onCategoryUpdated});

  @override
  _EditCategoryScreenState createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _categoryName;
  late Color _categoryColor;
  late bool _isIncome;

  @override
  void initState() {
    super.initState();
    _categoryName = widget.category.name;
    _categoryColor = widget.category.color;
    _isIncome = widget.category.isIncome;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактирование категории'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _categoryName,
                onChanged: (value) {
                  setState(() {
                    _categoryName = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название категории';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Название категории',
                  border: OutlineInputBorder(),
                ),
              ),
              CheckboxListTile(
                title: Text('Категория доходов?'),
                value: _isIncome,
                onChanged: (newValue) {
                  setState(() {
                    _isIncome = newValue!;
                  });
                },
              ),
              SizedBox(height: 16.0),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Выберите цвет категории'),
                        content: BlockPicker(
                          pickerColor: _categoryColor,
                          onColorChanged: (color) {
                            setState(() {
                              _categoryColor = color;
                            });
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Закрыть'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: _categoryColor,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onCategoryUpdated(Category(
                      id: widget.category.id,
                      name: _categoryName,
                      color: _categoryColor,
                      isIncome: _isIncome,
                    ));
                    Navigator.pop(context);
                  }
                },
                child: Text('Сохранить изменения'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
