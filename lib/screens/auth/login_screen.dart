import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/valeon_button.dart';
import '../../widgets/common/valeon_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    if (!_form.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // ── Logo ──────────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Titres ────────────────────────────────────────────────
                const Text(
                  'Connexion',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onBackground,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Content de vous revoir !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 36),

                // ── Champs formulaire ─────────────────────────────────────
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
                const SizedBox(height: 16),
                ValeonTextField(
                  controller: _password,
                  label: 'Mot de passe',
                  obscureText: _obscure,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppTheme.onSurface,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Mot de passe requis';
                    if (v.length < 8) return 'Min. 8 caractères';
                    return null;
                  },
                ),

                // ── Mot de passe oublié ───────────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Bouton principal ──────────────────────────────────────
                ValeonButton(
                  label: 'Se connecter',
                  isLoading: isLoading,
                  onPressed: _submitEmail,
                  icon: Icons.login_rounded,
                ),
                const SizedBox(height: 28),

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
                      'ou continuer avec',
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
                const SizedBox(height: 20),

                // ── Bouton Google ─────────────────────────────────────────
                _SocialButton(
                  label: 'Continuer avec Google',
                  icon: _GoogleIcon(),
                  isLoading: isLoading,
                  onPressed: _submitGoogle,
                  borderColor: AppTheme.onSurface.withOpacity(0.25),
                ),
                const SizedBox(height: 12),

                // ── Bouton Facebook ───────────────────────────────────────
                _SocialButton(
                  label: 'Continuer avec Facebook',
                  icon: _FacebookIcon(),
                  isLoading: isLoading,
                  onPressed: _submitFacebook,
                  borderColor: const Color(0xFF1877F2).withOpacity(0.5),
                  foregroundColor: const Color(0xFF1877F2),
                ),
                const SizedBox(height: 36),

                // ── Lien inscription ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Pas encore de compte ?",
                      style: TextStyle(
                        color: AppTheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Widgets locaux ──────────────────────────────────────────────────────────

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
    decoration: const BoxDecoration(shape: BoxShape.circle),
    child: CustomPaint(painter: _GooglePainter()),
  );
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Cercle de fond blanc
    paint.color = Colors.white;
    canvas.drawCircle(center, radius, paint);

    // Lettre G simplifiée par arcs colorés
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.15;

    // Rouge
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.65),
      -1.57, 1.5, false, paint,
    );
    // Bleu
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.65),
      -3.14, 1.5, false, paint,
    );
    // Vert
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.65),
      0, 0.8, false, paint,
    );
    // Jaune
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.65),
      -1.57, -0.8, false, paint,
    );
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
      borderRadius: BorderRadius.circular(4),
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
