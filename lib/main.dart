import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/db_service.dart';

// Since the user has `firebase_options.dart` we import it here if it exists.
// We fallback to standard explicit approach if we don't have it defined perfectly.
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase using the generated options for the platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Seed initial recipes if the database is empty
  await DBService().seedInitialRecipes();

  runApp(const RecipeApp());
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe Finder',
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        primaryColor: const Color(0xFFFFA559),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFA559)),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFFDFBF7),
            body: Center(child: CircularProgressIndicator(color: Color(0xFFFFA559))),
          );
        }
        
        // If the user is authenticated, direct them to HomeScreen
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        
        // Otherwise, direct them to WelcomeScreen
        return const WelcomeScreen();
      },
    );
  }
}