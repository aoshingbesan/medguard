import 'gtin_validator.dart';

class GtinParser {
  static GtinParseResult parseBarcode(String rawText, String symbology) {
    try {
      switch (symbology.toLowerCase()) {
        case 'ean-13':
        case 'ean13':
          return _parseEan13(rawText);
        case 'ean-8':
        case 'ean8':
          return _parseEan8(rawText);
        case 'upc-a':
        case 'upca':
          return _parseUpcA(rawText);
        case 'upc-e':
        case 'upce':
          return _parseUpcE(rawText);
        case 'code128':
          return _parseCode128(rawText);
        case 'datamatrix':
        case 'gs1-datamatrix':
          return _parseGs1DataMatrix(rawText);
        case 'qr':
        case 'qr-code':
          return _parseQrCode(rawText);
        default:
          return _parseGenericGtin(rawText, symbology);
      }
    } catch (e) {
      return GtinParseResult(
        rawText: rawText,
        gtin: '',
        symbology: symbology,
        isValid: false,
        error: 'Parse error: $e',
      );
    }
  }

  static GtinParseResult _parseEan13(String rawText) {
    final cleanText = rawText.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanText.length != 13) {
      return GtinParseResult(
        rawText: rawText,
        gtin: '',
        symbology: 'EAN-13',
        isValid: false,
        error: 'EAN-13 must be 13 digits',
      );
    }

    final isValid = GtinValidator.isValidEan13(cleanText);

    // Accept GTIN even if checksum fails - let API verify against database
    return GtinParseResult(
      rawText: rawText,
      gtin: cleanText,
      symbology: 'EAN-13',
      isValid: true, // Always allow to proceed, checksum validated in API
    );
  }

  /// Parses EAN-8 barcode
  static GtinParseResult _parseEan8(String rawText) {
    final cleanText = rawText.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanText.length != 8) {
      return GtinParseResult(
        rawText: rawText,
        gtin: '',
        symbology: 'EAN-8',
        isValid: false,
        error: 'EAN-8 must be 8 digits',
      );
    }

    // Accept if length is correct - let API verify
    return GtinParseResult(
      rawText: rawText,
      gtin: cleanText, // Keep original EAN-8 format
      symbology: 'EAN-8',
      isValid: true, // Allow to proceed, API will validate
    );
  }

  /// Parses UPC-A barcode
  static GtinParseResult _parseUpcA(String rawText) {
    final cleanText = rawText.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanText.length != 12) {
      return GtinParseResult(
        rawText: rawText,
        gtin: '',
        symbology: 'UPC-A',
        isValid: false,
        error: 'UPC-A must be 12 digits',
      );
    }

    // Accept if length is correct - let API verify
    return GtinParseResult(
      rawText: rawText,
      gtin: cleanText, // Keep original UPC-A format
      symbology: 'UPC-A',
      isValid: true, // Allow to proceed, API will validate
    );
  }

  /// Parses UPC-E barcode
  static GtinParseResult _parseUpcE(String rawText) {
    final cleanText = rawText.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanText.length != 8) {
      return GtinParseResult(
        rawText: rawText,
        gtin: '',
        symbology: 'UPC-E',
        isValid: false,
        error: 'UPC-E must be 8 digits',
      );
    }

    // Accept if length is correct - let API verify
    return GtinParseResult(
      rawText: rawText,
      gtin: cleanText, // Keep original UPC-E format
      symbology: 'UPC-E',
      isValid: true, // Allow to proceed, API will validate
    );
  }

  /// Parses Code128 barcode (fallback)
  static GtinParseResult _parseCode128(String rawText) {
    final cleanText = rawText.replaceAll(RegExp(r'[^\d]'), '');

    // Try to parse as GTIN if it looks like one
    if ([8, 12, 13, 14].contains(cleanText.length)) {
      // Accept if length is correct - let API verify
      return GtinParseResult(
        rawText: rawText,
        gtin: cleanText, // Keep original format
        symbology: 'Code128',
        isValid: true, // Allow to proceed, API will validate
      );
    }

    return GtinParseResult(
      rawText: rawText,
      gtin: '',
      symbology: 'Code128',
      isValid: false,
      error: 'Code128 does not contain valid GTIN length',
    );
  }

  /// Parses GS1 DataMatrix barcode
  static GtinParseResult _parseGs1DataMatrix(String rawText) {
    final gtin = _extractGtinFromGs1(rawText);

    if (gtin.isEmpty) {
      return GtinParseResult(
        rawText: rawText,
        gtin: '',
        symbology: 'GS1-DM',
        isValid: false,
        error: 'No GTIN found in GS1 DataMatrix',
      );
    }

    // Accept if we extracted a GTIN - API will validate
    return GtinParseResult(
      rawText: rawText,
      gtin: gtin, // Keep original GTIN format
      symbology: 'GS1-DM',
      isValid: true, // Allow to proceed, API will validate
    );
  }

  /// Parses QR code (only if it contains GS1 AIs)
  static GtinParseResult _parseQrCode(String rawText) {
    // Check if QR code contains GS1 Application Identifiers
    if (!_containsGs1Ais(rawText)) {
      return GtinParseResult(
        rawText: rawText,
        gtin: '',
        symbology: 'QR',
        isValid: false,
        error: 'QR code does not contain GS1 Application Identifiers',
      );
    }

    final gtin = _extractGtinFromGs1(rawText);

    if (gtin.isEmpty) {
      return GtinParseResult(
        rawText: rawText,
        gtin: '',
        symbology: 'QR',
        isValid: false,
        error: 'No GTIN found in GS1 QR code',
      );
    }

    // Accept if we extracted a GTIN - API will validate
    return GtinParseResult(
      rawText: rawText,
      gtin: gtin, // Keep original GTIN format
      symbology: 'QR',
      isValid: true, // Allow to proceed, API will validate
    );
  }

  /// Extracts GTIN from GS1 Application Identifier string
  static String _extractGtinFromGs1(String gs1String) {
    // Look for (01) Application Identifier
    final ai01Pattern = RegExp(r'\(01\)(\d{14})');
    final match = ai01Pattern.firstMatch(gs1String);

    if (match != null) {
      return match.group(1) ?? '';
    }

    // Also handle FNC1 separator (ASCII 29) format
    final fnc1Pattern = RegExp(r'\x1d(\d{14})');
    final fnc1Match = fnc1Pattern.firstMatch(gs1String);

    if (fnc1Match != null) {
      return fnc1Match.group(1) ?? '';
    }

    // Handle concatenated format without parentheses
    final concatPattern = RegExp(r'01(\d{14})');
    final concatMatch = concatPattern.firstMatch(gs1String);

    if (concatMatch != null) {
      return concatMatch.group(1) ?? '';
    }

    return '';
  }

  /// Checks if string contains GS1 Application Identifiers
  static bool _containsGs1Ais(String text) {
    // Check for various GS1 AI patterns
    return text.contains('(01)') ||
        text.contains('(17)') ||
        text.contains('(10)') ||
        text.contains('\x1d') || // FNC1 separator
        RegExp(r'01\d{14}').hasMatch(text);
  }

  /// Parse generic GTIN from unknown symbology
  static GtinParseResult _parseGenericGtin(String rawText, String symbology) {
    final cleanText = rawText.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it looks like a GTIN (13 or 14 digits most common)
    if ([8, 12, 13, 14].contains(cleanText.length)) {
      final gtinType = GtinValidator.getGtinType(cleanText);

      // Accept if length is correct - let API verify checksum and database
      return GtinParseResult(
        rawText: rawText,
        gtin: cleanText, // Keep original format
        symbology: gtinType,
        isValid: true, // Allow to proceed, API will validate
      );
    }

    // Check if it contains GS1 AIs
    if (_containsGs1Ais(rawText)) {
      final gtin = _extractGtinFromGs1(rawText);

      if (gtin.isNotEmpty) {
        // Accept if we extracted a GTIN - API will validate
        return GtinParseResult(
          rawText: rawText,
          gtin: gtin, // Keep original GTIN format
          symbology: 'GS1',
          isValid: true, // Allow to proceed
        );
      }
    }

    return GtinParseResult(
      rawText: rawText,
      gtin: '',
      symbology: symbology,
      isValid: false,
      error: 'Unable to parse as GTIN. Expected 8, 12, 13, or 14 digits.',
    );
  }
}

/// Result of GTIN parsing operation
class GtinParseResult {
  final String rawText;
  final String gtin;
  final String symbology;
  final bool isValid;
  final String? error;

  const GtinParseResult({
    required this.rawText,
    required this.gtin,
    required this.symbology,
    required this.isValid,
    this.error,
  });
}
