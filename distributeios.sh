#!/bin/bash

# Script to build Flutter project for iOS and send to App Distribution ./distributeios.sh
# Clean and build
echo "Cleaning Flutter project..."
flutter clean

echo "Installing dependencies..."
flutter pub get

# Start the iOS build process
echo "Building iOS IPA..."

# Update Pod installation
echo "Updating iOS Pods..."
cd ios
pod install --repo-update
cd ..

# Create archive
echo "Creating archive for iOS..."
flutter build ios --release --no-codesign

# Note: IPA file is required for Firebase App Distribution
# To automate archive and export operations with Xcode:
echo "Creating IPA file with Xcode..."
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -sdk iphoneos -configuration Release archive -archivePath ../build/ios/archive/Runner.xcarchive
xcodebuild -exportArchive -archivePath ../build/ios/archive/Runner.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath ../build/ios/ipa

cd ..

# Check if IPA file exists
IPA_PATH="build/ios/ipa/Runner.ipa"
if [ ! -f "$IPA_PATH" ]; then
    echo "Error: IPA file not found: $IPA_PATH"
    echo "Note: You may need to manually archive and export from Xcode to create an IPA file"
    exit 1
fi

echo "IPA file ready: $IPA_PATH"

# Send to Firebase App Distribution
echo "Uploading IPA to Firebase App Distribution..."
firebase appdistribution:distribute "$IPA_PATH" \
  --app "YOUR_IOS_FIREBASE_APP_ID_HERE" \
  --groups "testers" \
  --release-notes "iOS Test Version - $(date)"

echo "iOS application has been sent to Firebase App Distribution!"
