import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'create_password_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedGender = 'Male';
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  // New: hold coordinates once fetched automatically
  double? _currentLatitude;
  double? _currentLongitude;
  bool _isFetchingLocation = false;
  bool _locationTried = false; // avoid repeated prompts

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    if (_isFetchingLocation) return;
    setState(() => _isFetchingLocation = true);

    try {
      final hasPermission = await _requestLocationPermission(auto: true);
      if (!hasPermission) {
        setState(() {
          _isFetchingLocation = false;
          _locationTried = true;
        });
        return;
      }

      final position = await _getCurrentPosition();
      if (position != null) {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;

        // Reverse-geocode to a readable address
        final address = await _reverseGeocode(position.latitude, position.longitude);
        print(address);
        if (address != null && address.isNotEmpty) {
          _addressController.text = address;
        }
      }
    } catch (e) {
      debugPrint('Auto location init failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
          _locationTried = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    // Show loader while we ensure location
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    double? latitude = _currentLatitude;
    double? longitude = _currentLongitude;

    try {
      // 1) Make sure services and permission are enabled; will push to settings if needed
      final ok = await _requestLocationPermission(auto: false);
      if (!ok) {
        if (mounted) {
          Navigator.pop(context); // close loader
          _showPersistentSnack('Please enable location services and permission to continue.');
        }
        return;
      }

      // 2) Ensure we have coordinates
      if (latitude == null || longitude == null) {
        final pos = await _getCurrentPosition();
        if (pos != null) {
          latitude = pos.latitude;
          longitude = pos.longitude;
          _currentLatitude = latitude;
          _currentLongitude = longitude;
        }
      }

      if (latitude == null || longitude == null) {
        if (mounted) {
          Navigator.pop(context);
          _showPersistentSnack('Unable to get your location. Please try again.');
        }
        return;
      }

      // 3) Ensure address is filled (reverse geocode if needed)
      if (_addressController.text.trim().isEmpty) {
        final addr = await _reverseGeocode(latitude, longitude);
        if (addr != null && addr.isNotEmpty) {
          _addressController.text = addr;
        }
      }
    } finally {
      if (mounted) Navigator.pop(context); // close loader
    }

    if (!mounted) return;

    // Only navigate if we have coordinates
    if (_currentLatitude == null || _currentLongitude == null) {
      _showPersistentSnack('Location is required to continue.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePasswordPage(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          gender: _selectedGender,
          latitude: _currentLatitude,
          longitude: _currentLongitude,
        ),
      ),
    );
  }

  void _showPersistentSnack(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<bool> _requestLocationPermission({required bool auto}) async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        await _showLocationServiceDialog();
      }
      // Re-check after returning from settings
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!auto && mounted) {
          _showPermissionDeniedDialog();
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        _showPermissionDeniedForeverDialog();
      }
      return false;
    }

    return true;
  }

  Future<void> _showLocationServiceDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Location services are disabled. Please enable them in your device settings for better service.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Push user to turn on location services
              try {
                await Geolocator.openLocationSettings();
              } catch (_) {}
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Denied'),
        content: const Text(
          'Location permission is required to provide you with better tailoring services. You can continue without it, but some features may be limited.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission has been permanently denied. To enable it, please go to your device settings and grant location permission to this app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<String?> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      // Build a human-friendly address string
      final parts = <String?>[
        p.name,
        p.street,
        p.subLocality,
        p.locality,
        p.administrativeArea,
        p.postalCode,
        p.country,
      ];
      final joined = parts
          .where((e) => e != null && e.trim().isNotEmpty)
          .map((e) => e!.trim())
          .toList()
          .join(', ');
      return joined;
    } catch (e) {
      debugPrint('Reverse geocoding failed: $e');
      return null;
    }
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );
    } catch (e) {
      debugPrint('Error obtaining position: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Close button
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      const SizedBox(height: 20),
                      // Headline
                      Center(
                        child: Text(
                          'Begin Your Custom\nTailoring Experience with\nStitchanda',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3142),
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Full Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Phone Number Field
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Gender Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          hintText: 'Gender',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        items: _genderOptions.map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Address Field (auto-filled if permission granted)
                      TextFormField(
                        controller: _addressController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: _isFetchingLocation
                              ? 'Fetching your location...'
                              : 'Address (auto-filled, you can edit)',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: _isFetchingLocation
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : (_currentLatitude != null && _currentLongitude != null)
                                  ? IconButton(
                                      tooltip: 'Refresh location',
                                      icon: const Icon(Icons.my_location, color: Colors.black54),
                                      onPressed: _initLocation,
                                    )
                                  : IconButton(
                                      tooltip: 'Get location',
                                      icon: const Icon(Icons.location_searching, color: Colors.black54),
                                      onPressed: _initLocation,
                                    ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isFetchingLocation ? null : _handleContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            // Optional top linear progress indicator while first fetching
            if (_isFetchingLocation && !_locationTried)
              const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(minHeight: 3),
              ),
          ],
        ),
      ),
    );
  }
}
