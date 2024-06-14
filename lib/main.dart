import 'package:flutter/material.dart';
import 'category_list.dart';
import 'category_screen.dart';
import 'entry_list.dart';
import 'chart_screen.dart';
import 'history_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  initializeDateFormatting('ru_RU', null).then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ru', 'RU'), 
      ],
      home: const MyHomePage(title: 'Финансовый менеджер'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final EntryList _entryList = EntryList();
  final CategoryList _categoryList = CategoryList();

  @override
  void initState() {
    super.initState();
    _entryList.loadEntries();
    _categoryList.loadCategories();
  }

  void _updateState() {
    _entryList.loadEntries();
    _categoryList.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ChartScreen(entries: _entryList, categories: _categoryList),
          CategoryScreen(categoryList: _categoryList),
          HistoryScreen(entryList: _entryList, categoryList: _categoryList),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Категории',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'История',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _updateState(); 
          });
        },
      ),
    );
  }
}




// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   int _currentIndex = 0;
//   late SharedPreferences prefs;
//   late List<ViewedNews> viewedNews = [];

//   void onTabTapped(int index) async {
//     setState(() {
//       _currentIndex = index;
//     });
//     if (index == 1 || index == 2) {
//       await initSharedPreferences();
//     }
//   }

//   initSharedPreferences() async {
//     prefs = await SharedPreferences.getInstance();
//     viewedNews = (prefs.getStringList('viewedNews') ?? [])
//         .map((jsonString) => ViewedNews.fromMap(json.decode(jsonString)))
//         .toList();
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Новостной клиент',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       debugShowCheckedModeBanner: false,
//       localizationsDelegates: [
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: [
//         const Locale('ru', 'RU'), // Добавьте русский язык
//       ],
//       home: Scaffold(
//         body: IndexedStack(
//           index: _currentIndex,
//           children: [
//             NewsList(),
//             ViewedTab(viewedNews: viewedNews),
//           ],
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           onTap: onTabTapped,
//           items: const <BottomNavigationBarItem>[
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home),
//               label: 'Главная',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.remove_red_eye), // иконка просмотра
//               label: 'Просмотренное',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
