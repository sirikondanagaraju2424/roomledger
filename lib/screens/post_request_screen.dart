import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostRequestScreen extends StatefulWidget {
  final Map<String, dynamic>? existing; // when editing
  const PostRequestScreen({super.key, this.existing});

  @override
  State<PostRequestScreen> createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _priceCtrl   = TextEditingController();

  String _bhk = '1 BHK';
  bool _isAvailable = true;

  final _picker = ImagePicker();
  final List<XFile> _photos = [];
  final Set<String> _amenities = {}; // wifi, parking, pool, gym, laundry, pets

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final m = widget.existing!;
      _titleCtrl.text   = m['title'] ?? '';
      _addressCtrl.text = m['address'] ?? '';
      _descCtrl.text    = m['description'] ?? '';
      _priceCtrl.text   = m['pricePerMonth']?.toString() ?? '';
      _bhk              = m['bhk'] ?? '1 BHK';
      _isAvailable      = m['available'] == true;
      if (m['amenities'] is List) {
        _amenities.addAll((m['amenities'] as List).map((e) => e.toString()));
      }
      // photos are local paths in this demo; skip preloading for simplicity
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _addressCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final imgs = await _picker.pickMultiImage(imageQuality: 85, maxWidth: 1600);
    if (imgs.isNotEmpty) setState(() => _photos.addAll(imgs));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final map = <String, dynamic>{
      'id': widget.existing?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': _titleCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'bhk': _bhk,
      'available': _isAvailable,
      'pricePerMonth': _priceCtrl.text.trim().isEmpty ? null : int.tryParse(_priceCtrl.text.trim()),
      'description': _descCtrl.text.trim(),
      'amenities': _amenities.toList(),
      // store local file paths just for demo (no backend)
      'photos': _photos.map((x) => x.path).toList(),
    };

    Navigator.of(context).pop(map);
  }

  @override
  Widget build(BuildContext context) {
    const headerBlue = Color(0xFF2F7DDE);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerBlue,
        title: const Text('Post or Request Accommodation', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _field(_titleCtrl, 'Title (e.g., Cozy Studio in Downtown)', Icons.home, required: true),
            const SizedBox(height: 12),
            _field(_addressCtrl, 'Address', Icons.location_on, required: true),
            const SizedBox(height: 12),
            _field(_priceCtrl, 'Monthly Rent / Budget (₹)', Icons.price_change, keyboard: TextInputType.number),
            const SizedBox(height: 12),

            // BHK + Type
            Row(
              children: [
                const Text('BHK Type', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _bhk,
                  items: const ['1 BHK', '2 BHK', '3 BHK', '4+ BHK']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _bhk = v!),
                ),
                const Spacer(),
                ChoiceChip(
                  label: const Text('Available'),
                  selected: _isAvailable,
                  onSelected: (v) => setState(() => _isAvailable = true),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Need'),
                  selected: !_isAvailable,
                  onSelected: (v) => setState(() => _isAvailable = false),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text('Details', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _multiline(_descCtrl),
            const SizedBox(height: 16),

            const Text('Amenities', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _amenity('wifi', Icons.wifi, 'WiFi'),
                _amenity('parking', Icons.local_parking, 'Parking'),
                _amenity('pool', Icons.pool, 'Pool'),
                _amenity('gym', Icons.fitness_center, 'Gym'),
                _amenity('laundry', Icons.local_laundry_service, 'Laundry'),
                _amenity('pets', Icons.pets, 'Pets Allowed'),
              ],
            ),
            const SizedBox(height: 16),

            const Text('Upload Photos', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _photoPicker(),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: headerBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Post Listing'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ----- UI helpers -----

  Widget _field(
    TextEditingController c,
    String hint,
    IconData icon, {
    TextInputType? keyboard,
    bool required = false,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Please enter $hint' : null : null,
    );
  }

  Widget _multiline(TextEditingController c) {
    return TextFormField(
      controller: c,
      maxLines: 5,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _amenity(String key, IconData icon, String label) {
    final selected = _amenities.contains(key);
    return FilterChip(
      label: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label)]),
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
    );
  }

  Widget _photoPicker() {
    final canShowFile = !kIsWeb; // Image.file not supported on web without extra handling
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                if (i == _photos.length) {
                  // Add button tile
                  return InkWell(
                    onTap: _pickPhotos,
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Icon(Icons.add_a_photo)),
                    ),
                  );
                }
                final x = _photos[i];
                return Stack(
                  children: [
                    Container(
                      width: 90,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                      child: canShowFile
                          ? Image.file(File(x.path), fit: BoxFit.cover)
                          : const ColoredBox(color: Color(0xFFEAEAEA)),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: InkWell(
                        onTap: () => setState(() => _photos.removeAt(i)),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: _photos.length + 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Tap to add photos', style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
