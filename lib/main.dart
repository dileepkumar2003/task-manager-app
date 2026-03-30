import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'notifications.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initNotification();

  runApp(const TaskApp());
}

class TaskApp extends StatefulWidget {
  const TaskApp({super.key});

  @override
  State<TaskApp> createState() => _TaskAppState();
}

class _TaskAppState extends State<TaskApp> {
  bool isDark = true;

  // ✅ FIXED: Matches VoidCallback signature
  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor:
        isDark ? const Color(0xFF0F172A) : Colors.white,
      ),

      // 🔥 AUTO LOGIN SYSTEM
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 🔄 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ✅ User Logged In
          if (snapshot.hasData) {
            return HomeScreen(
              toggleTheme: toggleTheme,
              isDark: isDark, // ✅ Pass current theme state
            );
          }

          // ❌ Not Logged In
          return const LoginScreen();
        },
      ),

      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return null;
      },
    );
  }
}
