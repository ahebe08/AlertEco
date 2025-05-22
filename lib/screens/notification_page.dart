import 'package:flutter/material.dart';

// Assuming you have a Notification model similar to Signalement
// For demonstration, let's create a simple Notification class
class Notification {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final bool isRead;
  final String? imageUrl; // Optional image for the notification

  Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.isRead = false,
    this.imageUrl,
  });

  // Helper to format date
  String get dateFormatFr {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}

// Dummy data for notifications (replace with your actual data source)
List<Notification> notificationsTest = [
  Notification(
    id: '1',
    title: 'Nouvelle alerte Pollution de l\'air',
    body:
        'Le niveau de pollution de l\'air a atteint un seuil élevé dans votre région. Prenez des précautions.',
    date: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: false,
  ),
  Notification(
    id: '2',
    title: 'Mise à jour de votre signalement',
    body:
        'Votre signalement "Décharge sauvage" a été mis à jour au statut "En cours de traitement".',
    date: DateTime.now().subtract(const Duration(days: 1)),
    isRead: true,
  ),
  Notification(
    id: '3',
    title: 'Rappel : Événement Nettoyage de plage',
    body:
        'N\'oubliez pas l\'événement de nettoyage de plage ce samedi à 9h au Port de plaisance.',
    date: DateTime.now().subtract(const Duration(days: 3)),
    isRead: false,
    imageUrl: 'https://picsum.photos/id/237/200/100', // Example image URL
  ),
  Notification(
    id: '4',
    title: 'Message du support',
    body: 'Nous avons bien reçu votre demande et vous recontacterons bientôt.',
    date: DateTime.now().subtract(const Duration(days: 5)),
    isRead: true,
  ),
];

class NotificationPage extends StatelessWidget {
  final List<Notification> notifications =
      notificationsTest; // Use your notification data

  NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4D30),
        title: const Text('Notifications'),
        foregroundColor: Colors.white,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'Aucune notification pour le moment.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Icon(
                      notification.isRead
                          ? Icons.mark_email_read
                          : Icons.notifications,
                      color: notification.isRead
                          ? Colors.grey
                          : const Color(0xFF1D4D30),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: notification.isRead
                            ? Colors.black54
                            : const Color(0xFF111111),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          notification.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: notification.isRead
                                  ? Colors.black45
                                  : Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reçue le : ${notification.dateFormatFr}',
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                    onTap: () {
                      // In a real app, you would mark the notification as read here
                      // For this example, we just navigate to the detail page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailNotificationPage(
                              notification: notification),
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

// ---
class DetailNotificationPage extends StatelessWidget {
  final Notification notification;

  const DetailNotificationPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la notification'),
        backgroundColor: const Color(0xFF1D4D30),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Reçue le : ${notification.dateFormatFr}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (notification.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  // Using Image.network for simplicity, you can integrate cached_network_image here
                  child: Image.network(
                    notification.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildErrorImage(),
                  ),
                ),
              ),
            Text(
              notification.body,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            // You can add more details here if your Notification model has them
            _buildInfoItem(
              Icons.check_circle_outline,
              'Statut',
              notification.isRead ? 'Lue' : 'Non lue',
              color: notification.isRead ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value,
      {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color ?? Colors.grey, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(fontSize: 16, color: color ?? Colors.black)),
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
