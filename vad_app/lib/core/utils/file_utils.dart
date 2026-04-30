import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Utilidades para validación y procesamiento de archivos
/// antes de subirlos a Supabase Storage.

class FileUtils {
  static const int maxSizeBytes = 2 * 1024 * 1024;

  /// Tamaño máximo permitido: 2MB
  static const int targetSizeBytes = 1 * 1024 * 1024;

  /// Umbral de compresión: imágenes mayores de 1MB se comprimen

  /// Bucket de Supabase Storage donde se almacenan todos los archivos.
  /// Centralizado aquí para que un cambio de bucket no requiera
  /// modificar múltiples archivos.
  static const String bucket = 'archive';

  /// Valida el archivo y comprime al archivo, tras comprobar el tipo
  /// Comportamiento: PDF valida si no supera 2MB, no comprime
  /// JPG/PNG comprime al 80% si supera 1MB, luego prueba al 60% rechaza si tras comprimir sigue fuera de rango
  /// Otros archivos: no soportados, se rechazan.
  /// Devuelve los bytes procesados o null si hay error/rechazo.
  static Future<Uint8List?> processFile({
    required Uint8List bytes,
    required String extension,
    required BuildContext context,
  }) async {
    final ext = extension.toLowerCase();

    // PDF: solo validar tamaño, no se puede comprimir
    if (ext == 'pdf') {
      if (bytes.length > maxSizeBytes) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El PDF supera los 2MB')),
          );
        }
        return null;
      }
      return bytes;
    }

    // Imagen: comprimir si supera 1MB, rechazar si tras comprimir sigue >2MB
    if (['jpg', 'jpeg', 'png'].contains(ext)) {
      // Si ya es pequeña, devolverla tal cual
      if (bytes.length <= targetSizeBytes) return bytes;

      // Intentar comprimir
      final compressed = await _compressImage(bytes: bytes, extension: ext);

      if (compressed == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo procesar la imagen')),
          );
        }
        return null;
      }

      // Si tras comprimir sigue siendo muy grande, rechazar
      if (compressed.length > maxSizeBytes) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La imagen es demasiado grande incluso comprimida'),
            ),
          );
        }
        return null;
      }

      // Informar al usuario si se comprimió
      if (bytes.length > targetSizeBytes && context.mounted) {
        final originalKb = (bytes.length / 1024).round();
        final compressedKb = (compressed.length / 1024).round();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Imagen comprimida: ${originalKb}KB → ${compressedKb}KB',
            ),
          ),
        );
      }

      return compressed;
    }

    // Tipo no soportado
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formato de archivo no soportado')),
      );
    }
    return null;
  }

  /// Comprime la imagen reduciendo calidad progresivamente
  static Future<Uint8List?> _compressImage({
    required Uint8List bytes,
    required String extension,
  }) async {
    final format = extension == 'png'
        ? CompressFormat.png
        : CompressFormat.jpeg;

    // Intentamos con compresión al 80% primero
    var result = await FlutterImageCompress.compressWithList(
      bytes,
      quality: 80,
      format: format,
    );

    // Si sigue grande, comprimimos al 60%
    if (result.length > maxSizeBytes) {
      result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: 60,
        format: format,
      );
    }

    return result;
  }
}
