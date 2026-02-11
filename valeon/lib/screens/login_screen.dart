import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart';
import 'signup_screen.dart';
import 'main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
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
                          'Connexion',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
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
                        
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Mot de passe oublié ?',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        CustomButton(
                          text: 'Se Connecter',
                          onPressed: _login,
                          isLoading: _isLoading,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Ou continuez avec',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialButton(
                              platform: 'Google',
                              onTap: () {},
                            ),
                            const SizedBox(width: 16),
                            SocialButton(
                              platform: 'Facebook',
                              onTap: () {},
                            ),
                            const SizedBox(width: 16),
                            SocialButton(
                              platform: 'Apple',
                              onTap: () {},
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Pas encore de compte ? ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignupScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Inscrivez-vous',
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
        Icons.phone_iphone,
        size: 80,
        color: Colors.white,
      ),
    );
  }
}