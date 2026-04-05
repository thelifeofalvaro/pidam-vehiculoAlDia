import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vad_app/features/profile/screens/profile_screen.dart';
import 'package:vad_app/features/vehicles/screens/vehicle_list_screen.dart';
import 'package:vad_app/features/vehicles/screens/vehicle_manage_screen.dart';
import 'package:vad_app/features/vehicles/screens/vehicle_detail_screen.dart';
import 'package:vad_app/data/models/vehicle_model.dart';
import 'package:vad_app/features/interventions/screens/intervention_list_screen.dart';
import 'package:vad_app/features/interventions/screens/intervention_manage_screen.dart';

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

  //PARA PRODUCCIÓN, DESCOMENTAR Y CONFIGURAR LAS VARIABLES DE ENTORNO EN EL ARCHIVO .env
  //await Supabase.initialize(
  //  url: const String.fromEnvironment('SUPABASE_URL'),
  //  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  // );

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
        '/vehicles': (context) => const VehicleListScreen(),
        '/vehicle-manage': (context) => const VehicleManageScreen(),
        '/vehicle-detail': (context) => const VehicleDetailScreen(),
        '/intervention-list': (context) {
          final vehicle = ModalRoute.of(context)!.settings.arguments as Vehicle;
          return InterventionListScreen(vehicle: vehicle);
        },
        '/intervention-manage': (context) => const InterventionManageScreen(),
        '/profile': (context) => const ProfileScreen(),
      },

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('es'), // español
      ],
    );
  }
}
