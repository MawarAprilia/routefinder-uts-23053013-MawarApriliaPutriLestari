
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/location_model.dart';
import '../models/route_model.dart';

class MapWidget extends StatefulWidget {
  final List<LocationModel> locations;
  final List<LatLng> routePoints;
  final List<RouteModel> comparisonRoutes;
  final Function(LatLng) onMapTap;
  final Function(LatLng) onMapCenterChanged;
  final Color routeColor;

  const MapWidget({
    super.key,
    required this.locations,
    required this.routePoints,
    this.comparisonRoutes = const [],
    required this.onMapTap,
    required this.onMapCenterChanged,
    required this.routeColor,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController mapController = MapController();

  static const LatLng defaultPosition = LatLng(-7.2575, 112.7521);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onMapCenterChanged(defaultPosition);
      }
    });
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.locations.isEmpty && widget.locations.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          mapController.move(widget.locations.first.coordinate, 12);
        }
      });
    }
  }

  void showLocationInfo(LocationModel location, int index) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('P${index + 1} • ${location.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitude: ${location.latitude.toStringAsFixed(6)}'),
            const SizedBox(height: 6),
            Text('Longitude: ${location.longitude.toStringAsFixed(6)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Color getRouteColor(String algorithmName) {
    switch (algorithmName) {
      case 'Rute Berurutan':
        return Colors.orange;

      case 'Dijkstra':
        return Colors.blue;

      case 'Nearest Neighbor':
        return Colors.deepPurpleAccent;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.locations.isNotEmpty
        ? widget.locations.first.coordinate
        : defaultPosition;

    // Jika sedang membandingkan, tampilkan seluruh rute.
    final List<Polyline> routePolylines = [];

    if (widget.comparisonRoutes.isNotEmpty) {
      for (final route in widget.comparisonRoutes) {
        if (route.coordinates.length >= 2) {
          routePolylines.add(
            Polyline(
              points: route.coordinates,
              strokeWidth: route.algorithmName == 'Rute Berurutan'
                  ? 5
                  : 4,
              color: getRouteColor(route.algorithmName),
            ),
          );
        }
      }
    } else if (widget.routePoints.length >= 2) {
      // Jika hanya memilih satu algoritma, tampilkan satu rute.
      routePolylines.add(
        Polyline(
          points: widget.routePoints,
          strokeWidth: 5,
          color: widget.routeColor,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: 10,
          onTap: (tapPosition, point) => widget.onMapTap(point),
          onPositionChanged: (camera, hasGesture) {
            widget.onMapCenterChanged(camera.center);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.route_finder_uts',
          ),

          if (routePolylines.isNotEmpty)
            PolylineLayer(
              polylines: routePolylines,
            ),

          MarkerLayer(
            markers: widget.locations.asMap().entries.map((entry) {
              final index = entry.key;
              final location = entry.value;
              final markerColor = index == 0 ? Colors.green : Colors.red;

              return Marker(
                point: location.coordinate,
                width: 120,
                height: 78,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () => showLocationInfo(location, index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          'P${index + 1} ${location.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.location_on,
                        color: markerColor,
                        size: 32,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
