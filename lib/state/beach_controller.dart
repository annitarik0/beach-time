import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../data/popular_beaches.dart';
import '../logic/activity.dart';
import '../logic/beach_score.dart';
import '../logic/insights.dart';
import '../logic/offline_buddy.dart';
import '../models/beach.dart';
import '../models/forecast.dart';
import '../services/ai_service.dart';
import '../services/location_service.dart';
import '../services/open_meteo_service.dart';
import '../services/storage_service.dart';

class BeachController extends ChangeNotifier {
  BeachController({
    required this.api,
    required this.storage,
    required this.location,
    required this.ai,
  });

  final OpenMeteoService api;
  final StorageService storage;
  final LocationService location;
  final AiService ai;

  List<Beach> savedBeaches = [];
  Beach beach = defaultBeach;
  BeachForecast? forecast;
  bool loading = false;
  String? error;
  Activity activity = Activity.swim;
  bool imperial = false;
  int dayIndex = 0;
  late AiConfig aiConfig;

  List<HourScore> _scores = const [];
  Set<String> _checked = {};

  Units get units => Units(imperial: imperial);

  // ------------------------------------------------------------ lifecycle

  Future<void> init() async {
    savedBeaches = storage.loadBeaches();
    activity = storage.activity;
    imperial = storage.imperial;
    aiConfig = storage.aiConfig;
    final selectedId = storage.selectedBeachId;
    beach = savedBeaches.firstWhere(
      (b) => b.id == selectedId,
      orElse: () => savedBeaches.isNotEmpty ? savedBeaches.first : defaultBeach,
    );
    if (savedBeaches.isEmpty) {
      savedBeaches = [defaultBeach];
      await storage.saveBeaches(savedBeaches);
    }
    await refresh();
  }

  Future<void> refresh() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      forecast = await api.fetchForecast(beach);
      _rescore();
      _loadChecklist();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> selectBeach(Beach b) async {
    beach = b;
    dayIndex = 0;
    forecast = null;
    if (!savedBeaches.contains(b)) {
      savedBeaches = [b, ...savedBeaches];
      await storage.saveBeaches(savedBeaches);
    }
    await storage.setSelectedBeachId(b.id);
    await refresh();
  }

  Future<void> removeBeach(Beach b) async {
    savedBeaches = savedBeaches.where((x) => x != b).toList();
    await storage.saveBeaches(savedBeaches);
    notifyListeners();
  }

  Future<void> useMyLocation() async {
    final here = await location.currentLocation();
    await selectBeach(here);
  }

  void setActivity(Activity a) {
    if (a == activity) return;
    activity = a;
    storage.setActivity(a);
    _rescore();
    notifyListeners();
  }

  void setDay(int i) {
    if (i == dayIndex) return;
    dayIndex = i;
    _loadChecklist();
    notifyListeners();
  }

  void setImperial(bool v) {
    imperial = v;
    storage.setImperial(v);
    notifyListeners();
  }

  void setAiConfig(AiConfig c) {
    aiConfig = c;
    storage.setAiConfig(c);
    notifyListeners();
  }

  void _rescore() {
    final f = forecast;
    _scores = f == null
        ? const []
        : [for (final h in f.hourly) BeachScorer.scoreHour(h, activity)];
  }

  // -------------------------------------------------------------- derived

  bool get isToday => dayIndex == 0;

  DailySummary? get day {
    final d = forecast?.daily;
    if (d == null || d.isEmpty) return null;
    return d[dayIndex.clamp(0, d.length - 1)];
  }

  DateTime get beachNow => forecast?.beachNow ?? DateTime.now();

  List<int> _indicesFor(DateTime date) {
    final f = forecast;
    if (f == null) return const [];
    return [
      for (var i = 0; i < f.hourly.length; i++)
        if (f.hourly[i].time.year == date.year &&
            f.hourly[i].time.month == date.month &&
            f.hourly[i].time.day == date.day)
          i
    ];
  }

  List<HourlyConditions> get dayHours {
    final d = day;
    if (d == null) return const [];
    return [for (final i in _indicesFor(d.date)) forecast!.hourly[i]];
  }

  List<HourScore> get dayScores {
    final d = day;
    if (d == null || _scores.isEmpty) return const [];
    return [for (final i in _indicesFor(d.date)) _scores[i]];
  }

  BestWindow? windowFor(int index) {
    final f = forecast;
    if (f == null || index >= f.daily.length) return null;
    final idx = _indicesFor(f.daily[index].date);
    return BeachScorer.bestWindow(
      [for (final i in idx) f.hourly[i]],
      [for (final i in idx) _scores[i].score],
    );
  }

  BestWindow? get bestWindow => windowFor(dayIndex);

  int get dayScore => bestWindow?.score ?? 0;

  List<int> get weekScores => [
        for (var i = 0; i < (forecast?.daily.length ?? 0); i++)
          windowFor(i)?.score ?? 0
      ];

  int get bestDayIndex {
    final s = weekScores;
    if (s.isEmpty) return 0;
    var best = 0;
    for (var i = 1; i < s.length; i++) {
      if (s[i] > s[best]) best = i;
    }
    return best;
  }

  /// Index (within [dayHours]) of the hour to describe: "now" for today,
  /// otherwise the start of the best window.
  int get focusIndex {
    final hours = dayHours;
    if (hours.isEmpty) return 0;
    if (isToday) {
      final now = beachNow;
      final i = hours.indexWhere((h) => h.time.hour == now.hour);
      if (i >= 0) return i;
    }
    final w = bestWindow;
    if (w != null) {
      final i = hours.indexWhere((h) => h.time == w.start);
      if (i >= 0) return i;
    }
    return (hours.length / 2).floor();
  }

  HourlyConditions? get focusHour {
    final h = dayHours;
    return h.isEmpty ? null : h[focusIndex];
  }

  HourScore? get focusScore {
    final s = dayScores;
    return s.isEmpty ? null : s[focusIndex];
  }

  // ------------------------------------------------------------ checklist

  String get _checkKey =>
      'pack:${beach.id}:${day == null ? '' : DateFormat('yyyy-MM-dd').format(day!.date)}';

  void _loadChecklist() => _checked = storage.checked(_checkKey);

  bool isChecked(String id) => _checked.contains(id);

  void toggleCheck(String id) {
    _checked = {..._checked};
    if (!_checked.remove(id)) _checked.add(id);
    storage.setChecked(_checkKey, _checked);
    notifyListeners();
  }

  List<PackItem> get packing => packingList(dayHours, day, activity);

  // ------------------------------------------------------------------- AI

  /// Compact, factual context so the model reasons over real numbers.
  String aiContext() {
    final f = forecast;
    final d = day;
    if (f == null || d == null) return 'No forecast loaded.';
    final fmt = DateFormat('HH:00');
    final hours = dayHours;
    final scores = dayScores;
    final w = bestWindow;
    final buf = StringBuffer()
      ..writeln('Beach: ${beach.name} ${beach.subtitle}'.trim())
      ..writeln('Date: ${DateFormat('EEEE d MMMM').format(d.date)}'
          '${isToday ? ' (today, local time now ${fmt.format(beachNow)})' : ''}')
      ..writeln('Activity: ${activity.label}')
      ..writeln('Units: ${imperial ? 'imperial' : 'metric (°C, km/h, m)'}')
      ..writeln('Sunrise ${DateFormat.Hm().format(d.sunrise)}, sunset ${DateFormat.Hm().format(d.sunset)}, UV max ${d.uvMax.toStringAsFixed(1)}')
      ..writeln('Day beach score: $dayScore/100'
          '${w != null ? ', best window ${fmt.format(w.start)}-${fmt.format(w.end)}' : ''}')
      ..writeln('Best day this week: ${DateFormat('EEEE').format(f.daily[bestDayIndex].date)} (${weekScores[bestDayIndex]}/100)')
      ..writeln('Hourly (time | score | air°C | water°C | wind km/h dir | gust | waves m/period s | rain% | cloud% | UV | weather | tide m):');
    for (var i = 0; i < hours.length; i++) {
      final h = hours[i];
      if (h.time.hour < 6 || h.time.hour > 21) continue;
      buf.writeln('${fmt.format(h.time)} | ${scores[i].score} | ${h.airTemp.round()} | '
          '${h.waterTemp?.toStringAsFixed(1) ?? '-'} | ${h.windSpeed.round()} ${compass(h.windDirection)} | '
          '${h.windGusts.round()} | ${h.waveHeight?.toStringAsFixed(1) ?? '-'}/${h.wavePeriod?.round() ?? '-'} | '
          '${h.rainChance} | ${h.cloudCover} | ${h.uvIndex.toStringAsFixed(1)} | '
          '${weatherInfo(h.weatherCode).label} | ${h.seaLevel?.toStringAsFixed(2) ?? '-'}');
    }
    final safety = focusHour == null ? null : safetyFor(focusHour!);
    if (safety != null) {
      buf.writeln('Estimated flag: ${safety.flagLabel}, rip risk ${safety.ripRisk}');
    }
    return buf.toString();
  }

  /// Always answers: the chosen AI first, then the free built-in model,
  /// then offline answers computed from the forecast.
  Future<BuddyReply> askAi(List<AiMessage> history) async {
    final withContext = [
      AiMessage('user', 'Forecast data:\n${aiContext()}'),
      const AiMessage('assistant', 'Got it, I have the forecast. Ask me anything!'),
      ...history,
    ];
    final question = history.lastWhere((m) => m.role == 'user').content;
    try {
      return BuddyReply(await ai.chat(aiConfig, withContext));
    } on AiBusyException catch (e) {
      if (e.retryAfter <= const Duration(seconds: 12)) {
        await Future<void>.delayed(e.retryAfter + const Duration(seconds: 1));
        try {
          return BuddyReply(await ai.chat(aiConfig, withContext));
        } catch (_) {}
      }
    } catch (_) {
      if (!aiConfig.isFree) {
        try {
          return BuddyReply(await ai.chat(AiConfig.free, withContext));
        } catch (_) {}
      }
    }
    return BuddyReply(offlineAnswer(question, this), offline: true);
  }
}
