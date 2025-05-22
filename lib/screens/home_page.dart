import 'package:alert_eco/widgets/marker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedType;

  List<MarkerWidget> allMarkerData = [
    MarkerWidget(
      description: 'Problème de canalisation',
      position: LatLng(48.8566, 2.3522),
      type: 'EN ATTENTE',
    ),
    MarkerWidget(
      description: 'Problème de sécurité',
      position: LatLng(48.836, 2.3522),
      type: 'ANNULE',
    ),
    MarkerWidget(
      description: 'Bruit excessif',
      position: LatLng(48.866, 2.3722),
      type: 'RESOLU',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filtrage des marqueurs selon le type sélectionné
    final markers = allMarkerData
        .where((marker) => selectedType == null || marker.type == selectedType)
        .map((marker) => marker.buildMarker())
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4D30),
        title: const Text('AlertEco'),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Désactive le bouton de retour
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, "/notif");
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: MapController(),
            options: MapOptions(
              initialCenter: LatLng(48.8566, 2.3522),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: markers,
              ),
            ],
          ),

          // Bouton de filtre en haut à droite
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'filter',
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) {
                    return ListView(
                      padding: const EdgeInsets.all(8),
                      children: [
                        const ListTile(title: Text("Filtrer par type")),
                        ...[
                          'EN ATTENTE',
                          'EN COURS',
                          'RESOLU',
                          'NON TRAITE',
                          'ANNULE',
                          null
                        ].map((type) {
                          return ListTile(
                            title: Text(type ?? 'TOUS'),
                            onTap: () {
                              setState(() {
                                selectedType = type;
                              });
                              Navigator.pop(context);
                            },
                          );
                        }),
                      ],
                    );
                  },
                );
              },
              child: const Icon(Icons.filter_list, color: Colors.black),
            ),
          ),
        ],
      ),

      // Bouton d'ajout de signalement
      floatingActionButton: FloatingActionButton(
        heroTag: 'add',
        onPressed: () {
          Navigator.pushNamed(context, "/create_signal");
        },
        backgroundColor: const Color.fromARGB(255, 192, 233, 194),
        child: const Icon(Icons.add),
      ),
    );
  }
}
