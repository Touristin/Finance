import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'objects.dart';

class EntryList {
  List<Entry> _entries = [];

  static Future<EntryList> initialize() async {
    final entryList = EntryList();
    await entryList.loadEntries();
    return entryList;
  }

  Future<void> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('entries') ?? '[]';
    final jsonList = json.decode(jsonString) as List<dynamic>;
    _entries = jsonList.map((json) => Entry.fromJson(json)).toList();
  }

  Future<void> saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
        json.encode(_entries.map((entry) => entry.toJson()).toList());
    await prefs.setString('entries', jsonString);
  }

  void addEntry(Entry entry) {
    _entries.add(entry);
    saveEntries();
  }

  void updateEntry(String id, Entry updatedEntry) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      _entries[index] = updatedEntry;
      saveEntries();
    }
  }

  void updateEntries(List<Entry> newEntries) {
    _entries = newEntries;
    saveEntries();
  }

  void deleteEntry(String id) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      _entries.removeAt(index);
      saveEntries();
    }
  }

  List<Entry> get reversed => _entries.reversed.toList();
  List<Entry> get entries => _entries;

  List<Entry> where(bool Function(Entry entry) predicate) {
    return _entries.where(predicate).toList();
  }
}
