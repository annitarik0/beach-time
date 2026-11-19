/// A place the user wants to check: a beach, a city or their GPS position.
class Beach {
  const Beach({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.region,
    this.country,
  });

  final String name;
  final String? region;
  final String? country;
  final double latitude;
  final double longitude;

  /// Stable id built from rounded coordinates (~100 m).
  String get id =>
      '${latitude.toStringAsFixed(3)},${longitude.toStringAsFixed(3)}';

  String get subtitle => [region, country]
      .where((e) => e != null && e.isNotEmpty)
      .cast<String>()
      .toSet()
      .join(', ');

  Map<String, dynamic> toJson() => {
        'name': name,
        'region': region,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Beach.fromJson(Map<String, dynamic> json) => Beach(
        name: json['name'] as String,
        region: json['region'] as String?,
        country: json['country'] as String?,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );

  @override
  bool operator ==(Object other) => other is Beach && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
