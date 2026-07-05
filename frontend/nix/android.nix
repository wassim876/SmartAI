# Composes an Android SDK for building the Flutter Android target.
# Called from flake.nix via `pkgs.callPackage`; exposes `.androidsdk` (the
# combined SDK derivation) and `.platform-tools` (adb & friends).
{
  androidenv,
  # aapt2 build-tools version pulled out of the SDK and pinned via GRADLE_OPTS
  # so Gradle uses the Nix-provided binary instead of downloading its own.
  buildToolsVersionForAapt2 ? "36.0.0",
}:
androidenv.composeAndroidPackages {
  # Keep platform/build-tools aligned with android/app/build.gradle.kts
  # (compileSdk = flutter.compileSdkVersion, currently 36) and Flutter's
  # expectations. Include one older set so plugins that pin older tools resolve.
  platformVersions = ["36" "35" "34"];
  buildToolsVersions = [buildToolsVersionForAapt2 "35.0.0" "34.0.0"];

  platformToolsVersion = "36.0.0";
  cmdLineToolsVersion = "13.0";

  # Emulator + images are handy for `flutter emulators` but heavy; keep the
  # emulator, skip system images by default (pull them in on demand).
  includeEmulator = true;
  emulatorVersion = "36.6.11";
  includeSystemImages = false;
  systemImageTypes = ["google_apis_playstore"];
  abiVersions = ["arm64-v8a" "x86_64"];

  # Required by the app's Gradle build (ndkVersion = flutter.ndkVersion).
  # AGP would otherwise try to auto-install it into the read-only Nix SDK
  # and fail. Keep this pinned to Flutter's expected NDK version.
  includeNDK = true;
  ndkVersions = ["28.2.13676358"];

  # Native plugins (speech_to_text, file_picker, flutter_tts) drive a CMake
  # build; AGP would otherwise try to install cmake into the read-only Nix SDK
  # and fail ("SDK directory is not writable").
  cmakeVersions = ["3.22.1"];

  includeSources = false;
  includeExtras = ["extras;google;gcm"];
}
