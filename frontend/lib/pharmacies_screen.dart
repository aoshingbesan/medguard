import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'simple_language_service.dart';
import 'theme.dart';
import 'api.dart';
import 'widgets/academic_disclaimer.dart';

class Pharmacy {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final String? email;
  final String? district;
  final String? sector;
  final String? cell;
  final double? latitude;
  final double? longitude;
  final String? googleMapsLink;
  final bool isVerified;
  
  Pharmacy({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.email,
    this.district,
    this.sector,
    this.cell,
    this.latitude,
    this.longitude,
    this.googleMapsLink,
    this.isVerified = true,
  });

  factory Pharmacy.fromMap(Map<String, dynamic> map) {
    return Pharmacy(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      address: map['address'],
      phone: map['phone'],
      email: map['email'],
      district: map['district'],
      sector: map['sector'],
      cell: map['cell'],
      latitude: map['latitude'] != null ? (map['latitude'] is double ? map['latitude'] : (map['latitude'] as num).toDouble()) : null,
      longitude: map['longitude'] != null ? (map['longitude'] is double ? map['longitude'] : (map['longitude'] as num).toDouble()) : null,
      googleMapsLink: map['google_maps_link'],
      isVerified: map['is_verified'] ?? true,
    );
  }

  String get fullAddress {
    final parts = <String>[];
    if (cell != null && cell!.isNotEmpty) parts.add(cell!);
    if (sector != null && sector!.isNotEmpty) parts.add(sector!);
    if (district != null && district!.isNotEmpty) parts.add(district!);
    if (parts.isEmpty && address != null && address!.isNotEmpty) {
      return address!;
    }
    return parts.join(', ');
  }
}

class PharmaciesScreen extends StatefulWidget {
  const PharmaciesScreen({super.key});

  @override
  State<PharmaciesScreen> createState() => _PharmaciesScreenState();
}

class _PharmaciesScreenState extends State<PharmaciesScreen> {
  final TextEditingController _search = TextEditingController();
  List<Pharmacy> _all = [];
  List<Pharmacy> _filtered = [];
  bool _isLoading = true;
  String _error = '';
  String _q = '';

  @override
  void initState() {
    super.initState();
    _loadPharmacies();
  }

  Future<void> _loadPharmacies() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final data = await Api.getPharmacies();
      final pharmacies = data.map((map) => Pharmacy.fromMap(map)).toList();
      
      setState(() {
        _all = pharmacies;
        _filtered = pharmacies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load pharmacies: $e';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _q = query;
      if (query.isEmpty) {
        _filtered = _all;
      } else {
        final lowerQuery = query.toLowerCase();
        _filtered = _all.where((p) {
          return p.name.toLowerCase().contains(lowerQuery) ||
              (p.address?.toLowerCase().contains(lowerQuery) ?? false) ||
              (p.district?.toLowerCase().contains(lowerQuery) ?? false) ||
              (p.sector?.toLowerCase().contains(lowerQuery) ?? false);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    
    return Consumer<SimpleLanguageService>(
      builder: (context, languageService, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                languageService.verifiedPharmacies,
                style: t.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: kBrandPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _search,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: languageService.searchPharmacies,
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE6E9EF)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadPharmacies,
                child: _isLoading && _all.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty && _all.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.red.shade300),
                            const SizedBox(height: 16),
                            Text(_error,
                                style: t.bodyLarge?.copyWith(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadPharmacies,
                              child: Text(languageService.retry),
                            ),
                          ],
                        ),
                      )
                    : _filtered.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off,
                                        size: 64, color: Colors.grey.shade400),
                                    const SizedBox(height: 16),
                                    Text(
                                      _q.isEmpty
                                          ? languageService.noPharmaciesFound
                                          : '${languageService.noPharmaciesMatch} "$_q"',
                                      style: t.bodyLarge?.copyWith(
                                          color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final p = _filtered[i];
                              return Card(
                                elevation: 0,
                                color: Colors.white,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        kBrandPrimary.withOpacity(0.12),
                                    child: Icon(
                                      Icons.local_pharmacy_rounded,
                                      color: kBrandPrimary,
                                    ),
                                  ),
                                  title: Text(p.name, style: t.titleMedium),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      p.fullAddress.isNotEmpty
                                          ? p.fullAddress
                                          : languageService.addressNotAvailable,
                                      style: t.bodyMedium?.copyWith(
                                          color: kTextSecondary),
                                    ),
                                  ),
                                  trailing: p.district != null
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            if (p.isVerified)
                                              Icon(Icons.verified,
                                                  color: kSuccess, size: 20),
                                            if (p.district != null) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                p.district!,
                                                style: t.bodySmall?.copyWith(
                                                  color: kTextSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ],
                                        )
                                      : null,
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      showDragHandle: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20)),
                                      ),
                                      builder: (_) => _PharmacySheet(p: p),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PharmacySheet extends StatelessWidget {
  final Pharmacy p;
  const _PharmacySheet({required this.p});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final languageService = Provider.of<SimpleLanguageService>(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(p.name, style: t.headlineSmall),
              ),
              if (p.isVerified)
                Icon(Icons.verified, color: kSuccess, size: 24),
            ],
          ),
          const SizedBox(height: 6),
          if (p.fullAddress.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.place_rounded,
                    size: 18, color: kTextSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    p.fullAddress,
                    style:
                        t.bodyMedium?.copyWith(color: kTextSecondary),
                  ),
                ),
              ],
            ),
          if (p.district != null || p.sector != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (p.district != null)
                  Chip(
                    label: Text(p.district!),
                    avatar: const Icon(Icons.location_city, size: 16),
                    visualDensity: VisualDensity.compact,
                  ),
                if (p.sector != null)
                  Chip(
                    label: Text(p.sector!),
                    avatar: const Icon(Icons.location_on, size: 16),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
          if (p.phone != null && p.phone!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.phone_rounded,
                    size: 18, color: kTextSecondary),
                const SizedBox(width: 6),
                Text(p.phone!,
                    style: t.bodyMedium?.copyWith(color: kTextSecondary)),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (p.phone != null && p.phone!.isNotEmpty)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse('tel:${p.phone}');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(languageService.cannotMakePhoneCall),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.call_rounded),
                    label: Text(languageService.call),
                  ),
                ),
              if (p.phone != null && p.phone!.isNotEmpty)
                const SizedBox(width: 10),
              if (p.googleMapsLink != null || (p.latitude != null && p.longitude != null))
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      bool launched = false;
                      
                      // Prefer Google Maps link if available
                      if (p.googleMapsLink != null && p.googleMapsLink!.isNotEmpty) {
                        try {
                          final mapUri = Uri.parse(p.googleMapsLink!);
                          if (await canLaunchUrl(mapUri)) {
                            await launchUrl(mapUri, mode: LaunchMode.externalApplication);
                            launched = true;
                          }
                        } catch (e) {
                          debugPrint('Error parsing Google Maps link: $e');
                        }
                      }
                      
                      // If no link or link failed, use coordinates
                      if (!launched && p.latitude != null && p.longitude != null) {
                        final lat = p.latitude!;
                        final lon = p.longitude!;
                        final pharmacyName = Uri.encodeComponent(p.name);
                        
                        // Try multiple URI schemes for maximum compatibility
                        final uris = [
                          // Android: geo URI scheme (most universal - opens default map app)
                          Uri.parse('geo:$lat,$lon'),
                          // Android: geo URI with label (alternative format)
                          Uri.parse('geo:0,0?q=$lat,$lon($pharmacyName)'),
                          // Android: Google Maps directions intent
                          Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lon'),
                          // Android: Google Maps search
                          Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon'),
                          // Web fallback
                          Uri.parse('https://maps.google.com/?q=$lat,$lon'),
                        ];
                        
                        for (final uri in uris) {
                          try {
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                              launched = true;
                              break;
                            }
                          } catch (e) {
                            debugPrint('Error launching URI $uri: $e');
                            continue;
                          }
                        }
                      }
                      
                      if (!launched && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(languageService.cannotOpenMaps),
                            action: SnackBarAction(
                              label: languageService.openInBrowser,
                              onPressed: () async {
                                if (p.latitude != null && p.longitude != null) {
                                  final webUri = Uri.parse(
                                    'https://www.google.com/maps/search/?api=1&query=${p.latitude},${p.longitude}'
                                  );
                                  if (await canLaunchUrl(webUri)) {
                                    await launchUrl(webUri, mode: LaunchMode.externalApplication);
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.directions_rounded),
                    label: Text(languageService.directions),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
