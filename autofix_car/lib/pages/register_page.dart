// pages/register_page.dart (Register Page)
import 'package:autofix_car/services/token_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:autofix_car/pages/forgot_password_page.dart';
import 'package:autofix_car/pages/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Keep if used elsewhere, not directly used in this snippet's logic
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';
import '../widgets/dashboard_header.dart';
import './login_page.dart'; // Import LoginPage for redirection
import '../services/auth_service.dart'; // Import your authentication service
import './userForm_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
 final _emailController = TextEditingController();
 final _passwordController = TextEditingController();
 final _firebaseAuth = FirebaseAuth.instance;

 bool _isPasswordVisible = false;
 bool _isRegistering = false;
 String _authMessage = '';
 String? _emailErrorText;
 String? _passwordErrorText;

 @override
 void dispose() {
   _emailController.dispose();
   _passwordController.dispose();
   super.dispose();
 }

 void _loginRedirect() {
   Navigator.pushReplacement(
     context,
     MaterialPageRoute(builder: (context) => const LoginPage()),
   );
 }

 Future<void> _validateAndRegister() async {
   setState(() {
     _emailErrorText = null;
     _passwordErrorText = null;
     _authMessage = '';
   });

   bool isValid = true;
   if (_emailController.text.trim().isEmpty) {
     setState(() => _emailErrorText = 'Email cannot be empty');
     isValid = false;
   } else if (!_emailController.text.contains('@')) {
     setState(() => _emailErrorText = 'Please enter a valid email');
     isValid = false;
   }

   if (_passwordController.text.trim().isEmpty) {
     setState(() => _passwordErrorText = 'Password cannot be empty');
     isValid = false;
   } else if (_passwordController.text.length < 6) {
     setState(
         () => _passwordErrorText = 'Password must be at least 6 characters');
     isValid = false;
   }

   if (isValid) {
     await _handleRegister();
   } else {
     _showSnackBar('Please correct the errors in the form.', Colors.red);
   }
 }

 Future<void> _handleRegister() async {
   setState(() => _isRegistering = true);
   try {
     final result = await registerUserViaBackend(
       _emailController.text.trim(),
       _passwordController.text.trim(),
     );
     _handleAuthSuccess(
         'Registration successful for ${result['email']}! Please log in.');
   } catch (e) {
     _handleAuthError(e.toString());
   } finally {
     if (mounted) {
       setState(() => _isRegistering = false);
     }
   }
 }

 Future<void> _signInWithGoogle() async {
   setState(() => _isRegistering = true);
   try {
     final googleProvider = GoogleAuthProvider();
     final userCredential = await _firebaseAuth.signInWithPopup(googleProvider);

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

     _handleAuthSuccess(
       'Signed in with Google successfully!',
       navigateToMain: true,
     );
   } on FirebaseAuthException catch (e) {
     _handleAuthError(e.message ?? 'An unknown Firebase error occurred.');
   } catch (e) {
     _handleAuthError(e.toString());
   } finally {
     if (mounted) {
       setState(() => _isRegistering = false);
     }
   }
 }

 void _handleAuthSuccess(String message, {bool navigateToMain = false}) {
   if (mounted) {
     setState(() => _authMessage = message);
     _showSnackBar(message, Colors.green);
     if (navigateToMain) {
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(builder: (context) => const UserProfileForm()),
       );
     } else {
       _loginRedirect();
     }
   }
 }

 void _handleAuthError(String errorMessage) {
   if (mounted) {
     final finalErrorMessage =
         errorMessage.replaceFirst('Exception: ', '').replaceAll('Exception', '');
     setState(() => _authMessage = 'Error: $finalErrorMessage');
     _showSnackBar('Error: $finalErrorMessage', Colors.red);
   }
 }

 void _showSnackBar(String message, Color color) {
   if (mounted) {
     ScaffoldMessenger.of(context).hideCurrentSnackBar();
     ScaffoldMessenger.of(context)
         .showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
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
                     _buildRegisterForm(),
                     const SizedBox(height: 24),
                     _buildSocialLogin(),
                     const SizedBox(height: 32),
                     _buildLoginLink(),
                     SizedBox(
                         height:
                             MediaQuery.of(context).viewInsets.bottom + 20),
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
           'Create Account',
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
           'Start your journey with AutoFix.',
           style: TextStyle(
             fontSize: 16,
             color: Color(0xFF718096),
           ),
         ),
       ),
     ],
   );
 }

 Widget _buildRegisterForm() {
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
       const SizedBox(height: 24),
       SizedBox(
         width: double.infinity,
         height: 56,
         child: ElevatedButton(
           onPressed: _isRegistering ? null : _validateAndRegister,
           style: ElevatedButton.styleFrom(
             backgroundColor: const Color(0xFF3182CE),
             shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(12)),
             elevation: 0,
           ),
           child: _isRegistering
               ? const CircularProgressIndicator(
                   color: Colors.white, strokeWidth: 3)
               : const Text('Register',
                   style: TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.w600,
                       color: Colors.white)),
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
             child: Text('or register with',
                 style: TextStyle(color: Color(0xFF718096), fontSize: 14)),
           ),
           Expanded(child: Divider(color: Color(0xFFE2E8F0))),
         ],
       ),
       const SizedBox(height: 20),
       SocialLoginButton(
         icon: 'assets/google_icon.png',
         text: 'Register with Google',
         onPressed: _signInWithGoogle,
       ),
       const SizedBox(height: 12),
       SocialLoginButton(
         icon: 'assets/apple_icon.png',
         text: 'Register with Apple',
         onPressed: () =>
             _showSnackBar('Apple login not yet implemented.', Colors.grey),
       ),
     ],
   );
 }

 Widget _buildLoginLink() {
   return Center(
     child: RichText(
       text: TextSpan(
         text: 'Already have an account? ',
         style: const TextStyle(color: Color(0xFF718096), fontSize: 14),
         children: [
           WidgetSpan(
             child: GestureDetector(
               onTap: _loginRedirect,
               child: const Text(
                 'Login',
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
