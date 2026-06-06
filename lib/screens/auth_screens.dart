import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // To access AuthWrapper

// A screen widget representing the login interface of the application.
// This exists to allow registered users to authenticate using email and password.
// Returns: A LoginScreen widget.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  // Creates the mutable state for this widget in the widget tree.
  // Returns: An instance of _LoginScreenState.
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// The mutable state class for LoginScreen.
// It manages input controllers, the loading state, and the login logic.
class _LoginScreenState extends State<LoginScreen> {
  // Controller to capture and manage user input for the email text field.
  final _emailController = TextEditingController();
  
  // Controller to capture and manage user input for the password text field.
  final _passwordController = TextEditingController();
  
  // Flag indicating whether the login operation is currently in progress.
  bool _isLoading = false;

  // Handles the login logic when the user submits the form.
  // It validates input, signs in via Firebase, and navigates to the AuthWrapper.
  // Modifies: _isLoading state variable.
  // Returns: Future<void> representing the asynchronous operation.
  void _login() async {
    // Return early if any field is empty to prevent invalid requests
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    
    // Set loading to true to show progress indicator and disable interaction
    setState(() => _isLoading = true);
    try {
      // Attempt login with Firebase Authentication using email and password
      UserCredential cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Check if user has verified their email address
      if (cred.user != null && !cred.user!.emailVerified) {
        // Sign out user since email is not verified
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        
        // Show message requesting verification first
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please verify your email first"),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      
      if (!mounted) return;
      
      // Navigate to AuthWrapper and clear the navigation stack upon success
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    } catch (e) {
      // Show snackbar containing the error message to the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent));
    } finally {
      // Ensure state is updated only if the widget is still in the tree
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Builds the UI elements for the login screen.
  // It handles layout, text fields, error notifications, buttons, and navigation options.
  // Returns: A Scaffold widget configured with inputs, a login button, and a transition to register.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3142)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               // Shared logo transition between welcome/auth screens
               Hero(
                  tag: 'app_logo',
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset('assets/logo.png', height: 100),
                    )
                  ),
               ),
              const SizedBox(height: 32),
              Text("Welcome Back", textAlign: TextAlign.center, style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFF2D3142))),
              const SizedBox(height: 40),
              // Email input field for authentication credentials
              _buildTextField(controller: _emailController, label: "Email", icon: Icons.email_outlined),
              const SizedBox(height: 20),
              // Password input field (obscured text) for security
              _buildTextField(controller: _passwordController, label: "Password", icon: Icons.lock_outline, obscureText: true),
              const SizedBox(height: 48),
              // Conditional UI display based on loading state
              if (_isLoading) const Center(child: CircularProgressIndicator(color: Color(0xFFFFA559)))
              else ElevatedButton(
                onPressed: _login,
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
              const SizedBox(height: 24),
              // Row providing a link to register a new account instead of logging in
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: Colors.black54, fontSize: 16)),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text("Create Account", style: TextStyle(color: Color(0xFFFFA559), fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable helper method to build standardized styled input text fields.
  // Returns: A TextField widget wrapped with custom InputDecoration borders and styling.
  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFFA559))),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}

// A screen widget representing the registration interface of the application.
// This exists to allow new users to create an account with a display name, email, and password.
// Returns: A RegisterScreen widget.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  // Creates the mutable state for this registration widget.
  // Returns: An instance of _RegisterScreenState.
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// The mutable state class for RegisterScreen.
// It manages input controllers, registration validation, and account creation logic.
class _RegisterScreenState extends State<RegisterScreen> {
  // Controller to capture and manage user input for the full name text field.
  final _nameController = TextEditingController();
  
  // Controller to capture and manage user input for the email text field.
  final _emailController = TextEditingController();
  
  // Controller to capture and manage user input for the password text field.
  final _passwordController = TextEditingController();
  
  // Controller to capture and manage user input for password confirmation.
  final _confirmController = TextEditingController();
  
  // Flag indicating whether the account registration process is currently running.
  bool _isLoading = false;

  // Handles the registration logic when the user submits the registration form.
  // It validates matches, creates the user in Firebase Auth, updates their name, and navigates.
  // Modifies: _isLoading state variable.
  // Returns: Future<void> representing the asynchronous operation.
  void _register() async {
    // Return early if any required field is empty
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) return;
    
    // Ensure password matches the confirmation password before initiating registration
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match"), backgroundColor: Colors.redAccent));
      return;
    }
    
    // Set loading status to true to show progress indicator
    setState(() => _isLoading = true);
    try {
      // Create user credentials using Firebase authentication API
      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Update display name for the newly created user profile
      await cred.user?.updateDisplayName(_nameController.text.trim());
      
      // Send verification email to the user
      await cred.user?.sendEmailVerification();
      
      // Sign out the user immediately after registration
      await FirebaseAuth.instance.signOut();
      
      if (!mounted) return;
      
      // Show confirmation SnackBar to check email
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please check your email to verify your account"),
        ),
      );
      
      // Navigate to AuthWrapper, resetting the navigation history
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    } catch (e) {
      // Display error message if the registration operation fails
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent));
    } finally {
      // Clean up and update loading status if the widget remains active
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Builds the UI layout for the registration page.
  // It handles input alignment, buttons, error messages, and link back to login screen.
  // Returns: A Scaffold widget containing text fields for account setup.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3142)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               // App logo for branding consistency
               Hero(
                  tag: 'app_logo',
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset('assets/logo.png', height: 100),
                    )
                  ),
               ),
              const SizedBox(height: 24),
              Text("Create Account", textAlign: TextAlign.center, style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFF2D3142))),
              const SizedBox(height: 32),
              // Field to capture the user's personal display name
              _buildTextField(controller: _nameController, label: "Full Name", icon: Icons.person_outline),
              const SizedBox(height: 16),
              // Field to capture the user's primary contact email address
              _buildTextField(controller: _emailController, label: "Email", icon: Icons.email_outlined),
              const SizedBox(height: 16),
              // Secure password input field
              _buildTextField(controller: _passwordController, label: "Password", icon: Icons.lock_outline, obscureText: true),
              const SizedBox(height: 16),
              // Confirm password field to prevent typos in registration
              _buildTextField(controller: _confirmController, label: "Confirm Password", icon: Icons.lock_outline, obscureText: true),
              const SizedBox(height: 48),
              // Show circular loading indicator when performing the network operation
              if (_isLoading) const Center(child: CircularProgressIndicator(color: Color(0xFFFFA559)))
              else ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA559),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 4,
                  shadowColor: const Color(0xFFFFA559).withOpacity(0.5),
                ),
                child: const Text("Register", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              // Redirect option back to login page if user already possesses an account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ", style: TextStyle(color: Colors.black54, fontSize: 16)),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: const Text("Login", style: TextStyle(color: Color(0xFFFFA559), fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable helper method to build styled text inputs inside the registration screen state.
  // Returns: A custom-styled TextField.
  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFFA559))),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}
