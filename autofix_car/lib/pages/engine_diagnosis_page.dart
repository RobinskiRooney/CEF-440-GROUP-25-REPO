// lib/screens/engine_sound_diagnosis_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/how_it_works_card.dart';
import '../widgets/record_button_card.dart';
import '../widgets/diagnosis_result_card.dart';
import '../constants/app_colors.dart'; // Import AppColors
import '../constants/app_styles.dart'; // Import AppStyles

class EngineDiagnosisPage extends StatefulWidget {
  const EngineDiagnosisPage({super.key});

  @override
  State<EngineDiagnosisPage> createState() => _EngineDiagnosisPageState();
}

class _EngineDiagnosisPageState extends State<EngineDiagnosisPage> {
  bool _isRecording = false;
  bool _hasRecordedAudio = false; // New state to indicate if audio is recorded
  bool _isProcessingDiagnosis = false; // New state for diagnosis processing
  List<Map<String, String>> _diagnosisResults = [];

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (!_isRecording) {
        // Recording stopped
        _hasRecordedAudio = true; // Audio is now available
        _isProcessingDiagnosis = false; // Ensure processing is off
        ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide any previous snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio recorded. Ready for analysis.'),
            backgroundColor: AppColors.successColor,
          ),
        );
      } else {
        // Recording started
        _hasRecordedAudio = false; // Clear previous recorded state
        _isProcessingDiagnosis = false; // Ensure processing is off
        _diagnosisResults = []; // Clear previous results
        ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide any previous snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recording started...'),
            backgroundColor: AppColors.primaryColor,
          ),
        );
      }
    });
  }

  void _listenToAudio() async {
    if (!_hasRecordedAudio || _isProcessingDiagnosis) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing recorded audio...'),
        backgroundColor: AppColors.primaryColor,
      ),
    );
    await Future.delayed(const Duration(seconds: 2)); // Simulate playback duration
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Playback finished.'),
          backgroundColor: AppColors.successColor,
        ),
      );
    }
  }

  void _startDiagnosis() async {
    if (!_hasRecordedAudio || _isProcessingDiagnosis) return;

    setState(() {
      _isProcessingDiagnosis = true;
      _diagnosisResults = []; // Clear previous results before new diagnosis
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Analyzing engine sound...'),
        backgroundColor: AppColors.primaryColor,
      ),
    );

    await Future.delayed(const Duration(seconds: 3)); // Simulate API call or processing time

    if (mounted) {
      setState(() {
        _diagnosisResults = [
          {
            'title': 'Engine Misfire Detected',
            'description': 'Check spark plugs and ignition coils. Consider visiting a mechanic for detail inspection.'
          },
          {
            'title': 'Abnormal Noise from Belt',
            'description': 'Inspect serpentine belt for wear or tension issues. May require replacement.'
          },
          {
            'title': 'Normal Operation',
            'description': 'No significant abnormalities detected in engine sound.'
          }
        ];
        _isProcessingDiagnosis = false;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Diagnosis complete!'),
            backgroundColor: AppColors.successColor,
          ),
        );
      });
    }
  }

  void _recordNewSound() {
    setState(() {
      _isRecording = false;
      _hasRecordedAudio = false;
      _isProcessingDiagnosis = false;
      _diagnosisResults = [];
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // Using AppColors
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HowItWorksCard(),
            Center(
              child: RecordButtonCard(
                onRecordTap: _toggleRecording,
                isRecording: _isRecording,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Text(
                'Diagnosis Result',
                style: AppStyles.headline4.copyWith(color: AppColors.textColor), // Using AppStyles
              ),
            ),
            if (_isProcessingDiagnosis)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryColor),
                      const SizedBox(height: 16),
                      Text(
                        'Analyzing engine sound...',
                        style: AppStyles.bodyText.copyWith(color: AppColors.greyTextColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else if (_diagnosisResults.isEmpty && !_hasRecordedAudio)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    _isRecording ? 'Recording...' : 'Tap the microphone to start diagnosis.',
                    style: AppStyles.bodyText.copyWith(color: AppColors.greyTextColor),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (_diagnosisResults.isEmpty && _hasRecordedAudio)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Audio recorded. What next?',
                        style: AppStyles.bodyText.copyWith(color: AppColors.textColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _listenToAudio,
                              icon: const Icon(Icons.play_arrow, color: Colors.white),
                              label: Text('Listen to Audio', style: AppStyles.buttonText),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryColor, // A different accent color
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _startDiagnosis,
                              icon: const Icon(Icons.analytics_outlined, color: Colors.white),
                              label: Text('Process Diagnosis', style: AppStyles.buttonText),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: _recordNewSound,
                        child: Text(
                          'Record New Sound',
                          style: AppStyles.bodyText.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._diagnosisResults.map((result) => DiagnosisResultCard(
                    title: result['title']!,
                    description: result['description']!,
                    backgroundColor: result['title'] == 'Normal Operation' ? AppColors.successColor.withOpacity(0.1) : AppColors.errorColor.withOpacity(0.1), // Dynamic background
                    textColor: result['title'] == 'Normal Operation' ? AppColors.successColor : AppColors.errorColor, // Dynamic text color
                  )).toList(),
            if (_diagnosisResults.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: _recordNewSound,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Record New Sound',
                      style: AppStyles.buttonText,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20), // Padding at the bottom
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryColor, // Using AppColors
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () {
          Navigator.pop(context); // Go back to the previous screen (e.g., MainNavigation)
        },
      ),
      title: Text(
        'Engine Sound Diagnosis',
        style: AppStyles.headline4.copyWith(color: Colors.white), // Using AppStyles
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // Handle notification button press
          },
        ),
      ],
    );
  }
}
