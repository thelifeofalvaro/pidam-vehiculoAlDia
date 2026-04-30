import 'package:flutter/material.dart';
import 'app_color.dart';

/// Estilos de texto centralizados.
/// Para variantes, usamos el método copyWith():
/// Ejemlo: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryBlue)

/// Fuentes: Inter (títulos y botones), Roboto (cuerpo y etiquetas).

class AppTextStyles {
  AppTextStyles._();

  /// Título principal
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 28 / 22,
    color: AppColors.primaryBlue,
  );

  /// ítulo secundario
  static const TextStyle heading2 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    color: AppColors.primaryBlue,
  );

  /// Etiqueta de campo o titulo terciario
  static const TextStyle heading3 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 22 / 16,
    color: AppColors.carbonBlack,
  );

  /// Cuerpo de texto general
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 22 / 16,
    color: AppColors.carbonBlack,
  );

  /// Cuerpo de texto secundario
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 22 / 15,
    color: AppColors.textSteel,
  );

  /// Texto compacto: hints y pequeñas etiquetas
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    color: AppColors.textSteel,
  );

  /// Texto de botones
  static const TextStyle button = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 20 / 16,
    color: AppColors.carbonBlack,
  );

  /// Texto para etiquetas (secundario)
  static const TextStyle label = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.secondarySteel,
  );

  /// Texto de información adicional
  static const TextStyle caption = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.secondarySteel,
  );

  /// Texto para etiquetas de navegación (NavBar, TabBar)
  static const TextStyle navLabel = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    color: AppColors.secondarySteel,
  );
}
