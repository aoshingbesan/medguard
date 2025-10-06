import 'package:flutter/material.dart';
import 'theme.dart';
import 'history_storage.dart';

class ResultScreen extends StatefulWidget {
  final bool verified;
  final Map<String, dynamic>? data;

  const ResultScreen({
    super.key,
    this.verified = false,
    this.data,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    if (widget.data == null) return;
    
    final item = HistoryItemDTO(
      brand: widget.data!['product'] ?? 'Unknown Product',
      gtin: widget.data!['gtin'] ?? '',
      lot: widget.data!['batch'],
      verified: widget.verified,
      scannedAt: DateTime.now(),
    );
    
    await HistoryStorage.add(item);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.verified ? 'Medicine Verified' : 'Medicine Not Verified';
    final iconColor = widget.verified ? Colors.green : Colors.orange.shade700;
    final bgAccent = widget.verified
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            const SizedBox(height: 20),
            Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.verified
                      ? [Colors.green.shade800, Colors.green.shade900]
                      : [Colors.orange.shade100, Colors.orange.shade200],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.verified ? Colors.green.shade800 : iconColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  Icon(
                    widget.verified ? Icons.verified_rounded : Icons.warning_rounded,
                    color: iconColor,
                    size: 64,
                  ),
                  if (widget.verified)
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade800,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: widget.verified ? Colors.green.shade900 : Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.verified
                      ? 'This medicine is registered and verified by Rwanda FDA'
                      : 'This medicine could not be verified in our database',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (!widget.verified) ...[
              const SizedBox(height: 16),
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
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
            ],

            if (widget.verified) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.shade800.withOpacity(0.1),
                      Colors.green.shade900.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade800.withOpacity(0.3), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade800.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade800,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.medication_liquid_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Product Information',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _InfoSection(
                            title: 'Basic Information',
                            icon: Icons.info_outline,
                            children: [
                              _InfoRowWithIcon(
                                Icons.qr_code,
                                'GTIN',
                                widget.data?['gtin'] ?? '—',
                              ),
                              _InfoRowWithIcon(
                                Icons.medication,
                                'Product Name',
                                widget.data?['product'] ?? '—',
                              ),
                              _InfoRowWithIcon(
                                Icons.science,
                                'Generic Name',
                                widget.data?['genericName'] ?? '—',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _InfoSection(
                            title: 'Dosage & Packaging',
                            icon: Icons.local_pharmacy,
                            children: [
                              _InfoRowWithIcon(
                                Icons.medication_liquid,
                                'Dosage Form',
                                widget.data?['dosageForm'] ?? '—',
                              ),
                              _InfoRowWithIcon(
                                Icons.fitness_center,
                                'Strength',
                                widget.data?['strength'] ?? '—',
                              ),
                              _InfoRowWithIcon(
                                Icons.inventory_2,
                                'Pack Size',
                                widget.data?['pack_size'] ?? '—',
                              ),
                              _InfoRowWithIcon(
                                Icons.inventory,
                                'Packaging Type',
                                widget.data?['packaging_type'] ?? '—',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _InfoSection(
                            title: 'Registration Details',
                            icon: Icons.verified_user,
                            children: [
                              _InfoRowWithIcon(
                                Icons.calendar_today,
                                'Registration Date',
                                widget.data?['registration_date'] ?? '—',
                              ),
                              _InfoRowWithIcon(
                                Icons.event,
                                'License Expiry Date',
                                widget.data?['license_expiry_date'] ?? '—',
                                isExpiry: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _InfoSection(
                            title: 'Validity & Storage',
                            icon: Icons.schedule,
                            children: [
                              _InfoRowWithIcon(
                                Icons.timer,
                                'Shelf Life',
                                widget.data?['shelf_life'] ?? '—',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _InfoSection(
                            title: 'Manufacturer Details',
                            icon: Icons.business,
                            children: [
                              _InfoRowWithIcon(
                                Icons.factory,
                                'Manufacturer',
                                widget.data?['marketing_authorization_holder'] ?? '—',
                              ),
                              _InfoRowWithIcon(
                                Icons.location_on,
                                'Local Representative',
                                widget.data?['local_technical_representative'] ?? '—',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.verified
                      ? [Colors.green.shade800, Colors.green.shade900]
                      : [Colors.orange.shade600, Colors.orange.shade700],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (widget.verified ? Colors.green.shade800 : Colors.orange).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    if (widget.verified) {
                      Navigator.pushNamed(context, '/home');
                    } else {
                    }
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.verified ? Icons.qr_code_scanner : Icons.report,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.verified ? 'Scan another Medicine' : 'Report to RFDA',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home,
                          color: Colors.grey.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Go Back Home',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade800.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.green.shade800,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRowWithIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isExpiry;

  const _InfoRowWithIcon(
    this.icon,
    this.label,
    this.value, {
    this.isExpiry = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isExpiry ? Colors.orange.shade100 : Colors.green.shade800.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isExpiry ? Colors.orange.shade700 : Colors.green.shade800,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isExpiry ? Colors.orange.shade800 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
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
