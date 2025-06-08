import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart'; // Only if you're using Firebase Phone Auth or custom tokens

// Assuming kBaseUrl is defined somewhere accessible, e.g., in main.dart
// You can import it if it's in main.dart:
// import '../main.dart'; // Adjust path as necessary
// Or define it here if this page is standalone for testing
final String kBaseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost';

class OtpPage extends StatefulWidget {
  // If you send an OTP and receive a verification ID (e.g., from Firebase Phone Auth),
  // you would pass it to this page.
  final String? verificationId;
  final String? phoneNumber; // Optional: If OTP is for phone verification

  const OtpPage({Key? key, this.verificationId, this.phoneNumber}) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();
  String _message = ''; // To display messages to the user (e.g., success, error)
  bool _isLoading = false; // To show loading state

  // For Firebase Phone Auth, you might need a FirebaseAuth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  // --- OTP Verification Logic ---
  // This function demonstrates how you would verify the OTP.
  // The actual implementation depends on how you generate and verify OTPs (e.g., Firebase Phone Auth or your Node.js backend).
  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final String otp = _otpController.text.trim();

    if (otp.isEmpty || otp.length != 6) { // Assuming a 6-digit OTP
      setState(() {
        _message = 'Please enter a valid 6-digit OTP.';
        _isLoading = false;
      });
      return;
    }

    try {
      // --- Option 1: Using Firebase Phone Authentication (if you sent the OTP via Firebase) ---
      if (widget.verificationId != null) {
        // Create a PhoneAuthCredential with the code from the user
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId!,
          smsCode: otp,
        );

        // Sign the user in with the credential
        await _auth.signInWithCredential(credential);
        setState(() {
          _message = 'Phone number verified and logged in successfully!';
        });
        // Navigate to the next screen (e.g., home page)
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LandingPage())); // Replace with your actual next page
      }
      // --- Option 2: Verifying OTP via your Node.js backend (if you implemented server-side OTP) ---
      else {
        // This is a conceptual call to your backend, assuming you have an endpoint like /auth/verify-otp
        final url = Uri.parse('$kBaseUrl/auth/verify-otp'); // You would need to add this endpoint to your Node.js backend

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'emailOrPhoneNumber': widget.phoneNumber ?? 'user_email_here', // Or email if for email verification
            'otp': otp,
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            _message = 'OTP verified successfully via backend!';
          });
          // After backend verification, you might get a custom token or ID token to sign in with Firebase client
          // Or navigate the user based on backend's response.
          // Example:
          // final responseData = json.decode(response.body);
          // if (responseData['customToken'] != null) {
          //   await _auth.signInWithCustomToken(responseData['customToken']);
          //   _message = 'Signed in successfully after OTP verification!';
          //   // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LandingPage()));
          // }
        } else {
          setState(() {
            _message = 'OTP verification failed: ${json.decode(response.body)['message'] ?? 'Invalid OTP'}';
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = 'Firebase Auth Error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _message = 'Error verifying OTP: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- OTP Resend Logic ---
  // This function demonstrates how you would resend the OTP.
  // Similar to verification, implementation depends on your OTP sending mechanism.
  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      // --- Option 1: Using Firebase Phone Authentication (if you sent the OTP via Firebase) ---
      if (widget.phoneNumber != null) {
        await _auth.verifyPhoneNumber(
          phoneNumber: widget.phoneNumber!,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-sign in if verification is completed automatically
            await _auth.signInWithCredential(credential);
            setState(() {
              _message = 'Phone verification completed automatically!';
            });
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LandingPage()));
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() {
              _message = 'Phone verification failed: ${e.message}';
            });
          },
          codeSent: (String newVerificationId, int? resendToken) {
            setState(() {
              // Update the verification ID if a new one is sent
              // This is typically handled by passing it back to the parent widget or state management
              // For simplicity here, we're just updating message
              _message = 'New OTP sent to ${widget.phoneNumber}!';
              // In a real app, you might want to store newVerificationId if the widget is rebuilt
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Called when code auto-retrieval times out.
          },
          timeout: const Duration(seconds: 60), // Resend timeout
        );
      }
      // --- Option 2: Resending OTP via your Node.js backend ---
      else {
        // This is a conceptual call to your backend, assuming you have an endpoint like /auth/resend-otp
        final url = Uri.parse('$kBaseUrl/auth/resend-otp'); // You would need to add this endpoint to your Node.js backend

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'emailOrPhoneNumber': widget.phoneNumber ?? 'user_email_here', // Or email
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            _message = 'OTP resent successfully via backend!';
          });
        } else {
          setState(() {
            _message = 'Failed to resend OTP: ${json.decode(response.body)['message'] ?? 'Unknown error'}';
          });
        }
      }
    } catch (e) {
      setState(() {
        _message = 'Error resending OTP: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter OTP'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Enter the 6-digit code sent to your phone/email',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '******',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                style: const TextStyle(fontSize: 24, letterSpacing: 10),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Verify OTP',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _isLoading ? null : _resendOtp,
                child: Text(
                  'Resend OTP',
                  style: TextStyle(
                    fontSize: 16,
                    color: _isLoading ? Colors.grey : Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _message.contains('success') ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
