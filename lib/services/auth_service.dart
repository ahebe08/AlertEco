import 'package:bcrypt/bcrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  /// Connexion avec numéro de téléphone et mot de passe
  // static Future<Map<String, dynamic>> login(
  //     String telephone, String password) async {
  //   try {
  //     //     String normalizedPhone = _normalizePhoneNumber(telephone);
  //     //     DocumentSnapshot? userDoc = await _getUserByPhone(normalizedPhone);
  //     DocumentSnapshot? userDoc = await _getUserByPhone(telephone);

  //     if (userDoc == null) {
  //       return {
  //         'success': false,
  //         'message':
  //             'Aucun compte trouvé avec ce numéro de téléphone. Veuillez vous inscrire.'
  //       };
  //     }

  //     Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
  //     String email = userData['email'];
  //     String storedPassword = userData['motdepasse'];
  //     if (storedPassword != password) {
  //       return {
  //         'success': false,
  //         'message': 'Mot de passe incorrect. Veuillez réessayer.'
  //       };
  //     }

  //     UserCredential userCredential = await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );

  //     if (userCredential.user != null) {
  //       _currentUserData = userData;
  //       if (_currentUserData!['creeLe'] != null) {
  //         _currentUserData!['creeLe'] =
  //             (_currentUserData!['creeLe'] as Timestamp).toDate();
  //       }

  //       await _saveUserSession();

  //       return {
  //         'success': true,
  //         'message': 'Connexion réussie',
  //         'user': _currentUserData
  //       };
  //     }

  //     return {'success': false, 'message': 'Erreur lors de la connexion'};
  //   } on FirebaseAuthException catch (e) {
  //     String message = _getErrorMessage(e.code);
  //     return {'success': false, 'message': message};
  //   } catch (e) {
  //     return {
  //       'success': false,
  //       'message': 'Une erreur est survenue: ${e.toString()}'
  //     };
  //   }
  // }

  /// Connexion avec numéro de téléphone et mot de passe
  static Future<Map<String, dynamic>> login(
      String telephone, String password) async {
    try {
      // Normalisation du numéro de téléphone
      // String normalizedPhone = _normalizePhoneNumber(telephone);

      // Recherche de l'utilisateur par téléphone
      //DocumentSnapshot? userDoc = await _getUserByPhone(normalizedPhone);
      DocumentSnapshot? userDoc = await _getUserByPhone(telephone);

      if (userDoc == null || !userDoc.exists) {
        return {
          'success': false,
          'message':
              'Aucun compte trouvé avec ce numéro de téléphone. Veuillez vous inscrire.'
        };
      }

      // Récupération des données utilisateur
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String storedHashedPassword = userData['motdepasse'];

      // Vérification du mot de passe avec BCrypt
      bool isPasswordValid = BCrypt.checkpw(password, storedHashedPassword);
      if (!isPasswordValid) {
        return {
          'success': false,
          'message': 'Mot de passe incorrect. Veuillez réessayer.'
        };
      }

      // Authentification avec Firebase Auth
      String email = userData['email'];
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Mise à jour des données utilisateur en mémoire
        _currentUserData = userData;

        // Conversion du timestamp Firestore en DateTime
        if (_currentUserData!['creeLe'] != null) {
          _currentUserData!['creeLe'] =
              (_currentUserData!['creeLe'] as Timestamp).toDate();
        }

        // Sauvegarde de la session
        await _saveUserSession();

        return {
          'success': true,
          'message': 'Connexion réussie',
          'user': _currentUserData
        };
      }

      return {'success': false, 'message': 'Erreur lors de la connexion'};
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      return {'success': false, 'message': message};
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur est survenue: ${e.toString()}'
      };
    }
  }

  // Inscription d'un nouvel utilisateur
  static Future<Map<String, dynamic>> register({
    required String nom,
    required String email,
    required String telephone,
    required String password,
    String? photoUrl,
  }) async {
    try {
      String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      // String normalizedPhone = _normalizePhoneNumber(telephone);
      bool phoneExists = await _checkPhoneExists(telephone);
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

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        Map<String, dynamic> userData = {
          'email': email,
          'motdepasse': hashedPassword,
          'nom': nom,
          // 'telephone': normalizedPhone,
          'telephone': telephone,
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

        _currentUserData = userData;
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
      return {'success': false, 'message': message};
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur est survenue: ${e.toString()}'
      };
    }
  }

  // /// Déconnexion
  // static Future<void> logout() async {
  //   try {
  //     await _auth.signOut();
  //     await _clearUserSession();
  //     _currentUserData = null;
  //   } catch (e) {
  //     print('Erreur lors de la déconnexion: $e');
  //   }
  // }

  /// Déconnexion de l'utilisateur et redirection vers la page principale
  static Future<void> logout(BuildContext context) async {
    try {
      // Déconnexion Firebase
      await _auth.signOut();

      // Nettoyer SharedPreferences
      await _clearUserSession();

      // Réinitialiser les données locales
      _currentUserData = null;

      // Redirection vers la page principale
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/', // nom de la route principale (à adapter si différent)
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Erreur lors de la déconnexion : $e');
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
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        _currentUserData = doc.data() as Map<String, dynamic>;
        if (_currentUserData!['creeLe'] != null) {
          _currentUserData!['creeLe'] =
              (_currentUserData!['creeLe'] as Timestamp).toDate();
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des données utilisateur: $e');
    }
  }

  // Sauvegarder la session utilisateur localement
  static Future<void> _saveUserSession() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (_currentUserData != null && _auth.currentUser != null) {
        await prefs.setString(_userTokenKey, _auth.currentUser!.uid);
        Map<String, dynamic> userData =
            Map<String, dynamic>.from(_currentUserData!);
        userData.remove('motdepasse');

        if (userData['creeLe'] is DateTime) {
          userData['creeLe'] =
              (userData['creeLe'] as DateTime).toIso8601String();
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

  /// Normaliser le numéro de téléphone
  // static String _normalizePhoneNumber(String telephone) {
  //   String normalized = telephone.replaceAll(RegExp(r'[\s\.\-]'), '');
  //   if (normalized.startsWith('+33')) {
  //     normalized = '0' + normalized.substring(3);
  //   } else if (normalized.startsWith('0033')) {
  //     normalized = '0' + normalized.substring(4);
  //   }
  //   return normalized;
  // }

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
        return 'Le mot de passe est trop faible.';
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
  static Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword) async {
    try {
      if (_auth.currentUser == null || _currentUserData == null) {
        return {'success': false, 'message': 'Utilisateur non connecté'};
      }

      String storedPassword = _currentUserData!['motdepasse'] ?? '';
      if (storedPassword != oldPassword) {
        return {'success': false, 'message': 'Ancien mot de passe incorrect'};
      }

      await _auth.currentUser!.updatePassword(newPassword);
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({'motdepasse': newPassword});

      _currentUserData!['motdepasse'] = newPassword;

      return {
        'success': true,
        'message': 'Mot de passe mis à jour avec succès'
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Erreur lors de la mise à jour du mot de passe: ${e.toString()}'
      };
    }
  }
}
