import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/ph_icons.dart';

import '../models/forecast.dart';
import '../theme/palette.dart';
import 'activity.dart';

/// One ingredient of the score, shown in the "Why this score?" sheet.
class ScoreFactor {
  const ScoreFactor(this.label, this.value, this.weight, this.icon);
  final String label;
  final double value; // 0..1
  final double weight; // 0..1
  final IconData icon;
}

class HourScore {
  const HourScore(this.score, this.factors, this.penalty);
  final int score; // 0..100
  final List<ScoreFactor> factors;
  final String? penalty; // why the score was capped, if it was
}

class BestWindow {
  const BestWindow({required this.start, required this.end, required this.score});
  final DateTime start;
  final DateTime end; // exclusive
  final int score;
  int get hours => end.difference(start).inHours;
}

/// Surfline-style word rating plus a sentence of advice.
class Verdict {
  const Verdict(this.rating, this.title, this.color, this.message);
  final String rating; // EPIC, GOOD, FAIR, POOR, VERY POOR
  final String title;
  final Color color;
  final String message;
}

/// The brain of the app: turns raw weather and sea data into a 0-100
/// "beach score" for a given activity.
class BeachScorer {
  static double _ramp(double x, double x0, double x1) =>
      ((x - x0) / (x1 - x0)).clamp(0.0, 1.0).toDouble();

  static const _weights = <Activity, Map<String, double>>{
    Activity.swim: {'air': .22, 'water': .22, 'wind': .14, 'waves': .18, 'rain': .12, 'sky': .08, 'uv': .04},
    Activity.surf: {'air': .08, 'water': .10, 'wind': .22, 'waves': .40, 'rain': .10, 'sky': .05, 'uv': .05},
    Activity.sunbathe: {'air': .26, 'water': .06, 'wind': .16, 'waves': .04, 'rain': .22, 'sky': .20, 'uv': .06},
  };

  static HourScore scoreHour(HourlyConditions h, Activity a) {
    final w = _weights[a]!;
    final t = h.airTemp;

    final air = switch (a) {
      Activity.surf => t <= 32 ? _ramp(t, 8, 22) : 1 - .5 * _ramp(t, 32, 40),
      _ => t <= 32 ? _ramp(t, 14, 26) : 1 - .5 * _ramp(t, 32, 40),
    };

    final wt = h.waterTemp;
    final water = wt == null
        ? .55
        : switch (a) {
            Activity.swim => wt <= 29 ? _ramp(wt, 15, 24) : .9,
            Activity.surf => _ramp(wt, 10, 19),
            Activity.sunbathe => _ramp(wt, 14, 22),
          };

    final wind = switch (a) {
      Activity.surf => 1 - _ramp(h.windSpeed, 15, 45),
      _ => 1 - _ramp(h.windSpeed, 12, 40),
    };

    final wh = h.waveHeight;
    final double waves;
    if (wh == null) {
      waves = .6;
    } else {
      waves = switch (a) {
        Activity.swim => 1 - _ramp(wh, .4, 1.8),
        Activity.surf => (wh < 1 ? _ramp(wh, .3, 1) : 1 - .7 * _ramp(wh, 2.5, 4.5)) * .7 +
            _ramp(h.wavePeriod ?? 7, 6, 12) * .3,
        Activity.sunbathe => 1 - _ramp(wh, 1, 3),
      };
    }

    final rain = 1 - _ramp(h.rainChance.toDouble(), 10, 70);
    final cloud = h.cloudCover / 100;
    final sky = switch (a) {
      Activity.sunbathe => 1 - cloud * .9,
      Activity.swim => 1 - cloud * .6,
      Activity.surf => 1 - cloud * .3,
    };
    final uv = 1 - .4 * _ramp(h.uvIndex, 7, 11);

    final factors = [
      ScoreFactor('Air temperature', air, w['air']!, PhIcons.thermometerSimple),
      ScoreFactor('Water temperature', water, w['water']!, PhIcons.drop),
      ScoreFactor('Wind', wind, w['wind']!, PhIcons.wind),
      ScoreFactor(a == Activity.surf ? 'Surf quality' : 'Calm sea', waves, w['waves']!, PhIcons.waves),
      ScoreFactor('Dry weather', rain, w['rain']!, PhIcons.umbrella),
      ScoreFactor('Sunshine', sky, w['sky']!, PhIcons.sun),
      ScoreFactor('Safe UV', uv, w['uv']!, PhIcons.shieldCheck),
    ];

    var score = factors.fold<double>(0, (s, f) => s + f.value * f.weight) * 100;
    String? penalty;

    if (h.precipitation > 2) {
      score *= .6;
      penalty = 'Heavy rain expected';
    }
    if (h.windGusts > 55) {
      score *= .6;
      penalty = 'Strong gusts';
    }
    if (!h.isDay) {
      score *= .2;
      penalty = 'It is dark';
    }
    if (h.isThunderstorm) {
      score = math.min(score, 5);
      penalty = 'Thunderstorm, stay out of the water';
    }

    return HourScore(score.round().clamp(0, 100), factors, penalty);
  }

  /// Finds the best stretch of daylight: the top 3-hour block, then grows
  /// it while neighbouring hours stay nearly as good (max 6 hours).
  static BestWindow? bestWindow(List<HourlyConditions> hours, List<int> scores) {
    final day = [for (var i = 0; i < hours.length; i++) if (hours[i].isDay) i];
    if (day.isEmpty) return null;
    final len = math.min(3, day.length);

    int? bestStart;
    var bestAvg = -1.0;
    for (var s = 0; s + len <= day.length; s++) {
      final idx = day.sublist(s, s + len);
      if (idx.last - idx.first != len - 1) continue;
      final avg = idx.map((i) => scores[i]).reduce((a, b) => a + b) / len;
      if (avg > bestAvg) {
        bestAvg = avg;
        bestStart = idx.first;
      }
    }
    if (bestStart == null) return null;

    var from = bestStart;
    var to = bestStart + len - 1;
    bool good(int i) =>
        i >= 0 && i < hours.length && hours[i].isDay && scores[i] >= bestAvg - 6;
    while (to - from + 1 < 6) {
      if (good(to + 1) && (!good(from - 1) || scores[to + 1] >= scores[from - 1])) {
        to++;
      } else if (good(from - 1)) {
        from--;
      } else {
        break;
      }
    }
    final avg = [for (var i = from; i <= to; i++) scores[i]].reduce((a, b) => a + b) /
        (to - from + 1);
    return BestWindow(
      start: hours[from].time,
      end: hours[to].time.add(const Duration(hours: 1)),
      score: avg.round(),
    );
  }

  static String rating(int score) {
    if (score >= 85) return 'EPIC';
    if (score >= 70) return 'GOOD';
    if (score >= 55) return 'FAIR';
    if (score >= 40) return 'POOR';
    return 'VERY POOR';
  }

  static Verdict verdict(int score, Activity a) {
    final color = Palette.score(score);
    final r = rating(score);
    if (score >= 85) {
      return Verdict(r, 'A perfect beach day', color,
          'Drop everything. Conditions are ideal to ${a.verb}.');
    }
    if (score >= 70) {
      return Verdict(r, 'A good beach day', color,
          'Really nice conditions to ${a.verb}. Worth the trip.');
    }
    if (score >= 55) {
      return Verdict(r, 'Fair conditions', color,
          'Not perfect, but a good session is very possible.');
    }
    if (score >= 40) {
      return Verdict(r, 'Pick your hours', color,
          'Manageable, but only at the right time of day.');
    }
    return Verdict(r, 'Better stay dry', color,
        'Not a beach day here. Check the week ahead.');
  }

  static Color colorFor(int score) => Palette.score(score);
}
