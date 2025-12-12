# DocAI Repository Guide for Agents

This document provides context and instructions for AI agents working on the DocAI repository.

## Project Overview
DocAI is a Flutter-based medical AI assistant application. It provides evidence-based medical responses, symptom analysis, and health recommendations. The app is privacy-focused, offering local storage with optional cloud synchronization via Firebase.

## Repository Structure
- **`lib/`**: Contains the main Dart source code.
  - **`screens/`**: UI screens for the application.
  - **`widgets/`**: Reusable UI components.
  - **`services/`**: Logic for API calls, database interactions, and other services.
  - **`models/`**: Data models used throughout the app.
  - **`l10n/`**: Localization files (ARB and generated Dart files).
  - **`state/`**: State management logic.
- **`assets/`**: Static assets like images and logos.
- **`android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`**: Platform-specific configuration files.

## Localization & Internationalization (Important)
DocAI supports multiple languages including English (`en`), Spanish (`es`), Catalan (`ca`), French (`fr`), and German (`de`).

### Translation Workflow
1.  **ARB Files**: All translations are stored in Application Resource Bundle (`.arb`) files located in `lib/l10n/`.
    -   `app_en.arb` (English - likely source)
    -   `app_es.arb` (Spanish)
    -   `app_ca.arb` (Catalan)
    -   `app_fr.arb` (French)
    -   `app_de.arb` (German)

2.  **Adding/Modifying Translations**:
    -   To add a new string, define it in all `.arb` files with the same key.
    -   To modify a string, update the `value` in the respective `.arb` file.

3.  **Generating Code**:
    -   The project uses `flutter_localizations` and the `intl` package.
    -   Localization code is generated using the command:
        ```bash
        flutter gen-l10n
        ```
    -   This command generates the `AppLocalizations` class and language-specific subclasses.
    -   **Note**: In this repository, the generated files (`app_localizations.dart`, `app_localizations_en.dart`, etc.) are checked into `lib/l10n/`. You may need to run the generation command to update these files after modifying `.arb` files.

## Key Technologies
-   **Flutter**: UI framework.
-   **Firebase**: Backend for Analytics, Crashlytics, and Firestore.
-   **Shared Preferences**: For local data persistence.
-   **HTTP**: For API communication.
-   **Markdown**: For rendering rich text responses.
