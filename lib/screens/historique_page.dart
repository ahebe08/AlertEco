import 'package:flutter/material.dart';
import 'package:alert_eco/models/signalement.dart';

class HistoriqueSignalementsPage extends StatelessWidget {
  final List<Signalement> signalements = signalementsTest;

  Color getStatutColor(String statut) {
    return Signalement.getStatutColor(statut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4D30),
        title: const Text('Mon historique'),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: signalements.length,
        itemBuilder: (context, index) {
          final signalement = signalements[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                signalement.titre,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111111)),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    'Date : ${signalement.dateFormatFr}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('Statut : ', style: TextStyle(color: Colors.black54)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: getStatutColor(signalement.statut).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          signalement.statut.toUpperCase(),
                          style: TextStyle(
                            color: getStatutColor(signalement.statut),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailSignalementPage(signalement: signalement),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DetailSignalementPage extends StatelessWidget {
  final Signalement signalement;

  const DetailSignalementPage({required this.signalement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(signalement.titre),
        backgroundColor: const Color(0xFF1D4D30),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              signalement.description,
              style: const TextStyle(fontSize: 18, color: Color(0xFF111111)),
            ),
            const SizedBox(height: 20),
            Text('Date : ${signalement.dateFormatFr}'),
            const SizedBox(height: 10),
            Text('Statut : ${signalement.statut}'),
          ],
        ),
      ),
    );
  }
}