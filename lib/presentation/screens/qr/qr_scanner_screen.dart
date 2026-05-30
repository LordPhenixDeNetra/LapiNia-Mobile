import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../widgets/common/connectivity_banner.dart';

class QrScannerScreen extends HookConsumerWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isHandling = useState(false);

    void showError(String message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }

    String? parseLapinId(String raw) {
      final uri = Uri.tryParse(raw.trim());
      if (uri != null &&
          uri.scheme == 'lapinia' &&
          uri.host == 'lapin' &&
          uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.qrScanTitle),
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(
            child: MobileScanner(
              onDetect: (capture) async {
                if (isHandling.value) return;
                if (capture.barcodes.isEmpty) return;

                final value = capture.barcodes.first.rawValue;
                if (value == null || value.trim().isEmpty) return;

                final lapinId = parseLapinId(value);
                if (lapinId == null) {
                  isHandling.value = true;
                  showError(l10n.qrScanInvalid);
                  await Future<void>.delayed(const Duration(milliseconds: 900));
                  isHandling.value = false;
                  return;
                }

                isHandling.value = true;
                if (!context.mounted) return;
                context.go('/lapin/$lapinId');
              },
            ),
          ),
        ],
      ),
    );
  }
}

