// pages/login_page.dart (Landing Page)
import 'package:autofix_car/pages/forgot_password_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';
import '../widgets/dashboard_header.dart';
// import 'main_navigation.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './otp_page.dart';
import './login_page.dart';
// import 'forgot_password_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String _message = ''; // To display messages to the user (e.g., success, error)
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginRedirect() {

        Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );

  }

Future<Map<String, dynamic>?> registerUserViaBackend(String email, String password) async {
  final String kBaseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost';
   final url = Uri.parse('$kBaseUrl/auth/register');
       setState(() {
      _isLoading = true;
      _message = '';
    });

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      // User registered successfully on the backend
          Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OtpPage()),
    );
        setState(() {
      // _isLoading = true;
      _message = 'Backend registration successful: ${response.body}';
    });
      print(_message);
      return json.decode(response.body); // Returns success message, uid, email
    } else {
      // Handle backend errors (e.g., email already in use, validation errors)
      print('Backend registration failed: ${response.statusCode}');
      print(_message);
      final Map<String, dynamic> errorData = json.decode(response.body);
          setState(() {
      // _isLoading = false;
      _message = 'Response body: ${response.body}';
    });
      return {'error': errorData['message'] ?? 'Unknown error during registration'};
    }
  } catch (e) {
    print(_message);
        setState(() {
      // _isLoading = false;
      _message = 'Error during backend registration: $e';
    });
    return {'error': 'Network error or unexpected issue during registration'};
    
  }
}

  void _handleForgot(){
       // Navigate to the Forgot app with link
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
                          onPressed: _handleForgot,
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
    onPressed: _isLoading // Disable button while loading
        ? null
        : () async {
            setState(() {
              _isLoading = true; // Start loading
            });
            try {
              final result = await registerUserViaBackend(
                _phoneController.text,
                _passwordController.text,
              );
              // Handle result here (e.g., show success/error message)
              if (result != null && result.containsKey('uid')) {
                // Registration successful
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Registration successful for ${result['email']}!')),
                );
              } else if (result != null && result.containsKey('error')) {
                // Registration failed with specific error from backend
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Registration failed: ${result['error']}')),
                );
              } else {
                // Generic error
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('An unexpected error occurred.')),
                );
              }
            } catch (e) {
              // Catch any network or other exceptions
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${e.toString()}')),
              );
            } finally {
              setState(() {
                _isLoading = false; // Stop loading, regardless of success or failure
              });
            }
          },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3182CE),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    ),
    child: _isLoading // Conditional child based on loading state
        ? const SizedBox(
            width: 24, // Adjust size for your button
            height: 24, // Adjust size for your button
            child: CircularProgressIndicator(
              color: Colors.white, // Match button text color
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
                        onPressed: _loginRedirect,
                      ),
                      const SizedBox(height: 12),
                      SocialLoginButton(
                        icon: 'assets/apple_icon.png',
                        text: 'login with Apple',
                        onPressed: _loginRedirect,
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
                                    _loginRedirect();
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