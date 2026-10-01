@echo off
setlocal
cd /d "%~dp0"
where flutter >nul 2>&1
if errorlevel 1 (
  echo Instale Flutter e adicione flutter\bin ao PATH.
  exit /b 1
)
set "THIGAS_BUILD_MODE=%~1"
if "%THIGAS_BUILD_MODE%"=="" set "THIGAS_BUILD_MODE=debug"
if not "%THIGAS_BUILD_MODE%"=="debug" if not "%THIGAS_BUILD_MODE%"=="release" (
  echo Uso: build-apk.bat [debug^|release]
  exit /b 1
)
if "%THIGAS_BUILD_MODE%"=="release" if not exist android\key.properties (
  echo Configure android\key.properties e sua chave de assinatura.
  exit /b 1
)
call flutter pub get
if errorlevel 1 exit /b 1
call flutter gen-l10n
if errorlevel 1 exit /b 1
call dart run tools/focus_checks.dart
if errorlevel 1 exit /b 1
call flutter analyze --no-fatal-infos --no-fatal-warnings
if errorlevel 1 exit /b 1
call flutter test
if errorlevel 1 exit /b 1
call flutter build apk --%THIGAS_BUILD_MODE% --flavor github -t lib/main.dart
if errorlevel 1 exit /b 1
echo APK: build\app\outputs\flutter-apk\app-github-%THIGAS_BUILD_MODE%.apk
