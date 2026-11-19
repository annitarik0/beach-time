import 'beach.dart';

/// Everything we know about one hour at the beach.
class HourlyConditions {
  const HourlyConditions({
    required this.time,
    required this.airTemp,
    required this.feelsLike,
    required this.rainChance,
    required this.precipitation,
    required this.cloudCover,
    required this.windSpeed,
    required this.windGusts,
    required this.windDirection,
    required this.uvIndex,
    required this.weatherCode,
    required this.isDay,
    this.waterTemp,
    this.waveHeight,
    this.wavePeriod,
    this.waveDirection,
    this.swellHeight,
    this.seaLevel,
    this.aqi,
  });

  /// Local wall-clock time at the beach.
  final DateTime time;
  final double airTemp; // °C
  final double feelsLike; // °C
  final int rainChance; // %
  final double precipitation; // mm
  final int cloudCover; // %
  final double windSpeed; // km/h
  final double windGusts; // km/h
  final int windDirection; // degrees, where the wind comes from
  final double uvIndex;
  final int weatherCode; // WMO code
  final bool isDay;

  // Sea data, null when the point is inland or the model has no data.
  final double? waterTemp; // °C
  final double? waveHeight; // m
  final double? wavePeriod; // s
  final int? waveDirection;
  final double? swellHeight; // m
  final double? seaLevel; // m relative to mean sea level (tides)

  final int? aqi; // US AQI

  bool get isThunderstorm => weatherCode >= 95;
}

class DailySummary {
  const DailySummary({
    required this.date,
    required this.sunrise,
    required this.sunset,
    required this.tempMax,
    required this.tempMin,
    required this.uvMax,
    required this.rainChanceMax,
    required this.weatherCode,
  });

  final DateTime date;
  final DateTime sunrise;
  final DateTime sunset;
  final double tempMax;
  final double tempMin;
  final double uvMax;
  final int rainChanceMax;
  final int weatherCode;

  Duration get daylight => sunset.difference(sunrise);
}

class BeachForecast {
  const BeachForecast({
    required this.beach,
    required this.hourly,
    required this.daily,
    required this.utcOffsetSeconds,
    required this.fetchedAt,
  });

  final Beach beach;
  final List<HourlyConditions> hourly;
  final List<DailySummary> daily;
  final int utcOffsetSeconds;
  final DateTime fetchedAt;

  bool get hasSeaData => hourly.any((h) => h.waveHeight != null);

  /// Current wall-clock time at the beach (may differ from the phone's).
  DateTime get beachNow {
    final u = DateTime.now().toUtc().add(Duration(seconds: utcOffsetSeconds));
    return DateTime(u.year, u.month, u.day, u.hour, u.minute);
  }

  List<HourlyConditions> hoursFor(DateTime day) => hourly
      .where((h) =>
          h.time.year == day.year &&
          h.time.month == day.month &&
          h.time.day == day.day)
      .toList();
}
