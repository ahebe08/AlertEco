import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Clés pour SharedPreferences
  static const String _userTokenKey = 'user_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // Modèle utilisateur
  static Map<String, dynamic>? _currentUserData;

  // Getter pour les données utilisateur actuelles
  static Map<String, dynamic>? get currentUserData => _currentUserData;
  static User? get currentUser => _auth.currentUser;

  /// Hacher le mot de passe avec SHA-256 et sel
  static String _hashPassword(String password, String salt) {
    var bytes = utf8.encode(password + salt);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Générer un sel aléatoire
  static String _generateSalt() {
    var timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    var bytes = utf8.encode(timestamp);
    var digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  /// Connexion avec numéro de téléphone et mot de passe
  static Future<Map<String, dynamic>> login(String telephone, String password) async {
    try {
      String normalizedPhone = _normalizePhoneNumber(telephone);
      DocumentSnapshot? userDoc = await _getUserByPhone(normalizedPhone);

      if (userDoc == null) {
        return {
          'success': false,
          'message': 'Aucun compte trouvé avec ce numéro de téléphone. Veuillez vous inscrire.'
        };
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String email = userData['email'];
      String storedPasswordHash = userData['motdepasse'];
      String salt = userData['salt'] ?? '';
      
      // Vérifier le mot de passe haché
      String passwordHash = _hashPassword(password, salt);
      if (storedPasswordHash != passwordHash) {
        return {
          'success': false,
          'message': 'Mot de passe incorrect. Veuillez réessayer.'
        };
      }

      // Utiliser un mot de passe temporaire pour Firebase Auth
      // Car nous gérons notre propre système d'authentification
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: userData['firebasePassword'], // Mot de passe séparé pour Firebase
      );

      if (userCredential.user != null) {
        _currentUserData = userData;
        // Nettoyer les données sensibles
        _currentUserData!.remove('motdepasse');
        _currentUserData!.remove('salt');
        _currentUserData!.remove('firebasePassword');
        
        if (_currentUserData!['creeLe'] != null) {
          _currentUserData!['creeLe'] = (_currentUserData!['creeLe'] as Timestamp).toDate();
        }

        await _saveUserSession();

        return {
          'success': true,
          'message': 'Connexion réussie',
          'user': _currentUserData
        };
      }

      return {
        'success': false,
        'message': 'Erreur lors de la connexion'
      };

    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      return {
        'success': false,
        'message': message
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur est survenue: ${e.toString()}'
      };
    }
  }

  /// Inscription d'un nouvel utilisateur
  static Future<Map<String, dynamic>> register({
    required String nom,
    required String email,
    required String telephone,
    required String password,
    String? photoUrl,
  }) async {
    try {
      String normalizedPhone = _normalizePhoneNumber(telephone);
      bool phoneExists = await _checkPhoneExists(normalizedPhone);
      if (phoneExists) {
        return {
          'success': false,
          'message': 'Ce numéro de téléphone est déjà utilisé'
        };
      }

      bool emailExists = await _checkEmailExists(email);
      if (emailExists) {
        return {
          'success': false,
          'message': 'Cette adresse e-mail est déjà utilisée'
        };
      }

      // Générer un mot de passe Firebase séparé
      String firebasePassword = _generateSalt() + _generateSalt(); // Plus long et aléatoire

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: firebasePassword,
      );

      if (userCredential.user != null) {
        // Hacher le mot de passe utilisateur
        String salt = _generateSalt();
        String hashedPassword = _hashPassword(password, salt);

        Map<String, dynamic> userData = {
          'email': email,
          'motdepasse': hashedPassword,
          'salt': salt,
          'firebasePassword': firebasePassword,
          'nom': nom,
          'telephone': normalizedPhone,
          'photoUrl': photoUrl ?? '',
          'creeLe': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userData);

        await userCredential.user!.updateDisplayName(nom);
        if (photoUrl != null && photoUrl.isNotEmpty) {
          await userCredential.user!.updatePhotoURL(photoUrl);
        }

        // Préparer les données pour la session (sans mots de passe)
        _currentUserData = Map<String, dynamic>.from(userData);
        _currentUserData!.remove('motdepasse');
        _currentUserData!.remove('salt');
        _currentUserData!.remove('firebasePassword');
        _currentUserData!['creeLe'] = DateTime.now();

        await _saveUserSession();

        return {
          'success': true,
          'message': 'Compte créé avec succès',
          'user': _currentUserData
        };
      }

      return {
        'success': false,
        'message': 'Erreur lors de la création du compte'
      };

    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      return {
        'success': false,
        'message': message
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur est survenue: ${e.toString()}'
      };
    }
  }

  /// Déconnexion
  static Future<void> logout() async {
    try {
      await _auth.signOut();
      await _clearUserSession();
      _currentUserData = null;
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }

  /// Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      if (isLoggedIn && _auth.currentUser != null) {
        if (_currentUserData == null) {
          await _loadUserDataFromPrefs();
        }
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Récupérer l'utilisateur par numéro de téléphone
  static Future<DocumentSnapshot?> _getUserByPhone(String telephone) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('telephone', isEqualTo: telephone)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first;
      }
      return null;
    } catch (e) {
      print('Erreur lors de la recherche de l\'utilisateur: $e');
      return null;
    }
  }

  /// Vérifier si un numéro de téléphone existe déjà
  static Future<bool> _checkPhoneExists(String telephone) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('telephone', isEqualTo: telephone)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification du téléphone: $e');
      return false;
    }
  }

  /// Vérifier si un email existe déjà
  static Future<bool> _checkEmailExists(String email) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification de l\'email: $e');
      return false;
    }
  }

  /// Charger les données utilisateur depuis Firestore
  static Future<void> _loadUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        _currentUserData = doc.data() as Map<String, dynamic>;
        // Nettoyer les données sensibles
        _currentUserData!.remove('motdepasse');
        _currentUserData!.remove('salt');
        _currentUserData!.remove('firebasePassword');
        
        if (_currentUserData!['creeLe'] != null) {
          _currentUserData!['creeLe'] = (_currentUserData!['creeLe'] as Timestamp).toDate();
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des données utilisateur: $e');
    }
  }

  /// Sauvegarder la session utilisateur localement
  static Future<void> _saveUserSession() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (_currentUserData != null && _auth.currentUser != null) {
        await prefs.setString(_userTokenKey, _auth.currentUser!.uid);
        Map<String, dynamic> userData = Map<String, dynamic>.from(_currentUserData!);
        
        // S'assurer qu'aucune donnée sensible n'est sauvegardée
        userData.remove('motdepasse');
        userData.remove('salt');
        userData.remove('firebasePassword');

        if (userData['creeLe'] is DateTime) {
          userData['creeLe'] = (userData['creeLe'] as DateTime).toIso8601String();
        }

        await prefs.setString(_userDataKey, jsonEncode(userData));
        await prefs.setBool(_isLoggedInKey, true);
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde de la session: $e');
    }
  }

  /// Charger les données utilisateur depuis SharedPreferences
  static Future<void> _loadUserDataFromPrefs() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString(_userDataKey);

      if (userDataString != null) {
        Map<String, dynamic> userData = jsonDecode(userDataString);
        if (userData['creeLe'] is String) {
          userData['creeLe'] = DateTime.parse(userData['creeLe']);
        }
        _currentUserData = userData;
      }
    } catch (e) {
      print('Erreur lors du chargement des données depuis les préférences: $e');
    }
  }

  /// Effacer la session utilisateur localement
  static Future<void> _clearUserSession() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userTokenKey);
      await prefs.remove(_userDataKey);
      await prefs.setBool(_isLoggedInKey, false);
    } catch (e) {
      print('Erreur lors de l\'effacement de la session: $e');
    }
  }

  /// Normaliser le numéro de téléphone ivoirien
  static String _normalizePhoneNumber(String telephone) {
    // Supprimer tous les espaces, points, tirets
    String normalized = telephone.replaceAll(RegExp(r'[\s\.\-]'), '');
    
    // Gérer les formats ivoiriens
    if (normalized.startsWith('+225')) {
      // +225 XX XX XX XX XX → 225XXXXXXXXXX
      normalized = normalized.substring(1);
    } else if (normalized.startsWith('00225')) {
      // 00225 XX XX XX XX XX → 225XXXXXXXXXX
      normalized = normalized.substring(2);
    } else if (normalized.startsWith('225')) {
      // 225 XX XX XX XX XX → 225XXXXXXXXXX (déjà bon)
    } else if (normalized.length == 10 && normalized.startsWith('0')) {
      // 01 02 03 04 05 → 22501020304055
      normalized = '225' + normalized.substring(1);
    } else if (normalized.length == 8) {
      // 01020304 → 22501020304
      normalized = '225' + normalized;
    }
    
    return normalized;
  }

  /// Valider le format du numéro de téléphone ivoirien
  static bool isValidIvorianPhoneNumber(String telephone) {
    String normalized = _normalizePhoneNumber(telephone);
    
    // Format: 225 + 8 chiffres (01, 02, 03, 05, 07, 08, 09 + 6 chiffres)
    // Opérateurs principaux: Orange (07, 08, 09), MTN (05), Moov (01, 02, 03)
    RegExp ivorianPhoneRegex = RegExp(r'^225(0[1235789])\d{6}$');
    
    return ivorianPhoneRegex.hasMatch(normalized);
  }

  /// Obtenir un message d'erreur localisé
  static String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec ces identifiants. Veuillez vous inscrire.';
      case 'wrong-password':
        return 'Mot de passe incorrect. Veuillez réessayer.';
      case 'email-already-in-use':
        return 'Cette adresse e-mail est déjà utilisée.';
      case 'weak-password':
        return 'Le mot de passe est trop faible. Minimum 6 caractères.';
      case 'invalid-email':
        return 'Adresse e-mail invalide.';
      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez réessayer plus tard.';
      case 'network-request-failed':
        return 'Erreur de connexion. Vérifiez votre connexion internet.';
      default:
        return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }

  /// Récupérer le token utilisateur actuel
  static Future<String?> getUserToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Mettre à jour les données utilisateur
  static Future<bool> updateUserData(Map<String, dynamic> newData) async {
    try {
      if (_auth.currentUser != null) {
        // Ne pas permettre la mise à jour des champs sensibles
        newData.remove('motdepasse');
        newData.remove('salt');
        newData.remove('firebasePassword');
        newData.remove('email'); // L'email nécessite une procédure spéciale
        
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update(newData);

        await _loadUserData(_auth.currentUser!.uid);
        await _saveUserSession();

        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la mise à jour: $e');
      return false;
    }
  }

  /// Changer le mot de passe
  static Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    try {
      if (_auth.currentUser == null) {
        return {
          'success': false,
          'message': 'Utilisateur non connecté'
        };
      }

      // Récupérer les données complètes depuis Firestore
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (!doc.exists) {
        return {
          'success': false,
          'message': 'Données utilisateur introuvables'
        };
      }

      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      String storedPasswordHash = userData['motdepasse'] ?? '';
      String salt = userData['salt'] ?? '';

      // Vérifier l'ancien mot de passe
      String oldPasswordHash = _hashPassword(oldPassword, salt);
      if (storedPasswordHash != oldPasswordHash) {
        return {
          'success': false,
          'message': 'Ancien mot de passe incorrect'
        };
      }

      // Générer un nouveau sel et hacher le nouveau mot de passe
      String newSalt = _generateSalt();
      String newPasswordHash = _hashPassword(newPassword, newSalt);
      
      // Générer un nouveau mot de passe Firebase
      String newFirebasePassword = _generateSalt() + _generateSalt();

      // Mettre à jour Firebase Auth
      await _auth.currentUser!.updatePassword(newFirebasePassword);
      
      // Mettre à jour Firestore
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({
            'motdepasse': newPasswordHash,
            'salt': newSalt,
            'firebasePassword': newFirebasePassword,
          });

      return {
        'success': true,
        'message': 'Mot de passe mis à jour avec succès'
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la mise à jour du mot de passe: ${e.toString()}'
      };
    }
  }
}