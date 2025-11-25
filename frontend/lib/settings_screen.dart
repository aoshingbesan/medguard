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

  @override
  void initState() {
    super.initState();
    _loadSettings();
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
      // If enabling offline mode, always sync to get latest data
      if (enabled) {
        // Check if online before syncing
        final isOnline = await Api.isOnline();
        if (!isOnline) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No internet connection. Cannot sync data.'),
              backgroundColor: Colors.orange,
            ),
          );
          // Still enable offline mode with existing data
          await OfflineDatabase.setOfflineModeEnabled(enabled);
          setState(() {
            _offlineModeEnabled = enabled;
          });
          return;
        }

        // Show syncing message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Syncing data...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );

        // Sync data automatically when enabling offline mode
        final result = await Api.syncOfflineData();
        if (result['status'] != 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? languageService.failedToSync),
              backgroundColor: Colors.red,
            ),
          );
          // Don't enable offline mode if sync failed
          return;
        }

        // Success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${languageService.dataSyncedSuccessfully ?? 'Data synced'} (${result['total_records'] ?? 0} records)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Set offline mode state
      await OfflineDatabase.setOfflineModeEnabled(enabled);
      
      // Refresh stats after sync
      await _loadSettings();

      setState(() {
        _offlineModeEnabled = enabled;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled ? 'Offline Mode Enabled' : 'Online Mode Enabled',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
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
      body: Column(
        children: [
          Expanded(
            child: _isLoading
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

                        // About Section
                        _buildSectionHeader(languageService.about),
                        _buildAboutCard(languageService),
                      ],
                    ),
                  ),
          ),
        ],
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
              subtitle: Text(
                _offlineModeEnabled 
                  ? 'Data syncs automatically when enabled'
                  : languageService.enableOfflineVerification,
              ),
              value: _offlineModeEnabled,
              onChanged: (value) => _toggleOfflineMode(value),
              secondary: const Icon(Icons.offline_bolt),
            ),
            if (_offlineModeEnabled) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.sync),
                title: Text(languageService.syncData),
                subtitle: Text('Manual sync (auto-syncs when toggled on)'),
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
