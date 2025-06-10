// lib/screens/camera_overlay_scanner.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Import the camera package
import 'dart:io'; // For File
import '../pages/scanning_result_page.dart'; // Import the target page
import '../constants/app_colors.dart'; // Assuming you have AppColors
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
  bool _isCapturing = false; // To prevent multiple captures

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Ensure cameras are available
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        print('No cameras found on this device.');
        // Optionally show an error message or navigate away
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No cameras found on this device.')),
          );
        }
        return;
      }

      // Initialize the camera controller with the first available camera
      _cameraController = CameraController(
        _cameras![0], // Use the first available camera (usually back camera)
        ResolutionPreset.high, // Set resolution
        enableAudio: false, // No audio needed for dashboard scanning
      );

      // Initialize the controller
      await _cameraController!.initialize();

      if (!mounted) {
        return;
      }

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        // Handle camera initialization errors (e.g., show a message to the user)
        String errorMessage = 'Error initializing camera.';
        if (e is CameraException) {
          switch (e.code) {
            case 'CameraAccessDenied':
              errorMessage = 'Camera access denied. Please grant permissions.';
              break;
            case 'CameraNotAvailable':
              errorMessage = 'Camera not available.';
              break;
            default:
              errorMessage = 'Camera error: ${e.description}';
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
      setState(() {
        _isCameraInitialized = false;
      });
    }
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized || _cameraController == null || !_cameraController!.value.isInitialized || _isCapturing) {
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
        // Navigate to ScanningResultPage, passing the image path
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ScanningResultPage(capturedImagePath: image.path),
          ),
        );
      }
    } catch (e) {
      print('Error taking picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to take picture: $e')),
        );
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
    // Determine which borders to apply based on alignment
    BorderSide borderSide = BorderSide(color: Colors.blue.shade600, width: 3); // Changed to blue for better visibility
    return Container(
      width: 30, // Length of the corner line
      height: 30, // Length of the corner line
      decoration: BoxDecoration(
        border: Border(
          top: alignment == Alignment.topLeft || alignment == Alignment.topRight ? borderSide : BorderSide.none,
          bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight ? borderSide : BorderSide.none,
          left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft ? borderSide : BorderSide.none,
          right: alignment == Alignment.topRight || alignment == Alignment.bottomRight ? borderSide : BorderSide.none,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera Scan')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor), // Show loading indicator
        ),
      );
    }

    // Calculate aspect ratio to fit the camera preview
    final size = MediaQuery.of(context).size;
    final cameraAspectRatio = _cameraController!.value.aspectRatio;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Dark app bar for camera view
        elevation: 0,
        title: const Text('Scan Dashboard', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Camera Preview filling the entire screen
          SizedBox(
            width: size.width,
            height: size.height,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: size.width,
                height: size.width / cameraAspectRatio,
                child: CameraPreview(_cameraController!),
              ),
            ),
          ),
          // Transparent overlay to dim areas outside the scanning rectangle
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5), // Adjust opacity for desired dimming
              BlendMode.srcOut, // This blend mode creates the "cutout" effect
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black, // Background color for the filter
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.width * 0.55,
                    decoration: BoxDecoration(
                      color: Colors.white, // Color that gets "cut out"
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Blue scanning rectangle border and corners
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85, // Adjust width as needed
              height: MediaQuery.of(context).size.width * 0.55, // Adjust height
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade600, width: 3.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Stack(
                children: [
                  Positioned(top: 0, left: 0, child: _buildCorner(Alignment.topLeft)),
                  Positioned(top: 0, right: 0, child: _buildCorner(Alignment.topRight)),
                  Positioned(bottom: 0, left: 0, child: _buildCorner(Alignment.bottomLeft)),
                  Positioned(bottom: 0, right: 0, child: _buildCorner(Alignment.bottomRight)),
                ],
              ),
            ),
          ),
          // Text overlay (optional)
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2, // Adjust position
            left: 0,
            right: 0,
            child: Text(
              'Align car dashboard within the frame',
              textAlign: TextAlign.center,
              style: AppStyles.headline3.copyWith(color: Colors.white, shadows: [
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 3.0,
                  color: Colors.black.withOpacity(0.7),
                ),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isCameraInitialized && !_isCapturing
          ? FloatingActionButton(
              onPressed: _takePicture,
              backgroundColor: AppColors.primaryColor,
              child: const Icon(Icons.camera_alt, color: Colors.white),
            )
          : null, // Don't show button if not initialized or capturing
    );
  }
}