import 'package:alert_eco/widgets/marker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedType;
  late final MapController _mapController;
  LatLng? _currentPosition;

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
  void initState() {
    super.initState();
    _mapController = MapController();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      // Marqueur de position actuelle
      if (_currentPosition != null)
        Marker(
          point: _currentPosition!,
          width: 40,
          height: 40,
          child:
              const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
        ),

      // Marqueurs des signalements filtrés
      ...allMarkerData
          .where(
              (marker) => selectedType == null || marker.type == selectedType)
          .map((marker) => marker.buildMarker()),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4D30),
        title: const Text('AlertEco'),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, "/notif");
            },
          ),
        ],
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition!,
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
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
