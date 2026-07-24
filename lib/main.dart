import 'package:finance_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  static _MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  bool isDbReady = false;
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    setupApp();
  }

  Future<void> setupApp() async {
    await dbHelper.createDatabase();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    darkMode = prefs.getBool('darkModeEnabled') ?? false;

    setState(() {
      isDbReady = true;
    });
  }

  Future<void> changeTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('darkModeEnabled', value);

    setState(() {
      darkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isDbReady) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance App',

      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
        ),
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),

      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,

      home: const SplashScreen(),
    );
  }
}