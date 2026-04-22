class ErrorUtils {
  ErrorUtils._();

  /// [contexto] describe la acción que falló, ej: 'guardar el vehículo'
  /// El mensaje final combina el contexto con la causa técnica detectada
  static String mensajeLegible(Object e, {String? contexto}) {
    final msg = e.toString().toLowerCase();
    final accion = contexto != null ? 'Error al $contexto' : 'Algo salió mal';

    // Sin conexión
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

    // Sesión expirada
    if (msg.contains('jwt') ||
        msg.contains('unauthorized') ||
        msg.contains('401') ||
        msg.contains('not authenticated') ||
        msg.contains('invalid token')) {
      return 'Tu sesión ha expirado. Vuelve a iniciar sesión.';
    }

    // Servidor caído / Supabase pausado
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

    // Genérico con contexto
    return '$accion. Inténtalo de nuevo.';
  }
}
