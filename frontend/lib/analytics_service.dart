import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

/// Service for tracking analytics events from the mobile app
class AnalyticsService {
  static const String _deviceIdKey = 'medguard_device_id';
  static SupabaseClient get _supabase => Supabase.instance.client;

  /// Get or create a unique device ID
  static Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);
    
    if (deviceId == null || deviceId.isEmpty) {
      // Generate a unique device ID (UUID-like)
      deviceId = '${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}';
      await prefs.setString(_deviceIdKey, deviceId);
      debugPrint('📱 Generated new device ID: $deviceId');
    }
    
    return deviceId;
  }

  /// Generate a random string for device ID
  static String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(chars[(random + i) % chars.length]);
    }
    return buffer.toString();
  }

  /// Track a user session (call this on app startup or when user opens app)
  static Future<void> trackSession() async {
    try {
      final deviceId = await _getDeviceId();
      final platform = Platform.isIOS ? 'ios' : 'android';
      
      // Check if device already exists
      final { data: existingSession } = await _supabase
          .from('user_sessions')
          .select('id, total_verifications')
          .eq('device_id', deviceId)
          .maybeSingle();

      if (existingSession != null) {
        // Update last_seen_at
        await _supabase
            .from('user_sessions')
            .update({
              'last_seen_at': DateTime.now().toIso8601String(),
            })
            .eq('device_id', deviceId);
        debugPrint('✅ Updated session for device: $deviceId');
      } else {
        // Create new session
        await _supabase
            .from('user_sessions')
            .insert({
              'device_id': deviceId,
              'platform': platform,
              'first_seen_at': DateTime.now().toIso8601String(),
              'last_seen_at': DateTime.now().toIso8601String(),
            });
        debugPrint('✅ Created new session for device: $deviceId');
      }
    } catch (e) {
      // Silently fail - analytics shouldn't break the app
      debugPrint('⚠️ Failed to track session: $e');
    }
  }

  /// Track a verification event (scan or manual entry)
  static Future<void> trackVerification({
    required String gtin,
    required String method, // 'scan' or 'manual'
    required String result, // 'verified', 'unverified', or 'error'
    required String source, // 'online' or 'offline'
    String? productName,
    String? manufacturer,
  }) async {
    try {
      final deviceId = await _getDeviceId();
      
      // Insert verification event
      await _supabase
          .from('verification_events')
          .insert({
            'device_id': deviceId,
            'gtin': gtin,
            'verification_method': method,
            'verification_result': result,
            'source': source,
            'product_name': productName,
            'manufacturer': manufacturer,
            'created_at': DateTime.now().toIso8601String(),
          });

      // Update user session total_verifications count
      await _supabase.rpc('increment_verification_count', params: {
        'device_id_param': deviceId,
      }).catchError((e) {
        // If RPC doesn't exist, manually update
        debugPrint('⚠️ RPC not available, updating manually');
        _updateVerificationCount(deviceId);
      });

      debugPrint('✅ Tracked verification: $method -> $result ($source)');
    } catch (e) {
      // Silently fail - analytics shouldn't break the app
      debugPrint('⚠️ Failed to track verification: $e');
    }
  }

  /// Manually update verification count (fallback if RPC doesn't exist)
  static Future<void> _updateVerificationCount(String deviceId) async {
    try {
      final { data: session } = await _supabase
          .from('user_sessions')
          .select('total_verifications')
          .eq('device_id', deviceId)
          .single();

      final currentCount = (session?['total_verifications'] as int?) ?? 0;
      
      await _supabase
          .from('user_sessions')
          .update({
            'total_verifications': currentCount + 1,
          })
          .eq('device_id', deviceId);
    } catch (e) {
      debugPrint('⚠️ Failed to update verification count: $e');
    }
  }
}

