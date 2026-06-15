# Visual Break App - Procédure de Lancement

Cette application Flutter Desktop aide à prévenir la fatigue visuelle en suivant la règle **20-20-20**.

## 1. Prérequis

*   **Flutter SDK :** Assurez-vous d'avoir Flutter installé (`>= 3.0.0`).
*   **Système d'exploitation :** Windows 10/11, macOS ou Linux (Ubuntu recommandé).
*   **Outils de build :**
    *   *Windows :* Visual Studio 2022 avec la charge de travail "Desktop development with C++".
    *   *macOS :* Xcode installé.
    *   *Linux :* `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`, `libayatana-appindicator3-dev`.

## 2. Installation des dépendances

À la racine du projet `visual_break_app`, exécutez :

```bash
flutter pub get
```

## 3. Lancement en mode Développement

Pour lancer l'application sur votre système actuel :

```bash
flutter run
```

*Note : Si vous avez plusieurs périphériques connectés, utilisez `flutter run -d windows` (ou `macos`, `linux`).*

## 4. Compilation pour Production

Pour générer un exécutable optimisé :

```bash
# Pour Windows
flutter build windows

# Pour macOS
flutter build macos

# Pour Linux
flutter build linux
```

Les exécutables se trouveront dans le dossier `build/[os]/runner/Release/`.

## 5. Fonctionnalités Implémentées

*   **Timer Intelligent :** Décompte de 2h30 avec mise en pause automatique en cas d'inactivité (Idle Detection).
*   **Popup 20-20-20 :** S'affiche au centre de l'écran avec une instruction visuelle.
*   **System Tray :** L'application se réduit dans la zone de notification pour ne pas encombrer la barre des tâches.
*   **Logging :** Journalisation des événements dans la console et (bientôt) dans un fichier local.

## 6. Dépannage

*   **L'icône ne s'affiche pas :** Vérifiez que les fichiers `assets/app_icon.png` et `app_icon.ico` existent et sont déclarés dans le `pubspec.yaml`.
*   **Idle Detection (Windows) :** Nécessite les privilèges utilisateur standards pour interroger `GetLastInputInfo`.
