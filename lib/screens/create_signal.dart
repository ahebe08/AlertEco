// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class CreateReportPage extends StatefulWidget {
  @override
  _CreateReportPageState createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _image;
  String? _selectedCategory;
  Position? _currentPosition;
  bool _isLoading = false;
  List<Map<String, dynamic>> _categories = [];

  // Couleurs du projet
  final Color _darkGreen = Color(0xFF1D4D30);
  final Color _lightGreen = Color(0xFFA5D68F);
  final Color _alertOrange = Color(0xFFF25C34);
  final Color _white = Color(0xFFFFFFFF);
  final Color _black = Color(0xFF111111);

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      _categories = snapshot.docs.map((doc) => doc.data()).toList();
    });
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
          throw 'Permission refusée';
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _locationController.text = 
          '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
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
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ajoutez une photo')),
      );
      return;
    }

    if (_currentPosition == null && _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Indiquez une localisation')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      String imageUrl = await _uploadImage(_image!);
      
      // Gestion de la localisation
      Map<String, double> location = {};
      if (_currentPosition != null) {
        location = {
          'lat': _currentPosition!.latitude,
          'long': _currentPosition!.longitude,
        };
      } else {
        List<String> coords = _locationController.text.split(',');
        location = {
          'lat': double.parse(coords[0].trim()),
          'long': double.parse(coords[1].trim()),
        };
      }

      // await FirebaseFirestore.instance.collection('signalements').add({
      //   'description': _descriptionController.text,
      //   'imageUrl': imageUrl,
      //   'localisation': location,
      //   'status': 'En attente',
      //   'type': _selectedCategory,
      //   'userId': FirebaseAuth.instance.currentUser!.uid,
      //   'creeLe': FieldValue.serverTimestamp(),
      //   'modifieLe': FieldValue.serverTimestamp(),
      // });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signalement envoyé !')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _uploadImage(File image) async {
    String fileName = 'reports/${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = storageRef.putFile(image);
    await uploadTask.whenComplete(() => null);
    return await storageRef.getDownloadURL();
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

  Widget _buildLocationButton() {
    return ElevatedButton.icon(
      onPressed: _getCurrentLocation,
      icon: Icon(Icons.gps_fixed, color: _white),
      label: Text('Utiliser ma position actuelle'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkGreen,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
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
          ? Center(child: CircularProgressIndicator(color: _alertOrange))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section Catégorie
                    _buildSectionTitle('Catégorie'),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: _buildInputDecoration(
                        'Sélectionnez une catégorie',
                        Icons.category,
                      ),
                      value: _selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['id'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Sélectionnez une catégorie';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Section Description
                    _buildSectionTitle('Description'),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _buildInputDecoration(
                        'Décrivez le problème',
                        Icons.description,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Entrez une description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Section Photo
                    _buildSectionTitle('Photo'),
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
                              Icon(Icons.camera_alt, size: 50, color: _darkGreen),
                              SizedBox(height: 8),
                              Text('Aucune photo sélectionnée'),
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
                              foregroundColor: _darkGreen, side: BorderSide(color: _darkGreen),
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
                              foregroundColor: _darkGreen, side: BorderSide(color: _darkGreen),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Section Localisation
                    _buildSectionTitle('Localisation'),
                    SizedBox(height: 8),
                    
                    // Champ de saisie manuelle
                    TextFormField(
                      controller: _locationController,
                      decoration: _buildInputDecoration(
                        'Saisir manuellement (lat, long)',
                        Icons.edit_location,
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty && _currentPosition == null) {
                          return 'Saisissez une localisation ou utilisez le GPS';
                        }
                        if (value.isNotEmpty) {
                          try {
                            List<String> coords = value.split(',');
                            if (coords.length != 2) throw FormatException();
                            double.parse(coords[0].trim());
                            double.parse(coords[1].trim());
                          } catch (e) {
                            return 'Format invalide. Exemple: 48.8566, 2.3522';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // OU séparateur
                    Row(
                      children: [
                        Expanded(child: Divider(color: _darkGreen.withOpacity(0.3))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('OU'),
                        ),
                        Expanded(child: Divider(color: _darkGreen.withOpacity(0.3))),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Bouton géolocalisation
                    _buildLocationButton(),
                    if (_currentPosition != null)
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          '📍 Position enregistrée\n'
                          'Latitude: ${_currentPosition!.latitude.toStringAsFixed(4)}\n'
                          'Longitude: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                          style: TextStyle(color: _darkGreen),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(height: 32),

                    // Bouton de soumission
                    ElevatedButton(
                      onPressed: _submitReport,
                      child: Text(
                        'Envoyer le signalement',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _alertOrange,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}