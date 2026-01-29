#!/bin/bash
echo "🧹 Cleaning up Flutter and iOS..."
flutter clean
flutter pub get
rm -rf ~/Library/Developer/Xcode/DerivedData/*
cd ios
sudo rm -rf Pods
sudo rm Podfile.lock
pod install
cd ..
echo "✅ Everything is synced! Now open Xcode and Run."