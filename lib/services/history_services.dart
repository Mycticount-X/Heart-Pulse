import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String _key = 'heart_pulse_history';

  static Future<void> saveHistory(Map<String, dynamic> requestData, Map<String, dynamic> resultData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> histories = prefs.getStringList(_key) ?? [];

    final newEntry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'date': DateTime.now().toIso8601String(),
      'request': requestData,
      'response': resultData,
    };

    histories.insert(0, jsonEncode(newEntry));
    await prefs.setStringList(_key, histories);
  }

  static Future<List<Map<String, dynamic>>> getHistories() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> histories = prefs.getStringList(_key) ?? [];
    
    return histories.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }
}