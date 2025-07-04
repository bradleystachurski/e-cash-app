generate:
  flutter_rust_bridge_codegen generate --rust-input=crate --rust-root=$ROOT/rust/carbine_fedimint --dart-output=$ROOT/lib/
  # `freezed_annotation` requires this build step, which gives us rust-like pattern matching in dart's codegen
  flutter pub run build_runner build --delete-conflicting-outputs

build-android-x86_64:
  $ROOT/scripts/build-android.sh

build-android-arm:
  $ROOT/scripts/build-arm-android.sh

build-linux:
  $ROOT/scripts/build-linux.sh

run:
  nix run --impure github:guibou/nixGL flutter run

# Clean all APK build artifacts and caches
clean-apk:
  @echo "Cleaning APK build artifacts..."
  flutter clean
  rm -rf android/.gradle
  rm -rf android/app/build
  rm -rf build/
  rm -rf .dart_tool/
  rm -rf .flutter-plugins
  rm -rf .flutter-plugins-dependencies
  @echo "APK build artifacts cleaned"

# Build debug APK
build-apk:
  @echo "Building debug APK..."
  flutter build apk --debug
  @echo "Debug APK built at: build/app/outputs/flutter-apk/app-debug.apk"

# Build release APK
build-apk-release:
  @echo "Building release APK..."
  flutter build apk --release
  @echo "Release APK built at: build/app/outputs/flutter-apk/app-release.apk"
