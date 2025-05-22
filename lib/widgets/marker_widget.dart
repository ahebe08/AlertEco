import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MarkerWidget {
  final String description;
  final LatLng position;
  final String type;

  late final Color color; // `late` permet d'initialiser après

  MarkerWidget({
    required this.description,
    required this.position,
    required this.type,
  }) {
    // Initialisation de la couleur en fonction du type
    if (type == 'EN COURS') {
      color = const Color.fromARGB(255, 50, 142, 63);
    } else if (type == 'RESOLU') {
      color = const Color(0xFF1D4D30);
    } else if (type == 'EN ATTENTE') {
      color = const Color.fromARGB(255, 249, 68, 2);
    } else if (type == 'ANNULE') {
      color = const Color.fromARGB(255, 92, 90, 90);
    } else if (type == 'NON TRAITE') {
      color = const Color.fromARGB(255, 164, 207, 238);
    } else {
      color = const Color.fromARGB(255, 249, 68, 2); // Par défaut
    }
  }

  Marker buildMarker() {
    return Marker(
      point: position,
      width: 30,
      height: 30,
      alignment: Alignment.center,
      child: Tooltip(
        message: description,
        child: Icon(
          Icons.warning,
          color: color,
          size: 40,
        ),
      ),
    );
  }
}
