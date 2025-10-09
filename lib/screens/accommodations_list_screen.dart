// lib/screens/accommodations_list_screen.dart
import 'package:flutter/material.dart';
import '../models/accommodation.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'post_request_screen.dart';

class AccommodationsListScreen extends StatefulWidget {
  const AccommodationsListScreen({super.key});

  @override
  State<AccommodationsListScreen> createState() => _AccommodationsListScreenState();
}

class _AccommodationsListScreenState extends State<AccommodationsListScreen> {
  int _tab = 0; // 0=Available, 1=Need
  late Future<List<Accommodation>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getListings();
  }

  Future<void> _refresh() async {
    setState(() => _future = ApiService.getListings());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
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
                   onPressed: () {
                     // Use GoRouter to pop to welcome screen
                     if (Navigator.of(context).canPop()) {
                       Navigator.of(context).pop();
                     } else {
                       // fallback: pushReplacement to welcome
                       context.go('/');
                     }
                   },
                 ),
                 const SizedBox(width: 20),
                 Text(
                   'Accommodations',
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
      body: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Available'),
                selected: _tab == 0,
                selectedColor: Colors.deepOrange,
                labelStyle: TextStyle(
                  color: _tab == 0 ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) => setState(() => _tab = 0),
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 16),
              ChoiceChip(
                label: const Text('Need'),
                selected: _tab == 1,
                selectedColor: Colors.black,
                labelStyle: TextStyle(
                  color: _tab == 1 ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) => setState(() => _tab = 1),
                backgroundColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Accommodation>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final all = snap.data ?? <Accommodation>[];
                final shown = all.where((a) {
                  final t = (a.type ?? '').toUpperCase();
                  return _tab == 0 ? t == 'AVAILABLE' : t == 'NEEDED';
                }).toList();
                if (shown.isEmpty) {
                  return Center(
                    child: Text(
                      _tab == 0
                          ? 'No available listings yet.'
                          : 'No “Need” listings yet.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: shown.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) => _ListingCard(
                      a: shown[i],
                      onChanged: _refresh,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - 32,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          onPressed: () async {
            context.push('/accommodations/post').then((value) {
              if (value == true) _refresh();
            });
          },
          child: const Text('Post or Request', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final Accommodation a;
  final VoidCallback onChanged;
  const _ListingCard({required this.a, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final badgeColor =
        (a.type ?? '').toUpperCase() == 'AVAILABLE' ? Colors.green : Colors.orange;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFFF8F6FB),
      child: InkWell(
        onTap: () {
          // ...existing code for modal bottom sheet (optional)
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blueGrey.shade100,
                    child: Text(
                      a.title != null && a.title!.isNotEmpty ? a.title![0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      a.title ?? 'Untitled',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.apartment, size: 18, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text('${a.bhk ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(.15),
                      border: Border.all(color: badgeColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (a.type ?? '').toUpperCase(),
                      style: TextStyle(color: badgeColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      a.address ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (a.description != null && a.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(a.description!, style: const TextStyle(fontSize: 14, color: Colors.black)),
              ],
              const SizedBox(height: 8),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.payments, size: 18, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    a.price != null && a.price.toString().isNotEmpty ? '\$${a.price} /month' : 'Rent not specified',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.deepOrange),
                    onPressed: () {
                      context.push('/accommodations/chat/${Uri.encodeComponent(a.title ?? '')}');
                    },
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        context.push('/accommodations/edit/${a.id}', extra: a).then((value) {
                          if (value == true) onChanged();
                        });
                      } else if (v == 'delete') {
                        await ApiService.deleteListing(a.id!);
                        onChanged();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Listing deleted')),
                          );
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              if (a.amenities.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: a.amenities.map((am) {
                    IconData? icon;
                    switch (am.toLowerCase()) {
                      case 'wifi': icon = Icons.wifi; break;
                      case 'parking': icon = Icons.local_parking; break;
                      case 'pool': icon = Icons.pool; break;
                      case 'gym': icon = Icons.fitness_center; break;
                      case 'laundry': icon = Icons.local_laundry_service; break;
                      case 'pets': icon = Icons.pets; break;
                      default: icon = Icons.check_circle_outline;
                    }
                    return Chip(
                      avatar: Icon(icon, size: 18),
                      label: Text(am),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
