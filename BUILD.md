# Compiler l'APK Valeon (release)

Prérequis : Flutter (stable) et le SDK Android (`flutter doctor` sans erreur Android).

## 1. Récupérer le code

```bash
git clone https://github.com/andokevin/valeon_frontend.git
cd valeon_frontend
flutter pub get
```

## 2. Installer la clé de signature (fournie à part, jamais sur git)

Le propriétaire du projet vous envoie en privé deux fichiers :

| Fichier reçu | À placer dans |
|---|---|
| `valeon-release.jks` | `android/valeon-release.jks` |
| `key.properties` | `android/key.properties` |

Utilisez **cette clé-là** : c'est son empreinte qui est déclarée dans Firebase et
Facebook. Avec une autre clé, la connexion Google et Facebook échoue (erreur 10 côté Google).

Sans ces fichiers, le build passe quand même (signature debug), mais la connexion
Google/Facebook ne marchera pas.

## 3. Compiler

L'adresse du backend est donnée au moment du build (demandez-la au propriétaire) :

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://ADRESSE-DU-BACKEND/api
```

Le fichier à partager est `build/app/outputs/flutter-apk/app-release.apk`.
Envoyez ce fichier `.apk` directement (WhatsApp, Drive, câble…), pas via une
fonction de « partage d'application installée » (elle n'envoie qu'une partie de l'app).

## Vérifier la signature (optionnel)

```bash
keytool -list -v -keystore android/valeon-release.jks -alias valeon
```

Le SHA-1 doit être `7D:FA:D1:38:A8:BB:5A:38:FE:16:AA:D5:F1:A5:C2:B9:89:69:2C:97`.
