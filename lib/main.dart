import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/database/app_database.dart';
import 'providers/book_provider.dart';
import 'providers/patient_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.database;
  runApp(const HiNurseApp());
}

class HiNurseApp extends StatelessWidget {
  const HiNurseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
      ],
      child: MaterialApp(
        title: 'Quick Assesment Med', // NAMA APLIKASI DIUBAH
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF2D3748),
            elevation: 0,
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F9FC),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF2D3748)),
            bodyMedium: TextStyle(color: Color(0xFF2D3748)),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
