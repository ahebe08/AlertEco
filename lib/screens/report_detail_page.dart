import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportDetailPage extends StatelessWidget {
  final Map<String, dynamic> report;

  const ReportDetailPage({super.key, required this.report});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'En attente':
        return Colors.orange;
      case 'En cours':
        return const Color(0xFF1D4D30);
      case 'Résolu':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    final statusColor = _getStatusColor(report['status']);
    final date = report['date'] is DateTime 
        ? report['date'] 
        : DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du signalement'),
        backgroundColor: const Color(0xFF1D4D30),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                report['photoUrl'] ?? '',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.photo, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA5D68F).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFA5D68F)),
                  ),
                  child: Text(
                    report['type'] ?? 'Type inconnu',
                    style: const TextStyle(color: Color(0xFF1D4D30)),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    report['status'] ?? 'Statut inconnu',
                    style: TextStyle(color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              report['title'] ?? 'Titre non spécifié',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              report['description'] ?? 'Description manquante',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            _buildDetailItem(
              icon: Icons.location_on,
              title: 'Localisation',
              content: report['address'] ?? 'Localisation inconnue',
            ),
            _buildDetailItem(
              icon: Icons.calendar_today,
              title: 'Date',
              content: dateFormat.format(date),
            ),
            if (report.containsKey('author') && report['author'] != null)
              _buildDetailItem(
                icon: Icons.person,
                title: 'Signalé par',
                content: report['author'],
              ),
            if (report.containsKey('adminComment') && report['adminComment'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Commentaire administratif',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D4D30),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(report['adminComment']),
                  ),
                ],
              ),
            const SizedBox(height: 30),
            if (report['status'] != 'Résolu')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF25C34),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {},
                  child: const Text('Suivre ce signalement'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1D4D30)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}