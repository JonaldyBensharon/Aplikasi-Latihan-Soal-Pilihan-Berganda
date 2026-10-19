import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _key = 'drill_exe_state_v1';
  Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try { return (jsonDecode(raw) as Map).cast<String, dynamic>(); }
    catch (_) { return <String, dynamic>{}; }
  }
  Future<void> save(Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(value));
  }
}
