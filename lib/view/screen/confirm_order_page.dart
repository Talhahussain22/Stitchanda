import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controller/order_cubit.dart';
import '../../controller/auth_cubit.dart';
import '../../controller/tailor_cubit.dart';
import '../../data/models/order_details_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/tailor_model.dart';

class ConfirmOrderPage extends StatefulWidget {
  final List<Map<String, dynamic>> orders;
  final Tailor? preSelectedTailor;

  const ConfirmOrderPage({
    super.key,
    required this.orders,
    this.preSelectedTailor,
  });

  @override
  State<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage> {
  Tailor? _selectedTailor;
  DateTime? _selectedDeadline;
  List<bool> _expandedStates = [];

  @override
  void initState() {
    super.initState();
    _expandedStates = List.generate(widget.orders.length, (index) => index == 0);
    // Auto-select tailor if pre-selected
    _selectedTailor = widget.preSelectedTailor;
  }

  int _calculateTotalPrice() {
    int total = 0;
    for (var order in widget.orders) {
      final priceStr = order['price'].toString().replaceAll(RegExp(r'[^0-9]'), '');
      total += int.tryParse(priceStr) ?? 0;
    }
    return total;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD29356),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showTailorSelectionDialog(BuildContext context) async {
    final tailorState = context.read<TailorCubit>().state;

    if (tailorState is! TailorLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading tailors...'), backgroundColor: Colors.orange),
      );
      return;
    }

    final selectedTailor = await showDialog<Tailor>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Tailor'),
        content: SizedBox(
          width: double.maxFinite,
          child: tailorState.tailors.isEmpty
              ? const Center(child: Text('No tailors available'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: tailorState.tailors.length,
                  itemBuilder: (context, index) {
                    final tailor = tailorState.tailors[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFD29356),
                        child: Text(
                          tailor.initials,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(tailor.name),
                      subtitle: Text(tailor.area),
                      trailing: tailor.availability_status == true
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.cancel, color: Colors.grey),
                      onTap: () => Navigator.pop(context, tailor),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedTailor != null) {
      setState(() {
        _selectedTailor = selectedTailor;
      });
    }
  }

  Future<void> _handleConfirmOrder(BuildContext context) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to place an order'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedTailor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a tailor'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a deadline'), backgroundColor: Colors.red),
      );
      return;
    }

    final customer = authState.customer;

    final pickupLocation = Location(
      fullAddress: customer.address.fullAddress,
      latitude: customer.address.latitude,
      longitude: customer.address.longitude,
    );

    Location? dropoffLocation;
    if (_selectedTailor!.address != null) {
      dropoffLocation = Location(
        fullAddress: _selectedTailor!.address!.fullAddress ?? '',
        latitude: _selectedTailor!.address!.latitude ?? 0.0,
        longitude: _selectedTailor!.address!.longitude ?? 0.0,
      );
    }

    final orderDetailsList = widget.orders.map((order) {
      final priceStr = order['price'].toString().replaceAll(RegExp(r'[^0-9]'), '');
      final price = double.tryParse(priceStr) ?? 0.0;

      // Create Fabric object
      final fabric = Fabric(
        shirtFabric: order['stitchFabric']?.toString(),
        trouserFabric: order['threadFabric']?.toString(),
        dupataFabric: order['doubleFabric']?.toString(),
      );

      // Create Measurements object
      final measurements = Measurements(
        chest: double.tryParse(order['chest']?.toString() ?? ''),
        waist: double.tryParse(order['waist']?.toString() ?? ''),
        hips: double.tryParse(order['hips']?.toString() ?? ''),
        shoulder: double.tryParse(order['shoulder']?.toString() ?? ''),
        armLength: double.tryParse(order['armLength']?.toString() ?? ''),
        wrist: double.tryParse(order['wrist']?.toString() ?? ''),
        fittingPreferences: order['fittingPreference']?.toString(),
      );

      // Build description from available data
      final description = 'Custom order for ${order['fullName'] ?? 'customer'}';

      return OrderDetailsModel(
        detailsId: '',
        orderId: '',
        tailorId: _selectedTailor!.id,
        customerName: order['fullName']?.toString() ?? '',
        description: description,
        imagePath: null,
        fabric: fabric,
        measurements: measurements,
        price: price,
        totalPrice: price,
        dueData: _selectedDeadline?.toIso8601String(),
      );
    }).toList();

    final totalPrice = _calculateTotalPrice();

    // Get the correct tailor ID - use document ID
    final selectedTailorId = _selectedTailor!.id;


    final cubit = context.read<OrderCubit>();
    cubit.createOrder(
      customerId: customer.customerId,
      tailorId: selectedTailorId,
      riderId: null, // Status -1, no rider assigned yet
      pickupLocation: pickupLocation, // Customer's address
      dropoffLocation: dropoffLocation, // Tailor's address
      paymentMethod: 'Cash',
      paymentStatus: 'Pending',
      orderDetails: orderDetailsList,
      totalPrice: totalPrice.toDouble(),
      due_date: _selectedDeadline!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFD29356);
    final totalPrice = _calculateTotalPrice();

    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order created: ${state.orderId}'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
          Navigator.pop(context);
        }
        if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Confirm Order',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Orders list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: widget.orders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(context, index, accent);
                },
              ),
            ),

            // Bottom controls
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tailor selection
                    const Text(
                      'Select Tailor *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _showTailorSelectionDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[50],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedTailor == null
                                    ? 'Tap to select a tailor'
                                    : '${_selectedTailor!.name} - ${_selectedTailor!.area}',
                                style: TextStyle(
                                  color: _selectedTailor == null ? Colors.grey[600] : Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Deadline
                    const Text(
                      'Select Deadline *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: _selectedDeadline == null ? 'Due Date' : _formatDate(_selectedDeadline!),
                            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Total Price
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Price',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'PKR $totalPrice',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm button
                    BlocBuilder<OrderCubit, OrderState>(
                      builder: (context, state) {
                        final isSubmitting = state is OrderCreating;
                        final isFormValid = _selectedTailor != null && _selectedDeadline != null;

                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (isSubmitting || !isFormValid) ? null : () => _handleConfirmOrder(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              disabledBackgroundColor: Colors.grey[400],
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    isFormValid ? 'Confirm Order' : 'Select Tailor & Deadline',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, int index, Color accent) {
    final order = widget.orders[index];
    final isExpanded = _expandedStates[index];
    final price = order['price'].toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedStates[index] = !_expandedStates[index];
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isExpanded ? Radius.zero : const Radius.circular(12),
                  bottomRight: isExpanded ? Radius.zero : const Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                    color: accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Order ${index + 1}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                  const Spacer(),
                  if (!isExpanded)
                    Text(
                      'PKR $price',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Full Name', order['fullName'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Gender', order['gender'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Fitting Preference', order['fittingPreference'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Stitch Fabric', order['stitchFabric'] ?? 'N/A'),
                  const SizedBox(height: 16),
                  const Text(
                    'Price',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: 'PKR $price',
                    enabled: false,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
