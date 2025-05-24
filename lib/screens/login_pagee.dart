import 'package:alert_eco/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers pour les champs
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  /// Vérifier si l'utilisateur est déjà connecté
  void _checkIfLoggedIn() async {
    bool isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn && mounted) {
      Navigator.pushReplacementNamed(context, "/nav");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 160,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 160,
                        width: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D4D30).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(80),
                        ),
                        child: const Icon(
                          Icons.eco,
                          size: 80,
                          color: Color(0xFF1D4D30),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Connexion',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D4D30),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Affichage du message d'erreur
                if (_errorMessage != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setState(() {
                              _errorMessage = null;
                            });
                          },
                          color: Colors.red.shade600,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ],

                _buildTextField(
                  controller: _telephoneController,
                  label: 'Numéro de téléphone',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  icon: Icons.lock,
                  isPassword: true,
                  validator: _validatePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submitForm(),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4D30),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      disabledBackgroundColor:
                          const Color(0xFF1D4D30).withOpacity(0.6),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Se connecter",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pushNamed(context, "/signup");
                        },
                  child: const Text(
                    'Pas encore inscrit ? Créer un compte',
                    style: TextStyle(
                      color: Color(0xFF1D4D30),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
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
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator ??
          (value) =>
              value == null || value.isEmpty ? 'Ce champ est requis' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1D4D30)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF1D4D30),
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1D4D30)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1D4D30), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }


  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est requis';
    }

    // Nettoyage: supprime tous les caractères non numériques
    String cleanPhone = value.replaceAll(RegExp(r'[^\d+]'), '');

    // Validation pour:
    // - Format local: 10 chiffres (XXXXXXXXXX)
    // - Format international: +225XXXXXXXXXX ou 00225XXXXXXXXXX
    if (!RegExp(r'^(?:\+225\s?)?(01|05|07|25)\d{8}$').hasMatch(cleanPhone)) {
      return 'Format invalide. Accepté: 10 chiffres, +225XXXXXXXXXX ou 00225XXXXXXXXXX';
    }

    // Vérification supplémentaire pour le premier chiffre (généralement 0,4,5,6,7 en Côte d'Ivoire)
    String phoneDigits = cleanPhone.replaceAll(RegExp(r'^(\+|00)225'), '');
    if (!RegExp(r'^[0,4,5,6,7]').hasMatch(phoneDigits)) {
      return 'Le numéro doit commencer par 0, 4, 5, 6 ou 7';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  void _submitForm() async {
    // Annuler le focus du clavier
    FocusScope.of(context).unfocus();

    // Effacer le message d'erreur précédent
    setState(() {
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Appel au service d'authentification
        Map<String, dynamic> result = await AuthService.login(
          _telephoneController.text.trim(),
          _passwordController.text,
        );

        if (mounted) {
          if (result['success']) {
            // Connexion réussie
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(result['message']),
                  ],
                ),
                backgroundColor: const Color(0xFF1D4D30),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Naviguer vers la page principale après un délai
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              Navigator.pushReplacementNamed(context, "/nav");
            }
          } else {
            // Échec de la connexion
            setState(() {
              _errorMessage = result['message'];
            });

            // Effacer le mot de passe en cas d'erreur d'authentification
            if (result['message'].contains('Mot de passe incorrect') ||
                result['message'].contains('Veuillez vous inscrire')) {
              _passwordController.clear();
            }
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage =
                'Une erreur inattendue est survenue. Veuillez réessayer.';
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
