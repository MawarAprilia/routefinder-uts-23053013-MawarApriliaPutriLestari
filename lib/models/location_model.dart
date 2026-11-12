import 'package:latlong2/latlong.dart';

class LocationModel {
  final String name;
  final double latitude;
  final double longitude;

  const LocationModel({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  LatLng get coordinate => LatLng(latitude, longitude);
}