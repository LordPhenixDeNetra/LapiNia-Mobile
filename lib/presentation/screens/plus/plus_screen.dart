import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';

import '../../widgets/common/connectivity_banner.dart';

class PlusScreen extends StatelessWidget {
  const PlusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.plusTitle),
      ),
      body: ListView(
        children: [
          const ConnectivityBanner(),
          const SizedBox(height: 8),
          _Tile(
            icon: Icons.notifications_outlined,
            title: l10n.plusAlerts,
            onTap: () => context.push('/alertes'),
          ),
          _Tile(
            icon: Icons.grass_outlined,
            title: l10n.plusFeed,
            onTap: () => context.push('/aliments'),
          ),
          _Tile(
            icon: Icons.qr_code_scanner,
            title: l10n.plusQrScan,
            onTap: () => context.push('/qr/scan'),
          ),
          _Tile(
            icon: Icons.pets_outlined,
            title: l10n.plusRaces,
            onTap: () => context.push('/races'),
          ),
          _Tile(
            icon: Icons.settings_outlined,
            title: l10n.plusSettings,
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
