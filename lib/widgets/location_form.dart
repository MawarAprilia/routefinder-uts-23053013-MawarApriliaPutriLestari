
import 'package:flutter/material.dart';
import '../models/location_model.dart';

class LocationForm extends StatefulWidget {
  final Function(LocationModel) onAdd;

  const LocationForm({
    super.key,
    required this.onAdd,
  });

  @override
  State<LocationForm> createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  final nameController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  void addLocation() {
    final name = nameController.text.trim();
    final latitude = double.tryParse(latitudeController.text);
    final longitude = double.tryParse(longitudeController.text);

    if (name.isEmpty ||
        latitude == null ||
        longitude == null) {
      showMessage('Isi semua data lokasi dengan benar.');
      return;
    }

    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      showMessage('Koordinat latitude atau longitude tidak valid.');
      return;
    }

    widget.onAdd(
      LocationModel(
        name: name,
        latitude: latitude,
        longitude: longitude,
      ),
    );

    nameController.clear();
    latitudeController.clear();
    longitudeController.clear();

    showMessage('Lokasi berhasil ditambahkan.');
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  Widget buildField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambah Lokasi Tujuan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lokasi',
                hintText: 'Contoh: Surabaya',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            buildField(
              'Latitude',
              latitudeController,
              '-7.2575',
            ),

            const SizedBox(height: 12),

            buildField(
              'Longitude',
              longitudeController,
              '112.7521',
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: addLocation,
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Tambahkan Lokasi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D28D9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
