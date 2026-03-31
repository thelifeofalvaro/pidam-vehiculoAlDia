/// Pantalla para comprobar el estado de la aplicación y redirigir al usuario a la pantalla de inicio o a la pantalla de inicio de sesión según corresponda.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    await Future.delayed(const Duration(seconds: 1)); // opcional (mejor UX)

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
