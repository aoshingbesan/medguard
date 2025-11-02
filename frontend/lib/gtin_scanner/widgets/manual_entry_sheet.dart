import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../simple_language_service.dart';
import '../services/gtin_validator.dart';
import '../models/gtin_scan_result.dart';

/// Manual GTIN entry sheet with validation
class ManualEntrySheet extends StatefulWidget {
  final Function(GtinScanResult) onResult;

  const ManualEntrySheet({
    super.key,
    required this.onResult,
  });

  @override
  State<ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends State<ManualEntrySheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isValidating = false;
  String? _errorMessage;
  bool _isValid = false;
  late SimpleLanguageService _languageService;

  @override
  void initState() {
    super.initState();
    _languageService = Provider.of<SimpleLanguageService>(context, listen: false);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    final cleanText = text.replaceAll(RegExp(r'[^\d]'), '');
    
    setState(() {
      _errorMessage = null;
      _isValid = false;
    });

    // Check length first - must be 13 or 14 digits
    if (cleanText.length == 13 || cleanText.length == 14) {
      _validateGtin(text);
    } else if (cleanText.isNotEmpty && cleanText.length < 13) {
      setState(() {
        _errorMessage = _languageService.gtinMustBe13Or14Digits;
      });
    } else if (cleanText.length > 14) {
      setState(() {
        _errorMessage = _languageService.gtinCannotExceed14Digits;
      });
    }
  }

  Future<void> _validateGtin(String gtin) async {
    setState(() {
      _isValidating = true;
      _errorMessage = null;
    });

    // Simulate validation delay
    await Future.delayed(const Duration(milliseconds: 300));

    final cleanGtin = gtin.replaceAll(RegExp(r'[^\d]'), '');
    
    // Only check if it's 13 or 14 digits - let API verify checksum
    if (cleanGtin.length == 13 || cleanGtin.length == 14) {
      if (mounted) {
        setState(() {
          _isValidating = false;
          _isValid = true; // Accept if length is correct
        });
      }
      } else if (mounted) {
        setState(() {
          _isValidating = false;
          _isValid = false;
          _errorMessage = _languageService.gtinMustBeExactly13Or14Digits;
        });
      }
  }

  void _submitGtin() {
    if (!_isValid) return;

    final cleanGtin = _controller.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Only accept 13 or 14 digits
    if (cleanGtin.length != 13 && cleanGtin.length != 14) {
      setState(() {
        _errorMessage = _languageService.gtinMustBeExactly13Or14Digits;
        _isValid = false;
      });
      return;
    }
    
    // Normalize to GTIN-14 format for consistency
    final gtin14 = GtinValidator.normalizeToGtin14(cleanGtin);
    final gtinType = GtinValidator.getGtinType(cleanGtin);

    final result = GtinScanResult(
      rawText: _controller.text,
      gtin: gtin14,
      symbology: gtinType,
      scannedAt: DateTime.now(),
      isValid: true,
    );

    widget.onResult(result);
    Navigator.of(context).pop();
  }

  void _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      _controller.text = clipboardData!.text!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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

          // Title
          Builder(
            builder: (context) {
              final languageService = Provider.of<SimpleLanguageService>(context);
              return Column(
                children: [
                  Text(
                    languageService.manualGtinEntry,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    languageService.enterOrPasteGtinCode,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Input field
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(14),
            ],
            decoration: InputDecoration(
              hintText: _languageService.enterGtin13Or14Digits,
              prefixIcon: const Icon(Icons.qr_code),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _errorMessage = null;
                          _isValid = false;
                        });
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.paste),
                      onPressed: _pasteFromClipboard,
                      tooltip: 'Paste from clipboard',
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _isValid ? Colors.green : Colors.blue,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            onSubmitted: (_) => _submitGtin(),
          ),

          // Validation status
          if (_isValidating)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(_languageService.validating),
                ],
              ),
            ),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          if (_isValid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _languageService.validGtin,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Builder(
                builder: (context) {
                  final languageService = Provider.of<SimpleLanguageService>(context);
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(languageService.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _isValid ? _submitGtin : null,
                          child: Text(languageService.verifyGtin),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Help text
          Text(
            _languageService.enter13Or14DigitCode,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
