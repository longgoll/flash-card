import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings), centerTitle: true),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader(context, l10n.appearance),
          ListTile(
            title: Text(l10n.themeMode),
            subtitle: Text(
              themeProvider.themeMode == ThemeMode.system
                  ? l10n.systemDefault
                  : themeProvider.themeMode == ThemeMode.dark
                  ? l10n.darkMode
                  : l10n.lightMode,
            ),
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.themeMode,
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  themeProvider.setThemeMode(newValue);
                }
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(l10n.systemDefault),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(l10n.lightMode),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(l10n.darkMode),
                ),
              ],
            ),
            leading: Icon(
              themeProvider.themeMode == ThemeMode.light
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.language),
          ListTile(
            title: Text(l10n.language),
            subtitle: Text(
              localeProvider.currentLanguage == AppLanguage.vietnamese
                  ? l10n.vietnamese
                  : l10n.english,
            ),
            trailing: DropdownButton<AppLanguage>(
              value: localeProvider.currentLanguage,
              onChanged: (AppLanguage? newValue) {
                if (newValue != null) {
                  localeProvider.setLanguage(newValue);
                }
              },
              items: [
                DropdownMenuItem(
                  value: AppLanguage.vietnamese,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [const Text('🇻🇳 '), Text(l10n.vietnamese)],
                  ),
                ),
                DropdownMenuItem(
                  value: AppLanguage.english,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [const Text('🇺🇸 '), Text(l10n.english)],
                  ),
                ),
              ],
            ),
            leading: const Icon(Icons.language),
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.about),
          ListTile(
            title: Text(l10n.version),
            subtitle: const Text("1.0.0"),
            leading: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
