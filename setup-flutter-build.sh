#!/usr/bin/env bash
set -e

echo "Setting up writable Flutter SDK for Android build..."

# Create a writable copy of the Flutter SDK parts needed for Android build
FLUTTER_SDK_NIX="/nix/store/91m0561ikfipdjvszvllyj4q8qis2743-flutter-wrapped-3.29.3-sdk-links"
FLUTTER_SDK_LOCAL="$PWD/build/flutter-sdk-local"

rm -rf "$FLUTTER_SDK_LOCAL"
mkdir -p "$FLUTTER_SDK_LOCAL/packages/flutter_tools"

# Copy the gradle plugin directory as writable
cp -r "$FLUTTER_SDK_NIX/packages/flutter_tools/gradle" "$FLUTTER_SDK_LOCAL/packages/flutter_tools/"
chmod -R u+w "$FLUTTER_SDK_LOCAL"

# Update local.properties to use our writable SDK
cat > android/local.properties << EOF
sdk.dir=/nix/store/z88zrxa5h6fn8ilm9smm33xznsz9z0my-android-sdk-env/share/android-sdk
flutter.sdk=$FLUTTER_SDK_LOCAL
flutter.buildMode=debug
flutter.versionName=0.1.0
EOF

echo "Writable Flutter SDK created at: $FLUTTER_SDK_LOCAL"