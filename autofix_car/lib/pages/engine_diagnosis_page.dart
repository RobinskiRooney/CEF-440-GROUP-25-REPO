// lib/pages/engine_sound_diagnosis_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:url_launcher/url_launcher.dart'; // For launching YouTube videos
import 'package:record/record.dart' as audio_record; // IMPORTANT: Added 'as audio_record' to prevent conflict with dart:core.Record
import 'package:path_provider/path_provider.dart'; // For getting temporary directory
import 'package:permission_handler/permission_handler.dart'; // For requesting permissions
import 'dart:async'; // For Timer
import 'package:audioplayers/audioplayers.dart'; // Import the audioplayers package

import '../widgets/how_it_works_card.dart';
import '../widgets/record_button_card.dart';
import '../widgets/diagnosis_result_card.dart'; // Import the new diagnosis result card
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

// GlobalKey for navigation - should be defined in main.dart typically
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class EngineDiagnosisPage extends StatefulWidget {
  const EngineDiagnosisPage({super.key});

  @override
  State<EngineDiagnosisPage> createState() => _EngineDiagnosisPageState();
}

class _EngineDiagnosisPageState extends State<EngineDiagnosisPage> {
  final audio_record.AudioRecorder _audioRecorder = audio_record.AudioRecorder(); // Fixed: Use AudioRecorder instead of Record
  final AudioPlayer _audioPlayer = AudioPlayer(); // Instance of the audio player
  String? _recordedAudioPath; // Path to the recorded audio file

  bool _isRecording = false;
  bool _hasRecordedAudio = false;
  bool _isProcessingDiagnosis = false;
  bool _isPlayingAudio = false;
  List<Map<String, dynamic>> _diagnosisResults = [];
  double _audioPlaybackProgress = 0.0;
  String _recordingDuration = '00:00';
  Timer? _recordingTimer; // Timer for recording duration

  @override
  void initState() {
    super.initState();
    // Ensure the navigatorKey is set for launching URLs from diagnosis_result_card
    // This is a common pattern for static utility functions that need BuildContext
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorKey.currentState == null) {
        debugPrint('Navigator Key not yet set, relying on main app setup.');
      }
    });

    // Listen to audio player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingAudio = state == PlayerState.playing;
        });
      }
    });

    // Listen to audio playback position changes for progress bar
    _audioPlayer.onPositionChanged.listen((position) async {
      if (mounted && _recordedAudioPath != null) {
        final duration = await _audioPlayer.getDuration();
        if (duration != null && duration.inMilliseconds > 0) {
          setState(() {
            _audioPlaybackProgress = position.inMilliseconds / duration.inMilliseconds;
          });
        }
      }
    });

    // Listen for audio playback completion
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
          _audioPlaybackProgress = 0.0;
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose(); // Dispose the audio recorder
    _recordingTimer?.cancel(); // Cancel the timer
    _audioPlayer.dispose(); // Dispose the audio player
    super.dispose();
  }

  // --- Audio Recording Logic ---

  Future<bool> _checkAndRequestPermissions() async {
    final status = await Permission.microphone.status;
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      if (result.isDenied) {
        _showSnackBar('Microphone permission denied. Please enable it in app settings.', AppColors.errorColor);
        return false;
      }
    }
    if (status.isPermanentlyDenied) {
      _showSnackBar('Microphone permission permanently denied. Go to settings to enable.', AppColors.errorColor);
      openAppSettings(); // Opens app settings
      return false;
    }
    return status.isGranted || status.isLimited;
  }

  void _toggleRecording() async {
    if (_isRecording) {
      // Stop recording
      final path = await _audioRecorder.stop();
      _recordingTimer?.cancel(); // Stop the timer
      setState(() {
        _isRecording = false;
        _hasRecordedAudio = true;
        _recordedAudioPath = path;
      });
      _showSnackBar('Audio recorded successfully! Duration: $_recordingDuration', AppColors.successColor);
    } else {
      // Stop any active playback before starting a new recording
      if (_isPlayingAudio) {
        await _audioPlayer.stop();
      }

      // Start recording
      final hasPermission = await _checkAndRequestPermissions();
      if (!hasPermission) {
        return; // Don't proceed if permission isn't granted
      }

      try {
        if (await _audioRecorder.hasPermission()) {
          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/engine_sound_${DateTime.now().millisecondsSinceEpoch}.m4a';

          // Fixed: Use the correct RecordConfig parameters
          await _audioRecorder.start(
            const audio_record.RecordConfig(
              encoder: audio_record.AudioEncoder.aacLc,
              bitRate: 128000,
              sampleRate: 44100, // Fixed: Changed from samplingRate to sampleRate
            ),
            path: filePath,
          );

          setState(() {
            _isRecording = true;
            _hasRecordedAudio = false;
            _isProcessingDiagnosis = false;
            _diagnosisResults = [];
            _recordedAudioPath = null; // Clear previous path
            _recordingDuration = '00:00';
          });

          _showSnackBarWithProgress('Recording engine sound...', AppColors.primaryColor, 15);
          _startRecordingTimer(); // Start the visual timer
        }
      } catch (e) {
        debugPrint('Error starting recording: $e');
        _showSnackBar('Failed to start recording: ${e.toString()}', AppColors.errorColor);
        setState(() {
          _isRecording = false;
        });
      }
    }
  }

  void _startRecordingTimer() {
    int seconds = 0;
    _recordingTimer?.cancel(); // Cancel any existing timer
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isRecording) {
        timer.cancel();
        return;
      }
      seconds++;
      setState(() {
        _recordingDuration = '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
      });
      if (seconds >= 15) { // Stop recording automatically after 15 seconds
        _toggleRecording();
      }
    });
  }

  // --- Audio Playback Logic ---
  void _playAudio() async {
    if (!_hasRecordedAudio || _isPlayingAudio || _recordedAudioPath == null) return;

    setState(() {
      _isPlayingAudio = true;
      _audioPlaybackProgress = 0.0;
    });

    _showSnackBar('Playing recorded audio...', AppColors.primaryColor);

    try {
      Source audioSource = DeviceFileSource(_recordedAudioPath!); // Use DeviceFileSource for local files
      await _audioPlayer.play(audioSource);
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _showSnackBar('Failed to play audio: ${e.toString()}', AppColors.errorColor);
      setState(() {
        _isPlayingAudio = false;
        _audioPlaybackProgress = 0.0;
      });
    }
  }

  void _stopAudio() async {
    await _audioPlayer.stop(); // Stop audio playback
    if (mounted) {
      setState(() {
        _isPlayingAudio = false;
        _audioPlaybackProgress = 0.0;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  // --- Diagnosis Logic (Simulated AI) ---
  void _startDiagnosis() async {
    if (!_hasRecordedAudio || _isProcessingDiagnosis || _recordedAudioPath == null) return;

    // Ensure audio playback is stopped before diagnosis
    if (_isPlayingAudio) {
      await _audioPlayer.stop();
      setState(() {
        _isPlayingAudio = false;
        _audioPlaybackProgress = 0.0;
      });
    }

    setState(() {
      _isProcessingDiagnosis = true;
      _diagnosisResults = [];
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Simulate AI processing steps
    List<String> processingSteps = [
      'Analyzing frequency patterns...',
      'Detecting engine RPM...',
      'Comparing with database...',
      'Generating recommendations...',
      'Finalizing diagnosis...'
    ];

    for (String step in processingSteps) {
      if (!mounted) break;
      _showSnackBarWithProgress(step, AppColors.primaryColor, 1); // Show each step briefly
      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (mounted) {
      setState(() {
        _diagnosisResults = [
          {
            'title': 'Engine Misfire Detected',
            'severity': 'High',
            'description': 'Irregular combustion pattern detected in cylinder 2. This could be due to a faulty spark plug, ignition coil, or fuel injector.',
            'tips': [
              'Check spark plug condition (replace if worn)',
              'Inspect ignition coil for cracks or damage',
              'Verify fuel injector functionality (clean or replace if clogged)',
              'Perform a compression test on affected cylinder',
              'Consult a mechanic for further diagnostic'
            ],
            'youtubeVideos': [
              {
                'title': 'How to Diagnose Engine Misfire',
                'channel': 'Auto Repair Guy',
                'url': 'https://www.youtube.com/watch?v=R9K7-hP25XU', // Example URL
                'thumbnail': 'https://img.youtube.com/vi/R9K7-hP25XU/maxresdefault.jpg'
              },
              {
                'title': 'Spark Plug Replacement Tutorial (DIY)',
                'channel': 'Mechanic Man',
                'url': 'https://www.youtube.com/watch?v=0_u6eC_D4_0', // Example URL
                'thumbnail': 'https://img.youtube.com/vi/0_u6eC_D4_0/maxresdefault.jpg'
              }
            ],
            'isNormal': false
          },
          {
            'title': 'Normal Engine Operation',
            'severity': 'Low',
            'description': 'Overall engine sound is within normal parameters. No significant issues detected based on the audio analysis.',
            'tips': [
              'Continue regular maintenance schedule',
              'Monitor oil levels regularly',
              'Replace air filter as needed',
              'Schedule routine check-ups'
            ],
            'youtubeVideos': [
              {
                'title': 'Car Maintenance Schedule Guide',
                'channel': 'Auto Advisor',
                'url': 'https://www.youtube.com/watch?v=vV_R1Kk_P2Q', // Example URL
                'thumbnail': 'https://img.youtube.com/vi/vV_R1Kk_P2Q/maxresdefault.jpg'
              }
            ],
            'isNormal': true
          }
        ];
        _isProcessingDiagnosis = false;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showSnackBar('Diagnosis complete! Check results below.', AppColors.successColor);
    }
  }

  void _recordNewSound() {
    // Stop any active playback before resetting
    if (_isPlayingAudio) {
      _audioPlayer.stop();
    }
    setState(() {
      _isRecording = false;
      _hasRecordedAudio = false;
      _isProcessingDiagnosis = false;
      _isPlayingAudio = false;
      _diagnosisResults = [];
      _audioPlaybackProgress = 0.0;
      _recordingDuration = '00:00';
      _recordedAudioPath = null;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  // --- Snackbar Helpers ---
  void _showSnackBar(String message, Color backgroundColor) {
    // Ensuring context is valid before showing snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: AppStyles.bodyText1.copyWith(color: Colors.white)),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSnackBarWithProgress(String message, Color backgroundColor, int durationSeconds) {
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide previous snackbar if any
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(message, style: AppStyles.bodyText1.copyWith(color: Colors.white)),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: Duration(seconds: durationSeconds),
        ),
      );
    }
  }

  // --- UI Building Methods ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HowItWorksCard(),

            // Recording Section
            Center(
              child: Column(
                children: [
                  RecordButtonCard(
                    onRecordTap: _toggleRecording,
                    isRecording: _isRecording,
                    recordingDuration: _recordingDuration,
                  ),
                  if (_hasRecordedAudio && !_isRecording) // Only show audio controls if recorded and not actively recording
                    _buildAudioControlsCard(),
                ],
              ),
            ),

            // Diagnosis Results Section Header
            if (_isProcessingDiagnosis || _diagnosisResults.isNotEmpty || (_hasRecordedAudio && !_isRecording))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Text(
                  'Diagnosis Results',
                  style: AppStyles.headline3.copyWith(color: AppColors.textColor), // Consistent with AppStyles
                ),
              ),

            // Conditional Content based on State
            if (_isProcessingDiagnosis)
              _buildProcessingIndicator()
            else if (_diagnosisResults.isEmpty && !_hasRecordedAudio && !_isRecording)
              _buildInitialState()
            else if (_diagnosisResults.isEmpty && _hasRecordedAudio)
              _buildAudioRecordedState()
            else if (_diagnosisResults.isNotEmpty)
              ..._diagnosisResults.map((result) => DiagnosisResultCard(result: result)).toList(), // Use DiagnosisResultCard

            // Record New Sound Button (visible after diagnosis results are shown)
            if (_diagnosisResults.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _recordNewSound,
                    icon: const Icon(Icons.mic, color: Colors.white),
                    label: Text('Record New Sound', style: AppStyles.buttonText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioControlsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.audiotrack, color: AppColors.primaryColor, size: 24),
                const SizedBox(width: 8),
                Text('Recorded Audio', style: AppStyles.headline3.copyWith(fontSize: 18)),
                const Spacer(),
                Text(_recordingDuration, style: AppStyles.bodyText1),
              ],
            ),
            const SizedBox(height: 12),
            if (_isPlayingAudio) ...[
              LinearProgressIndicator(
                value: _audioPlaybackProgress,
                backgroundColor: AppColors.borderColor,
                color: AppColors.primaryColor,
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isPlayingAudio ? _stopAudio : _playAudio,
                    icon: Icon(
                      _isPlayingAudio ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isPlayingAudio ? 'Stop' : 'Play Audio',
                      style: AppStyles.buttonText,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPlayingAudio ? AppColors.errorColor : AppColors.secondaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessingDiagnosis || _recordedAudioPath == null ? null : _startDiagnosis,
                    icon: const Icon(Icons.analytics_outlined, color: Colors.white),
                    label: Text('Diagnose', style: AppStyles.buttonText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Analyzing engine sound...',
              style: AppStyles.bodyText1.copyWith(color: AppColors.secondaryTextColor), // Consistent style
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a few moments',
              style: AppStyles.bodyText2.copyWith(color: AppColors.secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.mic_outlined, size: 48, color: AppColors.secondaryTextColor), // Consistent color
            const SizedBox(height: 16),
            Text(
              'Tap the microphone to start recording',
              style: AppStyles.bodyText1.copyWith(color: AppColors.secondaryTextColor), // Consistent style
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Record your engine sound for 10-15 seconds',
              style: AppStyles.bodyText2.copyWith(color: AppColors.secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioRecordedState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.check_circle, size: 48, color: AppColors.successColor),
            const SizedBox(height: 16),
            Text(
              'Audio recorded successfully!',
              style: AppStyles.headline3.copyWith(color: AppColors.textColor), // Consistent style
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You can now play the audio or start diagnosis',
              style: AppStyles.bodyText2.copyWith(color: AppColors.secondaryTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _recordNewSound,
              child: Text(
                'Record Again',
                style: AppStyles.bodyText1.copyWith( // Consistent style
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Engine Sound Diagnosis',
        style: AppStyles.headline3.copyWith(color: Colors.white), // Consistent with AppStyles
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('How to Use', style: AppStyles.headline3),
                content: Text(
                  '1. Tap the microphone to start recording.\n'
                  '2. Record your engine sound for 10-15 seconds.\n'
                  '3. Play back the audio to verify quality (optional).\n'
                  '4. Tap "Diagnose" to analyze the sound.\n'
                  '5. Review recommendations and watch helpful videos.',
                  style: AppStyles.bodyText1,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Got it', style: AppStyles.buttonText.copyWith(color: AppColors.primaryColor)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}