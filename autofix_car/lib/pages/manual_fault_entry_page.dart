// lib/screens/manual_fault_entry_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // For date formatting (if needed for display)

// Assuming you have a Navigation page for consistency
import 'main_navigation.dart';
// Assuming a NotificationPage exists if you want to navigate there
// import 'notification_page.dart';

enum FaultSeverity { low, medium, high, critical }

extension FaultSeverityExtension on FaultSeverity {
  String get displayName {
    switch (this) {
      case FaultSeverity.low:
        return 'Low';
      case FaultSeverity.medium:
        return 'Medium';
      case FaultSeverity.high:
        return 'High';
      case FaultSeverity.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case FaultSeverity.low:
        return Colors.green;
      case FaultSeverity.medium:
        return Colors.orange;
      case FaultSeverity.high:
        return Colors.redAccent;
      case FaultSeverity.critical:
        return Colors.red.shade900;
    }
  }
}

class ManualFaultEntryPage extends StatefulWidget {
  const ManualFaultEntryPage({super.key});

  @override
  State<ManualFaultEntryPage> createState() => _ManualFaultEntryPageState();
}

class _ManualFaultEntryPageState extends State<ManualFaultEntryPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _faultTitleController = TextEditingController();
  final TextEditingController _faultDescriptionController =
      TextEditingController();

  String? _selectedCommonFault;
  FaultSeverity _selectedSeverity = FaultSeverity.medium; // Default severity

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Hardcoded list of common car faults for the dropdown
  final List<String> _commonFaults = const [
    'Engine Light On',
    'Brake Warning Light',
    'Low Tire Pressure',
    'Overheating Engine',
    'Strange Engine Noise',
    'Steering Wheel Vibration',
    'Brake Squealing/Grinding',
    'Weak AC/Heating',
    'Headlights/Taillights Out',
    'Power Window Malfunction',
    'Battery Warning Light',
    'Excessive Exhaust Smoke',
    'Rough Idling',
    'Gear Shifting Issues',
    'Windshield Wiper Problem',
    'Other (describe below)',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _faultTitleController.dispose();
    _faultDescriptionController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      toolbarHeight: 70,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E40AF), Color(0xFF3B82F6), Color(0xFF60A5FA)],
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
            // Or navigate to MainNavigation if this page is not part of a stack
            // Navigator.pushAndRemoveUntil(
            //   context,
            //   MaterialPageRoute(builder: (context) => const MainNavigation()),
            //   (Route<dynamic> route) => false,
            // );
          },
        ),
      ),
      title: const Column(
        children: [
          Text(
            'Manual Fault Entry',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Log Car Issues Manually',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // Navigate to notification page
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationPage()));
              debugPrint('Navigate to Notification Page');
            },
          ),
        ),
      ],
    );
  }

  void _submitFault() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields

      // Here you would typically send data to your backend service.
      // For this request, we'll just show a success message.

      final String faultTitle =
          _selectedCommonFault ?? _faultTitleController.text.trim();
      final String faultDescription = _faultDescriptionController.text.trim();
      final String severity = _selectedSeverity.displayName;
      final DateTime reportedAt = DateTime.now();

      debugPrint('Manual Fault Submitted:');
      debugPrint('Title: $faultTitle');
      debugPrint('Description: $faultDescription');
      debugPrint('Severity: $severity');
      debugPrint(
        'Reported At: ${DateFormat('yyyy-MM-dd HH:mm').format(reportedAt)}',
      );

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fault logged successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the form
      _faultTitleController.clear();
      _faultDescriptionController.clear();
      setState(() {
        _selectedCommonFault = null;
        _selectedSeverity = FaultSeverity.medium;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildModernAppBar(context),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildForm(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report a new issue',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 24),

            // Dropdown for common faults
            _buildSectionTitle('Select a Common Fault (Optional)'),
            const SizedBox(height: 12),
            _buildDropdownField(
              hintText: 'Choose from common issues',
              value: _selectedCommonFault,
              items: _commonFaults.map((fault) {
                return DropdownMenuItem(
                  value: fault,
                  child: Text(
                    fault,
                    style: const TextStyle(color: Colors.black87),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCommonFault = newValue;
                  if (newValue != null &&
                      newValue != 'Other (describe below)') {
                    _faultTitleController.text =
                        newValue; // Pre-fill title if selected
                  } else {
                    _faultTitleController.clear();
                  }
                });
              },
            ),
            const SizedBox(height: 24),

            // Fault Title (if 'Other' is selected or for custom entry)
            _buildSectionTitle('Fault Title'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _faultTitleController,
              hintText: 'e.g., Engine misfire, flat tire, brake noise',
              validator: (value) {
                if (_selectedCommonFault == null ||
                    _selectedCommonFault == 'Other (describe below)') {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a fault title.';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Fault Description
            _buildSectionTitle('Fault Description'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _faultDescriptionController,
              hintText:
                  'Provide a detailed description of the issue (e.g., when it occurs, what sounds it makes).',
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Severity Selector
            _buildSectionTitle('Severity'),
            const SizedBox(height: 12),
            _buildSeveritySelector(),
            const SizedBox(height: 30),

            // Submit Button
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.blueGrey[700],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      cursorColor: const Color(0xFF3B82F6),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      style: const TextStyle(color: Colors.black87),
    );
  }

  Widget _buildDropdownField({
    required String hintText,
    String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hintText, style: TextStyle(color: Colors.grey[500])),
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF3B82F6)),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dropdownColor: Colors.white, // Ensure dropdown background is white
      style: const TextStyle(
        color: Colors.black87,
      ), // Ensure selected text color is good
    );
  }

  Widget _buildSeveritySelector() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: FaultSeverity.values.map((severity) {
          final isSelected = _selectedSeverity == severity;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSeverity = severity;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? severity.color.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: severity.color, width: 1.5)
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getSeverityIcon(severity),
                      color: isSelected ? severity.color : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      severity.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? severity.color : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getSeverityIcon(FaultSeverity severity) {
    switch (severity) {
      case FaultSeverity.low:
        return Icons.check_circle_outline;
      case FaultSeverity.medium:
        return Icons.info_outline;
      case FaultSeverity.high:
        return Icons.warning_amber_rounded;
      case FaultSeverity.critical:
        return Icons.error_outline;
    }
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _submitFault,
      icon: const Icon(Icons.send_rounded, color: Colors.white),
      label: const Text(
        'Submit Fault',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6), // Primary blue
        minimumSize: const Size.fromHeight(55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        shadowColor: const Color(0xFF3B82F6).withOpacity(0.4),
      ),
    );
  }
}
