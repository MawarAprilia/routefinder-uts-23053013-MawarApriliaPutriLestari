
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/location_model.dart';
import '../models/route_model.dart';

import '../algorithms/distance_service.dart';
import '../algorithms/dijkstra_service.dart';
import '../algorithms/nearest_neighbor_service.dart';

import '../widgets/map_widget.dart';
import '../widgets/location_form.dart';
import '../widgets/result_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<LocationModel> locations = [];

  RouteModel? selectedResult;
  List<RouteModel> comparisonResults = [];
  LatLng mapCenter = const LatLng(-7.2575, 112.7521);

  void updateMapCenter(LatLng center) {
    if (!mounted) return;
    setState(() => mapCenter = center);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void addLocation(LocationModel location) {
    if (locations.length >= 10) {
      showMessage('Maksimal 10 lokasi.');
      return;
    }

    setState(() {
      locations.add(location);
      selectedResult = null;
      comparisonResults.clear();
    });
  }

  void addLocationFromMap(LatLng point) {
    if (locations.length >= 10) {
      showMessage('Maksimal 10 lokasi.');
      return;
    }

    addLocation(
      LocationModel(
        name: 'Titik ${locations.length + 1}',
        latitude: point.latitude,
        longitude: point.longitude,
      ),
    );
  }

  void deleteLocation(int index) {
    setState(() {
      locations.removeAt(index);
      selectedResult = null;
      comparisonResults.clear();
    });
  }

  bool validateLocations() {
    if (locations.length < 3) {
      showMessage('Masukkan minimal 3 lokasi terlebih dahulu.');
      return false;
    }

    return true;
  }

  void runSequential() {
    if (!validateLocations()) return;

    final route = List.generate(locations.length, (i) => i);

    final coordinates = route
        .map((index) => locations[index].coordinate)
        .toList();

    final result = RouteModel(
      algorithmName: 'Rute Berurutan',
      routeIndices: route,
      coordinates: coordinates,
      distance: DistanceService.calculateTotal(coordinates),
    );

    setState(() {
      selectedResult = result;
      comparisonResults.clear();
    });
  }

  void runDijkstra() {
    if (!validateLocations()) return;

    try {
      final result = DijkstraService.calculate(locations);

      setState(() {
        selectedResult = result;
        comparisonResults.clear();
      });
    } catch (e) {
      showMessage('Gagal menjalankan Dijkstra: $e');
    }
  }

  void runNearestNeighbor() {
    if (!validateLocations()) return;

    try {
      final result = NearestNeighborService.calculate(locations);

      setState(() {
        selectedResult = result;
        comparisonResults.clear();
      });
    } catch (e) {
      showMessage('Gagal menjalankan Nearest Neighbor: $e');
    }
  }

  void compareRoutes() {
    if (!validateLocations()) return;

    try {
      final sequential = RouteModel(
        algorithmName: 'Rute Berurutan',
        routeIndices: List.generate(locations.length, (i) => i),
        coordinates: locations.map((e) => e.coordinate).toList(),
        distance: DistanceService.calculateTotal(
          locations.map((e) => e.coordinate).toList(),
        ),
      );

      final dijkstra = DijkstraService.calculate(locations);

      final nearestNeighbor =
          NearestNeighborService.calculate(locations);

      setState(() {
        comparisonResults = [
          sequential,
          dijkstra,
          nearestNeighbor,
        ];

        selectedResult = comparisonResults.reduce(
          (a, b) => a.distance <= b.distance ? a : b,
        );
      });
    } catch (e) {
      showMessage('Gagal membandingkan rute: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final shortestDistance = comparisonResults.isEmpty
        ? 0.0
        : comparisonResults
            .map((result) => result.distance)
            .reduce((a, b) => a < b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RouteFinder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                locations.clear();
                selectedResult = null;
                comparisonResults.clear();
              });
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Smart Route Optimization',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172554),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Temukan rute perjalanan yang lebih efisien '
              'menggunakan algoritma pencarian rute.',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 18),

            const Text(
              'Peta Lokasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 300,
              child: MapWidget(
  locations: locations,
  routePoints: selectedResult?.coordinates ?? [],
  comparisonRoutes: comparisonResults,
  onMapTap: addLocationFromMap,
  onMapCenterChanged: updateMapCenter,
  routeColor: selectedResult?.algorithmName == 'Rute Berurutan'
      ? Colors.orange
      : selectedResult?.algorithmName == 'Dijkstra'
          ? Colors.blue
          : Colors.deepPurpleAccent,
),
            ),

            const SizedBox(height: 8),

            Text(
              'Titik tengah peta: ${mapCenter.latitude.toStringAsFixed(5)}, '
              '${mapCenter.longitude.toStringAsFixed(5)}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF172554),
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Ketuk peta untuk menambahkan titik lokasi.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            LocationForm(onAdd: addLocation),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Lokasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${locations.length}/10 Lokasi',
                  style: const TextStyle(
                    color: Color(0xFF6D28D9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (locations.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text('Belum ada lokasi ditambahkan.'),
                  ),
                ),
              )
            else
              ...locations.asMap().entries.map((entry) {
                final index = entry.key;
                final location = entry.value;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFEDE9FE),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Color(0xFF6D28D9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(location.name),
                    subtitle: Text(
                      '${location.latitude.toStringAsFixed(5)}, '
                      '${location.longitude.toStringAsFixed(5)}',
                    ),
                    trailing: IconButton(
                      onPressed: () => deleteLocation(index),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 20),

            const Text(
              'Pilih Algoritma',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: runSequential,
                icon: const Icon(Icons.route),
                label: const Text('Rute Berurutan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF172554),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: runDijkstra,
                icon: const Icon(Icons.account_tree),
                label: const Text('Algoritma Dijkstra'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4338CA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: runNearestNeighbor,
                icon: const Icon(Icons.near_me),
                label: const Text('Nearest Neighbor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: compareRoutes,
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Bandingkan Semua Algoritma'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF172554),
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ),

            if (selectedResult != null) ...[
              const SizedBox(height: 20),

              const Text(
                'Hasil Perhitungan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ResultCard(
                result: selectedResult!,
                locations: locations,
              ),
            ],

            if (comparisonResults.isNotEmpty) ...[
              const SizedBox(height: 20),

              const Text(
                'Perbandingan Hasil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ...comparisonResults.map((result) {
                final isShortest =
                    result.distance == shortestDistance;

                return Card(
                  child: ListTile(
                    leading: Icon(
                      isShortest
                          ? Icons.emoji_events
                          : Icons.route,
                      color: isShortest
                          ? Colors.orange
                          : Colors.deepPurple,
                    ),
                    title: Text(result.algorithmName),
                    subtitle: Text(
                      '${result.distance.toStringAsFixed(2)} km',
                    ),
                    trailing: isShortest
                        ? const Text(
                            'Terpendek',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                );
              }),

              Builder(
                builder: (context) {
                  final sequentialDistance = comparisonResults
                      .firstWhere((r) => r.algorithmName == 'Rute Berurutan')
                      .distance;
                  final saving = (sequentialDistance - shortestDistance)
                      .clamp(0.0, double.infinity);
                  final efficiency = sequentialDistance > 0
                      ? (saving / sequentialDistance) * 100
                      : 0.0;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Analisis Penghematan Jarak',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172554),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Jarak dihemat'),
                              Text(
                                '${saving.toStringAsFixed(2)} km',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Efisiensi'),
                              Text(
                                '${efficiency.toStringAsFixed(2)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
