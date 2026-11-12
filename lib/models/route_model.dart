import 'package:latlong2/latlong.dart';

class RouteModel {
  final String algorithmName;
  final List<int> routeIndices;
  final List<LatLng> coordinates;
  final double distance;

  const RouteModel({
    required this.algorithmName,
    required this.routeIndices,
    required this.coordinates,
    required this.distance,
  });
}