import 'package:flutter/material.dart';
import 'entry_list.dart';
import 'package:intl/intl.dart';
import 'add_entry_screen.dart';
import 'category_list.dart';

class HistoryScreen extends StatefulWidget {
  final EntryList entryList;
  final CategoryList categoryList;

  const HistoryScreen(
      {super.key, required this.entryList, required this.categoryList});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime(
        2000), 
    end: DateTime(2100),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('История доходов/расходов'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.categoryList.categories.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Нет доступных категорий'),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEntryScreen(
                  categoryList: widget
                      .categoryList, 
                ),
              ),
            ).then((value) {
              if (value != null) {
                widget.entryList.addEntry(value);
                setState(() {});
              }
            });
          }
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Выбрать временной промежуток'),
            subtitle: Text(
              '${DateFormat.yMMMd('ru_RU').format(_selectedDateRange.start)} - ${DateFormat.yMMMd('ru_RU').format(_selectedDateRange.end)}',
            ),
            trailing: IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () async {
                final DateTimeRange? newDateRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  currentDate: DateTime.now(),
                  initialDateRange: _selectedDateRange,
                );

                if (newDateRange != null) {
                  setState(() {
                    _selectedDateRange = newDateRange;
                  });
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.entryList.entries
                  .where((entry) {
                    return entry.date.isAfter(_selectedDateRange.start) &&
                        entry.date.isBefore(_selectedDateRange.end);
                  })
                  .toList()
                  .length,
              itemBuilder: (context, index) {
                final entry = widget.entryList.entries.where((entry) {
                  return entry.date.isAfter(_selectedDateRange.start) &&
                      entry.date.isBefore(_selectedDateRange.end);
                }).toList()[index];

                return ListTile(
                  title: Text('${entry.name} - ${entry.price}'),
                  subtitle: Text(
                      '${entry.category.name} - ${DateFormat('dd MMM yyyy, hh:mm a').format(entry.date)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Удалить запись'),
                                content: Text(
                                    'Вы точно хотите удалить запись "${entry.name}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Закрыть'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        widget.entryList.deleteEntry(entry.id);
                                      });
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
