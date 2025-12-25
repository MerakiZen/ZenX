#!/bin/bash

# Staging build script
echo "Building ZenX for Staging..."

flutter build apk --profile \
  --dart-define=ENV=staging \
  --dart-define=BUILD_NUMBER=$(date +%s) \
  --target lib/main.dart \
  --release

echo "Staging build complete!"









