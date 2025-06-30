// pages/login_page.dart (Landing Page)
import 'package:autofix_car/pages/forgot_password_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';
import '../widgets/dashboard_header.dart';
import 'main_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Essential for client-side Firebase Auth
import 'package:http/http.dart' as http; // Already imported by AuthService
import 'dart:convert'; // Already imported by AuthService
import './register_page.dart';
import './home_page.dart'; // Is this still needed? Looks like HomePage is not directly navigated to
import '../services/auth_service.dart'; // Contains your backend interaction functions
import '../services/token_manager.dart'; // For saving and retrieving tokens
import "./userForm_page.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isAuthenticating =
      false; // Renamed for broader use (login, Google sign-in)
  String _authMessage = ''; // Message to display to the user

  String? _emailErrorText;
  String? _passwordErrorText;

  String? _displayEmail;
  String? _displayUid;

  // Instance of Firebase Auth for client-side operations (Google Sign-In)
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _registerRedirect() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  // Checks if a user is already logged in (has tokens saved)
  Future<void> _checkLoginStatus() async {
    try {
      final bool loggedIn = await TokenManager.isLoggedIn();
      if (loggedIn) {
        final email = await TokenManager.getEmail();
        final uid = await TokenManager.getUid();
        _handleLoginSuccess(
          email: email,
          uid: uid,
          message: 'Welcome back, $email!',
        );
      } else {
        if (mounted) {
          setState(() {
            _authMessage = 'Please login or register.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _handleLoginError('Could not check login status: $e');
      }
    }
  }

  // Validates input fields and then handles the login process
  Future<void> _validateAndLogin() async {
    setState(() {
      _emailErrorText = null; // Clear previous errors
      _passwordErrorText = null; // Clear previous errors
      _authMessage = ''; // Clear general message
    });

    bool isValid = true;
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailErrorText = 'Email cannot be empty';
      });
      isValid = false;
    } else if (!_emailController.text.trim().contains('@')) {
      setState(() {
        _emailErrorText = 'Please enter a valid email';
      });
      isValid = false;
    }

    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _passwordErrorText = 'Password cannot be empty';
      });
      isValid = false;
    } else if (_passwordController.text.trim().length < 6) {
      setState(() {
        _passwordErrorText = 'Password must be at least 6 characters';
      });
      isValid = false;
    }

    if (!isValid) {
      _showSnackBar('Please correct the errors in the form.', Colors.red);
      return; // Stop if validation fails
    }

    await _handleEmailPasswordLogin(); // Proceed with backend login if validation passes
  }

  // Handles the email/password login process by calling the backend
  Future<void> _handleEmailPasswordLogin() async {
    setState(() {
      _isAuthenticating = true;
      _authMessage = '';
    });

    try {
      final result = await loginUserViaBackend(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (result != null && result.containsKey('idToken')) {
        _handleLoginSuccess(
          email: result['email'],
          uid: result['uid'],
          message: 'Logged in successfully!',
        );
      } else {
        _handleLoginError(
          'Login failed: Invalid credentials or no token received.',
        );
      }
    } catch (e) {
      _handleLoginError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  // Helper to show SnackBar messages
  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
    }
  }

  // Handles the Google Sign-In process on the client and backend
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isAuthenticating = true;
      _authMessage = '';
    });

    try {
      final googleProvider = GoogleAuthProvider();
      final userCredential = await _firebaseAuth.signInWithPopup(
        googleProvider,
      );

      if (userCredential.user == null) {
        throw Exception('Google sign-in failed or was canceled.');
      }

      final idToken = await userCredential.user!.getIdToken();
      if (idToken == null) {
        throw Exception('Could not retrieve ID token from Google.');
      }

      final backendResult = await signInWithGoogleBackend(idToken);
      if (backendResult == null || !backendResult.containsKey('uid')) {
        throw Exception('Backend verification failed for Google sign-in.');
      }

      final refreshToken = userCredential.user?.refreshToken;
      await TokenManager.saveTokens(
        idToken: idToken,
        refreshToken: refreshToken ?? '',
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? 'N/A',
      );

      _handleLoginSuccess(
        email: userCredential.user!.email,
        uid: userCredential.user!.uid,
        message: 'Signed in with Google successfully!',
      );
    } on FirebaseAuthException catch (e) {
      _handleLoginError(e.message ?? 'An unknown Firebase error occurred.');
    } catch (e) {
      _handleLoginError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  void _handleLoginSuccess({
    String? email,
    String? uid,
    required String message,
  }) {
    if (mounted) {
      setState(() {
        _displayEmail = email;
        _displayUid = uid;
        _authMessage = message;
      });
      _showSnackBar(message, Colors.green);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    }
  }

  void _handleLoginError(String errorMessage) {
    if (mounted) {
      final finalErrorMessage = errorMessage
          .replaceFirst('Exception: ', '')
          .replaceAll('Exception', '');
      setState(() {
        _authMessage = 'Error: $finalErrorMessage';
      });
      _showSnackBar('Error: $finalErrorMessage', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      body: SafeArea(
        child: Column(
          children: [
            const DashboardHeader(),
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
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildLoginForm(),
                      const SizedBox(height: 24),
                      _buildSocialLogin(),
                      const SizedBox(height: 32),
                      _buildRegisterLink(),
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

  Widget _buildHeader() {
    return const Column(
      children: [
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
        SizedBox(height: 8),
        Center(
          child: Text(
            'Your next service is just a tap away.',
            style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        CustomTextField(
          controller: _emailController,
          hintText: 'Email Address',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailErrorText,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _passwordController,
          hintText: 'Password',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          isPasswordVisible: _isPasswordVisible,
          onTogglePassword: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
          errorText: _passwordErrorText,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ForgotPasswordPage(),
              ),
            ),
            child: const Text(
              'Forgot Password?',
              style: TextStyle(color: Color(0xFF3182CE), fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isAuthenticating ? null : _validateAndLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3182CE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isAuthenticating
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
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
        if (_authMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Center(
              child: Text(
                _authMessage,
                style: TextStyle(
                  color: _authMessage.contains('Error')
                      ? Colors.red
                      : Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or login with',
                style: TextStyle(color: Color(0xFF718096), fontSize: 14),
              ),
            ),
            Expanded(child: Divider(color: Color(0xFFE2E8F0))),
          ],
        ),
        const SizedBox(height: 20),
        SocialLoginButton(
          icon: 'assets/google_icon.png',
          text: 'Login with Google',
          onPressed: _signInWithGoogle,
        ),
        const SizedBox(height: 12),
        SocialLoginButton(
          icon: 'assets/apple_icon.png',
          text: 'Login with Apple',
          onPressed: () =>
              _showSnackBar('Apple login not yet implemented.', Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Don\'t have an account? ',
          style: const TextStyle(color: Color(0xFF718096), fontSize: 14),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: _registerRedirect,
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
    );
  }
}
