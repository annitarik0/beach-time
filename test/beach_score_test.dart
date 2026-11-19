import 'package:beach_time/logic/activity.dart';
import 'package:beach_time/logic/beach_score.dart';
import 'package:beach_time/logic/insights.dart';
import 'package:beach_time/models/forecast.dart';
import 'package:flutter_test/flutter_test.dart';

HourlyConditions hour({
  int h = 12,
  double air = 29,
  double? water = 25,
  double wind = 8,
  double gusts = 14,
  double? waves = .3,
  double? period = 6,
  int rain = 0,
  int cloud = 5,
  double uv = 6,
  int code = 0,
  bool isDay = true,
  double? sea,
}) =>
    HourlyConditions(
      time: DateTime(2026, 7, 15, h),
      airTemp: air,
      feelsLike: air,
      rainChance: rain,
      precipitation: rain > 60 ? 4 : 0,
      cloudCover: cloud,
      windSpeed: wind,
      windGusts: gusts,
      windDirection: 270,
      uvIndex: uv,
      weatherCode: code,
      isDay: isDay,
      waterTemp: water,
      waveHeight: waves,
      wavePeriod: period,
      seaLevel: sea,
    );

void main() {
  group('BeachScorer.scoreHour', () {
    test('a perfect summer hour scores very high for swimming', () {
      final s = BeachScorer.scoreHour(hour(), Activity.swim);
      expect(s.score, greaterThanOrEqualTo(85));
      expect(s.penalty, isNull);
    });

    test('a cold, rainy, windy hour scores low', () {
      final s = BeachScorer.scoreHour(
          hour(air: 13, water: 14, wind: 38, gusts: 60, waves: 2.2, rain: 90, cloud: 100, code: 63),
          Activity.swim);
      expect(s.score, lessThan(20));
    });

    test('thunderstorms cap the score at 5', () {
      final s = BeachScorer.scoreHour(hour(code: 95), Activity.sunbathe);
      expect(s.score, lessThanOrEqualTo(5));
      expect(s.penalty, contains('Thunderstorm'));
    });

    test('night hours are heavily penalised', () {
      final day = BeachScorer.scoreHour(hour(), Activity.swim).score;
      final night = BeachScorer.scoreHour(hour(isDay: false, uv: 0), Activity.swim).score;
      expect(night, lessThan(day * .3));
    });

    test('surfers prefer waves, swimmers prefer flat water', () {
      final flat = hour(waves: .2, period: 5);
      final swell = hour(waves: 1.8, period: 12);
      expect(BeachScorer.scoreHour(swell, Activity.surf).score,
          greaterThan(BeachScorer.scoreHour(flat, Activity.surf).score));
      expect(BeachScorer.scoreHour(flat, Activity.swim).score,
          greaterThan(BeachScorer.scoreHour(swell, Activity.swim).score));
    });

    test('factor weights sum to 1 for every activity', () {
      for (final a in Activity.values) {
        final sum = BeachScorer.scoreHour(hour(), a).factors.fold<double>(0, (s, f) => s + f.weight);
        expect(sum, closeTo(1, 1e-9), reason: a.name);
      }
    });
  });

  group('BeachScorer.bestWindow', () {
    test('finds the best block of daylight', () {
      final hours = [for (var h = 0; h < 24; h++) hour(h: h, isDay: h >= 7 && h <= 19)];
      final scores = [for (var h = 0; h < 24; h++) (h >= 11 && h <= 13) ? 90 : (h >= 7 && h <= 19 ? 50 : 5)];
      final w = BeachScorer.bestWindow(hours, scores)!;
      expect(w.start.hour, 11);
      expect(w.end.hour, 14);
      expect(w.score, 90);
    });

    test('returns null without daylight', () {
      final hours = [for (var h = 0; h < 5; h++) hour(h: h, isDay: false)];
      expect(BeachScorer.bestWindow(hours, List.filled(5, 10)), isNull);
    });
  });

  group('insights', () {
    test('safety flags escalate with waves and storms', () {
      expect(safetyFor(hour(waves: .3)).flag, FlagLevel.green);
      expect(safetyFor(hour(waves: 1, period: 6)).flag, FlagLevel.yellow);
      expect(safetyFor(hour(waves: 1.7)).flag, FlagLevel.red);
      expect(safetyFor(hour(code: 95)).flag, FlagLevel.doubleRed);
    });

    test('tide extremes are detected', () {
      final hours = [
        for (var h = 0; h < 24; h++) hour(h: h, sea: [0.0, .5, 1.0, .5, 0.0, -.5, -1.0, -.5][h % 8])
      ];
      final events = tideEvents(hours);
      expect(events.where((e) => e.isHigh).first.time.hour, 2);
      expect(events.where((e) => !e.isHigh).first.time.hour, 6);
    });

    test('packing list adapts to conditions', () {
      final hot = packingList([hour(air: 34, uv: 10)], null, Activity.swim).map((i) => i.id);
      expect(hot, containsAll(['sunscreen', 'umbrella', 'hat', 'cooler']));
      final surf = packingList([hour(water: 15)], null, Activity.surf).map((i) => i.id);
      expect(surf, containsAll(['board', 'wetsuit']));
    });

    test('sun advice scales SPF with UV', () {
      expect(sunAdvice(2).spf, 'SPF 15');
      expect(sunAdvice(9).spf, 'SPF 50+');
      expect(sunAdvice(10).burnMinutes, 17);
    });
  });
}
