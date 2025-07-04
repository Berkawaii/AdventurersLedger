#!/bin/bash

# Flutter projesi derleyip App Distribution'a gönderen script

# Temizle ve derle
echo "Flutter projesini temizliyorum..."
flutter clean

echo "Bağımlılıkları yüklüyorum..."
flutter pub get

# Android için derle
echo "Android APK derliyorum..."
flutter build apk --release

# APK dosyasının varlığını kontrol et
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ ! -f "$APK_PATH" ]; then
    echo "Hata: APK dosyası bulunamadı: $APK_PATH"
    exit 1
fi

echo "APK dosyası hazır: $APK_PATH"

# Firebase App Distribution'a gönder
echo "Firebase App Distribution'a yükleniyor..."
firebase appdistribution:distribute "$APK_PATH" \
  --app "1:99674628115:android:a4b9d047e3dc84554d1fe6" \
  --groups "testers" \
  --release-notes "Test için yeni sürüm"

echo "Uygulama Firebase App Distribution'a gönderildi!"
