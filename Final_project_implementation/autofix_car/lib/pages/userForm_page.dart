// lib/screens/user_profile_form.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // For Timer/debounce
import 'package:autofix_car/services/token_manager.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import './main_navigation.dart';

// IMPORTANT: Replace with your actual backend API base URL
// Ensure this matches your Render deployed backend URL, or localhost for dev
const String kApiBaseUrl = 'http://localhost:5000'; // For local dev
// const String kApiBaseUrl = 'https://your-backend-app.onrender.com'; // For deployed backend

// This would be your real API base URL for geocoding
// For demonstration, we'll just log it.
const String kGeocodingApiBaseUrl =
    'https://api.example.com/geocoding/v1/search'; // Replace with a real API endpoint

class UserProfileForm extends StatefulWidget {
  const UserProfileForm({Key? key}) : super(key: key);

  @override
  State<UserProfileForm> createState() => _UserProfileFormState();
}

class _UserProfileFormState extends State<UserProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _pickedImageFile;

  Map<String, dynamic>? _selectedLocation; // To store lat, lon, display_name
  List<dynamic> _locationSuggestions = [];
  bool _isLoadingLocation = false;
  String? _locationError;
  Timer? _debounce;

  bool _isSubmitting = false;
  String? _formError;

  String? _userId;
  String? _authToken;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserCredentials();
    // In a real app, you might fetch existing user data here
    // Example: _nameController.text = existingUserData?.name ?? '';
  }

  Future<void> _loadUserCredentials() async {
    final userId = await TokenManager.getUid();
    final authToken = await TokenManager.getIdToken();
    setState(() {
      _userId = userId;
      _authToken = authToken;
      _isLoadingUser = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _carModelController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchLocationSuggestions(String query) async {
    if (query.length < 3) {
      setState(() {
        _locationSuggestions = [];
        _isLoadingLocation = false;
      });
      return;
    }

    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () async {
      print('Simulating API call for address: $query');
      try {
        // --- START SIMULATED API CALL ---
        await Future.delayed(
          const Duration(milliseconds: 500),
        ); // Simulate network delay

        final mockSuggestions =
            [
              {
                'display_name': '$query, Buea, Cameroon',
                'lat': 4.1504,
                'lon': 9.2458,
              },
              {
                'display_name': '$query, Douala, Cameroon',
                'lat': 4.0511,
                'lon': 9.7679,
              },
              {
                'display_name': '$query Street, Yaounde, Cameroon',
                'lat': 3.8480,
                'lon': 11.5021,
              },
            ].where((s) {
              // Add a null check here
              final displayName = s['display_name'];
              return displayName != null && // Check if it's not null
                  (displayName as String).toLowerCase().contains(
                    query.toLowerCase(),
                  );
            }).toList();

        setState(() {
          _locationSuggestions = mockSuggestions;
          _isLoadingLocation = false;
        });
        // --- END SIMULATED API CALL ---

        // --- REAL API CALL EXAMPLE (using OpenStreetMap Nominatim) ---
        /*
        final response = await http.get(Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5'));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _locationSuggestions = data; // Nominatim returns list of maps
            _isLoadingLocation = false;
          });
        } else {
          setState(() {
            _locationError = 'Failed to fetch suggestions.';
            _isLoadingLocation = false;
          });
        }
        */
      } catch (e) {
        print('Error fetching location suggestions: $e');
        setState(() {
          _locationError = 'Failed to fetch suggestions.';
          _isLoadingLocation = false;
        });
      }
    });
  }

  void _handleSuggestionSelected(Map<String, dynamic> suggestion) {
    setState(() {
      _addressController.text = suggestion['display_name'];
      _selectedLocation = {
        'lat': double.parse(suggestion['lat'].toString()), // Ensure double type
        'lon': double.parse(suggestion['lon'].toString()), // Ensure double type
        'display_name': suggestion['display_name'],
      };
      _locationSuggestions = []; // Clear suggestions
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocation == null) {
      setState(() {
        _formError = 'Please select a location from the suggestions.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    final payload = {
      'name': _nameController.text.trim(),
      'car_model': _carModelController.text.trim(),
      'contact': _phoneNumberController.text.trim(),
      'location': _selectedLocation,
      // 'imageUrl': _imageUrlController.text.trim(), // Removed undefined controller
      // If you want to send the image, you should handle file upload separately.
    };

    print('Sending payload to backend: ${jsonEncode(payload)}');
    print(
      'User ID: [32m[1m[4m${_userId}[0m, Auth Token: ${_authToken != null ? _authToken!.substring(0, 10) : 'null'}...',
    ); // Log partial token for safety

    try {
      final response = await http.put(
        Uri.parse(
          '$kApiBaseUrl/users/update/$_userId', // Ensure this matches your backend endpoint
        ), // Adjust your endpoint path
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authToken ?? ''}',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('Profile update successful: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        // Navigate away after success
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => MainNavigation()));
      } else {
        final errorData = json.decode(response.body);
        print(
          'Profile update failed: ${response.statusCode} - ${errorData['error']}',
        );
        setState(() {
          _formError =
              errorData['error'] ??
              'Failed to update profile. Please try again.';
        });
      }
    } catch (e) {
      print('Error submitting form: $e');
      setState(() {
        _formError = 'An error occurred: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_userId == null || _authToken == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to complete your profile.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('complete_profile'.tr()),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF6F8FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                    child: Stack(
                    children: [
                    CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.blueAccent,
                    backgroundImage: _pickedImageFile != null
                    ? FileImage(_pickedImageFile!)
                    : null,
                    child: _pickedImageFile == null
                    ? const Icon(Icons.person, size: 48, color: Colors.white)
                    : null,
                    ),
                    Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                    onTap: () async {
                    final picker = ImagePicker();
                    final source = await showDialog<ImageSource>(
                    context: context,
                    builder: (context) => AlertDialog(
                    title: const Text('Select Image Source'),
                    actions: [
                    TextButton(
                    onPressed: () => Navigator.pop(context, ImageSource.camera),
                    child: const Text('Camera'),
                    ),
                    TextButton(
                    onPressed: () => Navigator.pop(context, ImageSource.gallery),
                    child: const Text('Gallery'),
                    ),
                    ],
                    ),
                    );
                    if (source != null) {
                    final picked = await picker.pickImage(
                    source: source,
                    imageQuality: 75,
                    );
                    if (picked != null) {
                    setState(() {
                    _pickedImageFile = File(picked.path);
                    });
                    }
                    }
                    },
                    child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.camera_alt, color: Colors.blueAccent),
                    ),
                    ),
                    ),
                    ],
                    ),
                    ),
                    const SizedBox(height: 18.0),
                    Text(
                      'lets_get_to_know_you'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'fill_in_details'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                    const SizedBox(height: 24.0),
                    if (_formError != null)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red.shade200),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _formError!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'full_name'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'please_enter_full_name'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18.0),
                    DropdownButtonFormField<String>(
                      value: _carModelController.text.isNotEmpty
                          ? _carModelController.text
                          : null,
                      items:
                          [
                                'Toyota Corolla',
                                'Honda Civic',
                                'Ford Focus',
                                'Hyundai Elantra',
                                'BMW 3 Series',
                                'Mercedes-Benz C-Class',
                                'Volkswagen Golf',
                                'Kia Rio',
                                'Nissan Altima',
                                'Mazda 3',
                              ]
                              .map(
                                (model) => DropdownMenuItem(
                                  value: model,
                                  child: Text(model),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _carModelController.text = value ?? '';
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'car_model'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.car_repair),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'please_select_car_model'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18.0),
                    TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'phone_number'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.phone),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'please_enter_phone_number'.tr();
                        }
                        // Basic phone number validation (e.g., regex for specific formats)
                        return null;
                      },
                    ),
                    const SizedBox(height: 18.0),
                    // Location Input with Suggestions
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'your_location'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.location_on),
                        filled: true,
                        fillColor: Colors.grey[100],
                        suffixIcon: _isLoadingLocation
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : null,
                        errorText: _locationError,
                      ),
                      onChanged: _fetchLocationSuggestions,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'please_enter_address'.tr();
                        }
                        if (_selectedLocation == null ||
                            _selectedLocation!['display_name'] != value) {
                          return 'please_select_valid_address'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.map, color: Colors.white),
                      label: Text('pick_from_map'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      onPressed: () async {
                        final picked = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) {
                            LatLng selected = LatLng(
                              4.1504,
                              9.2458,
                            ); // Default to Buea
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  title: const Text('Pick Location from Map'),
                                  content: SizedBox(
                                    width: 320,
                                    height: 320,
                                    child: FlutterMap(
                                      options: MapOptions(
                                        center: selected,
                                        zoom: 13.0,
                                        onTap: (tapPos, latlng) {
                                          setState(() {
                                            selected = latlng;
                                          });
                                        },
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate:
                                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                          subdomains: const ['a', 'b', 'c'],
                                        ),
                                        MarkerLayer(
                                          markers: [
                                            Marker(
                                              width: 40.0,
                                              height: 40.0,
                                              point: selected,
                                              child: const Icon(
                                                Icons.location_on,
                                                color: Colors.red,
                                                size: 40,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.fromLTRB(
                                    24,
                                    20,
                                    24,
                                    0,
                                  ),
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        bottom: 12,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              // Reverse geocode using Nominatim
                                              final lat = selected.latitude;
                                              final lon = selected.longitude;
                                              String displayName =
                                                  'Lat: $lat, Lon: $lon';
                                              try {
                                                final url = Uri.parse(
                                                  'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon',
                                                );
                                                final response = await http.get(
                                                  url,
                                                  headers: {
                                                    'User-Agent': 'FlutterApp',
                                                  },
                                                );
                                                if (response.statusCode ==
                                                    200) {
                                                  final data = json.decode(
                                                    response.body,
                                                  );
                                                  if (data['display_name'] !=
                                                      null) {
                                                    displayName =
                                                        data['display_name'];
                                                  }
                                                }
                                              } catch (_) {}
                                              Navigator.of(context).pop({
                                                'display_name': displayName,
                                                'lat': lat,
                                                'lon': lon,
                                              });
                                            },
                                            child: const Text(
                                              'Select this location',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _addressController.text = picked['display_name'];
                            _selectedLocation = {
                              'lat': double.parse(picked['lat'].toString()),
                              'lon': double.parse(picked['lon'].toString()),
                              'display_name': picked['display_name'],
                            };
                            _locationSuggestions = [];
                          });
                        }
                      },
                    ),
                    if (_locationSuggestions.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.blue.shade100),
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.only(top: 6.0, bottom: 8.0),
                        height: _locationSuggestions.length * 56.0 > 224.0
                            ? 224.0
                            : _locationSuggestions.length * 56.0,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _locationSuggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = _locationSuggestions[index];
                            return ListTile(
                              title: Text(suggestion['display_name']),
                              onTap: () =>
                                  _handleSuggestionSelected(suggestion),
                              leading: const Icon(
                                Icons.location_searching,
                                color: Colors.blueAccent,
                              ),
                            );
                          },
                        ),
                      ),
                    if (_selectedLocation != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${'selected'.tr()}: ${_selectedLocation!['display_name']}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 28.0),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('update_profile'.tr()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
