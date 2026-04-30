import 'package:flutter/material.dart';

/// Paleta de colores centralizada de la aplicación.
/// Los widgets usan estos valores en lugar de códigos
/// hexadecimales directos. Así los cambios de color
/// se generan automáticamente en toda la app.

class AppColors {
  AppColors._(); // Clase de constantes, no instanciable

  // Colores principales
  static const Color primaryBlue = Color(0xFF0047AB); // Azul corporativo.
  static const Color actionOrange = Color(0xFFFF8C00); // Naranja de acción
  static const Color carbonBlack = Color(0xFF1A1A1A);
  static const Color cloudWhite = Color(0xFFF4F7F6);
  static const Color screenBg = Color(0xFFEAEAEA);

  // Colores para texto y elementos secundarios
  static const Color textSteel = Color(0xFF4A4A4A);
  static const Color secondarySteel = Color(0xFF708090);

  // Color de error y advertencia
  static const Color errorRed = Color(0xFFD32F2F);

  // Color para tarjetas y contenedores
  static const Color cardWhite = Color(0xFFFFFFFF);
}
