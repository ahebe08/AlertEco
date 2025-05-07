import 'package:alert_eco/screens/historique_page.dart';
import 'package:alert_eco/screens/sign_up_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
      },
    );
  }
}
