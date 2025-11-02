import 'package:flutter/material.dart';
import 'models/gtin_scan_result.dart';
import 'widgets/gtin_scanner_page.dart';

/// Main GTIN Scanner module
class GtinScanner {
  /// Opens the GTIN scanner page and returns the scanned result
  static Future<GtinScanResult?> scanGtin(BuildContext context) async {
    final result = await Navigator.of(context).push<GtinScanResult>(
      MaterialPageRoute(
        builder: (context) => GtinScannerPage(
          onResult: (result) => Navigator.of(context).pop(result),
        ),
      ),
    );
    return result;
  }

  /// Opens the GTIN scanner page with a custom callback
  static void openScanner(
    BuildContext context,
    Function(GtinScanResult) onResult,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GtinScannerPage(onResult: onResult),
      ),
    );
  }
}

/// GTIN Scanner widget for embedding in other screens
class GtinScannerWidget extends StatelessWidget {
  final Function(GtinScanResult) onResult;
  final Widget? child;

  const GtinScannerWidget({
    super.key,
    required this.onResult,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => GtinScanner.openScanner(context, onResult),
      child: child ?? const _DefaultScannerButton(),
    );
  }
}

class _DefaultScannerButton extends StatelessWidget {
  const _DefaultScannerButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Scan GTIN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
