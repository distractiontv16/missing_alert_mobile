# Missing Alert Setup Script - PowerShell Version with Supabase
# Execution Policy: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

param(
    [string]$ProjectName = "missing_alert"
)

# Configuration
$ROOT_DIR = Join-Path $PWD $ProjectName
$APP_DIR = Join-Path $ROOT_DIR "mobile_app"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "MISSING ALERT - SETUP COMPLET" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Fonction pour afficher les messages avec couleurs
function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Error { param($Message) Write-Host $Message -ForegroundColor Red }
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Blue }
function Write-Warning { param($Message) Write-Host $Message -ForegroundColor Yellow }

# Vérification Flutter
Write-Info "Vérification de Flutter..."
try {
    $flutterVersion = flutter --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Flutter détecté"
    } else {
        throw "Flutter non trouvé"
    }
} catch {
    Write-Error "Flutter n'est pas installé ou pas dans le PATH"
    Write-Host "Veuillez installer Flutter: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

# Créer la structure racine du projet
Write-Host ""
Write-Info "Création de la structure racine..."
if (-not (Test-Path $ROOT_DIR)) {
    New-Item -ItemType Directory -Path $ROOT_DIR -Force | Out-Null
}
Set-Location $ROOT_DIR

# Étape 1 - Créer l'application Flutter mobile
Write-Host ""
Write-Info "Création de l'application Flutter mobile..."
try {
    flutter create mobile_app --org com.missingalert --project-name missing_alert_mobile
    if ($LASTEXITCODE -ne 0) {
        throw "Erreur lors de la création du projet Flutter"
    }
    Set-Location mobile_app
    Write-Success "Projet Flutter créé avec succès"
} catch {
    Write-Error "Erreur lors de la création du projet Flutter"
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

# Étape 2 - Mise à jour des dépendances
Write-Host ""
Write-Info "Mise à jour des dépendances pubspec.yaml..."

# Backup du pubspec.yaml original
Copy-Item "pubspec.yaml" "pubspec.yaml.backup"

# Créer le nouveau pubspec.yaml avec Supabase
$pubspecContent = @"
name: missing_alert_mobile
description: Application Missing Alert pour retrouver les personnes disparues au Bénin
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.29.0"

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.3
  get_it: ^7.6.4
  equatable: ^2.0.5

  # UI & Navigation
  go_router: ^12.1.3
  flutter_screenutil: ^5.9.0
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.9

  # Maps & Geolocation
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  geocoding: ^2.1.1

  # Supabase & Backend
  supabase_flutter: ^2.3.4
  supabase: ^2.2.2

  # Media & Files
  image_picker: ^1.0.4
  permission_handler: ^11.1.0
  path_provider: ^2.1.1

  # Networking & Utils
  dio: ^5.3.3
  connectivity_plus: ^5.0.2
  package_info_plus: ^4.2.0
  device_info_plus: ^9.1.1

  # Local Storage
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2

  # UI Icons
  cupertino_icons: ^1.0.2

  # Additional Utils
  uuid: ^4.2.1
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Development Tools
  build_runner: ^2.4.7
  json_annotation: ^4.8.1
  json_serializable: ^6.7.1
  flutter_lints: ^3.0.1
  mockito: ^5.4.2

  # App Setup
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.3.6

flutter:
  uses-material-design: true
  assets:
    - assets/icons/
    - assets/images/
    - assets/fonts/
    - assets/lottie/

  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
"@

$pubspecContent | Out-File -FilePath "pubspec.yaml" -Encoding UTF8
Write-Success "pubspec.yaml mis à jour avec Supabase"

# Étape 3 - Installation des dépendances
Write-Host ""
Write-Info "Installation des dépendances..."
try {
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        throw "Erreur lors de l'installation des dépendances"
    }
    Write-Success "Dépendances installées avec succès"
} catch {
    Write-Error "Erreur lors de l'installation des dépendances"
    Write-Warning "Restauration du pubspec.yaml original..."
    Copy-Item "pubspec.yaml.backup" "pubspec.yaml"
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

# Étape 4 - Création de la structure de dossiers Mobile App
Write-Host ""
Write-Info "Création de la structure de dossiers..."

# Fonction pour créer des dossiers
function New-DirectoryStructure {
    param([string[]]$Paths)
    foreach ($path in $Paths) {
        $fullPath = Join-Path $PWD $path
        if (-not (Test-Path $fullPath)) {
            New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        }
    }
}

# Core structure
$coreStructure = @(
    "lib\core\constants",
    "lib\core\config",
    "lib\core\errors",
    "lib\core\network",
    "lib\core\services",
    "lib\core\utils",
    "lib\core\di"
)
New-DirectoryStructure $coreStructure

# Features structure
$featuresStructure = @(
    # Auth
    "lib\features\auth\data\models",
    "lib\features\auth\data\repositories",
    "lib\features\auth\data\datasources",
    "lib\features\auth\domain\entities",
    "lib\features\auth\domain\repositories",
    "lib\features\auth\domain\usecases",
    "lib\features\auth\presentation\bloc",
    "lib\features\auth\presentation\pages",
    "lib\features\auth\presentation\widgets",
    
    # Alerts
    "lib\features\alerts\data\models",
    "lib\features\alerts\data\repositories",
    "lib\features\alerts\data\datasources",
    "lib\features\alerts\domain\entities",
    "lib\features\alerts\domain\repositories",
    "lib\features\alerts\domain\usecases",
    "lib\features\alerts\presentation\bloc\alert_creation",
    "lib\features\alerts\presentation\bloc\alert_list",
    "lib\features\alerts\presentation\bloc\alert_details",
    "lib\features\alerts\presentation\pages",
    "lib\features\alerts\presentation\widgets",
    
    # Volunteers
    "lib\features\volunteers\data\models",
    "lib\features\volunteers\data\repositories",
    "lib\features\volunteers\data\datasources",
    "lib\features\volunteers\domain\entities",
    "lib\features\volunteers\domain\repositories",
    "lib\features\volunteers\domain\usecases",
    "lib\features\volunteers\presentation\bloc",
    "lib\features\volunteers\presentation\pages",
    "lib\features\volunteers\presentation\widgets",
    
    # Notifications
    "lib\features\notifications\data\models",
    "lib\features\notifications\data\repositories",
    "lib\features\notifications\data\datasources",
    "lib\features\notifications\domain\entities",
    "lib\features\notifications\domain\repositories",
    "lib\features\notifications\domain\usecases",
    "lib\features\notifications\presentation\bloc",
    "lib\features\notifications\presentation\pages",
    "lib\features\notifications\presentation\widgets",
    
    # Maps
    "lib\features\maps\data\models",
    "lib\features\maps\data\repositories",
    "lib\features\maps\data\datasources",
    "lib\features\maps\domain\entities",
    "lib\features\maps\domain\repositories",
    "lib\features\maps\domain\usecases",
    "lib\features\maps\presentation\bloc",
    "lib\features\maps\presentation\pages",
    "lib\features\maps\presentation\widgets"
)
New-DirectoryStructure $featuresStructure

# Shared & App structure
$sharedStructure = @(
    "lib\shared\widgets\common",
    "lib\shared\widgets\media",
    "lib\shared\widgets\navigation",
    "lib\shared\themes",
    "lib\shared\l10n",
    "lib\app\router"
)
New-DirectoryStructure $sharedStructure

# Assets structure
$assetsStructure = @(
    "assets\icons",
    "assets\images",
    "assets\fonts",
    "assets\lottie"
)
New-DirectoryStructure $assetsStructure

# Test structure
$testStructure = @(
    "test\unit",
    "test\widget",
    "test\integration"
)
New-DirectoryStructure $testStructure

Write-Success "Structure Mobile App créée"

# Retour au répertoire racine
Set-Location $ROOT_DIR

# Étape 5 - Création des autres composants du projet
Write-Host ""
Write-Info "Création des autres composants..."

# Autres structures du projet
$otherStructures = @(
    # Web Dashboard
    "web_dashboard\lib\features\admin\alert_validation",
    "web_dashboard\lib\features\admin\user_management",
    "web_dashboard\lib\features\admin\analytics",
    "web_dashboard\lib\features\family\dashboard",
    "web_dashboard\lib\features\family\alert_management",
    "web_dashboard\lib\features\reports\statistics",
    "web_dashboard\lib\features\reports\export",
    "web_dashboard\lib\shared\widgets\data_table",
    "web_dashboard\lib\shared\widgets\charts",
    "web_dashboard\lib\shared\widgets\forms",
    "web_dashboard\lib\shared\responsive",
    "web_dashboard\web",
    
    # Backend (Supabase Edge Functions)
    "backend\supabase\functions\alerts",
    "backend\supabase\functions\notifications",
    "backend\supabase\functions\users",
    "backend\supabase\functions\analytics",
    "backend\supabase\functions\_shared",
    "backend\supabase\migrations",
    "backend\supabase\seed",
    
    # Database
    "database\migrations",
    "database\seeds",
    "database\schemas",
    
    # Documentation
    "docs\api",
    "docs\deployment",
    "docs\architecture",
    "docs\user_guides",
    
    # Testing
    "testing\unit_tests",
    "testing\integration_tests",
    "testing\e2e_tests",
    "testing\performance_tests",
    
    # Deployment
    "deployment\scripts",
    "deployment\docker",
    "deployment\ci_cd",
    
    # Project Management
    "project_management\requirements",
    "project_management\user_stories",
    "project_management\wireframes",
    "project_management\api_specifications"
)
New-DirectoryStructure $otherStructures

Write-Success "Structure complète créée"

# Étape 6 - Création des fichiers de base
Write-Host ""
Write-Info "Création des fichiers de configuration de base..."

# Créer le README principal
$readmeContent = @"
# Missing Alert - Système d'Alerte pour Personnes Disparues

## 🚀 Architecture du Projet

Ce projet utilise une architecture modulaire avec :
- **Mobile App** : Flutter avec Clean Architecture + BLoC
- **Web Dashboard** : Flutter Web pour l'administration
- **Backend** : Supabase (Auth, Database, Storage, Edge Functions)

## 📁 Structure

```
missing_alert/
├── mobile_app/          # Application mobile Flutter
├── web_dashboard/       # Dashboard web Flutter
├── backend/            # Supabase Edge Functions
├── database/           # Migrations et schémas
├── docs/               # Documentation
├── testing/            # Tests centralisés
├── deployment/         # Scripts de déploiement
└── project_management/ # Gestion de projet
```

## 🛠️ Installation

1. Cloner le repository
2. Exécuter le script PowerShell : `.\setup_missing_alert.ps1`
3. Configurer Supabase (créer le projet et récupérer les clés)
4. Créer le fichier `.env` avec vos clés Supabase
5. Lancer `flutter run` dans mobile_app/

## 📱 Technologies

- Flutter 3.29.0+
- Supabase (Auth, Database, Storage, Edge Functions)
- Google Maps API
- BLoC State Management
- Clean Architecture

## ⚙️ Configuration Supabase

1. Créer un projet sur https://supabase.com
2. Récupérer les clés API
3. Créer un fichier `.env` dans mobile_app/ :

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## 🚀 Commandes utiles

```bash
# Démarrer l'app mobile
cd mobile_app && flutter run

# Démarrer le dashboard web
cd web_dashboard && flutter run -d chrome

# Déployer les fonctions Supabase
supabase functions deploy

# Exécuter les tests
flutter test
```
"@

$readmeContent | Out-File -FilePath "README.md" -Encoding UTF8

# Créer le .gitignore principal
$gitignoreContent = @"
# Compiled files
*.class
*.log
*.pyc
*.swp
.DS_Store
.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Android related
**/android/**/gradle-wrapper.jar
**/android/.gradle
**/android/captures/
**/android/gradlew
**/android/gradlew.bat
**/android/local.properties
**/android/**/GeneratedPluginRegistrant.java

# iOS related
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3
**/ios/**/*sync/
**/ios/**/.sconsign.dblite
**/ios/**/.tags*
**/ios/**/.vagrant/
**/ios/**/DerivedData/
**/ios/**/Icon?
**/ios/**/Pods/
**/ios/**/.symlinks/
**/ios/**/profile
**/ios/**/xcuserdata
**/ios/.generated/
**/ios/Flutter/App.framework
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Flutter.podspec
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/ephemeral/
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/Flutter/flutter_export_environment.sh
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*

# Supabase
**/.supabase/
**/supabase/.env

# Environment files
.env
.env.local
.env.development
.env.production

# IDE
.idea/
*.iml

# Others
node_modules/
npm-debug.log*
"@

$gitignoreContent | Out-File -FilePath ".gitignore" -Encoding UTF8

Write-Success "Fichiers de base créés"

# Étape 7 - Création des scripts de déploiement PowerShell
Write-Host ""
Write-Info "Création des scripts de déploiement..."

# Script de build Android
$androidBuildScript = @"
# Build Android Script
Write-Host "🤖 Building Android APK/AAB..." -ForegroundColor Yellow
Write-Host ""

Set-Location mobile_app

Write-Host "Cleaning project..." -ForegroundColor Blue
flutter clean
flutter pub get

Write-Host "Building APK for testing..." -ForegroundColor Blue
flutter build apk --release --dart-define=ENV=production

Write-Host "Building AAB for Play Store..." -ForegroundColor Blue
flutter build appbundle --release --dart-define=ENV=production

Write-Host ""
Write-Host "✅ Android build completed!" -ForegroundColor Green
Write-Host "📦 APK: build/app/outputs/flutter-apk/" -ForegroundColor Cyan
Write-Host "📦 AAB: build/app/outputs/bundle/release/" -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter to continue"
"@

$androidBuildScript | Out-File -FilePath "deployment\scripts\build_android.ps1" -Encoding UTF8

# Script de build iOS
$iosBuildScript = @"
# Build iOS Script
Write-Host "🍎 Building iOS IPA..." -ForegroundColor Yellow
Write-Host ""

Set-Location mobile_app

Write-Host "Cleaning project..." -ForegroundColor Blue
flutter clean
flutter pub get

Write-Host "Building iOS Archive..." -ForegroundColor Blue
flutter build ios --release --dart-define=ENV=production

Write-Host ""
Write-Host "✅ iOS build completed!" -ForegroundColor Green
Write-Host "📦 Archive location: build/ios/archive/" -ForegroundColor Cyan
Write-Host "💡 Open Xcode to create IPA for App Store" -ForegroundColor Yellow
Write-Host ""

Read-Host "Press Enter to continue"
"@

$iosBuildScript | Out-File -FilePath "deployment\scripts\build_ios.ps1" -Encoding UTF8

# Script de déploiement web
$webBuildScript = @"
# Build Web Script
Write-Host "🌐 Building Flutter Web..." -ForegroundColor Yellow
Write-Host ""

Set-Location web_dashboard

Write-Host "Cleaning project..." -ForegroundColor Blue
flutter clean
flutter pub get

Write-Host "Building for web..." -ForegroundColor Blue
flutter build web --release --dart-define=ENV=production

Write-Host ""
Write-Host "✅ Web build completed!" -ForegroundColor Green
Write-Host "📦 Output: build/web/" -ForegroundColor Cyan
Write-Host "💡 Deploy contents to your web server" -ForegroundColor Yellow
Write-Host ""

Read-Host "Press Enter to continue"
"@

$webBuildScript | Out-File -FilePath "deployment\scripts\build_web.ps1" -Encoding UTF8

Write-Success "Scripts de déploiement créés"

# Étape 8 - Création du fichier de configuration Supabase
Write-Host ""
Write-Info "Création des fichiers de configuration Supabase..."

# Créer le fichier .env template
$envTemplate = @"
# Supabase Configuration
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key

# Google Maps
GOOGLE_MAPS_API_KEY=your_google_maps_api_key

# Environment
ENV=development
"@

$envTemplate | Out-File -FilePath "mobile_app\.env.template" -Encoding UTF8

# Créer supabase config
$supabaseConfig = @"
{
  "project_id": "YOUR_PROJECT_ID",
  "api": {
    "enabled": true,
    "port": 54321,
    "schemas": [
      "public",
      "storage",
      "graphql_public"
    ],
    "extra_search_path": [
      "public"
    ],
    "max_rows": 1000
  },
  "db": {
    "enabled": true,
    "port": 54322,
    "shadow_port": 54320,
    "major_version": 15
  },
  "realtime": {
    "enabled": true,
    "port": 54323
  },
  "storage": {
    "enabled": true,
    "port": 54324,
    "image_transformation": {
      "enabled": true
    }
  },
  "edge_runtime": {
    "enabled": true,
    "port": 54325
  }
}
"@

$supabaseConfig | Out-File -FilePath "backend\supabase\config.json" -Encoding UTF8

Write-Success "Configuration Supabase créée"

# Étape 9 - Test de l'installation
Write-Host ""
Write-Info "Test de l'installation..."
Set-Location mobile_app
try {
    flutter doctor | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Des problèmes détectés avec Flutter Doctor"
        Write-Host "Exécutez 'flutter doctor' pour plus de détails" -ForegroundColor Yellow
    } else {
        Write-Success "Installation validée"
    }
} catch {
    Write-Warning "Impossible de valider l'installation Flutter"
}

# Retour au répertoire racine
Set-Location $ROOT_DIR

# Étape 10 - Résumé final
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ SETUP TERMINÉ AVEC SUCCÈS !" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📂 Projet créé dans: $ROOT_DIR" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Prochaines étapes:" -ForegroundColor Yellow
Write-Host "  1. cd $APP_DIR" -ForegroundColor White
Write-Host "  2. Configurer Supabase (.env)" -ForegroundColor White
Write-Host "  3. flutter run" -ForegroundColor White
Write-Host ""
Write-Host "📁 Structure complète créée:" -ForegroundColor Yellow
Write-Host "  ├── mobile_app/          (Application Flutter)" -ForegroundColor White
Write-Host "  ├── web_dashboard/       (Dashboard web)" -ForegroundColor White
Write-Host "  ├── backend/            (Supabase Functions)" -ForegroundColor White
Write-Host "  ├── database/           (Migrations)" -ForegroundColor White
Write-Host "  ├── docs/               (Documentation)" -ForegroundColor White
Write-Host "  ├── testing/            (Tests)" -ForegroundColor White
Write-Host "  ├── deployment/         (Scripts build)" -ForegroundColor White
Write-Host "  └── project_management/ (Gestion projet)" -ForegroundColor White
Write-Host ""
Write-Host "🎯 Le projet Missing Alert avec Supabase est prêt !" -ForegroundColor Green
Write-Host ""

Read-Host "Appuyez sur Entrée pour terminer"
