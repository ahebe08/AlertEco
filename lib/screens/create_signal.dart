// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class CreateReportPage extends StatefulWidget {
  @override
  _CreateReportPageState createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  Position? _currentPosition;
  bool _isLoading = false;

  // Configuration Cloudinary - À remplacer par vos vraies valeurs
  static const String CLOUDINARY_CLOUD_NAME = 'diyn9dglg';
  static const String CLOUDINARY_UPLOAD_PRESET = 'alerteco';

  // Couleurs du projet
  final Color _darkGreen = Color(0xFF1D4D30);
  final Color _lightGreen = Color(0xFFA5D68F);
  final Color _alertOrange = Color(0xFFF25C34);
  final Color _white = Color(0xFFFFFFFF);
  final Color _black = Color(0xFF111111);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Récupérer automatiquement la position au démarrage
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Activez le GPS pour continuer';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Permission GPS refusée';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Permission GPS refusée définitivement';
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur GPS: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Erreur lors de la sélection de l\'image: ${e.toString()}')),
      );
    }
  }

  Future<String> _uploadImageToCloudinary(File image) async {
    try {
      final url = Uri.parse(
          'https://api.cloudinary.com/v1_1/$CLOUDINARY_CLOUD_NAME/image/upload');

      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = CLOUDINARY_UPLOAD_PRESET;
      request.fields['folder'] = 'reports'; // Dossier dans Cloudinary

      final file = await http.MultipartFile.fromPath('file', image.path);
      request.files.add(file);

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);
        return jsonData['secure_url']; // URL sécurisée de l'image
      } else {
        throw 'Erreur lors de l\'upload: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Erreur Cloudinary: ${e.toString()}';
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs requis')),
      );
      return;
    }

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez ajouter une photo')),
      );
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Localisation requise. Veuillez activer le GPS')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Upload de l'image vers Cloudinary
      String imageUrl = await _uploadImageToCloudinary(_image!);

      // 2. Récupération des informations utilisateur (si disponible)
      String? userId;
      String? userName;

      // Si vous utilisez le service d'authentification
      // userId = AuthService.currentUser?.uid;
      // userName = AuthService.currentUserData?['nom'];

      // 3. Préparation des données du signalement
      Map<String, dynamic> reportData = {
        'titre': _titreController.text.trim(),
        'description': _descriptionController.text.trim(),
        'photo': imageUrl,
        'localisation': {
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
        },
        'statut': 'En attente', // Statut par défaut n
        'date': FieldValue.serverTimestamp(),
        'modifieLe': FieldValue.serverTimestamp(),
        'userId': userId, // Peut être null si pas d'authentification
        'userName': userName, // Peut être null
      };

      // 4. Enregistrement dans Firestore
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('signalements')
          .add(reportData);

      // 5. Mise à jour avec l'ID du document
      await docRef.update({'id': docRef.id});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signalement envoyé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      // Retour à la page précédente
      Navigator.pop(
          context, true); // true indique que le signalement a été créé
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Méthode optionnelle pour obtenir l'adresse à partir des coordonnées
  Future<String> _getAddressFromCoordinates(Position position) async {
    try {
      // Ici vous pouvez utiliser un service de géocodage inverse
      // Par exemple avec le package geocoding
      // List<Placemark> placemarks = await placemarkFromCoordinates(
      //   position.latitude,
      //   position.longitude
      // );
      // return "${placemarks.first.street}, ${placemarks.first.locality}";

      // Pour l'instant, retour des coordonnées formatées
      return "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
    } catch (e) {
      return "Adresse non disponible";
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: _darkGreen,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, color: _darkGreen),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _darkGreen),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _darkGreen, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      appBar: AppBar(
        title: Text(
          'Nouveau Signalement',
          style: TextStyle(color: _black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _white,
        iconTheme: IconThemeData(color: _darkGreen),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: _alertOrange),
                  SizedBox(height: 16),
                  Text('Chargement...', style: TextStyle(color: _darkGreen)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section Localisation (information)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _lightGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _lightGreen),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.location_on, color: _darkGreen, size: 30),
                          SizedBox(height: 8),
                          Text(
                            'Localisation actuelle',
                            style: TextStyle(
                              color: _darkGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          if (_currentPosition != null)
                            Text(
                              'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}\n'
                              'Long: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                              style: TextStyle(color: _darkGreen),
                              textAlign: TextAlign.center,
                            )
                          else
                            Text(
                              'Localisation en cours...',
                              style: TextStyle(color: _darkGreen),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Section Catégorie
                    _buildSectionTitle('Titre *'),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _titreController,
                      decoration: _buildInputDecoration(
                        'Donnez un titre à votre signalement',
                        Icons.title,
                      ),
                      maxLines: 2,
                      maxLength: 100,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer un titre';
                        }
                        return null;
                      },
                    ),
                    // Section Description
                    _buildSectionTitle('Description *'),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _buildInputDecoration(
                        'Décrivez le problème en détail',
                        Icons.description,
                      ),
                      maxLines: 5,
                      maxLength: 500,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer une description';
                        }
                        if (value.trim().length < 10) {
                          return 'La description doit contenir au moins 10 caractères';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Section Photo
                    _buildSectionTitle('Photo *'),
                    SizedBox(height: 8),
                    if (_image != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: _darkGreen),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt,
                                  size: 50, color: _darkGreen),
                              SizedBox(height: 8),
                              Text(
                                'Aucune photo sélectionnée',
                                style: TextStyle(color: _darkGreen),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: Icon(Icons.camera_alt),
                            label: Text('Prendre une photo'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _darkGreen,
                              side: BorderSide(color: _darkGreen),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: Icon(Icons.photo_library),
                            label: Text('Choisir une photo'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _darkGreen,
                              side: BorderSide(color: _darkGreen),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),

                    // Bouton de soumission
                    ElevatedButton(
                      onPressed: _submitReport,
                      child: Text(
                        'Envoyer le signalement',
                        style: TextStyle(fontSize: 18, color: _white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _alertOrange,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Note informative
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Le signalement sera créé avec votre position actuelle',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _titreController.dispose();
    super.dispose();
  }
}
