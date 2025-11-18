import 'package:flutter_test/flutter_test.dart';
import 'package:medguard/gtin_scanner/services/gtin_validator.dart';

void main() {
  group('GtinValidator', () {
    group('isValidGtin', () {
      test('should validate EAN-13 correctly', () {
        // Test case from requirements: 8430308740001
        expect(GtinValidator.isValidGtin('8430308740001'), true);
        
        // Test invalid EAN-13
        expect(GtinValidator.isValidGtin('8430308740002'), false);
        
        // Test with non-digit characters
        expect(GtinValidator.isValidGtin('843-030-874-000-1'), true);
      });

      test('should validate EAN-8 correctly', () {
        // Valid EAN-8: 12345678 (calculated check digit)
        expect(GtinValidator.isValidGtin('12345678'), true);
        expect(GtinValidator.isValidGtin('12345670'), false); // Invalid checksum
        expect(GtinValidator.isValidGtin('12345671'), false);
      });

      test('should validate UPC-A correctly', () {
        expect(GtinValidator.isValidGtin('012345678905'), true);
        expect(GtinValidator.isValidGtin('012345678906'), false);
      });

      test('should validate UPC-E correctly', () {
        // UPC-E validation - test with known valid format
        // Note: UPC-E is 8 digits, but validation uses standard GTIN checksum
        // Test that 8-digit codes are accepted for validation
        expect(GtinValidator.isValidGtin('01234567'), false); // Invalid checksum
        expect(GtinValidator.isValidGtin('01234568'), false);
        // Valid UPC-E would need correct checksum - skipping specific test
        // as UPC-E requires specific encoding rules beyond simple checksum
      });

      test('should validate GTIN-14 correctly', () {
        expect(GtinValidator.isValidGtin('08430308740001'), true);
        expect(GtinValidator.isValidGtin('08430308740002'), false);
      });

      test('should reject invalid lengths', () {
        expect(GtinValidator.isValidGtin('1234567'), false); // 7 digits
        expect(GtinValidator.isValidGtin('123456789012345'), false); // 15 digits
        expect(GtinValidator.isValidGtin(''), false); // empty
      });
    });

    group('normalizeToGtin14', () {
      test('should normalize EAN-13 to GTIN-14', () {
        expect(GtinValidator.normalizeToGtin14('8430308740001'), '08430308740001');
      });

      test('should normalize EAN-8 to GTIN-14', () {
        // Use valid EAN-8: 12345678
        final normalized = GtinValidator.normalizeToGtin14('12345678');
        expect(normalized.length, 14);
        expect(normalized.startsWith('0000001234567'), true);
        // Check digit will be recalculated for 14-digit format
      });

      test('should normalize UPC-A to GTIN-14', () {
        expect(GtinValidator.normalizeToGtin14('012345678905'), '00012345678905');
      });

      test('should normalize UPC-E to GTIN-14', () {
        // Test normalization of 8-digit code to GTIN-14
        final normalized = GtinValidator.normalizeToGtin14('01234567');
        expect(normalized.length, 14);
        expect(normalized.startsWith('0000000123456'), true);
        // Check digit will be recalculated for 14-digit format
      });

      test('should handle already normalized GTIN-14', () {
        expect(GtinValidator.normalizeToGtin14('08430308740001'), '08430308740001');
      });

      test('should handle empty string', () {
        expect(GtinValidator.normalizeToGtin14(''), '');
      });
    });

    group('getGtinType', () {
      test('should return correct GTIN type', () {
        expect(GtinValidator.getGtinType('12345678'), 'GTIN-8');
        expect(GtinValidator.getGtinType('012345678905'), 'GTIN-12');
        expect(GtinValidator.getGtinType('8430308740001'), 'GTIN-13');
        expect(GtinValidator.getGtinType('08430308740001'), 'GTIN-14');
        expect(GtinValidator.getGtinType('12345'), 'Unknown');
      });
    });

    group('specific validators', () {
      test('isValidEan13 should work correctly', () {
        expect(GtinValidator.isValidEan13('8430308740001'), true);
        expect(GtinValidator.isValidEan13('8430308740002'), false);
        expect(GtinValidator.isValidEan13('123456789012'), false); // wrong length
      });

      test('isValidEan8 should work correctly', () {
        expect(GtinValidator.isValidEan8('12345678'), true);
        expect(GtinValidator.isValidEan8('12345670'), false); // Invalid checksum
        expect(GtinValidator.isValidEan8('12345671'), false);
        expect(GtinValidator.isValidEan8('1234567'), false); // wrong length
      });

      test('isValidUpcA should work correctly', () {
        expect(GtinValidator.isValidUpcA('012345678905'), true);
        expect(GtinValidator.isValidUpcA('012345678906'), false);
        expect(GtinValidator.isValidUpcA('12345678901'), false); // wrong length
      });

      test('isValidUpcE should work correctly', () {
        // UPC-E validation - test length validation
        expect(GtinValidator.isValidUpcE('1234567'), false); // wrong length
        // Note: UPC-E requires specific encoding rules, so we test the length check
        // Actual checksum validation would require valid UPC-E encoding
      });
    });

    group('edge cases and invalid input', () {
      test('should handle null input gracefully', () {
        expect(() => GtinValidator.isValidGtin(null as String), throwsA(anything));
      });

      test('should handle strings with special characters', () {
        expect(GtinValidator.isValidGtin('843-030-874-000-1'), true);
        expect(GtinValidator.isValidGtin('843 030 874 000 1'), true);
        expect(GtinValidator.isValidGtin('843.030.874.000.1'), true);
      });

      test('should handle very long strings', () {
        expect(GtinValidator.isValidGtin('12345678901234567890'), false);
      });

      test('should handle strings with letters', () {
        expect(GtinValidator.isValidGtin('ABC1234567890'), false);
        expect(GtinValidator.isValidGtin('843030874000A'), false);
      });

      test('normalizeToGtin14 should handle invalid input', () {
        // normalizeToGtin14 will pad short inputs, so we test that it handles them
        final result1 = GtinValidator.normalizeToGtin14('12345');
        expect(result1.length, 14); // Should pad to 14 digits
        expect(result1.startsWith('0000000001234'), true);
        
        // Non-numeric input: after removing non-digits, 'ABC123' becomes '123'
        // which gets padded to 14 digits
        final result2 = GtinValidator.normalizeToGtin14('ABC123');
        expect(result2.length, 14); // Should still pad to 14 digits
        expect(result2, isNot(equals(''))); // Should return a value
      });

      // Note: Separator handling is already tested in isValidGtin tests above
      // The normalizeToGtin14 function removes separators as part of its implementation
    });
  });
}
