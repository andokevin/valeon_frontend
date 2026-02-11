import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'main_navigation.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingScreen),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIllustration(),
                  
                  const SizedBox(height: 40),
                  
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Inscription',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        CustomTextField(
                          hintText: 'Nom Complet',
                          prefixIcon: Icons.person_outline,
                          controller: _nameController,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          hintText: 'Email',
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          hintText: 'Mot de passe',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          controller: _passwordController,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          hintText: 'Confirmer le mot de passe',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          controller: _confirmPasswordController,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        CustomButton(
                          text: "S'inscrire",
                          onPressed: _signup,
                          isLoading: _isLoading,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'En vous inscrivant, vous acceptez ',
                                ),
                                TextSpan(
                                  text: "nos Conditions d'Utilisation",
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: ' et '),
                                TextSpan(
                                  text: 'Politique de Confidentialité',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Déjà un compte ? ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Connectez-vous',
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.rocket_launch,
        size: 80,
        color: Colors.white,
      ),
    );
  }
}