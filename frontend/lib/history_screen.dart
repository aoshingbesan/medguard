import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'simple_language_service.dart';
import 'theme.dart';
import 'history_storage.dart';
import 'result_screen.dart';
import 'widgets/academic_disclaimer.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryItemDTO> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _items = await HistoryStorage.loadAll();
    setState(() => _loading = false);
  }

  String _fmtTime(DateTime dt, SimpleLanguageService languageService) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return languageService.formatMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return languageService.formatHoursAgo(diff.inHours);
    return languageService.formatDaysAgo(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    
    return Consumer<SimpleLanguageService>(
      builder: (context, languageService, child) {
        if (_loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_items.isEmpty) {
          return const _HistoryEmptyState();
        }

        return Scaffold(
          body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    languageService.history,
                    style: t.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: kBrandPrimary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: languageService.clearHistory,
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: Text(languageService.clearHistory),
                        content: Text(languageService.clearHistoryDescription),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(c, false),
                              child: Text(languageService.cancel)),
                          FilledButton(
                              onPressed: () => Navigator.pop(c, true),
                              child: Text(languageService.clear)),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await HistoryStorage.clear();
                      await _load();
                    }
                  },
                  icon: const Icon(Icons.delete_sweep_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final it = _items[i];
                  final statusColor = it.verified ? kSuccess : kDanger;
                  final statusText = it.verified
                      ? languageService.verified
                      : languageService.notVerified;
                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      title: Text(it.brand, style: t.titleMedium),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          [
                            'GTIN: ${it.gtin}',
                            if (it.lot != null && it.lot!.isNotEmpty)
                              'Lot: ${it.lot}',
                            _fmtTime(it.scannedAt, languageService),
                          ].join(' • '),
                          style: t.bodyMedium?.copyWith(color: kTextSecondary),
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: statusColor.withOpacity(0.35)),
                        ),
                        child: Text(
                          statusText,
                          style: t.bodyMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onTap: () {
                        // Navigate to result screen with the stored data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultScreen(
                              verified: it.verified,
                              data: it.data ?? {
                                'gtin': it.gtin,
                                'product': it.brand,
                                'batch': it.lot,
                              },
                              fromHistory: true, // Flag to prevent duplicate save
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Consumer<SimpleLanguageService>(
      builder: (context, languageService, child) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded, size: 56, color: kTextSecondary),
            const SizedBox(height: 14),
            Text(languageService.noScansYet, style: t.headlineSmall),
            const SizedBox(height: 6),
            Text(
              languageService.scanHistoryDescription,
              style: t.bodyMedium?.copyWith(color: kTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
    );
  }
}
