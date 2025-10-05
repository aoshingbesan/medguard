import 'package:flutter/material.dart';
import 'api.dart';
import 'theme.dart';

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

    setState(() { _loading = true; _error = null; });

    final code = _controller.text.trim();
    try {
      final res = await MedGuardApi.verify(code);
      final verified = (res['status'] == 'valid');

      final data = verified
          ? <String, dynamic>{
              'product_name': res['product_name'] ?? '—',
              'manufacturer': (res['manufacturer'] is Map)
                  ? (res['manufacturer']['name'] ?? '—')
                  : (res['manufacturer'] ?? '—'),
              'country': (res['manufacturer'] is Map)
                  ? (res['manufacturer']['country'] ?? res['country'] ?? '—')
                  : (res['country'] ?? '—'),
              'rfda_reg_no': res['rfda_reg_no'] ?? '—',
              'reg_date': res['reg_date'] ?? '—',
              'status': res['reg_status'] ?? 'Active and Verified',
              'dosage_form': res['dosage_form'] ?? '—',
              'strength': res['strength'] ?? '—',
              'pack_size': res['pack_size'] ?? '—',
              'batch_number': res['batch'] ?? '—',
              'mfg_date': res['mfg_date'] ?? '—',
              'expiry': res['reg_expiry'] ?? '—',
              'gtin': res['gtin'] ?? code,
            }
          : <String, dynamic>{ 'gtin': res['gtin'] ?? code };

      if (!mounted) return;
      Navigator.pushNamed(context, '/result', arguments: {'verified': verified, 'data': data});
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Enter GTIN Manually'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GTIN / EAN-13', style: t.titleMedium),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'e.g., 5407003240214'),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'Please enter a code';
                  if (!RegExp(r'^\d{8,14}$').hasMatch(s)) return 'Enter 8–14 digits';
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(height: 12),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_outline_rounded),
                label: Text(_loading ? 'Verifying…' : 'Verify Medicine'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
