{
  inputs = {
    fedimint.url = "github:fedimint/fedimint?rev=b983d25d4c3cce1751c54e3ad0230fc507e3aeec";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixgl.url = "github:guibou/nixGL";
    android.url = "github:tadfisher/android-nixpkgs";
  };

  outputs = { self, fedimint, flake-utils, nixpkgs, nixgl, android, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        inherit (nixpkgs) lib;
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        androidPkgs = {
          android-sdk = android.sdk.${system} (sdkPkgs: with sdkPkgs; [
            # Useful packages for building and testing.
            build-tools-33-0-1
            build-tools-34-0-0
            build-tools-35-0-1
            cmdline-tools-latest
            cmake-3-22-1
            emulator
            platform-tools
            platforms-android-35
            # Other useful packages for a development environment.
            #ndk-26-1-10909125
            ndk-27-0-12077973
            # skiaparser-3
            # sources-android-34
          ]
          ++ lib.optionals (system == "aarch64-darwin") [
            # system-images-android-34-google-apis-arm64-v8a
            # system-images-android-34-google-apis-playstore-arm64-v8a
          ]
          ++ lib.optionals (system == "x86_64-darwin" || system == "x86_64-linux") [
            # system-images-android-34-google-apis-x86-64
            # system-images-android-34-google-apis-playstore-x86-64
          ]);
        } // lib.optionalAttrs (system == "x86_64-linux") {
          # Android Studio in nixpkgs is currently packaged for x86_64-linux only.
          android-studio = pkgs.androidStudioPackages.stable;
          # android-studio = pkgs.androidStudioPackages.beta;
          # android-studio = pkgs.androidStudioPackages.preview;
          # android-studio = pkgs.androidStudioPackage.canary;
        };
        
        nixglPkgs = import nixgl { inherit system; };

        # Import the `devShells` from the fedimint flake
        devShells = fedimint.devShells.${system};

        # Reproducibly install flutter_rust_bridge_codegen via Rust
        flutter_rust_bridge_codegen = pkgs.rustPlatform.buildRustPackage rec {
          name = "flutter_rust_bridge";

          src = pkgs.fetchFromGitHub {
            owner = "fzyzcjy";
            repo = name;
            rev = "v2.9.0";
            sha256 = "sha256-3Rxbzeo6ZqoNJHiR1xGR3wZ8TzUATyowizws8kbz0pM=";
          };

          cargoHash = "sha256-efMA8VJaQlqClAmjJ3zIYLUfnuj62vEIBKsz0l3CWxA=";
          
          # For some reason flutter_rust_bridge unit tests are failing
          doCheck = false;
        };

        # cargo-ndk binary
        cargo-ndk = pkgs.rustPlatform.buildRustPackage rec {
          pname = "cargo-ndk";
          version = "3.5.7";

          src = pkgs.fetchFromGitHub {
            owner = "bbqsrc";
            repo = "cargo-ndk";
            rev = "v${version}";
            sha256 = "sha256-tzjiq1jjluWqTl+8MhzFs47VRp3jIRJ7EOLhUP8ydbM=";
          };

          cargoHash = "sha256-Kt4GLvbGK42RjivLpL5W5z5YBfDP5B83mCulWz6Bisw=";
          doCheck = false;
        };
      in {
        devShells = {
          # You can expose all or specific shells from the original flake
          default = devShells.cross.overrideAttrs (old: {
            nativeBuildInputs = old.nativeBuildInputs or [] ++ [
              pkgs.flutter
              pkgs.gradle
              pkgs.just
              pkgs.zlib
              pkgs.curl
              pkgs.patchelf
              pkgs.autoPatchelfHook
              pkgs.file
              flutter_rust_bridge_codegen
              cargo-ndk
              pkgs.cargo-expand
              pkgs.jdk21
              androidPkgs.android-sdk
            ] ++ pkgs.lib.optionals (pkgs.stdenv.system == "x86_64-linux") [
              androidPkgs.android-studio
            ];

	    shellHook = ''
	      ${old.shellHook or ""}

              export LD_LIBRARY_PATH="${pkgs.zlib}/lib:${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"
              export NIXPKGS_ALLOW_UNFREE=1
              export ROOT="$PWD"
              export ANDROID_SDK_ROOT=${androidPkgs.android-sdk}/share/android-sdk
              export ANDROID_SDK_HOME=$HOME
              export ANDROID_NDK_ROOT=$ANDROID_SDK_ROOT/ndk/27.0.12077973
              export ANDROID_NDK_HOME=$ANDROID_SDK_ROOT/ndk/27.0.12077973
              export JAVA_HOME=${pkgs.jdk21}/lib/openjdk
              export FLUTTER_ROOT=${pkgs.flutter}
              export GRADLE_HOME=${pkgs.gradle}
              export PATH=${pkgs.gradle}/bin:$PATH
              
              export GRADLE_USER_HOME="$HOME/.gradle"
              export GRADLE_OPTS="-Dorg.gradle.java.home=${pkgs.jdk21}/lib/openjdk -Dorg.gradle.user.home=$HOME/.gradle"
              
              # Create gradle init directory and copy our init script
              mkdir -p "$HOME/.gradle/init.d"
              cp "$ROOT/android/gradle-init-patch-binaries.gradle" "$HOME/.gradle/init.d/"
              
              # Create minimal writable Flutter copy (only what's needed for gradle)
              if [ ! -d "$ROOT/.flutter-tools-local" ]; then
                echo "Creating minimal Flutter tools copy..."
                mkdir -p "$ROOT/.flutter-tools-local/packages/flutter_tools"
                mkdir -p "$ROOT/.flutter-tools-local/bin/internal"
                # Copy only the gradle directory that needs to be writable
                cp -r ${pkgs.flutter}/packages/flutter_tools/gradle "$ROOT/.flutter-tools-local/packages/flutter_tools/"
                # Copy minimal structure needed for gradle to find engine version
                cp ${pkgs.flutter}/bin/internal/engine.version "$ROOT/.flutter-tools-local/bin/internal/" 2>/dev/null || true
                cp ${pkgs.flutter}/version "$ROOT/.flutter-tools-local/" 2>/dev/null || true
                chmod -R +w "$ROOT/.flutter-tools-local"
              fi
              export FLUTTER_TOOLS_GRADLE_DIR="$ROOT/.flutter-tools-local/packages/flutter_tools/gradle"
              
              # Add patchelf for binary patching (still needed by the Gradle init script)
              export PATH="${pkgs.patchelf}/bin:$PATH"

              if [ -d .git ]; then
                ln -sf "$PWD/scripts/git-hooks/pre-commit.sh" .git/hooks/pre-commit
              fi
	    '';
          });
        };
      }
    );
}
