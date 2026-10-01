#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
if ! command -v flutter >/dev/null 2>&1; then
  echo 'Instale o Flutter compatível e adicione flutter/bin ao PATH.' >&2
  exit 1
fi
build_mode="${1:-debug}"
if [[ "$build_mode" != debug && "$build_mode" != release ]]; then
  echo 'Uso: bash build-apk.sh [debug|release]' >&2
  exit 1
fi
if [[ "$build_mode" == release && ! -f android/key.properties ]]; then
  echo 'Configure android/key.properties e sua chave antes do build release.' >&2
  exit 1
fi
flutter pub get
flutter gen-l10n
dart run tools/focus_checks.dart
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build apk "--$build_mode" --flavor github -t lib/main.dart
echo "APK gerado: build/app/outputs/flutter-apk/app-github-$build_mode.apk"
