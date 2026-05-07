import 'dart:typed_data';
import 'package:image/image.dart' as img;

// Utilidades para validación y procesamiento de archivos
// antes de subirlos a Supabase Storage.

/// Resultado del procesamiento de un archivo.
class FileProcessResult {
  final Uint8List? bytes;
  final String? errorMessage;
  final bool wasCompressed;
  final int originalKb;
  final int processedKb;

  const FileProcessResult({
    this.bytes,
    this.errorMessage,
    this.wasCompressed = false,
    this.originalKb = 0,
    this.processedKb = 0,
  });

  bool get isSuccess => bytes != null;
}

class FileUtils {
  // Tamaño máximo permitido: 2MB
  static const int maxSizeBytes = 2 * 1024 * 1024;

  // Umbral de compresión: imágenes mayores de 1MB se comprimen
  static const int targetSizeBytes = 1 * 1024 * 1024;

  /// Bucket de Supabase Storage donde se almacenan todos los archivos.
  static const String bucket = 'archive';

  /// Valida y comprime el archivo si es necesario.
  static Future<FileProcessResult> processFile({
    required Uint8List bytes,
    required String extension,
  }) async {
    try {
      // Si es imagen, comprimir
      if (['jpg', 'jpeg', 'png'].contains(extension.toLowerCase())) {
        final decodedImage = img.decodeImage(bytes);
        if (decodedImage == null) {
          return FileProcessResult(errorMessage: "Error al decodificar");
        }

        final compressed = img.encodeJpg(decodedImage, quality: 80);
        return FileProcessResult(bytes: Uint8List.fromList(compressed));
      }
      // Si es PDF u otro, devolver tal cual
      return FileProcessResult(bytes: bytes);
    } catch (e) {
      return FileProcessResult(errorMessage: e.toString());
    }
  }
}
