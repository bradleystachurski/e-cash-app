#!/usr/bin/env bash

set -e

echo "🚀 Final APK Build for Pixel 6a"

# Only make the minimal changes needed for JDK 21 compatibility

# 1. Java version is already set to 21 in build.gradle.kts
# Skip this step since build.gradle.kts is already properly configured

# 2. JDK 21 compatibility flags are already configured in gradle.properties
# Skip this step since gradle.properties is already properly configured

# 3. Ensure native libraries are built
just build-android-arm

# 4. Build APK
echo "Building APK..."
flutter build apk --debug --target-platform android-arm64

# 5. Check result
if [ -f "build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk" ]; then
    echo "✅ SUCCESS! APK built at: build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk"
    ls -lh build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk
elif [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
    echo "✅ SUCCESS! APK built at: build/app/outputs/flutter-apk/app-debug.apk"
    ls -lh build/app/outputs/flutter-apk/app-debug.apk
else
    echo "❌ APK not found"
    find build -name "*.apk" || echo "No APK files found"
    exit 1
fi