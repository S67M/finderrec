import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/db_service.dart';

// Since the user has `firebase_options.dart` we import it here if it exists.
// We fallback to standard explicit approach if we don't have it defined perfectly.
import 'firebase_options.dart';

// The main entry point of the Flutter application.
// This function initializes Flutter bindings, connects to Firebase, 
// seeds the database with initial recipe data if empty, and runs the application.
// Returns: Future<void> as it performs asynchronous setup.
void main() async {
  // Ensure that widget binding is initialized before interacting with native code/Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase using the generated options for the platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Seed initial recipes if the database is empty
  await DBService().seedInitialRecipes();

  // Run the root widget of the application
  runApp(const RecipeApp());
}

// The root widget of the recipe application.
// This class sets up global application configurations like themes, routing, and titles.
// It exists to provide the MaterialApp context and configure global styling using Google Fonts.
class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  // Builds the MaterialApp widget, defining the theme, app title, and starting screen.
  // Returns: A MaterialApp widget configured with custom theme colors and AuthWrapper as the home screen.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe Finder',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF8F3),
        primaryColor: const Color(0xFFF4631E),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF4631E)),
        textTheme: GoogleFonts.dmSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// A widget that manages and listens to the user's authentication state.
// This class determines whether to direct the user to the HomeScreen or the WelcomeScreen
// based on whether a user session is active.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // Listens to the Firebase authStateChanges stream and builds the appropriate screen dynamically.
  // Returns: A Scaffold with a CircularProgressIndicator when loading, a HomeScreen if authenticated,
  // or a WelcomeScreen if the user is unauthenticated.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to authentication state changes from Firebase Auth
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a loading indicator while the authentication state is being resolved
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