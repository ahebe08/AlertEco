import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic> userData = {
    'userId': 'user123',
    'nom': 'Stéphane Dupont',
    'email': 'stephane@example.com',
    'telephone': '+33 6 12 34 56 78',
    'photoUrl': null,
    'creeLe': '2023-01-15T10:30:00',
    'reportsCount': 12,
    'solvedReports': 8,
  };

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> _editProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          userData: {
            'nom': userData['nom'],
            'email': userData['email'],
            'telephone': userData['telephone'],
            'photoUrl': userData['photoUrl'],
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        userData['nom'] = result['nom'];
        userData['email'] = result['email'];
        userData['telephone'] = result['telephone'];
        if (result['photoUrl'] != null) {
          userData['photoUrl'] = result['photoUrl'];
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        // Ici vous devriez uploader l'image et mettre à jour photoUrl
        // Pour l'exemple, on utilise le chemin local
        userData['photoUrl'] = image.path;
      });
    }
  }

  Future<void> _viewUserReports() async {
    // Navigation vers la page des signalements de l'utilisateur
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => UserReportsPage(userId: userData['userId']),
    //   ),
    // );
    Navigator.pushNamed(context, "/historiquesignalement");
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnecter',
                style: TextStyle(color: Color(0xFFF25C34))),
          )
        ],
      ),
    );

    if (confirm == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1D4D30),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Photo de profil avec option de modification
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFA5D68F),
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (userData['photoUrl'] != null
                            ? NetworkImage(userData['photoUrl']!)
                            : null),
                    child: userData['photoUrl'] == null && _selectedImage == null
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D4D30),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Nom avec bouton d'édition
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userData['nom'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: _editProfile,
                  color: const Color(0xFF1D4D30),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              userData['email'],
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            // Section "Mes informations"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mes informations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D4D30),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildInfoItem(Icons.person, 'Nom complet', userData['nom']),
                  _buildInfoItem(Icons.email, 'Email', userData['email']),
                  _buildInfoItem(Icons.phone, 'Téléphone', userData['telephone']),
                  _buildInfoItem(Icons.calendar_today, 'Membre depuis', 
                      _formatDate(userData['creeLe'])),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Statistiques
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFA5D68F).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA5D68F), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Signalements', userData['reportsCount']),
                  _buildStatItem('Résolus', userData['solvedReports']),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Liste des options
            ListTile(
              leading: const Icon(Icons.report, color: Color(0xFF1D4D30)),
              title: const Text('Mes signalements'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _viewUserReports,
            ),
            const Divider(),
            const SizedBox(height: 20),
            // Bouton de déconnexion
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF25C34),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _logout,
                child: const Text('Se déconnecter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D4D30),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1D4D30)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilePage({super.key, required this.userData});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['nom']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _phoneController = TextEditingController(text: widget.userData['telephone']);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier mon profil'),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1D4D30),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context, {
                  'nom': _nameController.text,
                  'email': _emailController.text,
                  'telephone': _phoneController.text,
                  'photoUrl': _selectedImage != null ? _selectedImage!.path : widget.userData['photoUrl'],
                });
              }
            },
            child: const Text(
              'Enregistrer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Photo de profil éditable
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFFA5D68F),
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (widget.userData['photoUrl'] != null
                              ? NetworkImage(widget.userData['photoUrl']!)
                              : null),
                      child: widget.userData['photoUrl'] == null && _selectedImage == null
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D4D30),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Formulaire d'édition
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!value.contains('@')) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserReportsPage extends StatelessWidget {
  final String userId;

  const UserReportsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Ici vous devriez récupérer les signalements de l'utilisateur
    // Pour l'exemple, on utilise des données simulées
    final List<Map<String, dynamic>> reports = [
      {
        'signalId': '1',
        'type': 'Déchets',
        'description': 'Déchets abandonnés dans le parc',
        'status': 'Résolu',
        'date': '2023-05-10',
      },
      {
        'signalId': '2',
        'type': 'Pollution',
        'description': 'Fuite d\'eau dans la rue',
        'status': 'En cours',
        'date': '2023-06-15',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes signalements'),
        backgroundColor: const Color(0xFF1D4D30),
      ),
      body: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.report, color: Color(0xFF1D4D30)),
              title: Text(report['type']),
              subtitle: Text(report['description']),
              trailing: Chip(
                label: Text(
                  report['status'],
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: report['status'] == 'Résolu'
                    ? Colors.green
                    : const Color(0xFFF25C34),
              ),
              onTap: () {
                // Navigation vers le détail du signalement
              },
            ),
          );
        },
      ),
    );
  }
}