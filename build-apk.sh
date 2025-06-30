#!/usr/bin/env bash

set -e

echo "🔧 Building APK for Pixel 6a (ARM64)..."

# Step 1: Ensure we're in nix develop
if [ -z "$ANDROID_SDK_ROOT" ]; then
    echo "❌ Error: Must run from within 'nix develop'"
    exit 1
fi

echo "✅ Nix environment detected"

# Step 2: Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
rm -rf android/.gradle android/app/.gradle
rm -rf build/

# Step 3: Restore original local.properties  
echo "📝 Setting up local.properties..."
cat > android/local.properties << EOF
sdk.dir=/nix/store/z88zrxa5h6fn8ilm9smm33xznsz9z0my-android-sdk-env/share/android-sdk
flutter.sdk=/nix/store/91m0561ikfipdjvszvllyj4q8qis2743-flutter-wrapped-3.29.3-sdk-links
flutter.buildMode=debug
flutter.versionName=0.1.0
EOF

# Step 4: Build native libraries  
echo "🦀 Building Rust native libraries for ARM64..."
just build-android-arm

# Step 5: Generate Flutter bindings
echo "🔗 Generating Flutter-Rust bindings..."
just generate

# Step 6: Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Step 7: Try different Gradle versions until one works
echo "🔨 Attempting APK build..."

# Try with Gradle 8.3 (known to work with JDK 21)
echo "distributionUrl=https\://services.gradle.org/distributions/gradle-8.3-all.zip" > android/gradle/wrapper/gradle-wrapper.properties

# Clean and try build
rm -rf ~/.gradle/daemon ~/.gradle/caches/8.* android/.gradle

# Set Gradle properties for JDK 21 compatibility
cat > android/gradle.properties << 'EOF'
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=2G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.prefs/java.util.prefs=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED --add-opens=java.base/java.nio.charset=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED
android.useAndroidX=true
android.enableJetifier=true
org.gradle.daemon=false
org.gradle.console=plain
org.gradle.warning.mode=all
EOF

echo "🚀 Building APK..."
if flutter build apk --debug --target-platform android-arm64; then
    echo "✅ SUCCESS! APK built successfully"
    
    if [ -f "build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk" ]; then
        APK_FILE="build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk"
    elif [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
        APK_FILE="build/app/outputs/flutter-apk/app-debug.apk"
    else
        APK_FILE=$(find build -name "*.apk" | head -1)
    fi
    
    if [ -n "$APK_FILE" ]; then
        echo "📱 APK ready for Pixel 6a: $APK_FILE"
        ls -lh "$APK_FILE"
        echo ""
        echo "🔧 To install on your device:"
        echo "   adb install '$APK_FILE'"
    else
        echo "❌ APK file not found after build"
        exit 1
    fi
else
    echo "❌ APK build failed"
    exit 1
fi