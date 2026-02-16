import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// Imports conditionnels pour Facebook
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart'
    if (dart.library.html) 'package:flutter_facebook_auth_web/flutter_facebook_auth_web.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    } catch (e) {
      throw 'Erreur inattendue: $e';
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
    } catch (e) {
      throw 'Erreur inattendue: $e';
    }
  }

  // ===== CONNEXION GOOGLE =====
  Future<User?> signInWithGoogle() async {
    try {
      print('🟢 Démarrage Google Sign-In');

      // S'assurer qu'aucun utilisateur n'est déjà connecté
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        // Ignorer
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('🟡 Google Sign-In annulé');
        return null;
      }

      print('🟢 Utilisateur Google: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      print('🟢 Connexion Firebase réussie: ${result.user?.email}');

      return result.user;
    } on FirebaseAuthException catch (e) {
      print('🔴 FirebaseAuthException Google: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e, stack) {
      print('🔴 Erreur Google: $e');
      print(stack);
      throw 'Erreur de connexion Google: $e';
    }
  }

  // ===== CONNEXION APPLE =====
  Future<User?> signInWithApple() async {
    try {
      print('🟢 Démarrage Apple Sign-In');

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print('🟢 Credentials Apple obtenus');

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      UserCredential result = await _auth.signInWithCredential(oauthCredential);

      if (credential.givenName != null || credential.familyName != null) {
        final displayName =
            '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
                .trim();
        await result.user?.updateDisplayName(displayName);
      }

      print('🟢 Connexion Apple Firebase réussie');
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('🔴 FirebaseAuthException Apple: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e, stack) {
      print('🔴 Erreur Apple: $e');
      print(stack);
      throw 'Erreur de connexion Apple: $e';
    }
  }

  // ===== CONNEXION FACEBOOK =====
  Future<User?> signInWithFacebook() async {
    try {
      print('🟢 Démarrage Facebook Sign-In');

      final facebookAuth = FacebookAuth.instance;

      // Lancer la connexion avec permissions
      final LoginResult result = await facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      print('🟢 Statut Facebook: ${result.status}');

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        print('🟢 Token Facebook obtenu');

        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.tokenString,
        );

        try {
          UserCredential userCredential = await _auth.signInWithCredential(
            credential,
          );
          print('🟢 Connexion Firebase Facebook réussie');
          return userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            print('🟡 Email déjà utilisé avec une autre méthode');

            // Récupérer les infos Facebook
            try {
              final userData = await facebookAuth.getUserData();
              final email = userData['email'] as String?;

              if (email != null) {
                throw 'Un compte existe déjà avec l\'email $email. Veuillez vous connecter avec votre méthode habituelle.';
              }
            } catch (_) {}

            throw 'Un compte existe déjà avec cet email. Veuillez vous connecter avec votre méthode habituelle.';
          }
          rethrow;
        }
      } else if (result.status == LoginStatus.cancelled) {
        print('🟡 Facebook Sign-In annulé');
        return null;
      } else {
        print('🔴 Échec Facebook: ${result.message}');
        throw 'Échec de connexion Facebook: ${result.message}';
      }
    } on FirebaseAuthException catch (e) {
      print('🔴 FirebaseAuthException Facebook: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e, stack) {
      print('🔴 Erreur Facebook: $e');
      print(stack);
      throw 'Erreur de connexion Facebook: $e';
    }
  }

  // ===== DÉCONNEXION =====
  Future<void> signOut() async {
    try {
      print('🟢 Déconnexion en cours...');

      // Déconnexion Google
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print('⚠️ Erreur Google SignOut ignorée: $e');
      }

      // Déconnexion Facebook
      try {
        await _facebookSignOut();
      } catch (e) {
        print('⚠️ Erreur Facebook SignOut ignorée: $e');
      }

      // Déconnexion Firebase
      await _auth.signOut();
      print('🟢 Déconnexion réussie');
    } catch (e) {
      print('🔴 Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  Future<void> _facebookSignOut() async {
    try {
      await FacebookAuth.instance.logOut();
    } catch (e) {
      // Ignorer
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
      case 'account-exists-with-different-credential':
        return 'Un compte existe déjà avec le même email. Veuillez utiliser votre méthode de connexion habituelle.';
      case 'invalid-credential':
        return 'Identifiants invalides';
      case 'operation-not-allowed':
        return 'Cette méthode de connexion n\'est pas activée';
      case 'invalid-verification-code':
        return 'Code de vérification invalide';
      default:
        if (e.message != null && e.message!.contains('10')) {
          return 'Erreur de configuration Google Sign-In. Vérifiez Firebase Console.';
        }
        return 'Erreur: ${e.message}';
    }
  }
}

// Instance globale
final authService = AuthService();
