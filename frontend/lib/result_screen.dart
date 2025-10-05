import 'package:flutter/material.dart';
import 'theme.dart';

class ResultScreen extends StatelessWidget {
  final bool verified;
  final Map<String, dynamic>? data;

  const ResultScreen({
    super.key,
    this.verified = false,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    final title = verified ? 'Medicine Verified' : 'Medicine Not Verified';
    final iconColor = verified ? Colors.green : Colors.orange.shade700;
    final bgAccent = verified
        ? Colors.green.withOpacity(0.1)
        : Colors.orange.withOpacity(0.1);

    return Scaffold(
      backgroundColor: kAppBg,
      appBar: AppBar(
        backgroundColor: kAppBg,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black87),
          label: const Text('Back', style: TextStyle(color: Colors.black)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(color: bgAccent, shape: BoxShape.circle),
              child: Icon(
                verified ? Icons.verified_rounded : Icons.error_outline_rounded,
                color: iconColor,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 32),

            if (!verified) ...[
              _InfoCard(
                title: 'Important Notice',
                borderColor: Colors.orange.shade200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('This medicine could be not registered with Rwanda FDA or the barcode could not be verified.'),
                    SizedBox(height: 12),
                    Text('Possible Reason', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    _BulletList(items: [
                      'Counterfeit or fake medicine',
                      'Unregistered product',
                      'Damaged or incorrect barcode',
                      'Expired registration',
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _InfoCard(
                title: 'Safety Recommendations',
                borderColor: Colors.red.shade200,
                child: const _BulletList(items: [
                  'Do not consume this medicine',
                  'Keep the medicine package for evidence',
                  'Report immediately to Rwanda FDA',
                  'Return to the pharmacy where purchased',
                ]),
              ),
            ],

            if (verified) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Product Information', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('GTIN: ${data?['gtin'] ?? '—'}'),
                    Text('Brand: ${data?['brand'] ?? '—'}'),
                    Text('INN: ${data?['inn'] ?? '—'}'),
                    Text('Expiry Date: ${data?['expiry'] ?? '—'}'),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
            _MainButton(
              text: verified ? 'Scan another Medicine' : 'Report to RFDA',
              color: verified ? Colors.green.shade700 : Colors.orange.shade800,
              textColor: Colors.white,
              onPressed: () {
                if (verified) {
                  Navigator.pushNamed(context, '/home');
                } else {
                  // TODO: open report link or compose email
                }
              },
            ),
            const SizedBox(height: 16),
            _MainButton(
              text: 'Go Back Home',
              color: Colors.transparent,
              outline: true,
              textColor: Colors.black,
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color borderColor;

  const _InfoCard({
    required this.title,
    required this.child,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  const _BulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $e'),
              ))
          .toList(),
    );
  }
}

class _MainButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final bool outline;
  final VoidCallback onPressed;

  const _MainButton({
    required this.text,
    required this.color,
    required this.textColor,
    required this.onPressed,
    this.outline = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: outline
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kBrandPrimary, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
            )
          : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
            ),
    );
  }
}
