import 'package:flutter/material.dart';

/// Semantic color theme extension for the app
/// Provides consistent theming across all screens without hardcoded colors
class SemanticColorTheme extends ThemeExtension<SemanticColorTheme> {
  final Color infoContainer;
  final Color surfaceVariant;
  final Color successContainer;
  final Color errorContainer;
  final Color onInfoContainer;
  final Color onSurfaceVariant;
  final Color onSuccessContainer;
  final Color onErrorContainer;
  final Color borderColor;
  final Color primaryIcon;
  final Color secondaryText;
  final Color error;
  final Color success;

  const SemanticColorTheme({
    required this.infoContainer,
    required this.surfaceVariant,
    required this.successContainer,
    required this.errorContainer,
    required this.onInfoContainer,
    required this.onSurfaceVariant,
    required this.onSuccessContainer,
    required this.onErrorContainer,
    required this.borderColor,
    required this.primaryIcon,
    required this.secondaryText,
    required this.error,
    required this.success,
  });

  factory SemanticColorTheme.light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6B4C9A),
      brightness: Brightness.light,
    );

    return SemanticColorTheme(
      infoContainer: colorScheme.primaryContainer,
      surfaceVariant: colorScheme.surfaceContainerHighest,
      successContainer: colorScheme.primaryContainer,
      errorContainer: colorScheme.errorContainer,
      onInfoContainer: colorScheme.onPrimaryContainer,
      onSurfaceVariant: colorScheme.onSurfaceVariant,
      onSuccessContainer: colorScheme.onPrimaryContainer,
      onErrorContainer: colorScheme.onErrorContainer,
      borderColor: colorScheme.outline,
      primaryIcon: colorScheme.primary,
      secondaryText: colorScheme.onSurfaceVariant,
      error: colorScheme.error,
      success: colorScheme.primary,
    );
  }

  factory SemanticColorTheme.dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6B4C9A),
      brightness: Brightness.dark,
    );

    return SemanticColorTheme(
      infoContainer: colorScheme.primaryContainer,
      surfaceVariant: colorScheme.surfaceContainerHighest,
      successContainer: colorScheme.primaryContainer,
      errorContainer: colorScheme.errorContainer,
      onInfoContainer: colorScheme.onPrimaryContainer,
      onSurfaceVariant: colorScheme.onSurfaceVariant,
      onSuccessContainer: colorScheme.onPrimaryContainer,
      onErrorContainer: colorScheme.onErrorContainer,
      borderColor: colorScheme.outline,
      primaryIcon: colorScheme.primary,
      secondaryText: colorScheme.onSurfaceVariant,
      error: colorScheme.error,
      success: colorScheme.primary,
    );
  }

  @override
  ThemeExtension<SemanticColorTheme> copyWith({
    Color? infoContainer,
    Color? surfaceVariant,
    Color? successContainer,
    Color? errorContainer,
    Color? onInfoContainer,
    Color? onSurfaceVariant,
    Color? onSuccessContainer,
    Color? onErrorContainer,
    Color? borderColor,
    Color? primaryIcon,
    Color? secondaryText,
    Color? error,
    Color? success,
  }) {
    return SemanticColorTheme(
      infoContainer: infoContainer ?? this.infoContainer,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      successContainer: successContainer ?? this.successContainer,
      errorContainer: errorContainer ?? this.errorContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      borderColor: borderColor ?? this.borderColor,
      primaryIcon: primaryIcon ?? this.primaryIcon,
      secondaryText: secondaryText ?? this.secondaryText,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }

  @override
  ThemeExtension<SemanticColorTheme> lerp(
    covariant ThemeExtension<SemanticColorTheme>? other,
    double t,
  ) {
    if (other is! SemanticColorTheme) return this;
    return SemanticColorTheme(
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      onSurfaceVariant:
          Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      onErrorContainer: Color.lerp(onErrorContainer, other.onErrorContainer, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      primaryIcon: Color.lerp(primaryIcon, other.primaryIcon, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

/// Extension to easily access semantic colors from BuildContext
extension SemanticColorThemeExtension on BuildContext {
  SemanticColorTheme get semanticColors =>
      Theme.of(this).extension<SemanticColorTheme>()!;
}
