import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F3),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 16),
            // Avatar
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
            // Email
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
            // Logout tile
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
