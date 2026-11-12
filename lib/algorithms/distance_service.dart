import 'dart:math';
import 'package:latlong2/latlong.dart';

class DistanceService {
  static const double earthRadius = 6371.0;

  static double calculate(LatLng first, LatLng second) {
    final lat1 = first.latitude * pi / 180;
    final lat2 = second.latitude * pi / 180;

    final deltaLat =
        (second.latitude - first.latitude) * pi / 180;

    final deltaLng =
        (second.longitude - first.longitude) * pi / 180;

    final a = pow(sin(deltaLat / 2), 2) +
        cos(lat1) *
            cos(lat2) *
            pow(sin(deltaLng / 2), 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double calculateTotal(List<LatLng> points) {
    double total = 0;

    for (int i = 0; i < points.length - 1; i++) {
      total += calculate(points[i], points[i + 1]);
    }

    return total;
  }
}