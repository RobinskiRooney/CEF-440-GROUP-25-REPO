import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import '../pages/scanning_result_page.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class CameraOverlayScanner extends StatefulWidget {
  const CameraOverlayScanner({super.key});

  @override
  State<CameraOverlayScanner> createState() => _CameraOverlayScannerState();
}

class _CameraOverlayScannerState extends State<CameraOverlayScanner> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (_isCameraInitialized) return; // Prevent re-initialization

    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          _showSnackBar('No cameras found on this device.');
          Navigator.of(context).pop(); // Go back if no camera
        }
        return;
      }

      // Try to find a back camera, otherwise use the first available
      CameraDescription? backCamera;
      for (var camera in _cameras!) {
        if (camera.lensDirection == CameraLensDirection.back) {
          backCamera = camera;
          break;
        }
      }

      _cameraController = CameraController(
        backCamera ?? _cameras![0], // Use back camera if found, else first
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup:
            ImageFormatGroup.jpeg, // Ensure JPEG format for wider compatibility
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });
    } on CameraException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'CameraAccessDenied':
          errorMessage =
              'Camera access denied. Please grant permissions in settings.';
          break;
        case 'CameraNotAvailable':
          errorMessage = 'Camera not available or in use by another app.';
          break;
        default:
          errorMessage = 'Failed to initialize camera: ${e.description}';
      }
      print('Error initializing camera: $errorMessage');
      if (mounted) {
        _showSnackBar(errorMessage);
        // Optionally pop to previous screen or show retry button
      }
      setState(() {
        _isCameraInitialized = false;
      });
    } catch (e) {
      print('Unexpected error initializing camera: $e');
      if (mounted) {
        _showSnackBar(
          'An unexpected error occurred during camera initialization.',
        );
      }
      setState(() {
        _isCameraInitialized = false;
      });
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
          backgroundColor:
              AppColors.primaryColor, // Use your app's primary color
        ),
      );
    }
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isCapturing) {
      return;
    }
    if (_cameraController!.value.isTakingPicture) {
      // A capture is already pending
      return;
    }

    setState(() {
      _isCapturing = true; // Set flag to true
    });

    try {
      final XFile image = await _cameraController!.takePicture();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ScanningResultPage(capturedImagePath: image.path),
          ),
        );
      }
    } on CameraException catch (e) {
      print('Error taking picture: $e');
      if (mounted) {
        _showSnackBar('Failed to take picture: ${e.description}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false; // Reset flag
        });
      }
    }
  }

  Widget _buildCorner(Alignment alignment) {
    final BorderSide borderSide = BorderSide(
      color: AppColors.accentColor,
      width: 3.5,
    ); // Using accentColor
    return Container(
      width: 35, // Slightly larger corners
      height: 35,
      decoration: BoxDecoration(
        border: Border(
          top: alignment.y < 0 ? borderSide : BorderSide.none,
          bottom: alignment.y > 0 ? borderSide : BorderSide.none,
          left: alignment.x < 0 ? borderSide : BorderSide.none,
          right: alignment.x > 0 ? borderSide : BorderSide.none,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading or error state
    if (!_isCameraInitialized ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isCameraInitialized)
                const CircularProgressIndicator(color: AppColors.primaryColor)
              else
                Icon(
                  Icons.camera_alt_outlined,
                  size: 80,
                  color: AppColors.primaryColor.withOpacity(0.6),
                ),
              const SizedBox(height: 20),
              Text(
                _isCameraInitialized
                    ? 'Camera not ready or permission denied.'
                    : 'Initializing camera...',
                style: AppStyles.bodyText1.copyWith(
                  color: AppColors.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final cameraAspectRatio = _cameraController!.value.aspectRatio;

    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview filling the entire screen
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: cameraAspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          ),

          // --- Scanning Overlay ---
          // Dimming overlay with a cutout
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(
                0.6,
              ), // Slightly darker dimming for contrast
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width:
                        size.width * 0.90, // Match your desired scanning area
                    height: size.width * 0.85,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        12.0,
                      ), // Slightly more rounded corners
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Inner border and animated scanning line (optional but nice)
          Center(
            child: Container(
              width: size.width * 0.90,
              height: size.width * 0.85,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.accentColor.withOpacity(0.7),
                  width: 2.0,
                ), // Thinner, subtle border
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Stack(
                children: [
                  // Corner markers
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _buildCorner(Alignment.topLeft),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _buildCorner(Alignment.topRight),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _buildCorner(Alignment.bottomLeft),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _buildCorner(Alignment.bottomRight),
                  ),

                  // Add an animated scanning line for visual feedback (more advanced, requires AnimationController)
                  // For simplicity, I'll omit the full animation code here, but this is where it would go.
                  // Example:
                  // Positioned(
                  //   left: 0,
                  //   right: 0,
                  //   top: _animatedScanLinePosition.value, // Animate this
                  //   child: Container(
                  //     height: 2,
                  //     color: AppColors.accentColor.withOpacity(0.8),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),

          // Instruction Text
          Positioned(
            bottom: size.height * 0.15, // Adjusted position for better balance
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Position the car dashboard within the frame to scan.',
                textAlign: TextAlign.center,
                style: AppStyles.headline4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      offset: const Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isCameraInitialized && !_isCapturing
          ? FloatingActionButton(
              onPressed: _takePicture,
              backgroundColor: AppColors.primaryColor,
              shape: const CircleBorder(), // Make it perfectly round
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 30,
              ),
            )
          : null,
    );
  }
}
