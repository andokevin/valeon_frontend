import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription réussie ! Vérifiez vos emails.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Erreur d\'inscription'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Erreur Google'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Future<void> _signInWithApple() async {
  //   final authProvider = Provider.of<AuthProvider>(context, listen: false);
  //   final success = await authProvider.signInWithApple();

  //   if (!success && mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(authProvider.errorMessage ?? 'Erreur Apple'),
  //         backgroundColor: Colors.red,
  //         behavior: SnackBarBehavior.floating,
  //       ),
  //     );
  //   }
  // }

  Future<void> _signInWithFacebook() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithFacebook();

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Erreur Facebook'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final illustrationSize = ResponsiveHelper.illustrationSize(context);
    final illustrationIconSize = ResponsiveHelper.illustrationIconSize(context);

    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveHelper.paddingScreen(context)),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildIllustration(
                              illustrationSize,
                              illustrationIconSize,
                            ),

                            SizedBox(height: isTablet ? 52.0 : 40.0),

                            Container(
                              padding: EdgeInsets.all(isTablet ? 36.0 : 24.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(
                                  isTablet ? 32.0 : 24.0,
                                ),
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
                                  Text(
                                    'Inscription',
                                    style: TextStyle(
                                      fontSize: isTablet ? 30.0 : 24.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),

                                  SizedBox(height: isTablet ? 32.0 : 24.0),

                                  CustomTextField(
                                    hintText: 'Nom Complet',
                                    prefixIcon: Icons.person_outline,
                                    controller: _nameController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer votre nom';
                                      }
                                      return null;
                                    },
                                  ),

                                  SizedBox(height: isTablet ? 20.0 : 16.0),

                                  CustomTextField(
                                    hintText: 'Email',
                                    prefixIcon: Icons.email_outlined,
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer votre email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Email invalide';
                                      }
                                      return null;
                                    },
                                  ),

                                  SizedBox(height: isTablet ? 20.0 : 16.0),

                                  CustomTextField(
                                    hintText: 'Mot de passe',
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: true,
                                    controller: _passwordController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer un mot de passe';
                                      }
                                      if (value.length < 6) {
                                        return 'Minimum 6 caractères';
                                      }
                                      return null;
                                    },
                                  ),

                                  SizedBox(height: isTablet ? 20.0 : 16.0),

                                  CustomTextField(
                                    hintText: 'Confirmer le mot de passe',
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: true,
                                    controller: _confirmPasswordController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez confirmer';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Les mots de passe ne correspondent pas';
                                      }
                                      return null;
                                    },
                                  ),

                                  SizedBox(height: isTablet ? 32.0 : 24.0),

                                  CustomButton(
                                    text: "S'inscrire",
                                    onPressed: _signup,
                                    isLoading: authProvider.isLoading,
                                  ),

                                  SizedBox(height: isTablet ? 32.0 : 24.0),

                                  Row(
                                    children: [
                                      const Expanded(child: Divider()),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          'Ou inscrivez-vous avec',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: isTablet ? 15.0 : 13.0,
                                          ),
                                        ),
                                      ),
                                      const Expanded(child: Divider()),
                                    ],
                                  ),

                                  SizedBox(height: isTablet ? 32.0 : 24.0),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SocialButton(
                                        platform: 'Google',
                                        onTap: _signInWithGoogle,
                                        size: isTablet ? 64.0 : 52.0,
                                      ),
                                      SizedBox(width: isTablet ? 24.0 : 16.0),
                                      SocialButton(
                                        platform: 'Facebook',
                                        onTap: _signInWithFacebook,
                                        size: isTablet ? 64.0 : 52.0,
                                      ),
                                      SizedBox(width: isTablet ? 24.0 : 16.0),
                                    ],
                                  ),

                                  SizedBox(height: isTablet ? 20.0 : 16.0),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: isTablet ? 14.0 : 12.0,
                                        ),
                                        children: const [
                                          TextSpan(
                                            text:
                                                'En vous inscrivant, vous acceptez ',
                                          ),
                                          TextSpan(
                                            text:
                                                "nos Conditions d'Utilisation",
                                            style: TextStyle(
                                              color: AppColors.primaryBlue,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(text: ' et '),
                                          TextSpan(
                                            text:
                                                'Politique de Confidentialité',
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

                                  SizedBox(height: isTablet ? 32.0 : 24.0),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Déjà un compte ? ',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: isTablet ? 16.0 : 14.0,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginScreen(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Connectez-vous',
                                          style: TextStyle(
                                            color: AppColors.primaryBlue,
                                            fontSize: isTablet ? 16.0 : 14.0,
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
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(double size, double iconSize) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Icon(Icons.rocket_launch, size: iconSize, color: Colors.white),
    );
  }
}
