// lib/history_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItemDTO {
  final String brand;
  final String gtin;
  final String? lot;
  final bool verified;
  final DateTime scannedAt;
  final Map<String, dynamic>? data; // Full product data for viewing details

  HistoryItemDTO({
    required this.brand,
    required this.gtin,
    this.lot,
    required this.verified,
    required this.scannedAt,
    this.data,
  });

  Map<String, dynamic> toMap() => {
        'brand': brand,
        'gtin': gtin,
        'lot': lot,
        'verified': verified,
        'scannedAt': scannedAt.toIso8601String(),
        'data': data, // Store full data
      };

  factory HistoryItemDTO.fromMap(Map<String, dynamic> m) => HistoryItemDTO(
        brand: m['brand'] ?? '',
        gtin: m['gtin'] ?? '',
        lot: m['lot'],
        verified: m['verified'] == true,
        scannedAt: DateTime.tryParse(m['scannedAt'] ?? '') ?? DateTime.now(),
        data: m['data'] != null ? Map<String, dynamic>.from(m['data']) : null,
      );
}

class HistoryStorage {
  static const _k = 'medguard_history_v1';

  /// Prepend newest item.
  static Future<void> add(HistoryItemDTO item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_k) ?? <String>[];
    list.insert(0, jsonEncode(item.toMap()));
    await prefs.setStringList(_k, list);
  }

  static Future<List<HistoryItemDTO>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_k) ?? <String>[];
    return list
        .map((s) => jsonDecode(s))
        .whereType<Map<String, dynamic>>()
        .map(HistoryItemDTO.fromMap)
        .toList();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_k);
  }
}
