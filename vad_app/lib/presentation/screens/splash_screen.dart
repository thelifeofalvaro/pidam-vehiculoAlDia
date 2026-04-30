import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Pantalla de carga inicial. Comprueba la sesión y redirige.
///
/// Flujo:
/// 1. Espera 1 segundo (por si quisieramos poner el logo de la app o algo para indicar carga)
/// 2. Comprueba supabase.auth.currentUser
/// 3. Si hay sesión activa → /home
/// 4. Si no hay sesión → /login

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkSession();
  }

  /// Comprobar sesión inciada
  void checkSession() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      // Si logueado → Home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // No logueado → Login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
