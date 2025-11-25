import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'offline_database.dart';
import 'gtin_scanner/services/gtin_validator.dart';

class Api {
  static const String _lastSyncKey = 'last_sync_timestamp';
  
  static SupabaseClient get _supabase => Supabase.instance.client;

  static Future<bool> isOnline() async {
    try {
      // Try to query Supabase to check connection
      await _supabase
          .from('products')
          .select('id')
          .limit(1)
          .timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> verifyOnline(String gtin) async {
    try {
      // Clean GTIN - only digits, remove any non-digit characters
      String cleanGtin = gtin.replaceAll(RegExp(r'[^\d]'), '').trim();
      
      // Validate GTIN length (should be 8, 12, 13, or 14 digits)
      if (cleanGtin.isEmpty) {
        return {
          'status': 'error',
          'message': 'Invalid GTIN: Empty or no digits found',
          'source': 'online',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      }
      
      if (cleanGtin.length < 8 || cleanGtin.length > 14) {
        return {
          'status': 'error',
          'message': 'Invalid GTIN length: ${cleanGtin.length} digits (expected 8-14)',
          'source': 'online',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      }
      
      // Try exact match first (as text)
      debugPrint('Querying GTIN: $cleanGtin (exact match)');
      
      try {
        // Explicitly select all columns to ensure we get all data
        Map<String, dynamic>? response = await _supabase
            .from('products')
            .select('*')
            .eq('gtin', cleanGtin)
            .maybeSingle();
        
        if (response != null) {
          // Helper function to safely extract field value with multiple column name attempts
          String _extractField(Map<String, dynamic> data, List<String> possibleKeys) {
            // First, try exact matches
            for (String key in possibleKeys) {
              if (data.containsKey(key)) {
                final value = data[key];
                if (value != null) {
                  if (value is String && value.trim().isNotEmpty) {
                    return value.trim();
                  } else if (value is DateTime) {
                    return value.toIso8601String().split('T')[0];
                  } else if (value.toString().trim().isNotEmpty) {
                    return value.toString().trim();
                  }
                }
              }
            }
            
            // Try case-insensitive matches
            final allKeys = data.keys.toList();
            for (String possibleKey in possibleKeys) {
              final lowerKey = possibleKey.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
              for (String actualKey in allKeys) {
                final lowerActualKey = actualKey.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
                if (lowerActualKey == lowerKey || 
                    lowerActualKey.contains(lowerKey) || 
                    lowerKey.contains(lowerActualKey)) {
                  final value = data[actualKey];
                  if (value != null) {
                    if (value is String && value.trim().isNotEmpty) {
                      return value.trim();
                    } else if (value is DateTime) {
                      return value.toIso8601String().split('T')[0];
                    } else if (value.toString().trim().isNotEmpty) {
                      return value.toString().trim();
                    }
                  }
                }
              }
            }
            
            return '';
          }
          
          // Helper function to safely extract field value
          String _extractString(dynamic value) {
            if (value == null) return '';
            if (value is String) {
              final trimmed = value.trim();
              return trimmed.isEmpty ? '' : trimmed;
            }
            if (value is DateTime) return value.toIso8601String().split('T')[0]; // Format as YYYY-MM-DD
            final str = value.toString().trim();
            return str.isEmpty ? '' : str;
          }
          
          // Try multiple possible column name variations - use actual database column names first
          final productName = _extractField(response, ['product_brand_name', 'product_name', 'productName', 'product', 'Product Name']);
          final brand = _extractField(response, ['product_brand_name', 'brand', 'Brand']);
          final strength = _extractField(response, ['dosage_strength', 'strength', 'Strength']);
          final manufacturer = _extractField(response, ['manufacturer_name', 'manufacturer', 'Manufacturer']);
          // Registration Number: use registration_no (not rfda_reg_no)
          final rfdaRegNo = _extractField(response, ['registration_no', 'rfda_reg_no', 'rfdaRegNo', 'RFDA Reg No', 'registration_number']);
          final licenseExpiryDate = _extractField(response, ['license_expiry_date', 'licenseExpiryDate', 'license_expiry_date', 'License Expiry Date']);
          // Marketing Authorization Holder: use marketing_authorization_holder (not marketing_auth_holder)
          final marketingAuthHolder = _extractField(response, ['marketing_authorization_holder', 'marketing_auth_holder', 'marketingAuthHolder', 'Marketing Auth Holder']);
          // Local Representative: use local_technical_representative
          final localTechRep = _extractField(response, ['local_technical_representative', 'local_tech_rep', 'localTechRep', 'Local Tech Rep']);
          
          // Use extracted values with fallbacks
          final finalProductName = productName.isNotEmpty ? productName : (brand.isNotEmpty ? brand : '');
          final finalBrand = brand.isNotEmpty ? brand : (productName.isNotEmpty ? productName : '');
          
          return {
            'status': 'valid',
            'gtin': _extractString(response['gtin']),
            'product': finalProductName,
            'product_name': finalProductName,
            'brand': finalBrand,
            'genericName': _extractString(response['generic_name']),
            'manufacturer': manufacturer,
            'registrationNumber': rfdaRegNo,
            'dosageForm': _extractString(response['dosage_form']),
            'strength': strength,
            'pack_size': _extractString(response['pack_size']),
            'expiry_date': _extractString(response['expiry_date']),
            'shelf_life': _extractString(response['shelf_life']),
            'packaging_type': _extractString(response['packaging_type']),
            'marketing_authorization_holder': marketingAuthHolder,
            'local_technical_representative': localTechRep,
            'registration_date': _extractString(response['registration_date']),
            'license_expiry_date': licenseExpiryDate,
            'country': _extractString(response['country']),
            'source': 'online',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          };
        }
        
        // Try numeric matching (if GTIN is stored as number)
        final numericGtin = int.tryParse(cleanGtin);
        if (numericGtin != null) {
          debugPrint('Trying numeric match for GTIN: $numericGtin');
          response = await _supabase
              .from('products')
              .select('*')
              .eq('gtin', numericGtin.toString())
              .maybeSingle();
          
          if (response != null) {
            // Helper function to safely extract field value with multiple column name attempts
            String _extractField(Map<String, dynamic> data, List<String> possibleKeys) {
              // First, try exact matches
              for (String key in possibleKeys) {
                if (data.containsKey(key)) {
                  final value = data[key];
                  if (value != null) {
                    if (value is String && value.trim().isNotEmpty) {
                      return value.trim();
                    } else if (value is DateTime) {
                      return value.toIso8601String().split('T')[0];
                    } else if (value.toString().trim().isNotEmpty) {
                      return value.toString().trim();
                    }
                  }
                }
              }
              
              // Try case-insensitive matches
              final allKeys = data.keys.toList();
              for (String possibleKey in possibleKeys) {
                final lowerKey = possibleKey.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
                for (String actualKey in allKeys) {
                  final lowerActualKey = actualKey.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
                  if (lowerActualKey == lowerKey || 
                      lowerActualKey.contains(lowerKey) || 
                      lowerKey.contains(lowerActualKey)) {
                    final value = data[actualKey];
                    if (value != null) {
                      if (value is String && value.trim().isNotEmpty) {
                        return value.trim();
                      } else if (value is DateTime) {
                        return value.toIso8601String().split('T')[0];
                      } else if (value.toString().trim().isNotEmpty) {
                        return value.toString().trim();
                      }
                    }
                  }
                }
              }
              
              return '';
            }
            
            // Helper function to safely extract field value
            String _extractString(dynamic value) {
              if (value == null) return '';
              if (value is String) {
                final trimmed = value.trim();
                return trimmed.isEmpty ? '' : trimmed;
              }
              if (value is DateTime) return value.toIso8601String().split('T')[0]; // Format as YYYY-MM-DD
              final str = value.toString().trim();
              return str.isEmpty ? '' : str;
            }
            
            // Try multiple possible column name variations - use actual database column names first
            final productName = _extractField(response, ['product_brand_name', 'product_name', 'productName', 'product', 'Product Name']);
            final brand = _extractField(response, ['product_brand_name', 'brand', 'Brand']);
            final strength = _extractField(response, ['dosage_strength', 'strength', 'Strength']);
            final manufacturer = _extractField(response, ['manufacturer_name', 'manufacturer', 'Manufacturer']);
            // Registration Number: use registration_no (not rfda_reg_no)
            final rfdaRegNo = _extractField(response, ['registration_no', 'rfda_reg_no', 'rfdaRegNo', 'RFDA Reg No', 'registration_number']);
            final licenseExpiryDate = _extractField(response, ['license_expiry_date', 'licenseExpiryDate', 'license_expiry_date', 'License Expiry Date']);
            // Marketing Authorization Holder: use marketing_authorization_holder (not marketing_auth_holder)
            final marketingAuthHolder = _extractField(response, ['marketing_authorization_holder', 'marketing_auth_holder', 'marketingAuthHolder', 'Marketing Auth Holder']);
            // Local Representative: use local_technical_representative
            final localTechRep = _extractField(response, ['local_technical_representative', 'local_tech_rep', 'localTechRep', 'Local Tech Rep']);
            
            // Use extracted values with fallbacks
            final finalProductName = productName.isNotEmpty ? productName : (brand.isNotEmpty ? brand : '');
            final finalBrand = brand.isNotEmpty ? brand : (productName.isNotEmpty ? productName : '');
            
            return {
              'status': 'valid',
              'gtin': _extractString(response['gtin']),
              'product': finalProductName,
              'product_name': finalProductName,
              'brand': finalBrand,
              'genericName': _extractString(response['generic_name']),
              'manufacturer': manufacturer,
              'registrationNumber': rfdaRegNo,
              'dosageForm': _extractString(response['dosage_form']),
              'strength': strength,
              'pack_size': _extractString(response['pack_size']),
              'expiry_date': _extractString(response['expiry_date']),
              'shelf_life': _extractString(response['shelf_life']),
              'packaging_type': _extractString(response['packaging_type']),
              'marketing_authorization_holder': marketingAuthHolder,
              'local_technical_representative': localTechRep,
              'registration_date': _extractString(response['registration_date']),
              'license_expiry_date': licenseExpiryDate,
              'country': _extractString(response['country']),
              'source': 'online',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            };
          }
        }
        
        // If original format didn't match, try normalized GTIN-14 format as fallback
        // This handles cases where database might store normalized format
        if (cleanGtin.length < 14) {
          final normalizedGtin = GtinValidator.normalizeToGtin14(cleanGtin);
          if (normalizedGtin != cleanGtin && normalizedGtin.isNotEmpty) {
            debugPrint('Trying normalized GTIN-14 format: $normalizedGtin (original: $cleanGtin)');
            try {
              response = await _supabase
                  .from('products')
                  .select('*')
                  .eq('gtin', normalizedGtin)
                  .maybeSingle();
              
              if (response != null) {
                // Use the same extraction logic as above
                String _extractField(Map<String, dynamic> data, List<String> possibleKeys) {
                  for (String key in possibleKeys) {
                    if (data.containsKey(key)) {
                      final value = data[key];
                      if (value != null) {
                        if (value is String && value.trim().isNotEmpty) {
                          return value.trim();
                        } else if (value is DateTime) {
                          return value.toIso8601String().split('T')[0];
                        } else if (value.toString().trim().isNotEmpty) {
                          return value.toString().trim();
                        }
                      }
                    }
                  }
                  final allKeys = data.keys.toList();
                  for (String possibleKey in possibleKeys) {
                    final lowerKey = possibleKey.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
                    for (String actualKey in allKeys) {
                      final lowerActualKey = actualKey.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
                      if (lowerActualKey == lowerKey || 
                          lowerActualKey.contains(lowerKey) || 
                          lowerKey.contains(lowerActualKey)) {
                        final value = data[actualKey];
                        if (value != null) {
                          if (value is String && value.trim().isNotEmpty) {
                            return value.trim();
                          } else if (value is DateTime) {
                            return value.toIso8601String().split('T')[0];
                          } else if (value.toString().trim().isNotEmpty) {
                            return value.toString().trim();
                          }
                        }
                      }
                    }
                  }
                  return '';
                }
                
                String _extractString(dynamic value) {
                  if (value == null) return '';
                  if (value is String) {
                    final trimmed = value.trim();
                    return trimmed.isEmpty ? '' : trimmed;
                  }
                  if (value is DateTime) return value.toIso8601String().split('T')[0];
                  final str = value.toString().trim();
                  return str.isEmpty ? '' : str;
                }
                
                final productName = _extractField(response, ['product_brand_name', 'product_name', 'productName', 'product', 'Product Name']);
                final brand = _extractField(response, ['product_brand_name', 'brand', 'Brand']);
                final strength = _extractField(response, ['dosage_strength', 'strength', 'Strength']);
                final manufacturer = _extractField(response, ['manufacturer_name', 'manufacturer', 'Manufacturer']);
                final rfdaRegNo = _extractField(response, ['registration_no', 'rfda_reg_no', 'rfdaRegNo', 'RFDA Reg No', 'registration_number']);
                final licenseExpiryDate = _extractField(response, ['license_expiry_date', 'licenseExpiryDate', 'license_expiry_date', 'License Expiry Date']);
                final marketingAuthHolder = _extractField(response, ['marketing_authorization_holder', 'marketing_auth_holder', 'marketingAuthHolder', 'Marketing Auth Holder']);
                final localTechRep = _extractField(response, ['local_technical_representative', 'local_tech_rep', 'localTechRep', 'Local Tech Rep']);
                
                final finalProductName = productName.isNotEmpty ? productName : (brand.isNotEmpty ? brand : '');
                final finalBrand = brand.isNotEmpty ? brand : (productName.isNotEmpty ? productName : '');
                
                return {
                  'status': 'valid',
                  'gtin': cleanGtin, // Return original format for display
                  'product': finalProductName,
                  'product_name': finalProductName,
                  'brand': finalBrand,
                  'genericName': _extractString(response['generic_name']),
                  'manufacturer': manufacturer,
                  'registrationNumber': rfdaRegNo,
                  'dosageForm': _extractString(response['dosage_form']),
                  'strength': strength,
                  'pack_size': _extractString(response['pack_size']),
                  'expiry_date': _extractString(response['expiry_date']),
                  'shelf_life': _extractString(response['shelf_life']),
                  'packaging_type': _extractString(response['packaging_type']),
                  'marketing_authorization_holder': marketingAuthHolder,
                  'local_technical_representative': localTechRep,
                  'registration_date': _extractString(response['registration_date']),
                  'license_expiry_date': licenseExpiryDate,
                  'country': _extractString(response['country']),
                  'source': 'online',
                  'timestamp': DateTime.now().millisecondsSinceEpoch,
                };
              }
            } catch (e) {
              debugPrint('Error trying normalized GTIN format: $e');
            }
          }
        }
        
        // GTIN not found
        return {
          'status': 'warning',
          'gtin': cleanGtin,
          'message': 'GTIN not found in RFDA register. Possible counterfeit or unregistered product.',
          'source': 'online',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      } catch (e) {
        debugPrint('Error querying Supabase: $e');
        return {
          'status': 'error',
          'message': 'Database error: $e',
          'source': 'online',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Network error: $e',
        'source': 'online',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    }
  }

  static Future<Map<String, dynamic>> verifyOffline(String gtin) async {
    try {
      final medicine = await OfflineDatabase.getMedicineByGtin(gtin);

      if (medicine != null) {
        // Helper to safely get value
        String _getValue(dynamic value) {
          if (value == null) return '';
          final str = value.toString().trim();
          return str.isEmpty ? '' : str;
        }
        
        return {
          'status': 'valid',
          'gtin': _getValue(medicine['gtin']),
          'product': _getValue(medicine['product_name']),
          'product_name': _getValue(medicine['product_name']), // Add product_name for result screen
          'brand': _getValue(medicine['product_name']), // Use product_name as brand fallback
          'genericName': _getValue(medicine['generic_name']),
          'manufacturer': _getValue(medicine['manufacturer']),
          'registrationNumber': _getValue(medicine['registration_number']),
          'dosageForm': _getValue(medicine['dosage_form']),
          'strength': _getValue(medicine['strength']),
          'pack_size': _getValue(medicine['pack_size']),
          'expiry_date': _getValue(medicine['expiry_date']),
          'shelf_life': _getValue(medicine['shelf_life']),
          'packaging_type': _getValue(medicine['packaging_type']),
          'marketing_authorization_holder': _getValue(medicine['marketing_auth_holder']),
          'local_technical_representative': _getValue(medicine['local_tech_rep']),
          'registration_date': _getValue(medicine['registration_date']),
          'license_expiry_date': _getValue(medicine['license_expiry_date']),
          'country': _getValue(medicine['country']),
          'source': 'offline',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      } else {
        return {
          'status': 'warning',
          'gtin': gtin,
          'message':
              'GTIN not found in offline database. Please check your internet connection and try again.',
          'source': 'offline',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Offline verification error: $e',
        'source': 'offline',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    }
  }

  static Future<Map<String, dynamic>> verify(String gtin) async {
    final isOfflineMode = await OfflineDatabase.isOfflineModeEnabled();

    if (isOfflineMode) {
      return await verifyOffline(gtin);
    }

    final isOnline = await Api.isOnline();
    if (isOnline) {
      final result = await verifyOnline(gtin);
      if (result['status'] == 'valid' || result['status'] == 'warning') {
        return result;
      }
    }

    return await verifyOffline(gtin);
  }

  static Future<Map<String, dynamic>> syncOfflineData() async {
    try {
      final onlineStatus = await isOnline();
      if (!onlineStatus) {
        return {
          'status': 'error',
          'message': 'No internet connection available',
        };
      }

      // Fetch products from Supabase
      final response = await _supabase
          .from('products')
          .select();

      if (response != null) {
        final products = List<Map<String, dynamic>>.from(response);
        final totalProducts = products.length;

        await OfflineDatabase.clearOfflineData();

        for (final product in products) {
          final medicine = {
            'gtin': product['gtin']?.toString() ?? '',
            'product_name': product['product_brand_name'] ?? product['product_name'] ?? product['brand'] ?? '',
            'generic_name': product['generic_name'] ?? '',
            'manufacturer': product['manufacturer_name'] ?? product['manufacturer'] ?? '',
            'registration_number': product['registration_no'] ?? product['rfda_reg_no'] ?? '',
            'dosage_form': product['dosage_form'] ?? '',
            'strength': product['dosage_strength'] ?? product['strength'] ?? '',
            'pack_size': product['pack_size'] ?? '',
            'expiry_date': product['expiry_date']?.toString() ?? '',
            'shelf_life': product['shelf_life'] ?? '',
            'packaging_type': product['packaging_type'] ?? '',
            'marketing_auth_holder': product['marketing_authorization_holder'] ?? product['marketing_auth_holder'] ?? '',
            'local_tech_rep': product['local_technical_representative'] ?? product['local_tech_rep'] ?? '',
            'registration_date': product['registration_date']?.toString() ?? '',
            'license_expiry_date': product['license_expiry_date']?.toString() ?? '',
            'country': product['manufacturer_country'] ?? product['country'] ?? '',
            'last_updated': DateTime.now().millisecondsSinceEpoch,
            'is_verified': 1,
          };

          await OfflineDatabase.insertMedicine(medicine);
        }

        await OfflineDatabase.updateSyncStatus(
          lastSync: DateTime.now().millisecondsSinceEpoch,
          totalRecords: totalProducts,
          syncStatus: 'completed',
        );

        return {
          'status': 'success',
          'message': 'Offline data synced successfully',
          'total_records': totalProducts,
        };
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch data from database',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Sync error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getOfflineStats() async {
    return await OfflineDatabase.getDatabaseStats();
  }

  static Future<bool> needsSync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getInt(_lastSyncKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const syncInterval = 24 * 60 * 60 * 1000;

    return (now - lastSync) > syncInterval;
  }

  static Future<void> updateLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> clearCache() async {
    await OfflineDatabase.clearOfflineData();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSyncKey);
  }

  // Fetch pharmacies from Supabase
  static Future<List<Map<String, dynamic>>> getPharmacies() async {
    try {
      final response = await _supabase
          .from('pharmacies')
          .select()
          .eq('is_verified', true)
          .order('name');
      
      if (response == null) {
        return [];
      }
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching pharmacies: $e');
      return [];
    }
  }

  // Search pharmacies by name, address, or district
  static Future<List<Map<String, dynamic>>> searchPharmacies(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final response = await _supabase
          .from('pharmacies')
          .select()
          .eq('is_verified', true)
          .or('name.ilike.%$lowerQuery%,address.ilike.%$lowerQuery%,district.ilike.%$lowerQuery%')
          .order('name');
      
      if (response == null) {
        return [];
      }
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error searching pharmacies: $e');
      return [];
    }
  }

  // Test Supabase connection
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      await _supabase
          .from('products')
          .select('id')
          .limit(1)
          .timeout(const Duration(seconds: 5));
      
      return {
        'connected': true,
        'message': 'Connected to Supabase',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    } catch (e) {
      return {
        'connected': false,
        'message': 'Connection failed: $e',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    }
  }
}
