import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// Imports conditionnels pour Facebook
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart'
    if (dart.library.html) 'package:flutter_facebook_auth_web/flutter_facebook_auth_web.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ CORRECTION ICI - Utiliser le constructeur standard
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard();

  // Stream de l'utilisateur connecté
  Stream<User?> get user => _auth.authStateChanges();

  // Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // ===== INSCRIPTION EMAIL/MOT DE PASSE =====
  Future<User?> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Mettre à jour le nom d'affichage
      await result.user?.updateDisplayName(name);
      await result.user?.reload();

      // Envoyer l'email de vérification
      await result.user?.sendEmailVerification();

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ===== CONNEXION EMAIL/MOT DE PASSE =====
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ===== CONNEXION GOOGLE (CORRIGÉ) =====
  Future<User?> signInWithGoogle() async {
    try {
      // Déclencher Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Récupérer les infos d'authentification
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Créer les identifiants Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Connecter à Firebase
      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      throw 'Erreur de connexion Google: $e';
    }
  }

  // ===== CONNEXION APPLE =====
  Future<User?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      UserCredential result = await _auth.signInWithCredential(oauthCredential);

      // Mettre à jour le nom si disponible
      if (credential.givenName != null || credential.familyName != null) {
        final displayName =
            '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
                .trim();
        await result.user?.updateDisplayName(displayName);
      }

      return result.user;
    } catch (e) {
      throw 'Erreur de connexion Apple: $e';
    }
  }

  // ===== CONNEXION FACEBOOK =====
  Future<User?> signInWithFacebook() async {
    try {
      // Vérifier que le package est disponible
      final facebookAuth = FacebookAuth.instance;

      // Lancer la connexion Facebook
      final LoginResult result = await facebookAuth.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;

        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.tokenString,
        );

        UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );
        return userCredential.user;
      }
      return null;
    } catch (e) {
      throw 'Erreur de connexion Facebook: $e';
    }
  }

  // ===== DÉCONNEXION =====
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignorer les erreurs Google SignOut
    }

    try {
      await _facebookSignOut();
    } catch (e) {
      // Ignorer les erreurs Facebook SignOut
    }

    await _auth.signOut();
  }

  Future<void> _facebookSignOut() async {
    try {
      await FacebookAuth.instance.logOut();
    } catch (e) {
      // Ignorer les erreurs de déconnexion Facebook
    }
  }

  // ===== RÉINITIALISATION MOT DE PASSE =====
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ===== SUPPRIMER COMPTE =====
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ===== GESTION DES ERREURS =====
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Mot de passe trop faible (minimum 6 caractères)';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'invalid-email':
        return 'Email invalide';
      case 'user-not-found':
        return 'Aucun utilisateur avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      case 'network-request-failed':
        return 'Problème de connexion internet';
      default:
        return 'Erreur: ${e.message}';
    }
  }
}

// Instance globale
final authService = AuthService();
