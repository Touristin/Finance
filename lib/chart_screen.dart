import 'category_list.dart';
import 'entry_list.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'objects.dart';

enum Filter { lastDay, lastWeek, lastMonth, allTime }

class ChartScreen extends StatefulWidget {
  final EntryList entries;
  final CategoryList categories;

  const ChartScreen(
      {super.key, required this.entries, required this.categories});

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  Filter _selectedFilter = Filter.allTime;

  List<DoughnutSeries<MapEntry<String, double>, String>> _createSeries(
      List<Entry> entries, bool isIncome, Filter filter) {
    Map<String, double> groupedEntries = _groupEntriesByCategory(entries);

    return [
      DoughnutSeries<MapEntry<String, double>, String>(
        dataSource: groupedEntries.entries.toList(),
        xValueMapper: (MapEntry<String, double> entry, _) => entry.key,
        yValueMapper: (MapEntry<String, double> entry, _) => entry.value,
        pointColorMapper: (MapEntry<String, double> entry, _) {
          Category category = widget.categories.categories
              .where((category) => category.name == entry.key)
              .toList()
              .first;
          return category.color;
        },
        dataLabelMapper: (MapEntry<String, double> entry, _) =>
            '${entry.key}\n${entry.value}',
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
          connectorLineSettings:
              ConnectorLineSettings(length: '5%', type: ConnectorType.line),
          textStyle: TextStyle(
              color: Colors
                  .black), 
        ),
      ),
    ];
  }

  Map<String, double> _groupEntriesByCategory(List<Entry> entries) {
    Map<String, double> categoryTotals = {};

    for (Entry entry in entries) {
      if (categoryTotals.containsKey(entry.category.name)) {
        categoryTotals[entry.category.name] =
            categoryTotals[entry.category.name]! + entry.price;
      } else {
        categoryTotals[entry.category.name] = entry.price;
      }
    }

    return categoryTotals;
  }

  List<Entry> _filterEntriesByType(bool isIncome, Filter filter) {
    List<Entry> filteredEntries = widget.entries
        .where((entry) => entry.category.isIncome == isIncome)
        .toList();

    switch (filter) {
      case Filter.lastDay:
        filteredEntries = filteredEntries
            .where((entry) =>
                entry.date.isAfter(DateTime.now().subtract(Duration(days: 1))))
            .toList();
        break;
      case Filter.lastWeek:
        filteredEntries = filteredEntries
            .where((entry) =>
                entry.date.isAfter(DateTime.now().subtract(Duration(days: 7))))
            .toList();
        break;
      case Filter.lastMonth:
        filteredEntries = filteredEntries
            .where((entry) =>
                entry.date.isAfter(DateTime.now().subtract(Duration(days: 30))))
            .toList();
        break;
      case Filter.allTime:
        break;
    }

    return filteredEntries;
  }

  Future<void> _loadData() async {
    await widget.entries.loadEntries();
    await widget.categories.loadCategories();
  }

  String _getFilterLabel(Filter filter) {
    switch (filter) {
      case Filter.lastDay:
        return 'Last Day';
      case Filter.lastWeek:
        return 'Last Week';
      case Filter.lastMonth:
        return 'Last Month';
      case Filter.allTime:
        return 'All Time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadData(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Entry> incomeEntries =
                _filterEntriesByType(true, _selectedFilter);
            List<Entry> expenseEntries =
                _filterEntriesByType(false, _selectedFilter);

            double totalIncome = incomeEntries.fold(
                0, (previousValue, entry) => previousValue + entry.price);
            double totalExpense = expenseEntries.fold(
                0, (previousValue, entry) => previousValue + entry.price);

            double balance = totalIncome - totalExpense;
            String balanceText = '';

            if (balance > 0) {
              balanceText = 'Итоги: + ${balance.toStringAsFixed(2)}';
            } else if (balance < 0) {
              balanceText = 'Итоги: ${balance.toStringAsFixed(2)}';
            } else {
              balanceText = 'Итоги: 0';
            }
            return SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(top: 35),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20.0),
                      SegmentedButton<Filter>(
                        segments: <Filter>{
                          Filter.lastDay,
                          Filter.lastWeek,
                          Filter.lastMonth,
                          Filter.allTime,
                        }.map<ButtonSegment<Filter>>((Filter filter) {
                          return ButtonSegment<Filter>(
                            value: filter,
                            label: Text(
                              _getFilterLabel(filter),
                              style: TextStyle(
                                color: _selectedFilter == filter
                                    ? Colors.black
                                    : Colors.grey,
                                fontSize: 12.0,
                              ),
                            ),
                          );
                        }).toList(),
                        selected: <Filter>{_selectedFilter},
                        onSelectionChanged: (Set<Filter>? newSelection) {
                          if (newSelection != null && newSelection.isNotEmpty) {
                            setState(() {
                              _selectedFilter = newSelection.first;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 16.0),
                      Text('Доходы',
                          style:
                              TextStyle(color: Colors.black, fontSize: 24.0)),
                      SizedBox(height: 16.0),
                      Container(
                        height: 300,
                        color: Colors.grey[300],
                        child: SfCircularChart(
                            series: _createSeries(
                                incomeEntries, true, _selectedFilter)),
                      ),
                      SizedBox(height: 16.0),
                      Text('Расходы',
                          style:
                              TextStyle(color: Colors.black, fontSize: 24.0)),
                      SizedBox(height: 16.0),
                      Container(
                        height: 300,
                        color: Colors.grey[300],
                        child: SfCircularChart(
                            series: _createSeries(
                                expenseEntries, false, _selectedFilter)),
                      ),
                      SizedBox(height: 16.0),
                      Text(balanceText,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  24.0)), // Добавлено для отображения баланса
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}
