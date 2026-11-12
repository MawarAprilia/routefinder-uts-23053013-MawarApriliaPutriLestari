import '../models/location_model.dart';
import '../models/route_model.dart';
import 'distance_service.dart';

class NearestNeighborService {
  static RouteModel calculate(List<LocationModel> locations) {
    if (locations.length < 2) {
      throw Exception('Masukkan minimal 2 lokasi.');
    }

    final int totalLocations = locations.length;

    List<int> route = [0];
    List<bool> visited = List.filled(totalLocations, false);

    visited[0] = true;

    int current = 0;
    double totalDistance = 0;

    while (route.length < totalLocations) {
      int nearest = -1;
      double shortestDistance = double.infinity;

      for (int i = 0; i < totalLocations; i++) {
        if (visited[i]) continue;

        final distance = DistanceService.calculate(
          locations[current].coordinate,
          locations[i].coordinate,
        );

        if (distance < shortestDistance) {
          shortestDistance = distance;
          nearest = i;
        }
      }

      if (nearest == -1) break;

      totalDistance += shortestDistance;

      current = nearest;
      visited[current] = true;
      route.add(current);
    }

    return RouteModel(
      algorithmName: 'Nearest Neighbor',
      routeIndices: route,
      coordinates: route
          .map((index) => locations[index].coordinate)
          .toList(),
      distance: totalDistance,
    );
  }
}