import 'package:alert_eco/main.dart';
import 'package:alert_eco/screens/login_pageee.dart';
import 'package:alert_eco/services/auth_service.dart';
import 'package:alert_eco/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // 🔍 Vérification si l'utilisateur est déjà connecté
      bool isLoggedIn = await AuthService.isLoggedIn();

      if (isLoggedIn) {
        // ✅ Utilisateur connecté -> Redirection vers HomePage
        print(
            "🎉 Utilisateur déjà connecté : ${AuthService.currentUserData?['nom']}");

        // Petite pause pour éviter les erreurs de navigation
        await Future.delayed(Duration(milliseconds: 100));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NavBar()),
          );
        }
      } else {
        // ❌ Utilisateur non connecté -> Redirection vers LoginPage
        print("🔐 Aucune session trouvée, redirection vers login");

        await Future.delayed(Duration(milliseconds: 100));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      }
    } catch (e) {
      // 🚨 En cas d'erreur, rediriger vers login par défaut
      print("❌ Erreur lors de la vérification d'auth: $e");

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 📱 Écran de chargement pendant la vérification
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou image de ton app
            // Icon(
            //   Icons.eco,
            //   size: 80,
            //   color: Colors.green,
            // ),
            Image.asset('assets/images/logo.png', height: 80),
            SizedBox(height: 20),
            Text(
              'AlertEco',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 40),
            // Indicateur de chargement
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 20),
            Text(
              'Vérification...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
