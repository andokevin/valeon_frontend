import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'main_navigation.dart';

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
                            ),

                            SizedBox(height: isTablet ? 20.0 : 16.0),

                            CustomTextField(
                              hintText: 'Email',
                              prefixIcon: Icons.email_outlined,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            SizedBox(height: isTablet ? 20.0 : 16.0),

                            CustomTextField(
                              hintText: 'Mot de passe',
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                              controller: _passwordController,
                            ),

                            SizedBox(height: isTablet ? 20.0 : 16.0),

                            CustomTextField(
                              hintText: 'Confirmer le mot de passe',
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                              controller: _confirmPasswordController,
                            ),

                            SizedBox(height: isTablet ? 32.0 : 24.0),

                            CustomButton(
                              text: "S'inscrire",
                              onPressed: _signup,
                              isLoading: _isLoading,
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
                                    Navigator.pop(context);
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
