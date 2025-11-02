/// GTIN validation utilities
class GtinValidator {
  /// Validates a GTIN using the modulus-10 check digit algorithm
  /// Supports GTIN-8, GTIN-12, GTIN-13, and GTIN-14
  static bool isValidGtin(String gtin) {
    if (gtin.isEmpty) return false;

    // Remove any non-digit characters
    final cleanGtin = gtin.replaceAll(RegExp(r'[^\d]'), '');

    // Check length
    if (![8, 12, 13, 14].contains(cleanGtin.length)) {
      return false;
    }

    // Calculate check digit
    final checkDigit =
        _calculateCheckDigit(cleanGtin.substring(0, cleanGtin.length - 1));
    final providedCheckDigit =
        int.parse(cleanGtin.substring(cleanGtin.length - 1));

    return checkDigit == providedCheckDigit;
  }

  /// Calculates the check digit for a GTIN using modulus-10 algorithm
  static int _calculateCheckDigit(String gtinWithoutCheckDigit) {
    int sum = 0;
    bool isOddPosition = true;

    // Process digits from right to left
    for (int i = gtinWithoutCheckDigit.length - 1; i >= 0; i--) {
      int digit = int.parse(gtinWithoutCheckDigit[i]);

      if (isOddPosition) {
        sum += digit;
      } else {
        sum += digit * 3;
      }

      isOddPosition = !isOddPosition;
    }

    return (10 - (sum % 10)) % 10;
  }

  /// Normalizes any GTIN to GTIN-14 format
  /// Pads with zeros and recalculates check digit if needed
  static String normalizeToGtin14(String gtin) {
    if (gtin.isEmpty) return '';

    // Remove any non-digit characters
    final cleanGtin = gtin.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanGtin.length == 14) {
      return cleanGtin;
    }

    // Pad with zeros to make it 14 digits
    final paddedGtin = cleanGtin.padLeft(14, '0');

    // Recalculate check digit
    final checkDigit = _calculateCheckDigit(paddedGtin.substring(0, 13));

    return paddedGtin.substring(0, 13) + checkDigit.toString();
  }

  /// Validates EAN-13 checksum specifically
  static bool isValidEan13(String ean13) {
    if (ean13.length != 13) return false;
    return isValidGtin(ean13);
  }

  /// Validates EAN-8 checksum specifically
  static bool isValidEan8(String ean8) {
    if (ean8.length != 8) return false;
    return isValidGtin(ean8);
  }

  /// Validates UPC-A checksum specifically
  static bool isValidUpcA(String upcA) {
    if (upcA.length != 12) return false;
    return isValidGtin(upcA);
  }

  /// Validates UPC-E checksum specifically
  static bool isValidUpcE(String upcE) {
    if (upcE.length != 8) return false;
    return isValidGtin(upcE);
  }

  /// Gets the GTIN type based on length
  static String getGtinType(String gtin) {
    final cleanGtin = gtin.replaceAll(RegExp(r'[^\d]'), '');

    switch (cleanGtin.length) {
      case 8:
        return 'GTIN-8';
      case 12:
        return 'GTIN-12';
      case 13:
        return 'GTIN-13';
      case 14:
        return 'GTIN-14';
      default:
        return 'Unknown';
    }
  }
}
