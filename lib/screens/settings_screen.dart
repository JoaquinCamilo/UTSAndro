import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Pengaturan',
      currentIndex: 4,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection(
              'Tampilan',
              [
                _buildSwitchTile(
                  'Mode Gelap',
                  Icons.dark_mode,
                  false,
                  (value) {
                    // TODO: Implement dark mode
                  },
                ),
                _buildSwitchTile(
                  'Notifikasi',
                  Icons.notifications,
                  true,
                  (value) {
                    // TODO: Implement notifications
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Akun',
              [
                _buildListTile(
                  'Ubah Email',
                  Icons.email,
                  () {
                    // TODO: Implement change email
                  },
                ),
                _buildListTile(
                  'Ubah Password',
                  Icons.lock,
                  () {
                    // TODO: Implement change password
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Aplikasi',
              [
                _buildListTile(
                  'Tentang Aplikasi',
                  Icons.info,
                  () {
                    // TODO: Show about dialog
                  },
                ),
                _buildListTile(
                  'Bantuan',
                  Icons.help,
                  () {
                    // TODO: Show help dialog
                  },
                ),
                _buildListTile(
                  'Kebijakan Privasi',
                  Icons.privacy_tip,
                  () {
                    // TODO: Show privacy policy
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      secondary: Icon(icon),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildListTile(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
} 