// lib/widgets/camera_preview_widget.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';

class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({super.key});

  @override
  State<CameraPreviewWidget> createState() => CameraPreviewWidgetState();
}

class CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        print('No cameras found on this device.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No cameras found on this device.')),
          );
        }
        return;
      }

      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

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

  Future<Uint8List?> takePicture() async {
    if (!_isCameraInitialized || _cameraController == null || !_cameraController!.value.isInitialized) {
      print('Camera not initialized or ready for capture.');
      return null;
    }
    if (_cameraController!.value.isTakingPicture) {
      print('A picture is already being taken.');
      return null;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      return await image.readAsBytes();
    } catch (e) {
      print('Error taking picture in CameraPreviewWidget: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(), // Simple loading for camera init
      );
    }

    final size = MediaQuery.of(context).size;
    final cameraAspectRatio = _cameraController!.value.aspectRatio;

    return SizedBox(
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
    );
  }
}
