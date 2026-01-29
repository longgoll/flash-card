import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader("Appearance"),
          ListTile(
            title: const Text("Theme Mode"),
            subtitle: Text(
              themeProvider.themeMode == ThemeMode.system
                  ? "System Default"
                  : themeProvider.themeMode == ThemeMode.dark
                  ? "Dark Mode"
                  : "Light Mode",
            ),
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.themeMode,
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  themeProvider.setThemeMode(newValue);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text("System Default"),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text("Light Mode"),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text("Dark Mode"),
                ),
              ],
            ),
            leading: Icon(
              themeProvider.themeMode == ThemeMode.light
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
          // Future settings can go here
          const Divider(),
          _buildSectionHeader("About"),
          ListTile(
            title: const Text("Version"),
            subtitle: const Text("1.0.0"),
            leading: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
