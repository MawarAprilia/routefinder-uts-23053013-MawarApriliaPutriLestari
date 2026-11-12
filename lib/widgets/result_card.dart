
import 'package:flutter/material.dart';

import '../models/location_model.dart';
import '../models/route_model.dart';

class ResultCard extends StatelessWidget {
  final RouteModel result;
  final List<LocationModel> locations;

  const ResultCard({
    super.key,
    required this.result,
    required this.locations,
  });

  @override
  Widget build(BuildContext context) {
    final routeNames = result.routeIndices.map((index) {
      return locations[index].name;
    }).join(' → ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.algorithmName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172554),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Total Jarak',
              style: TextStyle(color: Colors.grey),
            ),

            Text(
              '${result.distance.toStringAsFixed(2)} km',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D28D9),
              ),
            ),

            const Divider(height: 25),

            const Text(
              'Urutan Perjalanan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              routeNames,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
