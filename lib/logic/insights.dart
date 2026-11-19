import 'package:flutter/material.dart';
import '../theme/ph_icons.dart';

import '../theme/palette.dart';

import '../models/forecast.dart';
import 'activity.dart';

// ------------------------------------------------------------------ weather

class WeatherInfo {
  const WeatherInfo(this.label, this.icon, this.iconFill);
  final String label;
  final IconData icon; // regular weight
  final IconData iconFill; // for large hero use
}

WeatherInfo weatherInfo(int code, {bool isDay = true}) {
  return switch (code) {
    0 => isDay
        ? const WeatherInfo('Clear sky', PhIcons.sun, PhIcons.sunFill)
        : const WeatherInfo('Clear night', PhIcons.moon, PhIcons.moonFill),
    1 || 2 => isDay
        ? WeatherInfo(code == 1 ? 'Mostly sunny' : 'Partly cloudy', PhIcons.cloudSun, PhIcons.cloudSunFill)
        : const WeatherInfo('Partly cloudy', PhIcons.cloudMoon, PhIcons.cloudMoonFill),
    3 => const WeatherInfo('Overcast', PhIcons.cloud, PhIcons.cloudFill),
    45 || 48 => const WeatherInfo('Fog', PhIcons.cloudFog, PhIcons.cloudFogFill),
    51 || 53 || 55 || 56 || 57 => const WeatherInfo('Drizzle', PhIcons.cloudRain, PhIcons.cloudRainFill),
    61 || 63 || 80 || 81 => const WeatherInfo('Rain showers', PhIcons.cloudRain, PhIcons.cloudRainFill),
    65 || 66 || 67 || 82 => const WeatherInfo('Heavy rain', PhIcons.cloudRain, PhIcons.cloudRainFill),
    71 || 73 || 75 || 77 || 85 || 86 => const WeatherInfo('Snow', PhIcons.cloudSnow, PhIcons.cloudSnowFill),
    95 || 96 || 99 => const WeatherInfo('Thunderstorm', PhIcons.cloudLightning, PhIcons.cloudLightningFill),
    _ => const WeatherInfo('Mixed', PhIcons.cloud, PhIcons.cloudFill),
  };
}

String compass(int degrees) {
  const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  return dirs[((degrees % 360) / 45).round() % 8];
}

// ------------------------------------------------------------------- units

class Units {
  const Units({this.imperial = false});
  final bool imperial;

  String temp(double c) => '${(imperial ? c * 9 / 5 + 32 : c).round()}°';
  String wind(double kmh) =>
      imperial ? '${(kmh * .621371).round()} mph' : '${kmh.round()} km/h';
  String height(double m) =>
      imperial ? '${(m * 3.28084).toStringAsFixed(1)} ft' : '${m.toStringAsFixed(1)} m';
}

// -------------------------------------------------------------------- sun

class SunAdvice {
  const SunAdvice(this.level, this.color, this.spf, this.burnMinutes, this.tip);
  final String level;
  final Color color;
  final String spf;
  final int? burnMinutes; // fair skin (type II), null when UV is negligible
  final String tip;
}

SunAdvice sunAdvice(double uv) {
  // UV index 1 = 0.025 W/m² erythemal; ~250 J/m² burns type II skin.
  final burn = uv < 1 ? null : (167 / uv).round();
  if (uv < 3) {
    return SunAdvice('Low', Palette.kelp, 'SPF 15', burn,
        'Minimal risk. Sunglasses on bright sand.');
  }
  if (uv < 6) {
    return SunAdvice('Moderate', Palette.sun, 'SPF 30', burn,
        'Reapply every 2 h and after swimming.');
  }
  if (uv < 8) {
    return SunAdvice('High', const Color(0xFFEA8A3A), 'SPF 30+', burn,
        'Seek shade 12:00-15:00. Hat & sunglasses.');
  }
  if (uv < 11) {
    return SunAdvice('Very high', Palette.coral, 'SPF 50+', burn,
        'Shade at midday. Reapply every 80 min.');
  }
  return SunAdvice('Extreme', const Color(0xFF9B3D6E), 'SPF 50+', burn,
      'Avoid the midday sun. Cover up fully.');
}

// ----------------------------------------------------------------- safety

enum FlagLevel { green, yellow, red, doubleRed }

class SafetyReport {
  const SafetyReport(this.flag, this.ripRisk, this.headline, this.notes);
  final FlagLevel flag;
  final String ripRisk;
  final String headline;
  final List<String> notes;

  Color get color => switch (flag) {
        FlagLevel.green => Palette.kelp,
        FlagLevel.yellow => Palette.sun,
        FlagLevel.red => Palette.coral,
        FlagLevel.doubleRed => const Color(0xFFB3261E),
      };

  String get flagLabel => switch (flag) {
        FlagLevel.green => 'Green flag',
        FlagLevel.yellow => 'Yellow flag',
        FlagLevel.red => 'Red flag',
        FlagLevel.doubleRed => 'Double red',
      };
}

SafetyReport safetyFor(HourlyConditions h) {
  final wave = h.waveHeight ?? 0;
  final period = h.wavePeriod ?? 0;
  final notes = <String>[];

  FlagLevel flag;
  if (h.isThunderstorm || wave >= 2.5 || h.windGusts >= 70) {
    flag = FlagLevel.doubleRed;
  } else if (wave >= 1.5 || (wave >= 1 && period >= 11) || h.windGusts >= 50) {
    flag = FlagLevel.red;
  } else if (wave >= .8 || h.windSpeed >= 25 || period >= 9) {
    flag = FlagLevel.yellow;
  } else {
    flag = FlagLevel.green;
  }

  final rip = switch (flag) {
    FlagLevel.doubleRed || FlagLevel.red => 'High',
    FlagLevel.yellow => 'Moderate',
    FlagLevel.green => 'Low',
  };

  if (h.isThunderstorm) notes.add('Lightning risk: leave the water and the beach.');
  if (period >= 10) notes.add('Long-period swell: sets can surprise you.');
  if (h.windSpeed >= 25) notes.add('Strong wind can push you away from shore.');
  if (h.waveHeight == null) notes.add('No sea data for this spot.');
  if ((h.aqi ?? 0) > 100) notes.add('Air quality is poor for sensitive groups.');
  notes.add('Estimate only. Always follow the lifeguards and local flags.');

  final headline = switch (flag) {
    FlagLevel.green => 'Calm water, enjoy!',
    FlagLevel.yellow => 'Swim with care',
    FlagLevel.red => 'Dangerous currents likely',
    FlagLevel.doubleRed => 'Stay out of the water',
  };
  return SafetyReport(flag, rip, headline, notes);
}

String aqiLabel(int aqi) {
  if (aqi <= 50) return 'Good';
  if (aqi <= 100) return 'Moderate';
  if (aqi <= 150) return 'Unhealthy (sensitive)';
  if (aqi <= 200) return 'Unhealthy';
  return 'Very unhealthy';
}

// ------------------------------------------------------------------ tides

class TideEvent {
  const TideEvent(this.time, this.height, this.isHigh);
  final DateTime time;
  final double height;
  final bool isHigh;
}

List<TideEvent> tideEvents(List<HourlyConditions> hours) {
  final events = <TideEvent>[];
  for (var i = 1; i < hours.length - 1; i++) {
    final prev = hours[i - 1].seaLevel, cur = hours[i].seaLevel, next = hours[i + 1].seaLevel;
    if (prev == null || cur == null || next == null) continue;
    if (cur > prev && cur >= next) events.add(TideEvent(hours[i].time, cur, true));
    if (cur < prev && cur <= next) events.add(TideEvent(hours[i].time, cur, false));
  }
  return events;
}

// ---------------------------------------------------------------- packing

class PackItem {
  const PackItem(this.id, this.icon, this.label, [this.reason]);
  final String id;
  final IconData icon;
  final String label;
  final String? reason;
}

List<PackItem> packingList(
  List<HourlyConditions> hours,
  DailySummary? day,
  Activity activity,
) {
  final daylight = hours.where((h) => h.isDay).toList();
  final source = daylight.isEmpty ? hours : daylight;
  if (source.isEmpty) return const [];

  double maxOf(double Function(HourlyConditions) f) =>
      source.map(f).reduce((a, b) => a > b ? a : b);
  final maxTemp = maxOf((h) => h.airTemp);
  final maxUv = day?.uvMax ?? maxOf((h) => h.uvIndex);
  final maxRain = maxOf((h) => h.rainChance.toDouble());
  final maxWind = maxOf((h) => h.windSpeed);
  final water = source.map((h) => h.waterTemp).whereType<double>().fold<double?>(
      null, (a, b) => a == null || b > a ? b : a);
  final minEvening = day?.tempMin ?? maxTemp;
  final waves = source.map((h) => h.waveHeight).whereType<double>().fold<double>(0, (a, b) => b > a ? b : a);
  final liters = maxTemp >= 30 ? 3 : (maxTemp >= 24 ? 2 : 1);
  final spf = sunAdvice(maxUv).spf;

  return [
    PackItem('sunscreen', PhIcons.dropHalf, 'Sunscreen $spf', 'UV peaks at ${maxUv.round()}'),
    PackItem('water', PhIcons.drop, '$liters L of water', maxTemp >= 30 ? 'Hot day, hydrate often' : null),
    const PackItem('towel', PhIcons.towel, 'Beach towel'),
    if (activity != Activity.sunbathe || maxTemp >= 26) const PackItem('swimsuit', PhIcons.personSimpleSwim, 'Swimsuit'),
    if (maxUv >= 3) const PackItem('sunglasses', PhIcons.sunglasses, 'Sunglasses'),
    if (maxUv >= 6) const PackItem('hat', PhIcons.sunHorizon, 'Sun hat'),
    if (maxUv >= 7 || maxTemp >= 30) const PackItem('umbrella', PhIcons.umbrellaSimple, 'Beach umbrella', 'For shade at midday'),
    if (activity == Activity.surf) const PackItem('board', PhIcons.waves, 'Surfboard & leash'),
    if (activity == Activity.surf || (water != null && water < 19))
      PackItem('wetsuit', PhIcons.tShirt, water != null && water < 16 ? 'Wetsuit 4/3 mm' : 'Wetsuit 3/2 mm',
          water != null ? 'Water ${water.round()}°C' : null),
    if (activity == Activity.swim && waves < .6) const PackItem('snorkel', PhIcons.fish, 'Snorkel & mask', 'Calm, clear water'),
    if (maxWind >= 25 || maxTemp < 22) const PackItem('windbreaker', PhIcons.wind, 'Windbreaker'),
    if (minEvening < 18) const PackItem('sweater', PhIcons.hoodie, 'Sweater for the evening'),
    if (maxRain >= 40) PackItem('rain', PhIcons.umbrella, 'Rain jacket', '${maxRain.round()}% rain chance'),
    if (maxTemp >= 27) const PackItem('cooler', PhIcons.iceCream, 'Cooler & snacks'),
    const PackItem('flipflops', PhIcons.sneaker, 'Flip-flops'),
    if (activity == Activity.sunbathe) const PackItem('book', PhIcons.bookOpen, 'A good book'),
    if (maxUv >= 8) const PackItem('aloe', PhIcons.leaf, 'Aloe vera (just in case)'),
    const PackItem('bag', PhIcons.trash, 'Bag for your trash'),
  ];
}

// --------------------------------------------------------------- summary

String conditionsSummary(HourlyConditions h, Units u) {
  final parts = <String>[];
  final air = h.airTemp;
  final airWord = air >= 32 ? 'Hot' : air >= 26 ? 'Warm' : air >= 20 ? 'Mild' : 'Cool';
  parts.add('$airWord ${u.temp(air)} air');
  if (h.waterTemp != null) {
    final w = h.waterTemp!;
    final waterWord = w >= 26 ? 'bath-warm' : w >= 22 ? 'pleasant' : w >= 18 ? 'refreshing' : 'chilly';
    parts.add('$waterWord ${u.temp(w)} water');
  }
  if (h.waveHeight != null) {
    final wh = h.waveHeight!;
    final waveWord = wh < .5 ? 'flat' : wh < 1 ? 'gentle' : wh < 2 ? 'lively' : 'big';
    parts.add('$waveWord ${u.height(wh)} waves');
  }
  final windWord = h.windSpeed < 10 ? 'barely a breeze' : h.windSpeed < 20 ? 'a light breeze' : h.windSpeed < 30 ? 'a fresh wind' : 'strong wind';
  final last = '$windWord from the ${compass(h.windDirection)}';
  return '${parts.join(', ')} and $last.';
}
