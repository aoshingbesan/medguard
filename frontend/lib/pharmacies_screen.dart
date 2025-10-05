import 'package:flutter/material.dart';
import 'theme.dart';

class Pharmacy {
  final String name;
  final String address;
  final String phone;
  final bool openNow; // simple flag; replace with real hours later
  Pharmacy({required this.name, required this.address, required this.phone, required this.openNow});
}

class PharmaciesScreen extends StatefulWidget {
  const PharmaciesScreen({super.key});

  @override
  State<PharmaciesScreen> createState() => _PharmaciesScreenState();
}

class _PharmaciesScreenState extends State<PharmaciesScreen> {
  final TextEditingController _search = TextEditingController();
  final List<Pharmacy> _all = [
    Pharmacy(name: 'CityCare Pharmacy', address: 'KG 11 Ave, Kigali', phone: '+250 788 123 456', openNow: true),
    Pharmacy(name: 'HealthPlus Pharmacy', address: 'KN 3 Rd, Kigali', phone: '+250 783 987 210', openNow: true),
    Pharmacy(name: 'MedTrust Pharmacy', address: 'KK 15 St, Kicukiro', phone: '+250 789 112 334', openNow: false),
    Pharmacy(name: 'GreenLeaf Pharmacy', address: 'KG 7 Ave, Gacuriro', phone: '+250 784 223 765', openNow: true),
  ];

  String _q = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final filtered = _all.where((p) {
      if (_q.isEmpty) return true;
      final q = _q.toLowerCase();
      return p.name.toLowerCase().contains(q) || p.address.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _search,
            onChanged: (v) => setState(() => _q = v),
            decoration: InputDecoration(
              hintText: 'Search pharmacies…',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE6E9EF)),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
          ),
        ),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final p = filtered[i];
              return Card(
                elevation: 0,
                color: Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: kBrandPrimary.withOpacity(0.12),
                    child: const Icon(Icons.local_pharmacy_rounded, color: kBrandPrimary),
                  ),
                  title: Text(p.name, style: t.titleMedium),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(p.address, style: t.bodyMedium?.copyWith(color: kTextSecondary)),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        p.openNow ? Icons.check_circle_rounded : Icons.schedule_rounded,
                        color: p.openNow ? kSuccess : kWarning,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.openNow ? 'Open now' : 'Closes soon',
                        style: t.bodySmall?.copyWith(
                          color: p.openNow ? kSuccess : kWarning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Later: deep-link to Maps or show a detail sheet with route/phone
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => _PharmacySheet(p: p),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PharmacySheet extends StatelessWidget {
  final Pharmacy p;
  const _PharmacySheet({required this.p});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.name, style: t.headlineSmall),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.place_rounded, size: 18, color: kTextSecondary),
              const SizedBox(width: 6),
              Expanded(child: Text(p.address, style: t.bodyMedium?.copyWith(color: kTextSecondary))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone_rounded, size: 18, color: kTextSecondary),
              const SizedBox(width: 6),
              Text(p.phone, style: t.bodyMedium?.copyWith(color: kTextSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: integrate url_launcher to dial
                    // launchUrl(Uri.parse('tel:${p.phone}'));
                  },
                  icon: const Icon(Icons.call_rounded),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    // TODO: integrate maps deep-link
                    // launchUrl(Uri.parse('https://maps.google.com/?q=${Uri.encodeComponent(p.name)} ${Uri.encodeComponent(p.address)}'));
                  },
                  icon: const Icon(Icons.directions_rounded),
                  label: const Text('Directions'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
