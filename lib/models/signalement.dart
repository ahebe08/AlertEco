import 'package:flutter/material.dart';

class Signalement {
  final String id;
  final String titre;
  final String description;
  final DateTime date;
  final String statut;
  final String? photo;         // Peut être une URL ou un chemin local
  final String localisation;   // Ex : "Quartier Bellevue, Dakar"

  Signalement({
    required this.id,
    required this.titre,
    required this.description,
    required this.date,
    required this.statut,
    this.photo,
    required this.localisation,
  });

  static Color getStatutColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'en attente':
        return const Color(0xFFF25C34);
      case 'en cours':
        return const Color(0xFFA5D68F);
      case 'résolu':
        return const Color(0xFF1D4D30);
      default:
        return Colors.grey;
    }
  }

  String get dateFormatFr {
    return '${date.day.toString().padLeft(2, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.year}';
  }
}

// Exemple de données
List<Signalement> signalementsTest = [
  Signalement(
    id: '1',
    titre: 'Décharge sauvage',
    description: 'Tas de déchets près du marché.',
    date: DateTime(2025, 4, 28),
    statut: 'en attente',
    localisation: 'Marché central, Dakar',
    photo: 'assets/images/Decharge.jpg',
  ),
  Signalement(
    id: '2',
    titre: 'Route endommagée',
    description: 'Nids de poule sur la route principale.',
    date: DateTime(2025, 4, 20),
    statut: 'résolu',
    localisation: 'Avenue Blaise Diagne, Dakar',
    photo: 'assets/images/Route-Endom.jpg',
  ),
  Signalement(
    id: '3',
    titre: 'Pollution de la rivière',
    description: 'Déversement de liquide suspect dans la rivière.',
    date: DateTime(2025, 4, 15),
    statut: 'en cours',
    localisation: 'Rivière Fass, Thiès',
    photo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Pollution_-_Rio_Tiete_-_panoramio.jpg/640px-Pollution_-_Rio_Tiete_-_panoramio.jpg',
    //photo: 'assets/images/Water_pollution.jpeg',
  ),
];
