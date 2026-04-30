/// Convierte cualquier excepción en un mensaje legible en español.
/// [contexto] describe la operación que falló. Se incluye en el
/// mensaje genérico cuando el error no es reconocible.
/// Ejemplo:
///   ErrorUtils.mensajeLegible(e, contexto: 'guardar el vehículo')
///   → "Error al guardar el vehículo. Inténtalo de nuevo."

class ErrorUtils {
  ErrorUtils._();

  /// El mensaje final  añade la razón que provoca la causa técnica detectada
  static String mensajeLegible(Object e, {String? contexto}) {
    final msg = e.toString().toLowerCase();
    final accion = contexto != null ? 'Error al $contexto' : 'Algo salió mal';

    //  Errores de red: sin conexión o DNS no resuelve
    if (msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection') ||
        msg.contains('failed host lookup') ||
        msg.contains('no route to host')) {
      return 'Sin conexión. Comprueba tu internet e inténtalo de nuevo.';
    }

    // Timeout
    if (msg.contains('timeout') || msg.contains('timed out')) {
      return 'La conexión tardó demasiado. Inténtalo de nuevo.';
    }

    // JWT caducado o usuario no autenticado.
    // Supabase devuelve estos mensajes en los errores 401.
    if (msg.contains('jwt') ||
        msg.contains('unauthorized') ||
        msg.contains('401') ||
        msg.contains('not authenticated') ||
        msg.contains('invalid token')) {
      return 'Tu sesión ha expirado. Vuelve a iniciar sesión.';
    }

    // Servidor no disponible: Supabase pausado (503) o error interno (500)
    if (msg.contains('503') ||
        msg.contains('502') ||
        msg.contains('500') ||
        msg.contains('project is paused') ||
        msg.contains('server error')) {
      return 'El servidor no está disponible. Inténtalo más tarde.';
    }

    // Storage
    if (msg.contains('bucket') || msg.contains('storage')) {
      return 'Error al gestionar el archivo. Inténtalo de nuevo.';
    }

    // Error no reconocido: se incluye el contexto para mayor claridad
    return '$accion. Inténtalo de nuevo.';
  }
}
