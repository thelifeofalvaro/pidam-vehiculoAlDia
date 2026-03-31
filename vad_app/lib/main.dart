import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'presentation/screens/inicio.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vfyfzbhwpnwmsloqmmdd.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmeWZ6Ymh3cG53bXNsb3FtbWRkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI0NTcxMTUsImV4cCI6MjA4ODAzMzExNX0.o7pGAc4FW3q3Yt_6I2Pq1D_y9_EcoGOBjVGy8Eu2PMU',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
