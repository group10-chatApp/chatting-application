import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔹 Hii ndio muhimu
import 'auth_service.dart';
import 'users_screen.dart'; // 🔹 Navigate here after login/register

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isLogin = true;
  bool loading = false;

  // 🔹 Toggle between login and register
  void toggleMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  // 🔹 Authentication
  Future<void> authenticate() async {
    setState(() {
      loading = true;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    User? user;

    try {
      user = isLogin
          ? await _authService.login(email, password)
          : await _authService.register(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    // 🔹 Navigate if login/register successful
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UsersScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isLogin
              ? "Login failed. Check your credentials."
              : "Registration failed. Try again."),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLogin ? "Login" : "Register",
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 20),
                  loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            backgroundColor: Colors.teal,
                          ),
                          onPressed: authenticate,
                          child: SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                isLogin ? "Login" : "Register",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: toggleMode,
                    child: Text(
                      isLogin
                          ? "Don't have an account? Register"
                          : "Already have an account? Login",
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
