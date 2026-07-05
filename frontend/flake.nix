{
  description = "Flutter dev environment for the SmartAi frontend";

  inputs.nixpkgs = {
    url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.android_sdk.accept_license = true;
      };
      inherit (pkgs) lib stdenv;

      # aapt2 is pulled from this build-tools version; keep in sync with
      # nix/android.nix and android/app/build.gradle.kts.
      buildToolsVersionForAapt2 = "36.0.0";
      android = pkgs.callPackage ./nix/android.nix {inherit buildToolsVersionForAapt2;};
      androidSdkRoot = "${android.androidsdk}/libexec/android-sdk";

      # Linux desktop / emulator runtime deps. These packages don't exist (or
      # aren't needed) on Darwin, so gate them so the shell evaluates on macOS.
      linuxOnly = with pkgs; [
        # Linux desktop target (GTK) build + run
        gtk3
        pcre2.dev
        util-linux.dev
        libselinux
        libsepol
        libthai
        libdatrie
        xorg.libXdmcp
        xorg.libXtst
        lerc.dev
        libxkbcommon
        libepoxy
        # emulator hardware decode
        vulkan-loader
        libGL
        # web target
        ungoogled-chromium
      ];
    in {
      # mkShellNoCC (NOT mkShell): the default Darwin stdenv injects Nix's
      # cc-wrapper, which shadows Apple's clang/ld/lipo on PATH, exports
      # NIX_CFLAGS_COMPILE/NIX_LDFLAGS, and points DEVELOPER_DIR at a Nix
      # apple-sdk stub. Xcode then links iOS/macOS targets with the Nix
      # toolchain and fails ("-objc_abi_version not supported", "ld: unknown
      # options", "lipo: Permission denied"). We don't need a host C compiler
      # (Flutter/Dart are prebuilt; Android uses the NDK), so drop it and let
      # Xcode own the Apple toolchain.
      devShells.default = pkgs.mkShellNoCC {
        buildInputs = with pkgs;
          [
            flutter
            jdk17
            android.platform-tools
            pkg-config
          ]
          # CocoaPods is required by Flutter to install iOS/macOS plugin pods
          # (supabase_flutter, firebase, flutter_secure_storage, …).
          ++ lib.optionals stdenv.isDarwin [cocoapods]
          ++ lib.optionals stdenv.isLinux linuxOnly;

        ANDROID_HOME = androidSdkRoot;
        ANDROID_SDK_ROOT = androidSdkRoot;
        GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdkRoot}/build-tools/${buildToolsVersionForAapt2}/aapt2";
        JAVA_HOME = pkgs.jdk17.home;
        ANDROID_AVD_HOME = (toString ./.) + "/.android/avd";

        # The Flutter SDK dir that contains packages/flutter_tools/gradle. The
        # Android Gradle build reads this from android/local.properties; we keep
        # that file pointed here (see shellHook).
        FLUTTER_ROOT = pkgs.flutter;

        # Point Flutter's web target at the Nix chromium (Linux only; on macOS
        # use the system Chrome via `flutter config`).
        CHROME_EXECUTABLE = lib.optionalString stdenv.isLinux "${pkgs.ungoogled-chromium}/bin/chromium";

        shellHook = ''
          export PATH="$ANDROID_HOME/platform-tools:$PATH"

          # Pin the Flutter SDK as a GC root so `nix-collect-garbage` can't
          # delete it out from under a build.
          mkdir -p "$PWD/.nix-gcroots"
          nix-store --realise --indirect \
            --add-root "$PWD/.nix-gcroots/flutter-sdk" \
            "$FLUTTER_ROOT" >/dev/null 2>&1 || true

          # The Android build (AGP) requires the Flutter Gradle composite-build
          # dir (packages/flutter_tools/gradle) to be WRITABLE, but the Nix
          # store is read-only -> settings.gradle.kts fails with
          # "projectDirectory '.../flutter_tools/gradle' ... can't be written
          # to". Materialize a writable skeleton of the SDK (real, writable
          # dirs; file contents stay as symlinks into the store, so it's tiny)
          # and drive the whole Flutter toolchain from it.
          writableSdk="$PWD/.flutter-sdk"
          marker="$writableSdk/.nix-source"
          if [ "$(cat "$marker" 2>/dev/null)" != "$FLUTTER_ROOT" ]; then
            rm -rf "$writableSdk"
            cp -R "$FLUTTER_ROOT" "$writableSdk"
            chmod -R u+w "$writableSdk" 2>/dev/null || true

            # `cp -R` copies symlinks verbatim. The SDK's `bin/dart` is a
            # RELATIVE link (../../<hash>-dart/bin/dart) into a sibling Nix
            # store path, so it dangles once copied out of /nix/store. Flutter
            # itself finds dart via bin/cache, but Xcode's xcode_backend.sh
            # calls "$FLUTTER_ROOT/bin/dart" directly and fails with status
            # 126. Re-point any now-dangling bin symlink at its absolute
            # /nix/store target (../../ from a store bin dir resolves to
            # /nix/store).
            for l in "$writableSdk"/bin/*; do
              if [ -L "$l" ] && [ ! -e "$l" ]; then
                t="$(readlink "$l")"
                case "$t" in
                  ../../*) ln -sf "/nix/store/''${t#../../}" "$l" ;;
                esac
              fi
            done

            # Xcode's "Prepare Flutter Framework" build phase rsyncs the
            # engine's *.xcframework into build/ and then thins it IN PLACE
            # with lipo. In this Nix Flutter the engine artifacts are symlinks
            # into the read-only /nix/store, so the copy inherits read-only
            # perms and lipo dies with "can't create temporary output file
            # ... Flutter.lipo (Permission denied)" (Xcode status 255).
            # Replace each store-symlinked engine framework with a writable
            # real copy so the in-place thinning can write.
            find "$writableSdk/bin/cache/artifacts/engine" -maxdepth 2 \
              -name '*.xcframework' -type l 2>/dev/null | while read -r fw; do
              real="$(readlink "$fw")"
              rm -f "$fw"
              cp -RL "$real" "$fw"
              chmod -R u+w "$fw"
            done

            printf '%s' "$FLUTTER_ROOT" > "$marker"
          fi
          # Point FLUTTER_ROOT and PATH at the writable copy. `flutter build`
          # regenerates android/local.properties (flutter.sdk) from this on
          # every run, so it stays consistent.
          export FLUTTER_ROOT="$writableSdk"
          export PATH="$writableSdk/bin:$PATH"

          # flutter shell completion, if the subcommand is available
          if flutter help bash-completion >/dev/null 2>&1; then
            . <(flutter bash-completion) 2>/dev/null || true
          fi
        ''
        + lib.optionalString stdenv.isDarwin ''
          # --- Apple-native (iOS/macOS) builds: hand the toolchain to Xcode ---
          # Even with mkShellNoCC, some inputs may still export a Nix apple-sdk
          # DEVELOPER_DIR or leftover compiler flags. Force the real Xcode and
          # strip any Nix compiler/linker env so xcodebuild uses Apple clang,
          # ld, lipo and the system SDK.
          export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
          unset SDKROOT NIX_CFLAGS_COMPILE NIX_CFLAGS_LINK NIX_LDFLAGS
          # Some inputs export CC/CXX/LD (=clang/clang++/ld) into the env.
          # Xcode/CocoaPods honor $LD as the linker DRIVER, so a bare "ld"
          # makes xcodebuild invoke Apple's ld directly with clang-style
          # "-Xlinker" flags it can't parse ("ld: -objc_abi_version
          # '-Xlinker' not supported"). Clear them so Xcode uses its own
          # defaults (LD = clang driver). Also drop the macOS deployment
          # target so it can't leak into iOS builds.
          unset CC CXX LD CFLAGS CXXFLAGS LDFLAGS MACOSX_DEPLOYMENT_TARGET
          # Ensure Apple's /usr/bin tools resolve ahead of anything else.
          export PATH="/usr/bin:$PATH"
        '';
      };
    });
}
