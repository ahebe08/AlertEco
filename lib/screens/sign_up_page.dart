import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers pour les champs
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/images/logo.png', // Remplacez par le bon chemin de votre logo
                  height: 160,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Créer un compte',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D4D30),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              _buildTextField(
                controller: _nameController,
                label: 'Nom complet',
                icon: Icons.person,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _emailController,
                label: 'Adresse e-mail',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                label: 'Mot de passe',
                icon: Icons.lock,
                isPassword: true,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1D4D30),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "S'inscrire",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: keyboardType,
      validator: (value) =>
          value == null || value.isEmpty ? 'Ce champ est requis' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF1D4D30)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Color(0xFF1D4D30),
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              )
            : null,
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Traitement de l'inscription
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription en cours...'),
          backgroundColor: Color(0xFFF25C34),
        ),
      );
    }
  }
}
