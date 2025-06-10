// pages/login_page.dart (Landing Page)
import 'package:autofix_car/pages/forgot_password_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';
import '../widgets/dashboard_header.dart';
import 'main_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './register_page.dart';
import './home_page.dart';
import '../services/auth_service.dart'; // Adjust path
import '../services/token_manager.dart'; // Adjust path

// Base URL for your Node.js backend.
// const String kBaseUrl = 'http://localhost:3000';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  // bool _isRegistering = false; // For the register button
  bool _isLoggingIn = false; // For the login button

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _registerRedirect() {
    // Navigate to main app with navbar
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  bool _isRegistering = false;
  //  bool _isLoggingIn = false;
  String _authMessage = ''; // Message to display to the user
  String? _displayEmail; // For displaying logged-in user info (optional)
  String? _displayUid; // For displaying logged-in user info (optional)

  @override
  void initState() {
    super.initState();
    // Check login status when the page initializes
    _checkLoginStatus();
  }

  // Checks if a user is already logged in (has tokens saved)
  Future<void> _checkLoginStatus() async {
    final bool loggedIn = await TokenManager.isLoggedIn();
    if (loggedIn) {
      final email = await TokenManager.getEmail();
      final uid = await TokenManager.getUid();
      setState(() {
        _displayEmail = email;
        _displayUid = uid;
        _authMessage = 'Already logged in as $_displayEmail.';
      });
      // If already logged in, navigate directly to LandingPage
      if (mounted) {
        // Check if the widget is still in the tree
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    } else {
      setState(() {
        _authMessage = 'Please login or register.';
      });
    }
  }

  // Handles the login process by calling the backend
  Future<void> _handleLogin() async {
    setState(() {
      _isLoggingIn = true;
      _authMessage = ''; // Clear previous messages
    });

    try {
      final Map<String, dynamic>? result = await loginUserViaBackend(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Check if login was successful and tokens were received
      if (result != null && result.containsKey('idToken')) {
        setState(() {
          _displayEmail = result['email'];
          _displayUid = result['uid'];
          _authMessage = 'Logged in successfully as ${_displayEmail}!';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Welcome, ${_displayEmail}!')));
        // Navigate to your main app screen (e.g., LandingPage)
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
        }
      } else {
        setState(() {
          _authMessage = 'Login failed: No tokens received.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please try again.')),
        );
      }
    } on Exception catch (e) {
      // Catch exceptions thrown by loginUserViaBackend (e.g., from backend error messages)
      setState(() {
        _authMessage =
            'Login Error: ${e.toString().replaceFirst('Exception: ', '')}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login Error: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } catch (e) {
      // Catch any other unexpected errors
      setState(() {
        _authMessage = 'An unexpected error occurred: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An unexpected error occurred.')));
    } finally {
      setState(() {
        _isLoggingIn = false; // Stop loading, regardless of success or failure
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      body: SafeArea(
        child: Column(
          children: [
            // Dashboard Header
            const DashboardHeader(),

            // Login Form
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),

                      // Title
                      Center(
                        child: Text(
                          'AutoFix car',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Your next service is just a tap away.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // email Number Field
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'email Number',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        onTogglePassword: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 8),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Forget Password?',
                            style: TextStyle(
                              color: Color(0xFF3182CE),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                              _isLoggingIn // Disable button while logging in
                              ? null
                              : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF3182CE,
                            ), // Or a different color for login
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child:
                              _isLoggingIn // Conditional child based on loading state
                              ? const SizedBox(
                                  width: 24, // Adjust size for your button
                                  height: 24, // Adjust size for your button
                                  child: CircularProgressIndicator(
                                    color:
                                        Colors.white, // Match button text color
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Divider
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or login with',
                              style: TextStyle(
                                color: Color(0xFF718096),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Social Login Buttons
                      SocialLoginButton(
                        icon: 'assets/google_icon.png',
                        text: 'login with Google',
                        onPressed: _registerRedirect,
                      ),
                      const SizedBox(height: 12),
                      SocialLoginButton(
                        icon: 'assets/apple_icon.png',
                        text: 'login with Apple',
                        onPressed: _registerRedirect,
                      ),
                      const SizedBox(height: 32),

                      // Register Link
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Do you have an account? ',
                            style: const TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 14,
                            ),
                            children: [
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    // Handle register - for now, just login
                                    _registerRedirect();
                                  },
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(
                                      color: Color(0xFF3182CE),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom + 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
