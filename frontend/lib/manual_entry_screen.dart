import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'simple_language_service.dart';
import 'api.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final code = _controller.text.trim();
    try {
      final apiResult = await Api.verify(code);
      print('Manual Entry API Result: $apiResult');

      if (!mounted) return;

      // Check if the API returned a valid medicine
      if (apiResult['status'] == 'valid') {
        print('Manual Entry: Medicine is VALID - showing success result');
        // Medicine is verified - show success result
        Navigator.pushNamed(
          context,
          '/result',
          arguments: {
            'verified': true,
            'data': apiResult,
            'source': 'online',
          },
        );
      } else if (apiResult['status'] == 'warning') {
        print('Manual Entry: Medicine is NOT FOUND - showing warning result');
        // Medicine not found - show warning result
        Navigator.pushNamed(
          context,
          '/result',
          arguments: {
            'verified': false,
            'data': {
              'gtin': apiResult['gtin'],
              'product': 'Unknown Product',
              'message': apiResult['message'],
            },
            'source': 'online',
          },
        );
      } else {
        // API error
        setState(() {
          _error = apiResult['message'] ?? 'Verification failed';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    
    return Consumer<SimpleLanguageService>(
      builder: (context, languageService, child) {
        return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(languageService.enterGtinManually),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(languageService.gtinEan13, style: t.titleMedium),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(14),
                ],
                decoration:
                    InputDecoration(hintText: languageService.enterGtinCode),
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return languageService.pleaseEnterGtinCode;
                        // Only allow digits
                        if (!RegExp(r'^\d+$').hasMatch(s)) {
                          return languageService.onlyDigitsAllowed;
                        }
                        // Must be exactly 13 or 14 digits
                        if (s.length != 13 && s.length != 14) {
                          return languageService.gtinMustBeExactly13Or14Digits;
                        }
                        return null;
                      },
                onFieldSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_outline_rounded),
                label: Text(_loading
                    ? languageService.loading
                    : languageService.verifyMedicine),
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}
