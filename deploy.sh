#!/bin/bash
# Script de déploiement automatisé pour ChainCacao
# Usage: ./deploy.sh (depuis la racine du projet)

echo "---------------------------------------------------"
echo "🍫 ChainCacao - Compilation et Déploiement Local"
echo "---------------------------------------------------"

# 1. Préparation de l'App Mobile
echo "📦 [1/3] Génération de l'APK Release..."
cd mobile/chaincacao
flutter pub get
dart run flutter_launcher_icons
flutter build apk --release

# Création du dossier de téléchargement dans le site vitrine s'il n'existe pas
mkdir -p ../../site-vitrine/downloads
cp build/app/outputs/flutter-apk/app-release.apk ../../site-vitrine/downloads/chaincacao-v1.apk

# 2. Synchronisation Git
echo "🚀 [2/3] Envoi vers GitHub..."
cd ../..
git add .
git commit -m "Auto-build: Mise à jour APK et site ($(date +'%Y-%m-%d %H:%M'))"
git push origin main

echo "✨ [3/3] Terminé ! L'APK est prêt dans site-vitrine/downloads/"