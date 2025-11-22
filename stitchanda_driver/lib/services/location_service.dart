import 'dart:async';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';

const Duration locationUpdateInterval = Duration(seconds: 10);


enum LocationServiceStatus {
  inactive,
  starting,
  active,
  error,
  permissionDenied,
  locationDisabled,
}


class LocationService {
  static final LocationService instance = LocationService._internal();
  factory LocationService() => instance;
  LocationService._internal();

  LocationServiceStatus _status = LocationServiceStatus.inactive;
  Position? _lastPosition;
  String? _lastError;
  Timer? _timer;

  final StreamController<LocationServiceStatus> _statusController =
  StreamController<LocationServiceStatus>.broadcast();
  final StreamController<Position> _locationController =
  StreamController<Position>.broadcast();

  // Public Getters
  LocationServiceStatus get status => _status;
  Position? get lastPosition => _lastPosition;
  String? get lastError => _lastError;

  Stream<LocationServiceStatus> get statusStream => _statusController.stream;
  Stream<Position> get locationStream => _locationController.stream;

  // ───── Start continuous tracking ─────
  Future<bool> start() async {

    if (_status == LocationServiceStatus.active) return true;

    _updateStatus(LocationServiceStatus.starting);
    _clearError();

    final granted = await _ensurePermissionGranted();
    if (!granted) {
      _handleError('Location permission not granted after retry');
      return false;
    }

    _updateStatus(LocationServiceStatus.active);
    await _getAndEmitLocation();

    // Start periodic updates every 10 seconds
    _timer = Timer.periodic(locationUpdateInterval, (_) async {
      await _getAndEmitLocation();
    });

    log('✅ Location tracking started');
    return true;
  }

  // ───── Stop tracking ─────
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _updateStatus(LocationServiceStatus.inactive);
    log('🛑 Location tracking stopped');
  }

  // ───── Get single location ─────
  Future<Position?> getCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _lastPosition = pos;
      return pos;
    } catch (e) {
      _handleError('Failed to get current location: $e');
      return null;
    }
  }

  // ───── Dispose streams ─────
  void dispose() {
    _timer?.cancel();
    _statusController.close();
    _locationController.close();
  }

  // ───────────────────────────────
  // PRIVATE HELPERS
  // ───────────────────────────────

  Future<bool> _ensurePermissionGranted() async {
    // Step 1: Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log('⚠️ Location services disabled — opening settings...');
      await Geolocator.openLocationSettings();

      // Wait for user to return
      await Future.delayed(const Duration(seconds: 3));

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _updateStatus(LocationServiceStatus.locationDisabled);
        return false;
      }
    }

    // Step 2: Check current permission
    LocationPermission permission = await Geolocator.checkPermission();

    // Step 3: Request if denied
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Step 4: Handle deniedForever
    if (permission == LocationPermission.deniedForever) {
      log('⚠️ Location permanently denied — open app settings...');
      await Geolocator.openAppSettings();

      // Give time for user to return
      await Future.delayed(const Duration(seconds: 3));

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        _updateStatus(LocationServiceStatus.permissionDenied);
        return false;
      }
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _getAndEmitLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _lastPosition = pos;
      _locationController.add(pos);
      log('📍 Updated location: ${pos.latitude}, ${pos.longitude}');
    } catch (e) {
      _handleError('Location update failed: $e');
    }
  }

  void _updateStatus(LocationServiceStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(newStatus);
    }
  }

  void _handleError(String error) {
    _lastError = error;
    _updateStatus(LocationServiceStatus.error);
    log('⚠️ $error');
  }

  void _clearError() {
    _lastError = null;
  }
}
