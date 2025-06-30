#!/usr/bin/env bash

set -e

echo "=== Manual APK Build Script ==="

# Check if we're in nix develop
if [ -z "$ANDROID_SDK_ROOT" ]; then
    echo "Error: ANDROID_SDK_ROOT not set. Run this from within 'nix develop'"
    exit 1
fi

echo "1. Building native libraries..."
cd rust/carbine_fedimint

export CC_aarch64_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang
export CXX_aarch64_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang++

cargo ndk -t arm64-v8a -o ../../android/app/src/main/jniLibs build --release --target aarch64-linux-android
chmod u+w ../../android/app/src/main/jniLibs/arm64-v8a/libc++_shared.so 2>/dev/null || true
cp $ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/libc++_shared.so ../../android/app/src/main/jniLibs/arm64-v8a/

cd ../..

echo "2. Generating Flutter bindings..."
flutter_rust_bridge_codegen generate --rust-input=crate --rust-root=$ROOT/rust/carbine_fedimint --dart-output=$ROOT/lib/

echo "3. Getting Flutter dependencies..."
flutter pub get

echo "4. Running code generation..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "5. Creating APK with direct tools..."
# Set up Android environment for direct tool usage
export PATH="$ANDROID_SDK_ROOT/build-tools/35-0-1:$PATH"
export CLASSPATH="$ANDROID_SDK_ROOT/platforms/android-35/android.jar"

mkdir -p build/android-manual

echo "6. Building with Flutter..."
# Try a simpler Flutter build approach
flutter build apk --debug --target-platform android-arm64 --split-per-abi || {
    echo "Flutter build failed, but native libraries are ready for manual APK creation"
    echo "Native libraries built successfully at:"
    ls -la android/app/src/main/jniLibs/arm64-v8a/
    exit 1
}

echo "7. APK build completed!"
if [ -f "build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk" ]; then
    echo "APK Location: build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk"
    ls -la build/app/outputs/flutter-apk/app-*-debug.apk
elif [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
    echo "APK Location: build/app/outputs/flutter-apk/app-debug.apk"
    ls -la build/app/outputs/flutter-apk/app-debug.apk
else
    echo "APK files:"
    find build -name "*.apk" 2>/dev/null || echo "No APK files found"
fi