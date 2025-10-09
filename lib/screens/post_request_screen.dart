// lib/screens/post_request_screen.dart
import 'package:flutter/material.dart';
import '../models/accommodation.dart';
import '../services/api_service.dart';

class PostRequestScreen extends StatefulWidget {
  final Accommodation? editing; // if present -> edit mode
  const PostRequestScreen({super.key, this.editing});

  @override
  State<PostRequestScreen> createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _address = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _user = TextEditingController(text: 'naga');

  int _bhk = 1;
  bool _available = true; // false => Need
  final Set<String> _amenities = <String>{};

  bool _submitting = false;
  bool get isEdit => widget.editing != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final a = widget.editing!;
      _title.text = a.title ?? '';
      _address.text = a.address ?? '';
      _description.text = a.description ?? '';
      _price.text = a.price ?? '';
      _user.text = a.userName ?? 'naga';
      _bhk = a.bhk ?? 1;
      _available = (a.type ?? '').toUpperCase() != 'NEEDED';
      _amenities.addAll(a.amenities);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _address.dispose();
    _description.dispose();
    _price.dispose();
    _user.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final type = _available ? 'AVAILABLE' : 'NEEDED';
      final am = _amenities.toList();

      if (isEdit) {
        await ApiService.updateListing(widget.editing!.id!, {
          'title': _title.text.trim(),
          'address': _address.text.trim(),
          'bhk': _bhk,
          'type': type,
          'price': _price.text.trim(), // keep string for backend Decimal
          'userName': _user.text.trim(),
          'description': _description.text.trim(),
          'amenities': am,
        });
      } else {
        await ApiService.createListing(
          title: _title.text.trim(),
          address: _address.text.trim(),
          bhk: _bhk,
          type: type,
          price: _price.text.trim(),
          userName: _user.text.trim(),
          description: _description.text.trim(),
          amenities: am,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Listing updated' : 'Listing posted'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = isEdit ? 'Edit Listing' : 'Post or Request Accommodation';
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFE0B2), Color(0xFFFFF3E0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 20),
                Text(
                  titleText,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _input(label: 'Title', controller: _title, hint: 'Cozy Studio'),
              const SizedBox(height: 12),
              _input(label: 'Address', controller: _address, hint: '456 Oak St'),
              const SizedBox(height: 12),
              _input(
                label: 'Detailed Description',
                controller: _description,
                hint: 'Tell us about the place…',
                maxLines: 4,
                requiredField: false,
              ),
              const SizedBox(height: 12),
              _input(
                label: 'Monthly Rent/Budget',
                controller: _price,
                hint: 'e.g. 1220.50',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text('BHK Type', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: [1, 2, 3, 4].map((v) {
                  return ChoiceChip(
                    label: Text('$v BHK'),
                    selected: _bhk == v,
                    onSelected: (_) => setState(() => _bhk = v),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Available'),
                    selected: _available,
                    onSelected: (_) => setState(() => _available = true),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Need'),
                    selected: !_available,
                    onSelected: (_) => setState(() => _available = false),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Amenities', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _amenity('wifi', Icons.wifi, 'Wifi'),
                  _amenity('parking', Icons.local_parking, 'Parking'),
                  _amenity('pool', Icons.pool, 'Pool'),
                  _amenity('gym', Icons.fitness_center, 'Gym'),
                  _amenity('laundry', Icons.local_laundry_service, 'Laundry'),
                  _amenity('pets', Icons.pets, 'Pets'),
                ],
              ),
              const SizedBox(height: 24),
              _input(
                label: 'Your Name',
                controller: _user,
                hint: 'naga',
                requiredField: false,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isEdit ? 'Update Listing' : 'Post Listing', style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ----- widgets/helpers -----
  Widget _input({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool requiredField = true,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: requiredField
              ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _amenity(String key, IconData icon, String label) {
    final selected = _amenities.contains(key);
    return FilterChip(
      avatar: Icon(icon, size: 18, color: selected ? Colors.white : Colors.black54),
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          if (selected) {
            _amenities.remove(key);
          } else {
            _amenities.add(key);
          }
        });
      },
      selectedColor: const Color(0xFF1E63B6),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(color: selected ? Colors.white : null),
    );
  }
}
