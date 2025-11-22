import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../data/models/order_model.dart';
import '../../../base/order_shimmer.dart';

class OrderRequestWidget extends StatefulWidget {
  final OrderModel order;
  final VoidCallback? onAccept;

  const OrderRequestWidget({
    super.key,
    required this.order,
    this.onAccept,
  });

  @override
  State<OrderRequestWidget> createState() => _OrderRequestWidgetState();
}

class _OrderRequestWidgetState extends State<OrderRequestWidget> {
  double? _driverLat;
  double? _driverLng;
  double? _distanceToPickup;
  double? _distancePickupToDropoff;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _initDriverLocation();
  }

  Future<void> _initDriverLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        if(!await Geolocator.isLocationServiceEnabled()) {
          return;
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final pickupLocation = widget.order.currentPickupLocation;
      final dropoffLocation = widget.order.currentDropoffLocation;

      final pickupLat = double.tryParse(pickupLocation.latitude) ?? 0.0;
      final pickupLng = double.tryParse(pickupLocation.longitude) ?? 0.0;
      final dropoffLat = double.tryParse(dropoffLocation.latitude) ?? 0.0;
      final dropoffLng = double.tryParse(dropoffLocation.longitude) ?? 0.0;

      final double driverToPickup =
      _calculateDistance(pos.latitude, pos.longitude, pickupLat, pickupLng);

      final double pickupToDropoff =
      _calculateDistance(pickupLat, pickupLng, dropoffLat, dropoffLng);

      setState(() {
        _driverLat = pos.latitude;
        _driverLng = pos.longitude;
        _distanceToPickup = driverToPickup;
        _distancePickupToDropoff = pickupToDropoff;
        _loadingLocation = false;
      });
    } catch (e) {
      debugPrint("Error getting location: $e");
      setState(() => _loadingLocation = false);
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2)/1000;
  }

  Future<void> _openGoogleMaps(double destLat, double destLng, String destinationName) async {
    if (_driverLat == null || _driverLng == null) return;
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$_driverLat,$_driverLng&destination=$destLat,$destLng&travelmode=driving';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch directions to $destinationName")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final bool isReturnTrip = order.status == 6;
    final pickupLabel = isReturnTrip ? "Pickup from Tailor" : "Pickup from Customer";
    final dropoffLabel = isReturnTrip ? "Deliver to Customer" : "Deliver to Tailor";
    final pickupLocation = order.currentPickupLocation;
    final dropoffLocation = order.currentDropoffLocation;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).cardColor,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25), width: 1.2),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 22, offset: const Offset(0, 10)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _loadingLocation
              ? const OrderShimmer(isEnabled: true)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(isReturnTrip ? Icons.keyboard_return : Icons.local_shipping, size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(isReturnTrip ? "Return Delivery" : "New Delivery", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _buildLocationRow(
                      context,
                      icon: Icons.store,
                      label: pickupLabel,
                      address: pickupLocation.location,
                      distanceText: "📍 You are ${_distanceToPickup?.toStringAsFixed(2)} km away",
                      onViewMap: () => _openGoogleMaps(
                        double.tryParse(pickupLocation.latitude) ?? 0.0,
                        double.tryParse(pickupLocation.longitude) ?? 0.0,
                        "Pickup",
                      ),
                    ),
                    const Divider(height: 24),
                    _buildLocationRow(
                      context,
                      icon: Icons.location_pin,
                      label: dropoffLabel,
                      address: dropoffLocation.location,
                      distanceText: "🚚 ${_distancePickupToDropoff?.toStringAsFixed(2)} km from pickup",
                      onViewMap: () => _openGoogleMaps(
                        double.tryParse(dropoffLocation.latitude) ?? 0.0,
                        double.tryParse(dropoffLocation.longitude) ?? 0.0,
                        "Dropoff",
                      ),
                    ),

                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onAccept,
                          icon: const Icon(Icons.check_circle, color: Colors.white),
                          label: Text(
                            _distancePickupToDropoff != null
                                ? "Accept • Rs ${( (_distancePickupToDropoff ?? 0) * 50).ceil()}"
                                : "Accept",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ])
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLocationRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String address,
    required String distanceText,
    required VoidCallback onViewMap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        ),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.95),
              )),
              const SizedBox(height: 3),
              Text(address, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
              )),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(distanceText, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  )),
                  TextButton.icon(
                    onPressed: onViewMap,
                    icon: const Icon(Icons.map, size: 18),
                    label: const Text('Route'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
