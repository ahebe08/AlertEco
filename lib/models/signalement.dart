import 'package:flutter/material.dart';

class Signalement {
  final String id;
  final String titre;
  final String description;
  final DateTime date;
  final String statut;

  Signalement({
    required this.id,
    required this.titre,
    required this.description,
    required this.date,
    required this.statut,
  });

  static Color getStatutColor(String statut) {
    switch (statut) {
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

// Exemples de données avec DateTime
List<Signalement> signalementsTest = [
  Signalement(
    id: '1',
    titre: 'Décharge sauvage',
    description: 'Tas de déchets près du marché.',
    date: DateTime(2025, 4, 28),
    statut: 'en attente',
  ),
  Signalement(
    id: '2',
    titre: 'Route endommagée',
    description: 'Nids de poule sur la route principale.',
    date: DateTime(2025, 4, 20),
    statut: 'résolu',
  ),
  Signalement(
    id: '3',
    titre: 'Pollution rivière',
    description: 'Déversement d’huile dans la rivière.',
    date: DateTime(2025, 4, 18),
    statut: 'en cours',
  ),
];
