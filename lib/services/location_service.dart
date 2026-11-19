import 'package:geolocator/geolocator.dart';

import '../models/beach.dart';

class LocationException implements Exception {
  LocationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class LocationService {
  Future<Beach> currentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationException('Location services are turned off.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw LocationException(
          'Location permission denied. You can still search for a beach.');
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return Beach(
      name: 'My location',
      latitude: pos.latitude,
      longitude: pos.longitude,
    );
  }
}
