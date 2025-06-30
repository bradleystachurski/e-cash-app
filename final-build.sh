#!/usr/bin/env bash

set -e

echo "🚀 Final APK Build for Pixel 6a"

# Only make the minimal changes needed for JDK 21 compatibility

# 1. Update Java version in build.gradle.kts to match our environment
sed -i 's/JavaVersion.VERSION_11/JavaVersion.VERSION_21/g' android/app/build.gradle.kts
sed -i 's/VERSION_11/VERSION_21/g' android/app/build.gradle.kts

# 2. Add JDK 21 compatibility flags to gradle.properties
cat >> android/gradle.properties << 'EOF'
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.prefs/java.util.prefs=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED --add-opens=java.base/java.nio.charset=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED
EOF

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