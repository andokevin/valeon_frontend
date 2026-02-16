import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'main_navigation.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Erreur de connexion'),
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

  Future<void> _signInWithApple() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithApple();

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Erreur Apple'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
                                    'Connexion',
                                    style: TextStyle(
                                      fontSize: isTablet ? 30.0 : 24.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),

                                  SizedBox(height: isTablet ? 32.0 : 24.0),

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
                                        return 'Veuillez entrer votre mot de passe';
                                      }
                                      return null;
                                    },
                                  ),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ForgotPasswordScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Mot de passe oublié ?',
                                        style: TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontSize: isTablet ? 15.0 : 13.0,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  CustomButton(
                                    text: 'Se Connecter',
                                    onPressed: _login,
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
                                          'Ou continuez avec',
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
                                      SocialButton(
                                        platform: 'Apple',
                                        onTap: _signInWithApple,
                                        size: isTablet ? 64.0 : 52.0,
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: isTablet ? 32.0 : 24.0),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Pas encore de compte ? ',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: isTablet ? 16.0 : 14.0,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignupScreen(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Inscrivez-vous',
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
      child: Icon(Icons.phone_iphone, size: iconSize, color: Colors.white),
    );
  }
}
