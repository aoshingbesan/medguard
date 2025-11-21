import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../simple_language_service.dart';
import '../services/gtin_parser.dart';
import '../models/gtin_scan_result.dart';
import 'manual_entry_sheet.dart';

/// Full-screen GTIN scanner page
class GtinScannerPage extends StatefulWidget {
  final Function(GtinScanResult) onResult;

  const GtinScannerPage({
    super.key,
    required this.onResult,
  });

  @override
  State<GtinScannerPage> createState() => _GtinScannerPageState();
}

class _GtinScannerPageState extends State<GtinScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  String? _lastScannedCode;
  final List<String> _recentScans = [];
  static const int _maxRecentScans = 2;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      await cameraController.start();
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Camera initialization failed: $e');
      }
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      final String? code = barcode.rawValue;
      final String symbology = barcode.type?.name ?? 'Unknown';

      if (code != null && code != _lastScannedCode) {
        _lastScannedCode = code;
        _processBarcode(code, symbology);
      }
    }
  }

  Future<void> _processBarcode(String rawText, String symbology) async {
    // Debug logging
    print('Processing barcode: "$rawText" with symbology: "$symbology"');

    // Check for duplicate scans
    if (_recentScans.contains(rawText)) {
      return;
    }

    // Add to recent scans
    _recentScans.add(rawText);
    if (_recentScans.length > _maxRecentScans) {
      _recentScans.removeAt(0);
    }

    // Pause scanning
    setState(() {
      _isScanning = false;
    });

    // Parse the barcode
    final parseResult = GtinParser.parseBarcode(rawText, symbology);
    print(
        'Parse result: ${parseResult.isValid}, GTIN: ${parseResult.gtin}, Error: ${parseResult.error}');

    if (parseResult.isValid) {
      // Haptic feedback for successful scan
      HapticFeedback.lightImpact();

      // Show result bottom sheet
      _showResultSheet(parseResult);
    } else {
      // Show error and resume scanning
      _showErrorDialog(parseResult.error ?? 'Invalid barcode format');
      setState(() {
        _isScanning = true;
      });
    }
  }

  void _showResultSheet(GtinParseResult parseResult) {
    final result = GtinScanResult(
      rawText: parseResult.rawText,
      gtin: parseResult.gtin, // Normalized for API
      originalGtin: parseResult.originalGtin, // Original for display
      symbology: parseResult.symbology,
      scannedAt: DateTime.now(),
      isValid: parseResult.isValid,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ResultBottomSheet(
        result: result,
        onVerify: () {
          Navigator.of(context).pop();
          widget.onResult(result);
        },
        onScanAgain: () {
          Navigator.of(context).pop();
          setState(() {
            _isScanning = true;
          });
        },
      ),
    );
  }

  void _showErrorDialog(String message) {
    final languageService = Provider.of<SimpleLanguageService>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageService.scanError),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isScanning = true;
              });
            },
            child: Text(languageService.ok),
          ),
        ],
      ),
    );
  }

  void _toggleTorch() {
    cameraController.toggleTorch();
  }

  void _switchCamera() {
    cameraController.switchCamera();
  }

  void _pauseResume() {
    setState(() {
      _isScanning = !_isScanning;
    });
  }

  void _openManualEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ManualEntrySheet(
        onResult: widget.onResult,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Scan GTIN',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard, color: Colors.white),
            onPressed: _openManualEntry,
            tooltip: 'Manual entry',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Camera access required',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please allow camera access to scan barcodes',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _initializeCamera,
                        child: const Text('Grant Camera Access'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Scanning overlay
          _buildScanningOverlay(),

          // Control buttons
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Column(
        children: [
          // Top section
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 64,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Point camera at barcode',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Position the barcode within the frame',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scanning area
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(40),
              child: Stack(
                children: [
                  // Corner indicators
                  ..._buildCornerIndicators(),

                  // Center crosshair
                  const Center(
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  // Scanning animation
                  if (_isScanning)
                    const Center(
                      child: SizedBox(
                        width: 200,
                        height: 2,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.transparent,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom section
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isScanning) ...[
                      const Icon(
                        Icons.camera_alt,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Scanning...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.pause_circle,
                        size: 48,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Paused',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerIndicators() {
    return [
      // Top-left corner
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white, width: 3),
              left: BorderSide(color: Colors.white, width: 3),
            ),
          ),
        ),
      ),
      // Top-right corner
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white, width: 3),
              right: BorderSide(color: Colors.white, width: 3),
            ),
          ),
        ),
      ),
      // Bottom-left corner
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white, width: 3),
              left: BorderSide(color: Colors.white, width: 3),
            ),
          ),
        ),
      ),
      // Bottom-right corner
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white, width: 3),
              right: BorderSide(color: Colors.white, width: 3),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildControlButtons() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Torch toggle
          _ControlButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.white);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: _toggleTorch,
            tooltip: 'Toggle torch',
          ),

          // Camera switch
          _ControlButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front, color: Colors.white);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear, color: Colors.white);
                }
              },
            ),
            onPressed: _switchCamera,
            tooltip: 'Switch camera',
          ),

          // Pause/Resume
          _ControlButton(
            icon: Icon(
              _isScanning ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: _pauseResume,
            tooltip: _isScanning ? 'Pause scanning' : 'Resume scanning',
          ),

          // Manual entry
          _ControlButton(
            icon: const Icon(Icons.keyboard, color: Colors.white),
            onPressed: _openManualEntry,
            tooltip: 'Manual entry',
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: IconButton(
          icon: icon,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _ResultBottomSheet extends StatelessWidget {
  final GtinScanResult result;
  final VoidCallback onVerify;
  final VoidCallback onScanAgain;

  const _ResultBottomSheet({
    required this.result,
    required this.onVerify,
    required this.onScanAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Success icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
          ),

          const SizedBox(height: 16),

          // GTIN display (show original format, not normalized)
          Text(
            result.originalGtin.isNotEmpty ? result.originalGtin : result.gtin,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Symbology
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              result.symbology,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Validation status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                result.isValid ? Icons.check_circle : Icons.error,
                color: result.isValid ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                result.isValid ? 'Valid GTIN' : 'Invalid GTIN',
                style: TextStyle(
                  color: result.isValid ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onScanAgain,
                  child: const Text('Scan Again'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: result.isValid ? onVerify : null,
                  child: const Text('Verify GTIN'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Raw text (collapsible)
          ExpansionTile(
            title: const Text('Raw Data'),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.rawText,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
