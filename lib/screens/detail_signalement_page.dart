import 'package:alert_eco/models/signalement.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Image avec Hero Animation
            if (signalement.photo != null) _buildImageSection(),

            // Contenu principal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et statut
                  _buildTitleSection(),
                  const SizedBox(height: 20),

                  // Description
                  _buildDescriptionSection(),
                  const SizedBox(height: 24),

                  // Informations détaillées
                  _buildDetailsSection(),
                  const SizedBox(height: 24),

                  // Boutons d'action
                  _buildActionButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Hero(
      tag: 'signalement-${signalement.id}',
      child: Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: _buildOptimizedImage(),
        ),
      ),
    );
  }

  Widget _buildOptimizedImage() {
    if (signalement.photo!.startsWith('http')) {
      // Configuration pour Cloudinary
      String imageUrl = _getCloudinaryUrl(signalement.photo!);

      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[100],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D4D30)),
                ),
                SizedBox(height: 8),
                Text('Chargement...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildErrorImage(),
        fadeInDuration: const Duration(milliseconds: 300),
      );
    } else {
      return Image.asset(
        signalement.photo!,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
      );
    }
  }

  String _getCloudinaryUrl(String originalUrl) {
    // Si l'URL contient déjà des transformations Cloudinary, on la retourne telle quelle
    if (originalUrl.contains('c_fill') || originalUrl.contains('w_')) {
      return originalUrl;
    }

    // Si c'est une URL Cloudinary, on ajoute les transformations
    if (originalUrl.contains('cloudinary.com')) {
      // Chercher la position après "/upload/"
      int uploadIndex = originalUrl.indexOf('/upload/');
      if (uploadIndex != -1) {
        String baseUrl = originalUrl.substring(0, uploadIndex + 8);
        String imagePath = originalUrl.substring(uploadIndex + 8);

        // Ajouter les transformations pour optimiser l'image
        String transformations = 'c_fill,w_800,h_600,f_auto,q_auto/';
        return '$baseUrl$transformations$imagePath';
      }
    }

    // Retourner l'URL originale si ce n'est pas Cloudinary
    return originalUrl;
  }

  Widget _buildTitleSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                signalement.titre,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D4D30),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Signalé le ${signalement.dateFormatFr}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Signalement.getStatutColor(signalement.statut),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            signalement.statut,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            signalement.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations détaillées',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            Icons.place_outlined,
            'Localisation',
            signalement.localisation,
            Colors.red[400]!,
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            Icons.access_time,
            'Date de signalement',
            signalement.dateFormatFr,
            Colors.blue[400]!,
          ),
          if (signalement.date != null) ...[
            const SizedBox(height: 16),
            _buildDetailItem(
              Icons.schedule,
              'Heure',
              DateFormat('HH:mm').format(signalement.date!),
              Colors.orange[400]!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Bouton principal
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Action à définir (partager, signaler un problème, etc.)
              _showActionSheet(context);
            },
            icon: const Icon(Icons.share),
            label: const Text('Partager ce signalement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4D30),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Boutons secondaires
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Ouvrir la localisation sur la carte
                  _openLocation(context);
                },
                icon: const Icon(Icons.map),
                label: const Text('Voir sur la carte'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1D4D30),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Signaler un problème
                  _reportIssue(context);
                },
                icon: const Icon(Icons.flag),
                label: const Text('Signaler'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[400],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorImage() {
    return Container(
      height: 250,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Image non disponible',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Partager le lien'),
              onTap: () {
                Navigator.pop(context);
                // Implémenter le partage
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copier le lien'),
              onTap: () {
                Navigator.pop(context);
                // Implémenter la copie
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openLocation(BuildContext context) {
    // Implémenter l'ouverture sur la carte
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ouverture de la carte...')),
    );
  }

  void _reportIssue(BuildContext context) {
    // Implémenter le signalement d'un problème
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signalement envoyé')),
    );
  }
}
