import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// A screen widget representing the user's profile and settings tab.
// This exists to display profile credentials and provide log out functions.
// Returns: A ProfileScreen widget.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Handles the sign-out request from Firebase Auth.
  // This exists to end the user session and return them to the WelcomeScreen.
  // Returns: Future<void> representing the asynchronous operation.
  void _logout() async {
    // Triggers firebase sign out operation
    await FirebaseAuth.instance.signOut();
  }

  // Builds the UI layout structure for the profile dashboard.
  // Returns: A Scaffold widget displaying user information and a logout button.
  @override
  Widget build(BuildContext context) {
    // Retrieve the currently logged-in user profile from Firebase
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F3),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 16),
            // Avatar block
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFA559).withOpacity(0.15),
                  border: Border.all(color: const Color(0xFFFFA559), width: 2.5),
                ),
                child: const Icon(Icons.person, size: 48, color: Color(0xFFFFA559)),
              ),
            ),
            const SizedBox(height: 16),
            // Email detail view
            Center(
              child: Text(
                user?.email ?? 'No email',
                style: const TextStyle(fontSize: 16, color: Color(0xFF2D3142), fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 40),
            // Divider section
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 24),
            // Logout button tile trigger
            GestureDetector(
              onTap: _logout,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Color(0xFFFFA559)),
                    SizedBox(width: 16),
                    Text(
                      'Log Out',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                    ),
                    Spacer(),
                    Icon(Icons.chevron_right, color: Colors.black26),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
