import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart';
import 'signup_screen.dart';
import 'main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
                            ),

                            SizedBox(height: isTablet ? 20.0 : 16.0),

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
                              isLoading: _isLoading,
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
                                  onTap: _login,
                                  size: isTablet ? 64.0 : 52.0,
                                ),
                                SizedBox(width: isTablet ? 24.0 : 16.0),
                                SocialButton(
                                  platform: 'Facebook',
                                  onTap: _login,
                                  size: isTablet ? 64.0 : 52.0,
                                ),
                                SizedBox(width: isTablet ? 24.0 : 16.0),
                                SocialButton(
                                  platform: 'Apple',
                                  onTap: _login,
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
