import 'package:alert_eco/models/signalement.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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

