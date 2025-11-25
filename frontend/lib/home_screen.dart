import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'simple_language_service.dart';
import 'theme.dart';
import 'history_screen.dart';
import 'pharmacies_screen.dart';
import 'settings_screen.dart';
import 'gtin_scanner/gtin_scanner.dart';
import 'gtin_scanner/models/gtin_scan_result.dart';
import 'api.dart';
import 'analytics_service.dart';
import 'widgets/academic_disclaimer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  Future<void> _scanGtin() async {
    final result = await GtinScanner.scanGtin(context);
    if (result != null) {
      await _processGtinResult(result);
    }
  }

  Future<void> _processGtinResult(GtinScanResult result) async {
    if (!result.isValid) {
      final languageService = Provider.of<SimpleLanguageService>(context, listen: false);
      _showErrorDialog('${languageService.invalidGtin} ${result.gtin}');
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Verify the medicine using the original GTIN format (not normalized)
      // Use original format for API call since database likely stores original format
      final gtinForApi = result.originalGtin.isNotEmpty ? result.originalGtin : result.gtin;
      final apiResult = await Api.verify(gtinForApi);
      print('API Result: $apiResult');
      print('GTIN used for API: $gtinForApi (original: ${result.originalGtin}, normalized: ${result.gtin})');

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Check if the API returned a valid medicine
        if (apiResult['status'] == 'valid') {
          print('Medicine is VALID - showing success result');
          // Use original GTIN for display, but keep normalized for API
          final displayData = Map<String, dynamic>.from(apiResult);
          displayData['gtin'] = result.originalGtin.isNotEmpty ? result.originalGtin : apiResult['gtin'];
          
          // Track analytics: verified scan
          AnalyticsService.trackVerification(
            gtin: gtinForApi,
            method: 'scan',
            result: 'verified',
            source: apiResult['source'] ?? 'online',
            productName: displayData['product']?.toString(),
            manufacturer: displayData['manufacturer']?.toString(),
          );
          
          // Medicine is verified - show success result
          Navigator.pushNamed(
            context,
            '/result',
            arguments: {
              'verified': true,
              'data': displayData,
              'source': 'online',
            },
          );
        } else if (apiResult['status'] == 'warning') {
          print('Medicine is NOT FOUND - showing warning result');
          // Use original GTIN for display
          final displayGtin = result.originalGtin.isNotEmpty ? result.originalGtin : apiResult['gtin'];
          
          // Track analytics: unverified scan
          AnalyticsService.trackVerification(
            gtin: gtinForApi,
            method: 'scan',
            result: 'unverified',
            source: apiResult['source'] ?? 'online',
          );
          
          // Medicine not found - show warning result
          Navigator.pushNamed(
            context,
            '/result',
            arguments: {
              'verified': false,
              'data': {
                'gtin': displayGtin,
                'product': 'Unknown Product',
                'message': apiResult['message'],
              },
              'source': 'online',
            },
          );
        } else {
          // API error
          // Track analytics: error
          AnalyticsService.trackVerification(
            gtin: gtinForApi,
            method: 'scan',
            result: 'error',
            source: apiResult['source'] ?? 'online',
          );
          _showErrorDialog(apiResult['message'] ?? 'Verification failed');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog('Error processing GTIN: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    final languageService = Provider.of<SimpleLanguageService>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageService.error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(languageService.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Consumer<SimpleLanguageService>(
      builder: (context, languageService, child) {
        return _buildContent(context, t, languageService);
      },
    );
  }

  Widget _buildContent(BuildContext context, TextTheme t, SimpleLanguageService languageService) {
    Widget homeBody() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                style: t.displaySmall?.copyWith(height: 1.25),
                children: [
                  TextSpan(text: '${languageService.verifyYourMedicine} '),
                  TextSpan(
                    text: languageService.seconds,
                    style: const TextStyle(color: kBrandPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              languageService.scanAndVerify,
              style: const TextStyle(
                  color: kTextSecondary, fontSize: 18, height: 1.35),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _scanGtin,
                child: Text(languageService.scanTheProduct),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/manual'),
                child: Text(languageService.enterGtinManually),
              ),
            ),
          ],
        ),
      );
    }

    Widget body() {
      Widget content;
      if (_tab == 0) {
        content = homeBody();
      } else if (_tab == 1) {
        content = const HistoryScreen();
      } else if (_tab == 2) {
        content = const PharmaciesScreen();
      } else {
        content = const SettingsScreen();
      }
      
      return Column(
        children: [
          Expanded(child: content),
          const AcademicDisclaimer(),
        ],
      );
    }

    return Scaffold(
      backgroundColor: kAppBg,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: kAppBg,
        // Removed settings icon from AppBar - it's already in bottom navigation
      ),
      body: body(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: languageService.home),
          BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart_rounded),
              label: languageService.history),
          BottomNavigationBarItem(
              icon: const Icon(Icons.local_pharmacy_rounded),
              label: languageService.pharmacies),
          BottomNavigationBarItem(
              icon: const Icon(Icons.settings_rounded),
              label: languageService.settings),
        ],
      ),
    );
  }
}
