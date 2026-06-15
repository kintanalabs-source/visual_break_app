# Documentation Technique : Visual Break App

## 1. Choix Technologique : Flutter for Desktop

Pour ce projet, **Flutter** a été choisi comme framework principal pour le frontend desktop. Voici la comparaison avec les alternatives envisagées :

| Critère | Flutter | Electron | Tauri |
| :--- | :--- | :--- | :--- |
| **Performance** | Haute (Compilation native) | Moyenne (Consomme beaucoup de RAM) | Très haute (Rust + WebView native) |
| **Poids de l'app** | Moyen (~30-50 Mo) | Lourd (> 150 Mo) | Très léger (< 10 Mo) |
| **UI/UX** | Rendu pixel-perfect identique partout | Web (Facile mais hétérogène) | Web (Dépendant de l'OS) |
| **Intégration OS** | Excellente (Plugins & FFI) | Bonne (Node.js) | Excellente (Rust) |
| **Complexité** | Moyenne (Dart) | Faible (JS/TS) | Haute (Rust) |

**Pourquoi Flutter ?** 
Flutter offre le meilleur compromis entre la **vitesse de développement**, la **qualité de l'UI** (essentielle pour un popup non-intrusif mais élégant) et la capacité à interagir avec les API bas niveau des systèmes (Windows/macOS/Linux) via une base de code unique.

---

## 2. Architecture du Projet

L'application suit une architecture en couches de type **DDD-lite (Domain-Driven Design)**. Cette structure garantit que la logique métier est isolée des détails techniques (OS, API, UI).

### Les Couches
1.  **Domain (Cœur Métier) :** 
    *   Contient les entités (`PopupConfig`, `BreakState`) et les interfaces (`ISystemHooks`, `IBreakApi`).
    *   C'est la couche la plus stable, sans dépendances externes.
2.  **Infrastructure (Détails Techniques) :**
    *   Implémente les interfaces du domaine. 
    *   C'est ici que l'on gère les spécificités de Windows/Mac/Linux et les futurs appels au Backend Symfony.
3.  **Application (Coordination) :**
    *   Gère les services globaux comme le `BreakTimerService` ou le `NotificationManager`.
4.  **Presentation (UI) :**
    *   Widgets Flutter, thèmes et gestion d'état.

---

## 3. Structure des Dossiers

```text
lib/
├── core/                    # Code partagé et utilitaires
│   ├── logging/             # Logger centralisé (AppLogger)
│   ├── theme/               # Design System (Couleurs, Typo)
│   └── constants/           # Délais, URLs, Paramètres par défaut
├── domain/                  # Logique métier pure (Entities & Interfaces)
│   ├── entities/            # Modèles de données
│   └── repositories/        # Contrats (Interfaces) pour l'infra
├── infrastructure/          # Implémentations concrètes (OS & Data)
│   ├── os_hooks/            # Hooks système (Idle, Always on Top)
│   ├── persistence/         # Stockage local (Preferences)
│   └── api/                 # Client API (Mock pour le moment)
├── application/             # Logique de contrôle et coordination
│   ├── timer_service/       # Gestion du cycle de 2h30
│   └── break_controller/    # Gestionnaire de popups (PopupManager)
├── presentation/            # Composants graphiques Flutter
│   ├── widgets/             # Composants réutilisables (Boutons, etc.)
│   ├── popups/              # Différents layouts de popup
│   └── tray_menu/           # Intégration barre des tâches
└── main.dart                # Point d'entrée et initialisation
```

---

## 4. Evolutivité vers le Backend

L'architecture a été pensée pour une transition transparente vers le backend Symfony :
*   **Injection de Dépendances :** Nous utilisons `get_it`. Actuellement, nous injectons des "Mocks".
*   **Contrat d'API :** L'interface `IBreakApi` est déjà définie. Pour activer le backend, il suffira de créer une classe `SymfonyBreakApi` et de changer une seule ligne dans l'initialisation.
*   **Abstraction OS :** Si un comportement spécifique à un OS est requis (ex: détection d'appel Teams via API locale vs Graph API), le code est déjà segmenté pour accueillir ces implémentations sans polluer l'UI.

---

## 5. Gestion des Popups

Le système de positionnement est **découplé**. Le `PopupManager` calcule les coordonnées dynamiquement en fonction de la résolution de l'écran principal (via `screen_retriever`) et de la configuration souhaitée (`PopupPosition`). Cela permet de supporter nativement les configurations multi-écrans.

---

## 6. Détails d'Implémentation Core

### BreakTimerService (Gestion du Temps)
Le cœur de la logique temporelle réside dans le `BreakTimerService`. 
*   **Cycle de travail :** Fixé à 2h30 par défaut.
*   **Cycle de pause :** 20 secondes conformément à la règle 20-20-20.
*   **États :** `working` (décompte actif), `breaking` (pause en cours), `paused` (veille/inactivité).
*   **UI Réactive :** Utilise `notifyListeners()` pour mettre à jour l'interface utilisateur en temps réel sans recharger toute l'application.

### TrayManager (Arrière-plan)
Pour assurer que l'application reste active sans encombrer la barre des tâches :
*   **Réduction en zone de notification :** L'application se loge dans le System Tray (Windows) ou la barre de menus (macOS).
*   **Menu Contextuel :** Permet d'afficher/cacher la fenêtre principale ou de quitter l'application.
*   **Persistance :** Le timer continue de tourner même si la fenêtre principale est cachée.

### VisualBreakPopup (Mode Strict Plein Écran)
Lorsqu'une pause est déclenchée :
1.  Le `BreakTimerService` passe en état `breaking`.
2.  Le `PopupManager` active le **Mode Plein Écran** via `windowManager.setFullScreen(true)`.
3.  L'application passe au-dessus de toutes les autres fenêtres (Always on Top) et bloque la visibilité du reste de l'écran.
4.  Un design immersif sombre (noir à 95%) avec un gradient radial bleu est affiché pour forcer le repos visuel.
5.  À la fin des 20 secondes, le mode plein écran est désactivé et l'application est réduite/masquée.

### Idle Detection (Détection d'Inactivité)
Pour éviter de déclencher des pauses si l'utilisateur n'est pas devant son écran :
*   **Fonctionnement :** Le `DesktopSystemHooks` interroge le système toutes les 5 secondes pour obtenir le temps écoulé depuis la dernière interaction (clavier/souris).
*   **Seuil :** Après 5 minutes d'inactivité, l'application considère l'utilisateur comme "Absent".
*   **Impact sur le Timer :** Le `BreakTimerService` suspend le décompte. Il reprend automatiquement dès qu'une activité est détectée.
*   **Technique :** Utilise l'API native `GetLastInputInfo` via le package `win32` (Windows) et des stubs extensibles pour macOS/Linux.
