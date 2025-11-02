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
        expect(GtinValidator.isValidGtin('12345670'), true);
        expect(GtinValidator.isValidGtin('12345671'), false);
      });

      test('should validate UPC-A correctly', () {
        expect(GtinValidator.isValidGtin('012345678905'), true);
        expect(GtinValidator.isValidGtin('012345678906'), false);
      });

      test('should validate UPC-E correctly', () {
        expect(GtinValidator.isValidGtin('01234567'), true);
        expect(GtinValidator.isValidGtin('01234568'), false);
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
        expect(GtinValidator.normalizeToGtin14('12345670'), '00000012345670');
      });

      test('should normalize UPC-A to GTIN-14', () {
        expect(GtinValidator.normalizeToGtin14('012345678905'), '00012345678905');
      });

      test('should normalize UPC-E to GTIN-14', () {
        expect(GtinValidator.normalizeToGtin14('01234567'), '00000001234567');
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
        expect(GtinValidator.getGtinType('12345670'), 'GTIN-8');
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
        expect(GtinValidator.isValidEan8('12345670'), true);
        expect(GtinValidator.isValidEan8('12345671'), false);
        expect(GtinValidator.isValidEan8('1234567'), false); // wrong length
      });

      test('isValidUpcA should work correctly', () {
        expect(GtinValidator.isValidUpcA('012345678905'), true);
        expect(GtinValidator.isValidUpcA('012345678906'), false);
        expect(GtinValidator.isValidUpcA('12345678901'), false); // wrong length
      });

      test('isValidUpcE should work correctly', () {
        expect(GtinValidator.isValidUpcE('01234567'), true);
        expect(GtinValidator.isValidUpcE('01234568'), false);
        expect(GtinValidator.isValidUpcE('1234567'), false); // wrong length
      });
    });
  });
}
