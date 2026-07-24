import 'package:finance_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'database/database_helper.dart';
import 'screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DatabaseHelper dbHelper = DatabaseHelper();
  bool isDbReady = false;

  @override
  void initState() {
    super.initState();
    setupApp();
  }

  Future<void> setupApp() async {
    await dbHelper.createDatabase();

    setState(() {
      isDbReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isDbReady == false) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance App',
      theme: ThemeData(
        primaryColor: const Color(0xFF1E88E5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),   // ← always Splash. It decides Login vs Lock vs Home.
    );
  }
}