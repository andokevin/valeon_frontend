// lib/screens/profile/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/layout/space_background.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  bool _showPasswords = false;

  @override
  void dispose() {
    _current.dispose();
    _newPassword.dispose();
    _confirm.dispose();
    super.dispose();
  }

  /// Mêmes règles que le backend : 8 caractères, une majuscule, un chiffre
  String? _validateNew(String? value) {
    final v = value ?? '';
    if (v.length < 8) return 'Au moins 8 caractères';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'Au moins une majuscule';
    if (!v.contains(RegExp(r'[0-9]'))) return 'Au moins un chiffre';
    if (v == _current.text) return "Doit être différent de l'ancien";
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final error = await auth.changePassword(
      currentPassword: _current.text,
      newPassword: _newPassword.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? 'Mot de passe modifié'),
      backgroundColor: error == null ? Colors.green : Colors.red,
    ));
    if (error == null) Navigator.pop(context);
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 20),
        child: Text(text,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
      );

  @override
  Widget build(BuildContext context) {
    final toggle = IconButton(
      tooltip: _showPasswords ? 'Masquer' : 'Afficher',
      icon: Icon(_showPasswords ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey[600]),
      onPressed: () => setState(() => _showPasswords = !_showPasswords),
    );

    return SpaceBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Mot de passe')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Si vous vous connectez avec Google ou Facebook, vous n\'avez pas '
                    'de mot de passe Valeon : utilisez « Mot de passe oublié » pour en créer un.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  _label('Mot de passe actuel'),
                  CustomTextField(
                    controller: _current,
                    hintText: 'Mot de passe actuel',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !_showPasswords,
                    suffixIcon: toggle,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Obligatoire' : null,
                  ),
                  _label('Nouveau mot de passe'),
                  CustomTextField(
                    controller: _newPassword,
                    hintText: '8 caractères, 1 majuscule, 1 chiffre',
                    prefixIcon: Icons.lock_reset,
                    obscureText: !_showPasswords,
                    validator: _validateNew,
                  ),
                  _label('Confirmer le nouveau mot de passe'),
                  CustomTextField(
                    controller: _confirm,
                    hintText: 'Répétez le nouveau mot de passe',
                    prefixIcon: Icons.lock_reset,
                    obscureText: !_showPasswords,
                    validator: (v) => v != _newPassword.text
                        ? 'Les mots de passe ne correspondent pas'
                        : null,
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Changer le mot de passe',
                    icon: Icons.check,
                    isLoading: _saving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
