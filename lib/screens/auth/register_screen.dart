import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/valeon_button.dart';
import '../../widgets/common/valeon_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    if (!_form.currentState!.validate()) return;
    if (!_acceptTerms) {
      _showError('Vous devez accepter les conditions d\'utilisation');
      return;
    }
    await ref.read(authProvider.notifier).register(
      _name.text.trim(),
      _email.text.trim(),
      _password.text,
    );
  }

  Future<void> _submitGoogle() async {
    await ref.read(authProvider.notifier).loginWithGoogle();
  }

  Future<void> _submitFacebook() async {
    await ref.read(authProvider.notifier).loginWithFacebook();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Mot de passe requis';
    if (v.length < 8) return 'Min. 8 caractères';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'Au moins une majuscule';
    if (!v.contains(RegExp(r'[0-9]'))) return 'Au moins un chiffre';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final isLoading = state.status == AuthStatus.loading;

    ref.listen(authProvider, (_, next) {
      if (next.status == AuthStatus.error && next.error != null) {
        _showError(next.error!);
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ────────────────────────────────────────────────
                Row(children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: AppTheme.onBackground,
                    ),
                    onPressed: () => context.go('/login'),
                  ),
                ]),
                const SizedBox(height: 8),

                // ── Logo ──────────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      size: 38,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Titres ────────────────────────────────────────────────
                const Text(
                  'Créer un compte',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onBackground,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Rejoignez Valeon gratuitement',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Boutons sociaux ───────────────────────────────────────
                _SocialButton(
                  label: 'S\'inscrire avec Google',
                  icon: _GoogleIcon(),
                  isLoading: isLoading,
                  onPressed: _submitGoogle,
                  borderColor: AppTheme.onSurface.withOpacity(0.25),
                ),
                const SizedBox(height: 10),
                _SocialButton(
                  label: 'S\'inscrire avec Facebook',
                  icon: _FacebookIcon(),
                  isLoading: isLoading,
                  onPressed: _submitFacebook,
                  borderColor: const Color(0xFF1877F2).withOpacity(0.5),
                  foregroundColor: const Color(0xFF1877F2),
                ),
                const SizedBox(height: 24),

                // ── Séparateur ────────────────────────────────────────────
                Row(children: [
                  Expanded(
                    child: Divider(
                      color: AppTheme.onSurface.withOpacity(0.25),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'ou avec email',
                      style: TextStyle(
                        color: AppTheme.onSurface.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppTheme.onSurface.withOpacity(0.25),
                      thickness: 1,
                    ),
                  ),
                ]),
                const SizedBox(height: 24),

                // ── Champs formulaire ─────────────────────────────────────
                ValeonTextField(
                  controller: _name,
                  label: 'Nom complet',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Nom requis';
                    if (v.trim().length < 2) return 'Nom trop court';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                ValeonTextField(
                  controller: _email,
                  label: 'Adresse email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email requis';
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                ValeonTextField(
                  controller: _password,
                  label: 'Mot de passe',
                  obscureText: _obscurePass,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePass
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppTheme.onSurface,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 14),

                ValeonTextField(
                  controller: _confirm,
                  label: 'Confirmer le mot de passe',
                  obscureText: _obscureConfirm,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppTheme.onSurface,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirmation requise';
                    if (v != _password.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Indicateur force mot de passe ─────────────────────────
                _PasswordStrengthBar(password: _password.text),
                const SizedBox(height: 16),

                // ── Conditions d'utilisation ──────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (v) =>
                            setState(() => _acceptTerms = v ?? false),
                        activeColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _acceptTerms = !_acceptTerms),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: AppTheme.onSurface,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(text: "J'accepte les "),
                              TextSpan(
                                text: "Conditions d'utilisation",
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: " et la "),
                              TextSpan(
                                text: "Politique de confidentialité",
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Bouton inscription ────────────────────────────────────
                ValeonButton(
                  label: "S'inscrire",
                  isLoading: isLoading,
                  onPressed: _submitEmail,
                  icon: Icons.person_add_rounded,
                ),
                const SizedBox(height: 24),

                // ── Lien connexion ────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Déjà un compte ?",
                      style: TextStyle(
                        color: AppTheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text(
                        "Se connecter",
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Widget force du mot de passe ─────────────────────────────────────────────

class _PasswordStrengthBar extends StatefulWidget {
  final String password;
  const _PasswordStrengthBar({required this.password});
  @override
  State<_PasswordStrengthBar> createState() => _PasswordStrengthBarState();
}

class _PasswordStrengthBarState extends State<_PasswordStrengthBar> {
  int _getStrength(String p) {
    int score = 0;
    if (p.length >= 8) score++;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.password.isEmpty) return const SizedBox.shrink();
    final strength = _getStrength(widget.password);
    final (label, color) = switch (strength) {
      1 => ('Très faible', AppTheme.error),
      2 => ('Faible', Colors.orange),
      3 => ('Moyen', Colors.yellow),
      4 => ('Fort', Colors.green),
      _ => ('', Colors.grey),
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: List.generate(4, (i) => Expanded(
        child: Container(
          height: 4,
          margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
          decoration: BoxDecoration(
            color: i < strength ? color : AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ))),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    ]);
  }
}

// ─── Widgets partagés ─────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final bool isLoading;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color foregroundColor;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
    this.borderColor = Colors.white24,
    this.foregroundColor = AppTheme.onBackground,
  });

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: isLoading ? null : onPressed,
    style: OutlinedButton.styleFrom(
      foregroundColor: foregroundColor,
      backgroundColor: AppTheme.surfaceVariant,
      side: BorderSide(color: borderColor, width: 1.2),
      padding: const EdgeInsets.symmetric(vertical: 14),
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: foregroundColor,
          ),
        ),
      ],
    ),
  );
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 22,
    height: 22,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
        ),
      ],
    ),
    child: CustomPaint(painter: _GooglePainter()),
  );
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.14
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.32;

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -1.57, 1.6, false, paint);

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -3.14, 1.6, false, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        0.0, 0.9, false, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -1.57, -0.9, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FacebookIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 22,
    height: 22,
    decoration: BoxDecoration(
      color: const Color(0xFF1877F2),
      borderRadius: BorderRadius.circular(5),
    ),
    child: const Center(
      child: Text(
        'f',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 15,
          height: 1.1,
        ),
      ),
    ),
  );
}
