import 'package:flutter/material.dart';
import 'confirm_order_page.dart';
import '../../data/models/tailor_model.dart';

class CreateOrderPage extends StatefulWidget {
  final Tailor? preSelectedTailor;

  const CreateOrderPage({super.key, this.preSelectedTailor});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();

  // List to store multiple orders
  List<Map<String, dynamic>> _orders = [];
  List<bool> _expandedStates = [];
  int _currentOrderIndex = 0;

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _hipsController = TextEditingController();
  final TextEditingController _shoulderController = TextEditingController();
  final TextEditingController _armLengthController = TextEditingController();
  final TextEditingController _wristController = TextEditingController();
  final TextEditingController _setPriceController = TextEditingController();

  String? _selectedGender;
  String? _selectedFittingPreference;
  String? _selectedStitchFabric;
  String? _selectedThreadFabric;
  String? _selectedDoubleFabric;

  @override
  void initState() {
    super.initState();
    // Initialize with one empty order
    _addNewOrder();
  }

  void _addNewOrder() {
    setState(() {
      _orders.add({});
      _expandedStates.add(true);
      if (_orders.length > 1) {
        _expandedStates[_currentOrderIndex] = false;
      }
      _currentOrderIndex = _orders.length - 1;
    });
  }

  void _confirmRemoveCurrentOrder() async {
    if (_orders.length <= 1) return; // Don't remove the only order
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Order'),
        content: Text('Are you sure you want to remove Order ${_currentOrderIndex + 1}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
        ],
      ),
    );
    if (shouldRemove == true) {
      _removeCurrentOrder();
    }
  }

  void _removeCurrentOrder() {
    if (_orders.length <= 1) return;
    setState(() {
      _orders.removeAt(_currentOrderIndex);
      _expandedStates.removeAt(_currentOrderIndex);
      if (_currentOrderIndex >= _orders.length) {
        _currentOrderIndex = _orders.length - 1;
      }
      _loadOrderData(_currentOrderIndex);
    });
  }

  void _removeOrder(int index) {
    if (_orders.length > 1) {
      setState(() {
        _orders.removeAt(index);
        _expandedStates.removeAt(index);
        if (_currentOrderIndex >= _orders.length) {
          _currentOrderIndex = _orders.length - 1;
        }
        _loadOrderData(_currentOrderIndex);
      });
    }
  }

  void _saveCurrentOrder() {
    _orders[_currentOrderIndex] = {
      'fullName': _fullNameController.text,
      'gender': _selectedGender,
      'age': _ageController.text,
      'height': _heightController.text,
      'weight': _weightController.text,
      'chest': _chestController.text,
      'waist': _waistController.text,
      'hips': _hipsController.text,
      'shoulder': _shoulderController.text,
      'armLength': _armLengthController.text,
      'wrist': _wristController.text,
      'fittingPreference': _selectedFittingPreference,
      'stitchFabric': _selectedStitchFabric,
      'threadFabric': _selectedThreadFabric,
      'doubleFabric': _selectedDoubleFabric,
      'price': _setPriceController.text,
    };
  }

  void _loadOrderData(int index) {
    final order = _orders[index];
    _fullNameController.text = order['fullName'] ?? '';
    _ageController.text = order['age'] ?? '';
    _heightController.text = order['height'] ?? '';
    _weightController.text = order['weight'] ?? '';
    _chestController.text = order['chest'] ?? '';
    _waistController.text = order['waist'] ?? '';
    _hipsController.text = order['hips'] ?? '';
    _shoulderController.text = order['shoulder'] ?? '';
    _armLengthController.text = order['armLength'] ?? '';
    _wristController.text = order['wrist'] ?? '';
    _setPriceController.text = order['price'] ?? '';
    _selectedGender = order['gender'];
    _selectedFittingPreference = order['fittingPreference'];
    _selectedStitchFabric = order['stitchFabric'];
    _selectedThreadFabric = order['threadFabric'];
    _selectedDoubleFabric = order['doubleFabric'];
  }



  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _shoulderController.dispose();
    _armLengthController.dispose();
    _wristController.dispose();
    _setPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFD29356);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Display saved orders as collapsible cards in vertical list (all orders except current)
          if (_orders.length > 1)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Column(
                children: List.generate(
                  _orders.length - 1,
                  (listIndex) {
                    // Skip the current order index
                    int orderIndex = listIndex >= _currentOrderIndex ? listIndex + 1 : listIndex;
                    final order = _orders[orderIndex];
                    final price = order['price'] ?? '0';
                    return GestureDetector(
                      onTap: () {
                        _saveCurrentOrder();
                        setState(() {
                          _expandedStates[_currentOrderIndex] = false;
                          _currentOrderIndex = orderIndex;
                          _expandedStates[orderIndex] = true;
                          _loadOrderData(orderIndex);
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(210, 147, 86, 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color.fromRGBO(210, 147, 86, 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order ${orderIndex + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: accent,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'PKR $price',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: accent,
                                  ),
                                ),
                                if (_orders.length > 1) ...[
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () => _removeOrder(orderIndex),
                                    child: Icon(Icons.close, size: 18, color: Colors.red),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Current order form
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order number indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(210, 147, 86, 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order ${_currentOrderIndex + 1}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                          if (_orders.length > 1)
                            IconButton(
                              tooltip: 'Remove this order',
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: _confirmRemoveCurrentOrder,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
              // Customer Info Section
              const Text(
                'Customer Info',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Full Name
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
                  labelText: 'Full Name',
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
              const SizedBox(height: 12),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  hintText: 'Select Gender',
                  labelText: 'Gender',
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
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: 12),

              // Age and Height Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter age',
                        labelText: 'Age',
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Height (ft)',
                        labelText: 'Height',
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
                ],
              ),
              const SizedBox(height: 12),

              // Weight
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Weight (in kg)',
                  labelText: 'Weight',
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
              const SizedBox(height: 20),

              // Measurements & Fit Section
              const Text(
                'Measurements & Fit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Chest and Waist Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _chestController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Chest',
                        labelText: 'Chest',
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _waistController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Waist',
                        labelText: 'Waist',
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
                ],
              ),
              const SizedBox(height: 12),

              // Hips and Shoulder Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hipsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Hips',
                        labelText: 'Hips',
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _shoulderController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Shoulder',
                        labelText: 'Shoulder',
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
                ],
              ),
              const SizedBox(height: 12),

              // Arm Length and Wrist Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _armLengthController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Arm Length',
                        labelText: 'Arm Length',
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _wristController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Wrist',
                        labelText: 'Wrist',
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
                ],
              ),
              const SizedBox(height: 12),

              // Fitting Preferences Dropdown
              DropdownButtonFormField<String>(
                value: _selectedFittingPreference,
                decoration: InputDecoration(
                  hintText: 'Select Fitting Preference',
                  labelText: 'Fitting Preferences',
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
                items: ['Slim Fit', 'Regular Fit', 'Loose Fit']
                    .map((fit) => DropdownMenuItem(
                          value: fit,
                          child: Text(fit),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedFittingPreference = value),
              ),
              const SizedBox(height: 20),

              // Fabric Details Section
              const Text(
                'Fabric Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Stitch Fabric Dropdown
              DropdownButtonFormField<String>(
                value: _selectedStitchFabric,
                decoration: InputDecoration(
                  hintText: 'Select Fabric',
                  labelText: 'Stitch Fabric',
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
                items: ['Cotton', 'Silk', 'Linen', 'Polyester', 'Wool']
                    .map((fabric) => DropdownMenuItem(
                          value: fabric,
                          child: Text(fabric),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedStitchFabric = value),
              ),
              const SizedBox(height: 12),

              // Thread Fabric Dropdown
              DropdownButtonFormField<String>(
                value: _selectedThreadFabric,
                decoration: InputDecoration(
                  hintText: 'Select Thread Fabric',
                  labelText: 'Thread Fabric',
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
                items: ['Cotton Thread', 'Silk Thread', 'Polyester Thread']
                    .map((thread) => DropdownMenuItem(
                          value: thread,
                          child: Text(thread),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedThreadFabric = value),
              ),
              const SizedBox(height: 12),

              // Double Fabric Optional Dropdown
              DropdownButtonFormField<String>(
                value: _selectedDoubleFabric,
                decoration: InputDecoration(
                  hintText: 'Select Double Fabric (Optional)',
                  labelText: 'Double Fabric (Optional)',
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
                items: ['None', 'Cotton', 'Silk', 'Linen']
                    .map((fabric) => DropdownMenuItem(
                          value: fabric,
                          child: Text(fabric),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedDoubleFabric = value),
              ),
              const SizedBox(height: 20),

              // Pricing Section
              const Text(
                'Pricing',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Set Price
              TextFormField(
                controller: _setPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Price in PKR',
                  labelText: 'Set Price',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Next Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Save current order before navigating
                      _saveCurrentOrder();

                      // Navigate to confirmation page with all orders
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConfirmOrderPage(
                            orders: _orders,
                            preSelectedTailor: widget.preSelectedTailor,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 80), // Extra space for FAB
            ],
          ),
        ),
      ),
    ),
      ],
    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _saveCurrentOrder();
            _addNewOrder();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please complete the current order before adding a new one'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        backgroundColor: accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

