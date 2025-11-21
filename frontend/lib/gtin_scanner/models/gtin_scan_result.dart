/// Result of a GTIN scan operation
class GtinScanResult {
  /// The raw decoded text from the barcode
  final String rawText;

  /// The normalized GTIN-14 string (for API calls)
  final String gtin;

  /// The original GTIN format (for display)
  final String originalGtin;

  /// The symbology that was detected (e.g., "EAN-13", "GS1-DM", "UPC-A")
  final String symbology;

  /// When the scan was performed
  final DateTime scannedAt;

  /// Whether the GTIN passed checksum validation
  final bool isValid;

  const GtinScanResult({
    required this.rawText,
    required this.gtin,
    required this.originalGtin,
    required this.symbology,
    required this.scannedAt,
    required this.isValid,
  });

  @override
  String toString() {
    return 'GtinScanResult(rawText: $rawText, gtin: $gtin, originalGtin: $originalGtin, symbology: $symbology, scannedAt: $scannedAt, isValid: $isValid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GtinScanResult &&
        other.rawText == rawText &&
        other.gtin == gtin &&
        other.originalGtin == originalGtin &&
        other.symbology == symbology &&
        other.scannedAt == scannedAt &&
        other.isValid == isValid;
  }

  @override
  int get hashCode {
    return Object.hash(rawText, gtin, originalGtin, symbology, scannedAt, isValid);
  }
}
