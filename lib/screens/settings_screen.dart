import 'package:flutter/material.dart';

import '../widgets/app_theme.dart';
import '../widgets/screen_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _biometricLogin = false;
  bool _offlineModeDefault = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppTheme.contentMaxWidth(context),
          ),
          child: ListView(
            padding: AppTheme.pagePadding(context),
            children: [
              const ScreenHeader(
                title: 'Settings',
                subtitle: 'Customize your FlowPay experience',
              ),
              _SettingsSection(
                title: 'Notifications',
                children: [
                  _SwitchTile(
                    title: 'Push notifications',
                    subtitle: 'Payment alerts and security updates',
                    value: _pushNotifications,
                    onChanged: (v) => setState(() => _pushNotifications = v),
                  ),
                  _SwitchTile(
                    title: 'Email alerts',
                    subtitle: 'Weekly wallet summary',
                    value: _emailAlerts,
                    onChanged: (v) => setState(() => _emailAlerts = v),
                  ),
                ],
              ),
              _SettingsSection(
                title: 'Security & Privacy',
                children: [
                  _SwitchTile(
                    title: 'Biometric login',
                    subtitle: 'Use fingerprint or face unlock',
                    value: _biometricLogin,
                    onChanged: (v) => setState(() => _biometricLogin = v),
                  ),
                ],
              ),
              _SettingsSection(
                title: 'Offline',
                children: [
                  _SwitchTile(
                    title: 'Prefer offline queue',
                    subtitle: 'Save transfers locally when network is weak',
                    value: _offlineModeDefault,
                    onChanged: (v) => setState(() => _offlineModeDefault = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.panel(),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.cyanAccent),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Settings are stored locally for this demo build.',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.purpleAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppTheme.panel(),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        value: value,
        activeColor: AppColors.cyanAccent,
        onChanged: onChanged,
      ),
    );
  }
}
