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
import 'package:vad_app/core/app_config.dart';
import 'package:file_picker/file_picker.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'presentation/screens/inicio.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FilePicker.clearTemporaryFiles();

  // Recogemos las credenciales de Supabase desde AppConfig y las inicializamos
  // Ver lib/core/app_config.dart para más detalles
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
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
        '/vehicles': (context) => const VehicleListScreen(),
        '/vehicle-manage': (context) => const VehicleManageScreen(),
        '/vehicle-detail': (context) => const VehicleDetailScreen(),
        // La ruta de la lista de intervenciones recibe un vehículo como argumento obligatorio para mostrar solo sus intervenciones
        '/intervention-list': (context) {
          final vehicle = ModalRoute.of(context)!.settings.arguments as Vehicle;
          return InterventionListScreen(vehicle: vehicle);
        },
        '/intervention-manage': (context) => const InterventionManageScreen(),
        '/profile': (context) => const ProfileScreen(),
      },

      // Configuración de localización para soportar español
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
