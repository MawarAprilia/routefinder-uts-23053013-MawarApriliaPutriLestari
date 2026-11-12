
import '../models/location_model.dart';
import '../models/route_model.dart';
import 'distance_service.dart';

class DijkstraService {
  static RouteModel calculate(List<LocationModel> locations) {
    final int n = locations.length;

    if (n < 2) {
      throw Exception('Minimal harus ada 2 lokasi.');
    }

    // Membuat graf lengkap: setiap lokasi terhubung
    // dengan seluruh lokasi lainnya.
    final List<Map<int, double>> graph =
        List.generate(n, (_) => <int, double>{});

    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        final double weight = DistanceService.calculate(
          locations[i].coordinate,
          locations[j].coordinate,
        );

        graph[i][j] = weight;
        graph[j][i] = weight;
      }
    }

    // Rute dimulai dari lokasi pertama.
    final List<int> route = [0];
    final List<bool> visited = List<bool>.filled(n, false);

    visited[0] = true;

    int current = 0;
    double totalDistance = 0.0;

    // Jalankan Dijkstra berulang sampai semua lokasi dikunjungi.
    while (visited.any((value) => !value)) {
      final _ShortestPaths paths = _shortestPaths(
        graph,
        current,
      );

      int next = -1;
      double shortestDistance = double.infinity;

      // Cari lokasi yang belum dikunjungi dengan
      // jarak lintasan terpendek dari lokasi saat ini.
      for (int i = 0; i < n; i++) {
        if (visited[i]) continue;

        if (paths.distance[i] < shortestDistance) {
          shortestDistance = paths.distance[i];
          next = i;
        }
      }

      if (next == -1 || !shortestDistance.isFinite) {
        throw Exception(
          'Tidak ditemukan jalur menuju lokasi berikutnya.',
        );
      }

      // Rekonstruksi lintasan terpendek.
      final List<int> path = _reconstructPath(
        paths.previous,
        current,
        next,
      );

      if (path.isEmpty) {
        throw Exception('Gagal menyusun lintasan Dijkstra.');
      }

      // Tambahkan lintasan ke hasil rute dan hitung jaraknya.
      for (int i = 1; i < path.length; i++) {
        final int from = path[i - 1];
        final int to = path[i];

        if (!visited[to]) {
          final double? weight = graph[from][to];

          if (weight == null) {
            throw Exception('Bobot jalur tidak ditemukan.');
          }

          totalDistance += weight;
          route.add(to);
          visited[to] = true;
        }
      }

      current = next;
    }

    return RouteModel(
      algorithmName: 'Dijkstra',
      routeIndices: route,
      coordinates: route
          .map((index) => locations[index].coordinate)
          .toList(),
      distance: totalDistance,
    );
  }

  // Algoritma Dijkstra untuk mencari jarak terpendek
  // dari satu titik sumber ke seluruh titik lainnya.
  static _ShortestPaths _shortestPaths(
    List<Map<int, double>> graph,
    int start,
  ) {
    final int n = graph.length;

    final List<double> distance =
        List<double>.filled(n, double.infinity);

    final List<int> previous = List<int>.filled(n, -1);

    final List<bool> visited = List<bool>.filled(n, false);

    distance[start] = 0.0;

    for (int step = 0; step < n; step++) {
      int current = -1;
      double minimumDistance = double.infinity;

      // Pilih simpul belum dikunjungi dengan jarak terkecil.
      for (int i = 0; i < n; i++) {
        if (!visited[i] && distance[i] < minimumDistance) {
          minimumDistance = distance[i];
          current = i;
        }
      }

      if (current == -1) break;

      visited[current] = true;

      // Relaksasi bobot seluruh sisi yang terhubung.
      for (final edge in graph[current].entries) {
        final int neighbor = edge.key;
        final double weight = edge.value;

        if (visited[neighbor]) continue;

        final double newDistance =
            distance[current] + weight;

        if (newDistance < distance[neighbor]) {
          distance[neighbor] = newDistance;
          previous[neighbor] = current;
        }
      }
    }

    return _ShortestPaths(distance, previous);
  }

  // Menyusun kembali jalur dari titik sumber ke tujuan.
  static List<int> _reconstructPath(
    List<int> previous,
    int start,
    int destination,
  ) {
    final List<int> path = [];

    int current = destination;

    while (current != -1) {
      path.add(current);

      if (current == start) break;

      current = previous[current];
    }

    if (path.isEmpty || path.last != start) {
      return [];
    }

    return path.reversed.toList();
  }
}

class _ShortestPaths {
  final List<double> distance;
  final List<int> previous;

  const _ShortestPaths(this.distance, this.previous);
}
