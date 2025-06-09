// pages/register_page.dart (Register Page)
import 'package:autofix_car/pages/forgot_password_page.dart';
import 'package:autofix_car/pages/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Keep if used elsewhere, not directly used in this snippet's logic
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';
import '../widgets/dashboard_header.dart';
import './login_page.dart'; // Import LoginPage for redirection
import '../services/auth_service.dart'; // Import your authentication service

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String _authMessage = ''; // To display messages to the user (e.g., success, error)
  bool _isRegistering = false; // Directly use this for loading state

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Redirects to the LoginPage
  void _loginRedirect() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

    void _loginHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // Handles the registration process by calling the backend
  Future<void> _handleRegister() async {
    setState(() {
      _isRegistering = true; // Set loading state to true
      _authMessage = ''; // Clear previous messages
    });

    try {
      final Map<String, dynamic>? result = await registerUserViaBackend(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (result != null && result.containsKey('uid')) {
        setState(() {
          _authMessage = 'Registration successful for ${result['email']}! Now you can log in.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registered: ${result['email']}! Now try logging in.')),
        );
        // After successful registration, you might want to redirect to the login page
           Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigation()),
    );
      } else {
        setState(() {
          _authMessage = 'Registration failed: User not created.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. Please try again.')),
        );
      }
    } on Exception catch (e) {
      setState(() {
        _authMessage = 'Registration Error: ${e.toString().replaceFirst('Exception: ', '')}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Error: ${e.toString().replaceFirst('Exception: ', '')}')),
      );
    } catch (e) {
      setState(() {
        _authMessage = 'An unexpected error occurred during registration: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred during registration.')),
      );
    } finally {
      setState(() {
        _isRegistering = false; // Stop loading, regardless of success or failure
      });
    }
  }

  // Handles redirection to the ForgotPasswordPage
  void _handleForgot() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      body: SafeArea(
        child: Column(
          children: [
            // Dashboard Header (Assumed custom widget)
            const DashboardHeader(),

            // Registration Form Section
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

                      // App Title
                      const Center(
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
                      // Tagline
                      const Center(
                        child: Text(
                          'Your next service is just a tap away.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Email Input Field
                      CustomTextField( // Assumed custom widget
                        controller: _emailController,
                        hintText: 'Email Address', // Changed hint text for clarity
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Password Input Field
                      CustomTextField( // Assumed custom widget
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

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgot,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF3182CE),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isRegistering // Use _isRegistering directly
                              ? null
                              : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3182CE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isRegistering // Use _isRegistering for loading indicator
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Divider for Social Login
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or register with', // Changed text to reflect "register" context
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

                      // Social Login Buttons (These will redirect to login page)
                      SocialLoginButton( // Assumed custom widget
                        icon: 'assets/google_icon.png',
                        text: 'Register with Google', // Changed text for clarity
                        onPressed: _loginHome, // Still redirects to login
                      ),
                      const SizedBox(height: 12),
                      SocialLoginButton( // Assumed custom widget
                        icon: 'assets/apple_icon.png',
                        text: 'Register with Apple', // Changed text for clarity
                        onPressed: _loginRedirect, // Still redirects to login
                      ),
                      const SizedBox(height: 32),

                      // Login Link (Corrected text)
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ', // Corrected introductory text
                            style: const TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 14,
                            ),
                            children: [
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    _loginRedirect(); // Navigates to LoginPage
                                  },
                                  child: const Text(
                                    'Login', // Corrected actionable text
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
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
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
