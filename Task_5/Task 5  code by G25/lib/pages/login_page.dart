// pages/login_page.dart (Landing Page)
import 'package:autofix_car/pages/forgot_password_page.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';
import '../widgets/dashboard_header.dart';
import 'main_navigation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // Navigate to main app with navbar
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigation()),
    );
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
                      
                      // Phone Number Field
                      CustomTextField(
                        controller: _phoneController,
                        hintText: 'Phone Number',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
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
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
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
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3182CE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
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
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: 12),
                      SocialLoginButton(
                        icon: 'assets/apple_icon.png',
                        text: 'login with Apple',
                        onPressed: _handleLogin,
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
                                    _handleLogin();
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