#!/bin/bash

# Build APK Script for ZenX
# This script ensures clean build and handles common issues

echo "🧹 Cleaning project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🔨 Building APK (this may take a few minutes)..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo "✅ APK built successfully!"
    echo "📍 Location: build/app/outputs/flutter-apk/app-release.apk"
else
    echo "❌ APK build failed. Check the error messages above."
    exit 1
fi

