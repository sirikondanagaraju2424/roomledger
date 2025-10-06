import 'package:flutter/material.dart';
import 'post_request_screen.dart';

enum ListingTab { available, need }

class AccommodationsListScreen extends StatefulWidget {
  const AccommodationsListScreen({super.key});

  @override
  State<AccommodationsListScreen> createState() => _AccommodationsListScreenState();
}

class _AccommodationsListScreenState extends State<AccommodationsListScreen> {
  // Demo data kept in memory (no backend)
  final List<Map<String, dynamic>> _all = [
    {
      'id': '1',
      'title': 'Cozy Studio in Downtown',
      'address': '456 Oak St, City C',
      'bhk': '1 BHK',
      'available': true,
      'pricePerMonth': 1220,
      'description': 'Fully furnished, in-unit laundry.',
      'amenities': ['wifi', 'laundry'],
      'photos': <String>[],
    },
    {
      'id': '2',
      'title': 'Need a shared 2 BHK near Tech Park',
      'address': 'City B',
      'bhk': '2 BHK',
      'available': false,
      'pricePerMonth': 800,
      'description': 'Budget 800. Prefer non-smoking.',
      'amenities': ['wifi'],
      'photos': <String>[],
    },
  ];

  ListingTab _tab = ListingTab.available;
  String _query = '';

  List<Map<String, dynamic>> get _filtered {
    final isAvail = _tab == ListingTab.available;
    final q = _query.trim().toLowerCase();
    return _all.where((m) {
      if ((m['available'] == true) != isAvail) return false;
      if (q.isEmpty) return true;
      final hay = '${m['title']} ${m['address']} ${m['bhk']}'.toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  void _openPost({Map<String, dynamic>? editItem}) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => PostRequestScreen(existing: editItem),
      ),
    );
    if (result == null) return;
    setState(() {
      if (editItem == null) {
        _all.insert(0, result);
      } else {
        final i = _all.indexWhere((e) => e['id'] == editItem['id']);
        if (i != -1) _all[i] = result;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1E3A5F);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accommodations', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: primary,
      ),
      body: Column(
        children: [
          // Segmented control
          Container(
            color: primary,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.12),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  _segment('Available', _tab == ListingTab.available, onTap: () {
                    setState(() => _tab = ListingTab.available);
                  }),
                  _segment('Need', _tab == ListingTab.need, onTap: () {
                    setState(() => _tab = ListingTab.need);
                  }),
                ],
              ),
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search location, title…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemBuilder: (_, i) => _card(_filtered[i]),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: _filtered.length,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openPost(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F7DDE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Post or Request Accommodation'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _segment(String label, bool selected, {required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? const Color(0xFF1E3A5F) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(Map<String, dynamic> m) {
    final isAvail = m['available'] == true;
    final chipColor = isAvail ? const Color(0xFF34C759) : const Color(0xFFFF8A4D);
    final chipText = isAvail ? 'Available' : 'Needed';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        title: Text(m['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m['address'] ?? '', style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: chipColor.withOpacity(.12), borderRadius: BorderRadius.circular(20)),
                    child: Text(chipText, style: TextStyle(color: chipColor, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  _tag(m['bhk'] ?? '1 BHK'),
                ],
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') _openPost(editItem: m);
            if (v == 'delete') setState(() => _all.removeWhere((e) => e['id'] == m['id']));
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.meeting_room, size: 16, color: Colors.black54),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
