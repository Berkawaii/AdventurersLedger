#!/bin/bash

# Flutter projesi derleyip iOS için App Distribution'a gönderen script ./distributeios.sh
# Temizle ve derle
echo "Flutter projesini temizliyorum..."
flutter clean

echo "Bağımlılıkları yüklüyorum..."
flutter pub get

# iOS için build işlemini başlat
echo "iOS IPA derliyorum..."

# Pod kurulumunu güncelle
echo "iOS Pod'larını güncelliyorum..."
cd ios
pod install --repo-update
cd ..

# Archive oluştur
echo "iOS için archive oluşturuyorum..."
flutter build ios --release --no-codesign

# Not: Firebase App Distribution için IPA dosyası gerekli
# Xcode ile archive ve export işlemlerini otomatikleştirmek için:
echo "Xcode ile IPA dosyası oluşturuluyor..."
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -sdk iphoneos -configuration Release archive -archivePath ../build/ios/archive/Runner.xcarchive
xcodebuild -exportArchive -archivePath ../build/ios/archive/Runner.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath ../build/ios/ipa

cd ..

# IPA dosyasının varlığını kontrol et
IPA_PATH="build/ios/ipa/Runner.ipa"
if [ ! -f "$IPA_PATH" ]; then
    echo "Hata: IPA dosyası bulunamadı: $IPA_PATH"
    echo "Not: IPA dosyası oluşturmak için Xcode'dan manuel olarak archive ve export işlemlerini yapmanız gerekebilir"
    exit 1
fi

echo "IPA dosyası hazır: $IPA_PATH"

# Firebase App Distribution'a gönder
echo "Firebase App Distribution'a IPA yükleniyor..."
firebase appdistribution:distribute "$IPA_PATH" \
  --app "IOS_FIREBASE_APP_ID_BURAYA_GELECEK" \
  --groups "testers" \
  --release-notes "iOS Test Sürümü - $(date)"

echo "iOS uygulaması Firebase App Distribution'a gönderildi!"
