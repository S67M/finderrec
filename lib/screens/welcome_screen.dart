import 'package:flutter/material.dart';
import 'auth_screens.dart';

// A stateless screen widget representing the initial welcome/onboarding view.
// This exists as the landing page for unauthenticated users, offering buttons to log in or register.
// Returns: A WelcomeScreen widget.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  
  // Builds the UI layout structure for the welcome page.
  // Returns: A Scaffold layout containing branding logo, text descriptions, and access buttons.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               // Shared logo with hero animations for smooth transitions
               Hero(
                  tag: 'app_logo',
                  child: Center(
                    child: Image.asset('assets/logo.png', height: 160),
                  ),
               ),
               const SizedBox(height: 48),
               const Text(
                 "Recipe Finder",
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   fontSize: 32,
                   fontWeight: FontWeight.bold,
                   color: Color(0xFF2D3142)
                 )
               ),
               const SizedBox(height: 16),
               const Text(
                 "Discover, Cook, and Enjoy!",
                 textAlign: TextAlign.center,
                 style: TextStyle(fontSize: 16, color: Colors.black54)
               ),
               const SizedBox(height: 60),
               // Access button triggering redirection to LoginScreen
               ElevatedButton(
                 onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: const Color(0xFFFFA559),
                   foregroundColor: Colors.white,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                   padding: const EdgeInsets.symmetric(vertical: 18),
                   elevation: 4,
                   shadowColor: const Color(0xFFFFA559).withOpacity(0.5),
                 ),
                 child: const Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               ),
               const SizedBox(height: 20),
               // Access button triggering redirection to RegisterScreen
               OutlinedButton(
                 onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                 style: OutlinedButton.styleFrom(
                   foregroundColor: const Color(0xFFFFA559),
                   side: const BorderSide(color: Color(0xFFFFA559), width: 2),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                   padding: const EdgeInsets.symmetric(vertical: 18),
                 ),
                 child: const Text("Create Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               )
            ],
          )
        )
      )
    );
  }
}