import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../logic/activity.dart';
import '../models/beach.dart';
import 'ai_service.dart';

class StorageService {
  StorageService._(this._prefs);
  final SharedPreferences _prefs;

  static Future<StorageService> create() async =>
      StorageService._(await SharedPreferences.getInstance());

  List<Beach> loadBeaches() {
    final raw = _prefs.getString('beaches');
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Beach.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBeaches(List<Beach> beaches) => _prefs.setString(
      'beaches', jsonEncode(beaches.map((b) => b.toJson()).toList()));

  String? get selectedBeachId => _prefs.getString('selected');
  Future<void> setSelectedBeachId(String id) => _prefs.setString('selected', id);

  Activity get activity => Activity.values.firstWhere(
        (a) => a.name == _prefs.getString('activity'),
        orElse: () => Activity.swim,
      );
  Future<void> setActivity(Activity a) => _prefs.setString('activity', a.name);

  bool get imperial => _prefs.getBool('imperial') ?? false;
  Future<void> setImperial(bool v) => _prefs.setBool('imperial', v);

  Set<String> checked(String key) =>
      (_prefs.getStringList(key) ?? const []).toSet();
  Future<void> setChecked(String key, Set<String> ids) =>
      _prefs.setStringList(key, ids.toList());

  AiConfig get aiConfig {
    final raw = _prefs.getString('ai');
    if (raw == null) return AiConfig.free;
    try {
      final c = AiConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      // Old default (Ollama on localhost) never works on a phone.
      return c.isConfigured && !c.baseUrl.contains('localhost:11434') ? c : AiConfig.free;
    } catch (_) {
      return AiConfig.free;
    }
  }

  Future<void> setAiConfig(AiConfig c) =>
      _prefs.setString('ai', jsonEncode(c.toJson()));
}
