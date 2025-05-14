import 'package:cached_network_image/cached_network_image.dart';
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                signalement.titre,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF111111)),
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
                      const Text('Statut : ',
                          style: TextStyle(color: Colors.black54)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: getStatutColor(signalement.statut)
                              .withOpacity(0.2),
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
                    builder: (_) =>
                        DetailSignalementPage(signalement: signalement),
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

  const DetailSignalementPage({super.key, required this.signalement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(signalement.titre),
        backgroundColor: const Color(0xFF1D4D30),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Image
            if (signalement.photo != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: signalement.photo!.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: signalement.photo!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (_, __, ___) => _buildErrorImage(),
                      )
                    : Image.asset(
                        signalement.photo!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildErrorImage(),
                      ),
              ),
            const SizedBox(height: 20),

            // Description
            Text(
              signalement.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Informations
            _buildInfoItem(Icons.calendar_today, 'Date', signalement.dateFormatFr),
            const SizedBox(height: 16),
            _buildInfoItem(Icons.place, 'Lieu', signalement.localisation),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.info, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Chip(
                  label: Text(signalement.statut),
                  backgroundColor: Signalement.getStatutColor(signalement.statut),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorImage() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
      ),
    );
  }
}

