#!/bin/bash

# Production build script
echo "Building ZenX for Production..."

# Android
flutter build appbundle --release \
  --dart-define=ENV=production \
  --dart-define=BUILD_NUMBER=$1 \
  --target lib/main.dart

# iOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
  flutter build ios --release \
    --dart-define=ENV=production \
    --dart-define=BUILD_NUMBER=$1 \
    --target lib/main.dart
fi

# Web
flutter build web --release \
  --dart-define=ENV=production \
  --dart-define=BUILD_NUMBER=$1 \
  --target lib/main.dart

echo "Production build complete!"









