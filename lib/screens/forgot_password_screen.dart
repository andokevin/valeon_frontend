import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.resetPassword(
      _emailController.text.trim(),
    );

    if (success && mounted) {
      setState(() {
        _emailSent = true;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Erreur'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.maxContentWidth(context),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingScreen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),

                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (_emailSent) {
                          return _buildSuccessMessage(context);
                        }
                        return _buildResetForm(authProvider, context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetForm(AuthProvider authProvider, BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mot de passe oublié ?',
            style: TextStyle(
              fontSize: isTablet ? 34.0 : 28.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Entrez votre email pour recevoir un lien de réinitialisation',
            style: TextStyle(
              fontSize: isTablet ? 18.0 : 16.0,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 40),

          Container(
            padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(isTablet ? 32.0 : 24.0),
            ),
            child: Column(
              children: [
                CustomTextField(
                  hintText: 'Votre email',
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
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Envoyer le lien',
                  onPressed: _resetPassword,
                  isLoading: authProvider.isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? 180.0 : 120.0,
            height: isTablet ? 180.0 : 120.0,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: isTablet ? 110.0 : 80.0,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Email envoyé !',
            style: TextStyle(
              fontSize: isTablet ? 32.0 : 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Vérifiez votre boîte de réception',
            style: TextStyle(
              fontSize: isTablet ? 18.0 : 16.0,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 40),
          CustomButton(
            text: 'Retour à la connexion',
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            width: isTablet ? 300.0 : 250.0,
          ),
        ],
      ),
    );
  }
}
