/*
 *     Copyright (C) 2026 Valeri Gokadze
 *
 *     Musify is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Musify is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *
 *     For more information about Musify, including how to contribute,
 *     please visit: https://github.com/gokadzev/Musify
 */

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thigas_music/services/settings_manager.dart';

ThemeMode themeMode = getThemeMode(themeModeSetting);
Brightness brightness = getBrightnessFromThemeMode(themeMode);

Brightness getBrightnessFromThemeMode(ThemeMode themeMode) {
  final themeBrightnessMapping = {
    ThemeMode.light: Brightness.light,
    ThemeMode.dark: Brightness.dark,
    ThemeMode.system:
        SchedulerBinding.instance.platformDispatcher.platformBrightness,
  };

  return themeBrightnessMapping[themeMode] ?? Brightness.dark;
}

ThemeMode getThemeMode(int themeModeIndex) {
  const themeModes = ThemeMode.values;
  if (themeModeIndex >= 0 && themeModeIndex < themeModes.length) {
    return themeModes[themeModeIndex];
  }
  return ThemeMode.system;
}

ColorScheme getAppColorScheme(
  ColorScheme? lightColorScheme,
  ColorScheme? darkColorScheme,
) {
  final selectedScheme = (brightness == Brightness.light)
      ? lightColorScheme
      : darkColorScheme;

  if (useSystemColor.value && selectedScheme != null) {
    return selectedScheme;
  } else {
    final seeded = ColorScheme.fromSeed(
      seedColor: primaryColorSetting,
      brightness: brightness,
    );
    if (primaryColorSetting != const Color(0xFFA8D5BA)) return seeded;
    final dark = brightness == Brightness.dark;
    return seeded.copyWith(
      primary: Color(dark ? 0xFFA8D5BA : 0xFF285C3E),
      onPrimary: Color(dark ? 0xFF102317 : 0xFFFFFFFF),
      primaryContainer: Color(dark ? 0xFF293D31 : 0xFFD4EBDC),
      onPrimaryContainer: Color(dark ? 0xFFD4EBDC : 0xFF102317),
      secondary: Color(dark ? 0xFFA8D5BA : 0xFF285C3E),
      surface: Color(dark ? 0xFF121614 : 0xFFF5F7F5),
      surfaceContainerLowest: Color(dark ? 0xFF121614 : 0xFFFFFFFF),
      surfaceContainerLow: Color(dark ? 0xFF1D2420 : 0xFFFFFFFF),
      surfaceContainer: Color(dark ? 0xFF232B26 : 0xFFEEF2EF),
      surfaceContainerHigh: Color(dark ? 0xFF29332D : 0xFFE8EEE9),
      surfaceContainerHighest: Color(dark ? 0xFF323E36 : 0xFFDFE7E1),
      onSurface: Color(dark ? 0xFFF2F5F2 : 0xFF17211B),
      onSurfaceVariant: Color(dark ? 0xFFB8C4BB : 0xFF526358),
      error: Color(dark ? 0xFFFFB4AB : 0xFFBA1A1A),
    );
  }
}

ThemeData getAppTheme(ColorScheme colorScheme) {
  final base = colorScheme.brightness == Brightness.light
      ? ThemeData.light()
      : ThemeData.dark();

  final isLight = colorScheme.brightness == Brightness.light;
  final isPureBlack =
      colorScheme.brightness == Brightness.dark && usePureBlackColor.value;

  // Pure black theme colors
  const pureBlack = Color(0xFF000000);
  const pureBlackElevated = Color(0xFF0A0A0A);
  const pureBlackContainer = Color(0xFF121212);
  const pureBlackContainerHigh = Color(0xFF1A1A1A);

  final bgColor = isLight
      ? colorScheme.surface
      : (isPureBlack ? pureBlack : null);

  final cardBgColor = isLight
      ? colorScheme.surfaceContainerLow
      : (isPureBlack ? pureBlackElevated : null);

  // modified color scheme for pure black theme
  final effectiveColorScheme = isPureBlack
      ? colorScheme.copyWith(
          surface: pureBlack,
          surfaceContainerLowest: pureBlack,
          surfaceContainerLow: pureBlackElevated,
          surfaceContainer: pureBlackContainer,
          surfaceContainerHigh: pureBlackContainerHigh,
          surfaceContainerHighest: pureBlackContainerHigh,
        )
      : colorScheme;

  final textTheme = base.textTheme
      .copyWith(
        headlineMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        bodyMedium: const TextStyle(fontSize: 16, height: 1.5),
        bodySmall: const TextStyle(fontSize: 14, height: 1.5),
      )
      .apply(
        fontFamily: 'Outfit',
        bodyColor: effectiveColorScheme.onSurface,
        displayColor: effectiveColorScheme.onSurface,
      );

  return ThemeData(
    fontFamily: 'Outfit',
    textTheme: textTheme,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    scaffoldBackgroundColor: bgColor,
    colorScheme: effectiveColorScheme,
    cardColor: cardBgColor,
    cardTheme: base.cardTheme.copyWith(
      elevation: 0,
      color: cardBgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: bgColor,
      foregroundColor: effectiveColorScheme.primary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 26,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w600,
        color: effectiveColorScheme.primary,
        letterSpacing: -0.5,
      ),
      toolbarHeight: 64,
      iconTheme: IconThemeData(
        color: effectiveColorScheme.onSurfaceVariant,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: effectiveColorScheme.onSurfaceVariant,
        size: 24,
      ),
    ),
    listTileTheme: base.listTileTheme.copyWith(
      textColor: effectiveColorScheme.primary,
      iconColor: effectiveColorScheme.primary,
    ),
    sliderTheme: base.sliderTheme.copyWith(
      year2023: false,
      trackHeight: 6,
      thumbSize: WidgetStateProperty.all(const Size(6, 30)),
    ),
    bottomSheetTheme: base.bottomSheetTheme.copyWith(
      backgroundColor: isLight
          ? colorScheme.surfaceContainerLow
          : (isPureBlack ? pureBlackElevated : null),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      filled: true,
      isDense: true,
      fillColor: isLight
          ? colorScheme.surfaceContainerHighest
          : (isPureBlack
                ? pureBlackContainerHigh
                : colorScheme.surfaceContainerHigh),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.fromLTRB(18, 14, 20, 14),
    ),
    dialogTheme: base.dialogTheme.copyWith(
      backgroundColor: isLight
          ? colorScheme.surfaceContainerLow
          : (isPureBlack ? pureBlackContainer : null),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    navigationBarTheme: base.navigationBarTheme.copyWith(
      backgroundColor: bgColor,
      elevation: 0,
      height: 70,
      indicatorColor: effectiveColorScheme.primaryContainer,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(
            color: effectiveColorScheme.onPrimaryContainer,
            size: 24,
          );
        }
        return IconThemeData(
          color: effectiveColorScheme.onSurfaceVariant,
          size: 24,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            color: effectiveColorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }
        return TextStyle(
          color: effectiveColorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }),
    ),
    navigationRailTheme: base.navigationRailTheme.copyWith(
      backgroundColor: bgColor,
      elevation: 0,
      indicatorColor: effectiveColorScheme.primaryContainer,
      selectedIconTheme: IconThemeData(
        color: effectiveColorScheme.onPrimaryContainer,
        size: 24,
      ),
      unselectedIconTheme: IconThemeData(
        color: effectiveColorScheme.onSurfaceVariant,
        size: 24,
      ),
      selectedLabelTextStyle: TextStyle(
        color: effectiveColorScheme.onSurface,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: effectiveColorScheme.onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    popupMenuTheme: base.popupMenuTheme.copyWith(
      color: isLight
          ? colorScheme.surfaceContainerLow
          : (isPureBlack ? pureBlackContainer : null),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: base.dividerTheme.copyWith(
      color: effectiveColorScheme.outlineVariant,
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: effectiveColorScheme.secondaryContainer,
      closeIconColor: effectiveColorScheme.onSecondaryContainer,
      contentTextStyle: TextStyle(
        color: effectiveColorScheme.onSecondaryContainer,
        fontWeight: FontWeight.w500,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: effectiveColorScheme.outlineVariant,
          width: 0.2,
        ),
      ),
      elevation: 0,
      actionTextColor: effectiveColorScheme.secondary,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
  );
}
