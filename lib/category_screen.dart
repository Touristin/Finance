import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'category_list.dart';
import 'objects.dart';
import 'edit_category_screen.dart';
import 'entry_list.dart';

class CategoryScreen extends StatefulWidget {
  final CategoryList categoryList;

  const CategoryScreen({super.key, required this.categoryList});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late EntryList entryList;
  String _categoryName = '';
  Color _categoryColor = Colors.blue;
  bool _isIncome = false;

  @override
  void initState() {
    super.initState();
    EntryList.initialize().then((initializedEntryList) {
      setState(() {
        entryList = initializedEntryList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Категории'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.categoryList.categories.length,
                itemBuilder: (context, index) {
                  final category = widget.categoryList.categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        category.name,
                        style: TextStyle(
                          color: category.color,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit), //редактирование категории
                            color: category.color,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditCategoryScreen(
                                    category: category,
                                    onCategoryUpdated: (updatedCategory) {
                                      setState(() {
                                        widget.categoryList.updateCategory(
                                            index, updatedCategory);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete), //удаление категории
                            color: category.color,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Удаление категории'),
                                    content: Text(
                                        'Все записи в этой категорией будут удалены. Вы уверены ?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Закрыть'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await widget.categoryList
                                              .deleteCategory(index, entryList);
                                          setState(() {});
                                          // ignore: use_build_context_synchronously
                                          Navigator.pop(context);
                                        },
                                        child: Text('Удалить'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: category.color,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
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
                    SizedBox(height: 16.0),
                    CheckboxListTile(
                      title: Text('Категория доходов'), //флаг доходы
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
                              title: Text('Выберите цвет'),
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
                          widget.categoryList.addCategory(Category(
                            id: DateTime.now().toIso8601String(),
                            name: _categoryName,
                            color: _categoryColor,
                            isIncome: _isIncome,
                          ));
                          _categoryName = '';
                          _formKey.currentState!.reset();
                        }
                      },
                      child: Text('Создать категорию'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
