import 'package:alert_eco/screens/detail_signalement_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:alert_eco/models/signalement.dart';
import 'package:intl/intl.dart';

class HistoriqueSignalementsPage extends StatefulWidget {
  @override
  _HistoriqueSignalementsPageState createState() => _HistoriqueSignalementsPageState();
}

class _HistoriqueSignalementsPageState extends State<HistoriqueSignalementsPage> {
  final List<Signalement> signalements = signalementsTest;
  List<Signalement> signalementsFiltrés = [];
  String filtreStatut = 'Tous';
  String recherche = '';

  @override
  void initState() {
    super.initState();
    signalementsFiltrés = List.from(signalements);
  }

  void _filtrerSignalements() {
    setState(() {
      signalementsFiltrés = signalements.where((signalement) {
        bool matchStatut = filtreStatut == 'Tous' || signalement.statut == filtreStatut;
        bool matchRecherche = recherche.isEmpty || 
                             signalement.titre.toLowerCase().contains(recherche.toLowerCase()) ||
                             signalement.description.toLowerCase().contains(recherche.toLowerCase());
        return matchStatut && matchRecherche;
      }).toList();
    });
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
        
        // Ajouter les transformations pour optimiser l'image (version miniature)
        String transformations = 'c_fill,w_100,h_100,f_auto,q_auto/';
        return '$baseUrl$transformations$imagePath';
      }
    }
    
    // Retourner l'URL originale si ce n'est pas Cloudinary
    return originalUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4D30),
        title: const Text('Mon historique'),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et statistiques
          _buildHeaderSection(),
          
          // Liste des signalements
          Expanded(
            child: signalementsFiltrés.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: signalementsFiltrés.length,
                    itemBuilder: (context, index) {
                      final signalement = signalementsFiltrés[index];
                      return _buildSignalementCard(signalement, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            onChanged: (value) {
              recherche = value;
              _filtrerSignalements();
            },
            decoration: InputDecoration(
              hintText: 'Rechercher un signalement...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF1D4D30)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1D4D30)),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Statistiques
          _buildStatistiques(),
        ],
      ),
    );
  }

  Widget _buildStatistiques() {
    Map<String, int> stats = <String, int>{};
    for (var signalement in signalements) {
      stats[signalement.statut] = (stats[signalement.statut] ?? 0) + 1;
    }

    return Container(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard('Total', signalements.length, Colors.blue[400]!),
          ...stats.entries.map((entry) => _buildStatCard(
            entry.key,
            entry.value,
            Signalement.getStatutColor(entry.key),
          )),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSignalementCard(Signalement signalement, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    DetailSignalementPage(signalement: signalement),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
                    ),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image miniature
                _buildThumbnail(signalement),
                
                const SizedBox(width: 16),
                
                // Contenu principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre et numéro
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              signalement.titre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1D4D30),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '#${(index + 1).toString().padLeft(3, '0')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Description courte
                      Text(
                        signalement.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Informations détaillées
                      Row(
                        children: [
                          // Date
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            signalement.dateFormatFr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Localisation
                          Icon(Icons.place, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              signalement.localisation,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Statut et actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                          
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.share, size: 20),
                                onPressed: () => _partagerSignalement(signalement),
                                color: Colors.grey[600],
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailSignalementPage(signalement: signalement),
                                  ),
                                ),
                                color: const Color(0xFF1D4D30),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(Signalement signalement) {
    return Hero(
      tag: 'signalement-${signalement.id}',
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[100],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: signalement.photo != null
              ? (signalement.photo!.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: _getCloudinaryUrl(signalement.photo!),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D4D30)),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildDefaultThumbnail(),
                    )
                  : Image.asset(
                      signalement.photo!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildDefaultThumbnail(),
                    ))
              : _buildDefaultThumbnail(),
        ),
      ),
    );
  }

  Widget _buildDefaultThumbnail() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: Icon(
        Icons.eco,
        size: 32,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun signalement trouvé',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres de recherche',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer par statut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Tous',
            ...signalements.map((s) => s.statut).toSet().toList(),
          ].map((statut) => RadioListTile<String>(
            title: Text(statut),
            value: statut,
            groupValue: filtreStatut,
            onChanged: (value) {
              setState(() {
                filtreStatut = value!;
                _filtrerSignalements();
              });
              Navigator.pop(context);
            },
            activeColor: const Color(0xFF1D4D30),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _partagerSignalement(Signalement signalement) {
    // Implémenter le partage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Partage du signalement "${signalement.titre}"'),
        backgroundColor: const Color(0xFF1D4D30),
      ),
    );
  }
}