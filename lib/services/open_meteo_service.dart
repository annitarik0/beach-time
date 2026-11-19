import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/beach.dart';
import '../models/forecast.dart';

class ForecastException implements Exception {
  ForecastException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Talks to the free Open-Meteo APIs (no key needed).
/// Weather, marine (waves, sea temperature, tides), air quality, geocoding.
class OpenMeteoService {
  OpenMeteoService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _timeout = Duration(seconds: 15);

  Future<BeachForecast> fetchForecast(Beach beach) async {
    final coords = {
      'latitude': beach.latitude.toString(),
      'longitude': beach.longitude.toString(),
      'timezone': 'auto',
    };

    final weatherUri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      ...coords,
      'hourly': 'temperature_2m,apparent_temperature,precipitation_probability,'
          'precipitation,cloud_cover,wind_speed_10m,wind_direction_10m,'
          'wind_gusts_10m,uv_index,weather_code,is_day',
      'daily': 'sunrise,sunset,uv_index_max,temperature_2m_max,'
          'temperature_2m_min,precipitation_probability_max,weather_code',
      'forecast_days': '7',
    });
    final marineUri = Uri.https('marine-api.open-meteo.com', '/v1/marine', {
      ...coords,
      'hourly': 'wave_height,wave_period,wave_direction,swell_wave_height,'
          'sea_surface_temperature,sea_level_height_msl',
      'forecast_days': '7',
    });
    final airUri =
        Uri.https('air-quality-api.open-meteo.com', '/v1/air-quality', {
      ...coords,
      'hourly': 'us_aqi',
      'forecast_days': '5',
    });

    // Weather is required; sea and air data are a bonus.
    final results = await Future.wait([
      _getJson(weatherUri),
      _tryGetJson(marineUri),
      _tryGetJson(airUri),
    ]);
    final weather = results[0]!;
    final marine = results[1];
    final air = results[2];

    // The three APIs sometimes disagree on the UTC offset for the same
    // place (seen in Morocco: weather said +0, marine and air said +1).
    // Use the offset most of them agree on and shift every series onto it.
    final offsets = [weather, marine, air]
        .whereType<Map<String, dynamic>>()
        .map((j) => (j['utc_offset_seconds'] as num?)?.toInt())
        .whereType<int>()
        .toList();
    final offset = _majority(offsets) ?? 0;

    final hourly = _parseHourly(weather, marine, air, offset);
    final now = DateTime.now().toUtc().add(Duration(seconds: offset));
    final today = DateTime(now.year, now.month, now.day);
    final daily = _parseDaily(weather, offset).where((d) => !d.date.isBefore(today)).toList();

    return BeachForecast(
      beach: beach,
      hourly: hourly,
      daily: daily,
      utcOffsetSeconds: offset,
      fetchedAt: DateTime.now(),
    );
  }

  static int? _majority(List<int> values) {
    if (values.isEmpty) return null;
    final counts = <int, int>{};
    for (final v in values) {
      counts[v] = (counts[v] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }

  /// Parses an Open-Meteo local time string and moves it from the
  /// response's offset onto the chosen [target] offset (wall-clock result).
  static DateTime _wall(String iso, int responseOffset, int target) {
    final u = DateTime.parse('${iso}Z').add(Duration(seconds: target - responseOffset));
    return DateTime(u.year, u.month, u.day, u.hour, u.minute);
  }

  static int _offsetOf(Map<String, dynamic>? json) =>
      (json?['utc_offset_seconds'] as num?)?.toInt() ?? 0;

  Future<List<Beach>> searchPlaces(String query) async {
    final q = query.trim();
    if (q.length < 2) return const [];
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': q,
      'count': '12',
      'language': 'en',
      'format': 'json',
    });
    final json = await _getJson(uri);
    final results = (json['results'] as List?) ?? const [];
    return results.cast<Map<String, dynamic>>().map((r) {
      return Beach(
        name: r['name'] as String,
        region: r['admin1'] as String?,
        country: r['country'] as String?,
        latitude: (r['latitude'] as num).toDouble(),
        longitude: (r['longitude'] as num).toDouble(),
      );
    }).toList();
  }

  // ---------------------------------------------------------------- parsing

  List<HourlyConditions> _parseHourly(
    Map<String, dynamic> weather,
    Map<String, dynamic>? marine,
    Map<String, dynamic>? air,
    int offset,
  ) {
    final h = weather['hourly'] as Map<String, dynamic>;
    final wo = _offsetOf(weather);
    final times = [for (final t in (h['time'] as List).cast<String>()) _wall(t, wo, offset)];
    final m = marine?['hourly'] as Map<String, dynamic>?;
    final a = air?['hourly'] as Map<String, dynamic>?;
    final mi = _indexByTime(m, _offsetOf(marine), offset);
    final ai = _indexByTime(a, _offsetOf(air), offset);

    return [
      for (var i = 0; i < times.length; i++)
        HourlyConditions(
          time: times[i],
          airTemp: _d(h['temperature_2m'], i) ?? 0,
          feelsLike: _d(h['apparent_temperature'], i) ?? _d(h['temperature_2m'], i) ?? 0,
          rainChance: _d(h['precipitation_probability'], i)?.round() ?? 0,
          precipitation: _d(h['precipitation'], i) ?? 0,
          cloudCover: _d(h['cloud_cover'], i)?.round() ?? 0,
          windSpeed: _d(h['wind_speed_10m'], i) ?? 0,
          windGusts: _d(h['wind_gusts_10m'], i) ?? 0,
          windDirection: _d(h['wind_direction_10m'], i)?.round() ?? 0,
          uvIndex: _d(h['uv_index'], i) ?? 0,
          weatherCode: _d(h['weather_code'], i)?.round() ?? 0,
          isDay: (_d(h['is_day'], i) ?? 1) == 1,
          waterTemp: _d(m?['sea_surface_temperature'], mi[times[i]]),
          waveHeight: _d(m?['wave_height'], mi[times[i]]),
          wavePeriod: _d(m?['wave_period'], mi[times[i]]),
          waveDirection: _d(m?['wave_direction'], mi[times[i]])?.round(),
          swellHeight: _d(m?['swell_wave_height'], mi[times[i]]),
          seaLevel: _d(m?['sea_level_height_msl'], mi[times[i]]),
          aqi: _d(a?['us_aqi'], ai[times[i]])?.round(),
        ),
    ];
  }

  List<DailySummary> _parseDaily(Map<String, dynamic> weather, int offset) {
    final d = weather['daily'] as Map<String, dynamic>;
    final wo = _offsetOf(weather);
    final dates = (d['time'] as List).cast<String>();
    final sunrise = (d['sunrise'] as List).cast<String?>();
    final sunset = (d['sunset'] as List).cast<String?>();
    return [
      for (var i = 0; i < dates.length; i++)
        DailySummary(
          date: DateTime.parse(dates[i]),
          sunrise: _wall(sunrise[i] ?? '${dates[i]}T06:30', wo, offset),
          sunset: _wall(sunset[i] ?? '${dates[i]}T19:00', wo, offset),
          tempMax: _d(d['temperature_2m_max'], i) ?? 0,
          tempMin: _d(d['temperature_2m_min'], i) ?? 0,
          uvMax: _d(d['uv_index_max'], i) ?? 0,
          rainChanceMax: _d(d['precipitation_probability_max'], i)?.round() ?? 0,
          weatherCode: _d(d['weather_code'], i)?.round() ?? 0,
        ),
    ];
  }

  Map<DateTime, int> _indexByTime(Map<String, dynamic>? hourly, int from, int to) {
    final times = (hourly?['time'] as List?)?.cast<String>();
    if (times == null) return const {};
    return {for (var i = 0; i < times.length; i++) _wall(times[i], from, to): i};
  }

  static double? _d(Object? list, int? i) {
    if (list is! List || i == null || i < 0 || i >= list.length) return null;
    final v = list[i];
    return v is num ? v.toDouble() : null;
  }

  // ------------------------------------------------------------------ http

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final http.Response res;
    try {
      res = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw ForecastException('The forecast server is taking too long. Try again.');
    } catch (_) {
      throw ForecastException('No connection. Check your internet and try again.');
    }
    if (res.statusCode != 200) {
      throw ForecastException('Forecast unavailable (error ${res.statusCode}).');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> _tryGetJson(Uri uri) async {
    try {
      return await _getJson(uri);
    } catch (_) {
      return null;
    }
  }
}
