import 'package:flutter_test/flutter_test.dart';
import 'package:medguard/gtin_scanner/services/gtin_parser.dart';

void main() {
  group('GtinParser', () {
    group('parseBarcode', () {
      test('should parse EAN-13 correctly', () {
        final result = GtinParser.parseBarcode('8430308740001', 'EAN-13');
        
        expect(result.rawText, '8430308740001');
        expect(result.gtin, '08430308740001');
        expect(result.symbology, 'EAN-13');
        expect(result.isValid, true);
        expect(result.error, null);
      });

      test('should parse EAN-8 correctly', () {
        final result = GtinParser.parseBarcode('12345670', 'EAN-8');
        
        expect(result.rawText, '12345670');
        expect(result.gtin, '00000012345670');
        expect(result.symbology, 'EAN-8');
        expect(result.isValid, true);
      });

      test('should parse UPC-A correctly', () {
        final result = GtinParser.parseBarcode('012345678905', 'UPC-A');
        
        expect(result.rawText, '012345678905');
        expect(result.gtin, '00012345678905');
        expect(result.symbology, 'UPC-A');
        expect(result.isValid, true);
      });

      test('should parse UPC-E correctly', () {
        final result = GtinParser.parseBarcode('01234567', 'UPC-E');
        
        expect(result.rawText, '01234567');
        expect(result.gtin, '00000001234567');
        expect(result.symbology, 'UPC-E');
        expect(result.isValid, true);
      });

      test('should handle invalid EAN-13', () {
        final result = GtinParser.parseBarcode('8430308740002', 'EAN-13');
        
        expect(result.rawText, '8430308740002');
        expect(result.gtin, '08430308740002');
        expect(result.symbology, 'EAN-13');
        expect(result.isValid, false);
      });

      test('should handle wrong length EAN-13', () {
        final result = GtinParser.parseBarcode('843030874000', 'EAN-13');
        
        expect(result.rawText, '843030874000');
        expect(result.gtin, '');
        expect(result.symbology, 'EAN-13');
        expect(result.isValid, false);
        expect(result.error, 'EAN-13 must be 13 digits');
      });
    });

    group('GS1 DataMatrix parsing', () {
      test('should parse GS1 DataMatrix with (01) AI', () {
        final result = GtinParser.parseBarcode(
          '(01)09506000134352(17)260101(10)ABC123',
          'GS1-DM',
        );
        
        expect(result.rawText, '(01)09506000134352(17)260101(10)ABC123');
        expect(result.gtin, '09506000134352');
        expect(result.symbology, 'GS1-DM');
        expect(result.isValid, true);
      });

      test('should parse GS1 DataMatrix with FNC1 separator', () {
        final result = GtinParser.parseBarcode(
          '\x1d09506000134352\x1d260101\x1dABC123',
          'GS1-DM',
        );
        
        expect(result.rawText, '\x1d09506000134352\x1d260101\x1dABC123');
        expect(result.gtin, '09506000134352');
        expect(result.symbology, 'GS1-DM');
        expect(result.isValid, true);
      });

      test('should parse GS1 DataMatrix with concatenated format', () {
        final result = GtinParser.parseBarcode(
          '01095060001343521726010110ABC123',
          'GS1-DM',
        );
        
        expect(result.rawText, '01095060001343521726010110ABC123');
        expect(result.gtin, '09506000134352');
        expect(result.symbology, 'GS1-DM');
        expect(result.isValid, true);
      });

      test('should handle GS1 DataMatrix without (01) AI', () {
        final result = GtinParser.parseBarcode(
          '(17)260101(10)ABC123',
          'GS1-DM',
        );
        
        expect(result.rawText, '(17)260101(10)ABC123');
        expect(result.gtin, '');
        expect(result.symbology, 'GS1-DM');
        expect(result.isValid, false);
        expect(result.error, 'No GTIN found in GS1 DataMatrix');
      });
    });

    group('QR code parsing', () {
      test('should parse QR code with GS1 AIs', () {
        final result = GtinParser.parseBarcode(
          '(01)09506000134352(17)260101',
          'QR',
        );
        
        expect(result.rawText, '(01)09506000134352(17)260101');
        expect(result.gtin, '09506000134352');
        expect(result.symbology, 'QR');
        expect(result.isValid, true);
      });

      test('should reject QR code without GS1 AIs', () {
        final result = GtinParser.parseBarcode(
          'https://example.com/product/123',
          'QR',
        );
        
        expect(result.rawText, 'https://example.com/product/123');
        expect(result.gtin, '');
        expect(result.symbology, 'QR');
        expect(result.isValid, false);
        expect(result.error, 'QR code does not contain GS1 Application Identifiers');
      });
    });

    group('Code128 parsing', () {
      test('should parse Code128 with valid GTIN', () {
        final result = GtinParser.parseBarcode('8430308740001', 'Code128');
        
        expect(result.rawText, '8430308740001');
        expect(result.gtin, '08430308740001');
        expect(result.symbology, 'Code128');
        expect(result.isValid, true);
      });

      test('should handle Code128 with invalid GTIN', () {
        final result = GtinParser.parseBarcode('8430308740002', 'Code128');
        
        expect(result.rawText, '8430308740002');
        expect(result.gtin, '08430308740002');
        expect(result.symbology, 'Code128');
        expect(result.isValid, false);
      });

      test('should handle Code128 with non-GTIN data', () {
        final result = GtinParser.parseBarcode('ABC123', 'Code128');
        
        expect(result.rawText, 'ABC123');
        expect(result.gtin, '');
        expect(result.symbology, 'Code128');
        expect(result.isValid, false);
        expect(result.error, 'Code128 does not contain valid GTIN');
      });
    });

    group('unsupported symbologies', () {
      test('should handle unsupported symbology', () {
        final result = GtinParser.parseBarcode('123456', 'PDF417');
        
        expect(result.rawText, '123456');
        expect(result.gtin, '');
        expect(result.symbology, 'PDF417');
        expect(result.isValid, false);
        expect(result.error, 'Unsupported symbology: PDF417');
      });
    });
  });
}
