
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

final String kBaseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost';

class OtpPage extends StatefulWidget {
  final String? verificationId;
  final String? phoneNumber;

  const OtpPage({Key? key, this.verificationId, this.phoneNumber}) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  String _message = '';
  bool _isLoading = false;
  bool _isSuccess = false;
  late Timer _timer;
  int _resendCountdown = 60;
  bool _canResend = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer.cancel();
    _animationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String get _otpCode {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    if (_otpCode.length == 6) {
      _verifyOtp();
    }
  }

  void _clearOtp() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _showError() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  Future<void> _verifyOtp() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final String otp = _otpCode;

    if (otp.isEmpty || otp.length != 6) {
      setState(() {
        _message = 'Please enter a complete 6-digit OTP.';
        _isLoading = false;
      });
      _showError();
      return;
    }

    try {
      if (widget.verificationId != null) {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId!,
          smsCode: otp,
        );

        await _auth.signInWithCredential(credential);
        setState(() {
          _message = 'Phone number verified successfully!';
          _isSuccess = true;
        });
        
        // Add success haptic feedback
        HapticFeedback.lightImpact();
        
        // Navigate after a short delay to show success state
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
        }
      } else {
        final url = Uri.parse('$kBaseUrl/auth/verify-otp');

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'emailOrPhoneNumber': widget.phoneNumber ?? 'user_email_here',
            'otp': otp,
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            _message = 'OTP verified successfully!';
            _isSuccess = true;
          });
          
          HapticFeedback.lightImpact();
          
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
          }
        } else {
          setState(() {
            _message = 'Invalid OTP. Please try again.';
          });
          _showError();
          _clearOtp();
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = e.message ?? 'Verification failed. Please try again.';
      });
      _showError();
      _clearOtp();
    } catch (e) {
      setState(() {
        _message = 'Network error. Please check your connection.';
      });
      _showError();
      _clearOtp();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend || _isLoading) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      if (widget.phoneNumber != null) {
        await _auth.verifyPhoneNumber(
          phoneNumber: widget.phoneNumber!,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
            setState(() {
              _message = 'Phone verification completed automatically!';
              _isSuccess = true;
            });
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() {
              _message = 'Failed to resend OTP: ${e.message}';
            });
          },
          codeSent: (String newVerificationId, int? resendToken) {
            setState(() {
              _message = 'New OTP sent successfully!';
            });
            _startResendTimer();
            _clearOtp();
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
          timeout: const Duration(seconds: 60),
        );
      } else {
        final url = Uri.parse('$kBaseUrl/auth/resend-otp');

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'emailOrPhoneNumber': widget.phoneNumber ?? 'user_email_here',
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            _message = 'New OTP sent successfully!';
          });
          _startResendTimer();
          _clearOtp();
        } else {
          setState(() {
            _message = 'Failed to resend OTP. Please try again.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _message = 'Network error. Please try again.';
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
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 50),
                _buildOtpInputSection(),
                const SizedBox(height: 40),
                _buildVerifyButton(),
                const SizedBox(height: 30),
                _buildResendSection(),
                const SizedBox(height: 30),
                _buildMessageSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textColor,
            size: 20,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.security,
            color: Colors.white,
            size: 50,
          ),
        ),
        const SizedBox(height: 30),
        Text(
          'Verification Code',
          style: AppStyles.headline1.copyWith(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter the 6-digit code sent to',
          style: AppStyles.bodyText.copyWith(
            color: AppColors.greyTextColor,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.phoneNumber ?? 'your registered number',
          style: AppStyles.bodyText.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInputSection() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) => _buildOtpBox(index)),
                ),
                const SizedBox(height: 20),
                if (_otpCode.isNotEmpty && _otpCode.length < 6)
                  Text(
                    'Enter ${6 - _otpCode.length} more digits',
                    style: AppStyles.bodyText.copyWith(
                      color: AppColors.greyTextColor,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtpBox(int index) {
    final bool isFilled = _otpControllers[index].text.isNotEmpty;
    final bool isFocused = _focusNodes[index].hasFocus;
    
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: isFilled 
            ? AppColors.primaryColor.withOpacity(0.1)
            : AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused 
              ? AppColors.primaryColor
              : isFilled 
                  ? AppColors.primaryColor.withOpacity(0.3)
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: AppStyles.headline2.copyWith(
          color: AppColors.textColor,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) => _onOtpChanged(value, index),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: _isSuccess
            ? LinearGradient(
                colors: [Colors.green, Colors.green.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (_isSuccess ? Colors.green : AppColors.primaryColor).withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : _isSuccess
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Verified!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Verify Code',
                    style: AppStyles.headline3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
      ),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          'Didn\'t receive the code?',
          style: AppStyles.bodyText.copyWith(
            color: AppColors.greyTextColor,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _canResend ? _resendOtp : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _canResend 
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : AppColors.lightGrey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: _canResend 
                    ? AppColors.primaryColor.withOpacity(0.3)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh,
                  color: _canResend 
                      ? AppColors.primaryColor
                      : AppColors.greyTextColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _canResend 
                      ? 'Resend Code'
                      : 'Resend in ${_resendCountdown}s',
                  style: AppStyles.bodyText.copyWith(
                    color: _canResend 
                        ? AppColors.primaryColor
                        : AppColors.greyTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageSection() {
    if (_message.isEmpty) return const SizedBox.shrink();
    
    final bool isSuccess = _message.contains('success') || _isSuccess;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSuccess 
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess 
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _message,
              style: AppStyles.bodyText.copyWith(
                color: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
