import 'dart:async';

import 'package:alert_eco/firebase_options.dart';
import 'package:alert_eco/screens/create_signal.dart';
import 'package:alert_eco/screens/historique_page.dart';
import 'package:alert_eco/screens/home_page.dart';
import 'package:alert_eco/screens/login_page.dart';
import 'package:alert_eco/screens/notification_page.dart';
import 'package:alert_eco/screens/sign_up_page.dart';
import 'package:alert_eco/widgets/navbar_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded(() async {
    try {
      await dotenv.load(fileName: ".env");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      runApp(const MyApp());
    } catch (e, stack) {
      print("🔥 ERREUR FATALE: $e\n$stack");
      // Optionnel : Envoyer l'erreur à un service de crash reporting
    }
  }, (error, stack) => print("🚨 Zone error: $error"));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      home: SignUpPage(),
      //home: HistoriqueSignalementsPage()
      routes: {
        '/historiquesignalement': (context) => HistoriqueSignalementsPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        '/nav': (context) => NavBar(),
        '/create_signal': (context) => CreateReportPage(),
        '/notif': (context) => NotificationPage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}
