#!/bin/bash

# Script to build Flutter project and send to App Distribution ./distributeandroid.sh
# flutter build apk --target-platform android-arm,android-arm64 --split-per-abi
# Clean and build
echo "Cleaning Flutter project..."
flutter clean

echo "Installing dependencies..."
flutter pub get

# Build for Android (debug mode)
echo "Building Android APK (debug mode)..."
flutter build apk --debug

# Check if APK file exists
APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
if [ ! -f "$APK_PATH" ]; then
    echo "Error: APK file not found: $APK_PATH"
    exit 1
fi

echo "APK file ready: $APK_PATH"

# Send to Firebase App Distribution (with debug APK)
echo "Uploading debug APK to Firebase App Distribution..."
firebase appdistribution:distribute "$APK_PATH" \
  --app "1:99674628115:android:a4b9d047e3dc84554d1fe6" \
  --groups "testers" \
  --release-notes "Debug APK - New version for testing"

echo "Application has been sent to Firebase App Distribution!"
