#!/bin/bash

# Development build script
echo "Building ZenX for Development..."

flutter build apk --debug \
  --dart-define=ENV=development \
  --dart-define=BUILD_NUMBER=$(date +%s) \
  --target lib/main.dart

echo "Development build complete!"









