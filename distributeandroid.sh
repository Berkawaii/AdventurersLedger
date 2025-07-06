#!/bin/bash

# Flutter projesi derleyip App Distribution'a gönderen script ./distribute.sh
# flutter build apk --target-platform android-arm,android-arm64 --split-per-abi
# Temizle ve derle
echo "Flutter projesini temizliyorum..."
flutter clean

echo "Bağımlılıkları yüklüyorum..."
flutter pub get

# Android için derle (debug modunda)
echo "Android APK derliyorum (debug modu)..."
flutter build apk --debug

# APK dosyasının varlığını kontrol et
APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
if [ ! -f "$APK_PATH" ]; then
    echo "Hata: APK dosyası bulunamadı: $APK_PATH"
    exit 1
fi

echo "APK dosyası hazır: $APK_PATH"

# Firebase App Distribution'a gönder (debug APK ile)
echo "Firebase App Distribution'a debug APK yükleniyor..."
firebase appdistribution:distribute "$APK_PATH" \
  --app "1:99674628115:android:a4b9d047e3dc84554d1fe6" \
  --groups "testers" \
  --release-notes "Debug APK - Test için yeni sürüm"

echo "Uygulama Firebase App Distribution'a gönderildi!"
