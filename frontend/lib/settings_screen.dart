import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'simple_language_service.dart';
import 'offline_database.dart';
import 'api.dart';
import 'theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _offlineModeEnabled = false;
  bool _isLoading = false;
  Map<String, dynamic>? _offlineStats;
  Map<String, dynamic>? _connectionStatus;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _testConnection();
  }

  Future<void> _testConnection() async {
    final status = await Api.testConnection();
    setState(() {
      _connectionStatus = status;
    });
  }

  Future<void> _loadSettings() async {
    final offlineMode = await OfflineDatabase.isOfflineModeEnabled();
    final stats = await OfflineDatabase.getDatabaseStats();

    setState(() {
      _offlineModeEnabled = offlineMode;
      _offlineStats = stats;
    });
  }

  Future<void> _toggleOfflineMode(bool enabled) async {
    final languageService = Provider.of<SimpleLanguageService>(context, listen: false);
    setState(() {
      _isLoading = true;
    });

    try {
      await OfflineDatabase.setOfflineModeEnabled(enabled);

      if (enabled && !await OfflineDatabase.hasOfflineData()) {
        // Sync data when enabling offline mode
        final result = await Api.syncOfflineData();
        if (result['status'] != 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? languageService.failedToSync),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      setState(() {
        _offlineModeEnabled = enabled;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled ? 'Offline Mode' : 'Online Mode',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${languageService.error}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _syncOfflineData() async {
    final languageService = Provider.of<SimpleLanguageService>(context, listen: false);
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await Api.syncOfflineData();

      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(languageService.dataSyncedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        await _loadSettings(); // Refresh stats
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? languageService.syncFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearOfflineData() async {
    final languageService = Provider.of<SimpleLanguageService>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageService.clearHistory),
        content: Text(languageService.areYouSureClearOfflineData),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(languageService.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(languageService.delete),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await OfflineDatabase.clearOfflineData();
        await _loadSettings();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(languageService.offlineDataClearedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${languageService.errorClearingData} $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SimpleLanguageService>(
      builder: (context, languageService, child) {
        return _buildContent(context, languageService);
      },
    );
  }

  Widget _buildContent(BuildContext context, SimpleLanguageService languageService) {
    return Scaffold(
      appBar: AppBar(
        title: Text(languageService.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language Section
                  _buildSectionHeader(languageService.language),
                  _buildLanguageCard(languageService),

                  const SizedBox(height: 24),

                  // Offline Mode Section
                  _buildSectionHeader(languageService.offlineVerification),
                  _buildOfflineModeCard(languageService),

                  const SizedBox(height: 24),

                  // Offline Data Section
                  if (_offlineStats != null) ...[
                    _buildSectionHeader('Offline Data'),
                    _buildOfflineDataCard(languageService),
                    const SizedBox(height: 24),
                  ],

                  // Connection Status Section
                  _buildSectionHeader(languageService.databaseConnection),
                  _buildConnectionCard(languageService),

                  const SizedBox(height: 24),

                  // About Section
                  _buildSectionHeader(languageService.about),
                  _buildAboutCard(languageService),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: kBrandPrimary,
        ),
      ),
    );
  }

  Widget _buildLanguageCard(SimpleLanguageService languageService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(languageService.selectLanguage),
              subtitle: Text(languageService.getLanguageName(languageService.currentLanguage)),
              onTap: () => _showLanguageDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineModeCard(SimpleLanguageService languageService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(languageService.offlineVerification),
              subtitle: Text(languageService.enableOfflineVerification),
              value: _offlineModeEnabled,
              onChanged: (value) => _toggleOfflineMode(value),
              secondary: const Icon(Icons.offline_bolt),
            ),
            if (_offlineModeEnabled) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.sync),
                title: Text(languageService.syncData),
                subtitle: Text(languageService.lastSyncNever),
                onTap: () => _syncOfflineData(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineDataCard(SimpleLanguageService languageService) {
    final stats = _offlineStats!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.storage),
              title: Text('${stats['total_medicines']} ${languageService.totalMedicines}'),
              subtitle: Text('${stats['verified_medicines']} ${languageService.verifiedMedicines}'),
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: Text(languageService.syncData),
              onTap: () => _syncOfflineData(),
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(languageService.clearHistory),
              onTap: () => _clearOfflineData(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionCard(SimpleLanguageService languageService) {
    final status = _connectionStatus;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (status == null)
              ListTile(
                leading: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                title: Text(languageService.testingConnection),
              )
            else ...[
              ListTile(
                leading: Icon(
                  status['connected'] == true
                      ? Icons.cloud_done
                      : Icons.cloud_off,
                  color: status['connected'] == true
                      ? Colors.green
                      : Colors.red,
                ),
                title: Text(
                  status['connected'] == true
                      ? languageService.connectedToSupabase
                      : languageService.notConnected,
                  style: TextStyle(
                    color: status['connected'] == true
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(status['message'] ?? languageService.unknownStatus),
              ),
              if (status['connected'] == true) ...[
                const Divider(),
                if (status['products_table'] != null)
                  ListTile(
                    leading: const Icon(Icons.medication, size: 20),
                    title: Text(languageService.productsTable),
                    subtitle: Text(status['products_table'] ?? ''),
                    dense: true,
                  ),
                if (status['pharmacies_table'] != null)
                  ListTile(
                    leading: const Icon(Icons.local_pharmacy, size: 20),
                    title: Text(languageService.pharmaciesTable),
                    subtitle: Text(status['pharmacies_table'] ?? ''),
                    dense: true,
                  ),
              ] else if (status['error'] != null) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.error_outline, size: 20, color: Colors.red),
                  title: Text(languageService.error),
                  subtitle: Text(
                    status['error'] ?? languageService.unknownError,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  dense: true,
                ),
              ],
              const Divider(),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(languageService.testConnection),
                onTap: () {
                  setState(() {
                    _connectionStatus = null;
                  });
                  _testConnection();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(SimpleLanguageService languageService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(languageService.version),
              subtitle: const Text('1.0.0'),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: Text(languageService.help),
              onTap: () {
                // Show help dialog
                showDialog(
                  context: context,
                  builder: (context) {
                    final langService = Provider.of<SimpleLanguageService>(context);
                    return AlertDialog(
                      title: Text(langService.help),
                      content: Text(langService.helpDescription),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(langService.ok),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Consumer<SimpleLanguageService>(
          builder: (context, langService, child) {
            return AlertDialog(
              title: Text(langService.selectLanguage),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<AppLanguage>(
                      title: Text(langService.getLanguageName(AppLanguage.english)),
                      value: AppLanguage.english,
                      groupValue: langService.currentLanguage,
                      onChanged: (AppLanguage? value) {
                        if (value != null) {
                          Navigator.of(dialogContext).pop();
                          _changeLanguage(value);
                        }
                      },
                    ),
                    RadioListTile<AppLanguage>(
                      title: Text(langService.getLanguageName(AppLanguage.french)),
                      value: AppLanguage.french,
                      groupValue: langService.currentLanguage,
                      onChanged: (AppLanguage? value) {
                        if (value != null) {
                          Navigator.of(dialogContext).pop();
                          _changeLanguage(value);
                        }
                      },
                    ),
                    RadioListTile<AppLanguage>(
                      title: Text(langService.getLanguageName(AppLanguage.kinyarwanda)),
                      value: AppLanguage.kinyarwanda,
                      groupValue: langService.currentLanguage,
                      onChanged: (AppLanguage? value) {
                        if (value != null) {
                          Navigator.of(dialogContext).pop();
                          _changeLanguage(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _changeLanguage(AppLanguage language) async {
    // Use the language service to change language
    final languageService =
        Provider.of<SimpleLanguageService>(context, listen: false);
    
    // Change the language
    await languageService.changeLanguage(language);
    
    // Force a rebuild of the settings screen
    if (mounted) {
      setState(() {});
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(languageService.languageChanged),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
