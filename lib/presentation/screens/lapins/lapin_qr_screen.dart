import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../providers/core_providers.dart';
import '../../providers/lapin_provider.dart';
import '../../widgets/common/connectivity_banner.dart';
import '../../widgets/common/loading_widget.dart';

class LapinQrScreen extends HookConsumerWidget {
  final String lapinId;

  const LapinQrScreen({super.key, required this.lapinId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final repaintKey = useMemoized(GlobalKey.new);
    final lapinAsync = ref.watch(lapinDetailProvider(lapinId));
    final isBusy = useState(false);

    Future<Uint8List> capturePng() async {
      final renderObject = repaintKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        throw Exception('QR render not ready');
      }

      final image = await renderObject.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Could not encode PNG');
      return byteData.buffer.asUint8List();
    }

    Future<void> shareQrPng({
      required String filename,
    }) async {
      final bytes = await capturePng();
      final fileShare = ref.read(fileShareServiceProvider);
      final path = await fileShare.saveBytes(bytes: bytes, filename: filename);
      await fileShare.shareFile(path: path, mimeType: 'image/png');
    }

    Future<void> printQrPdf({
      required String title,
      required String qrData,
      required String? numeroIdentification,
    }) async {
      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Center(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(title, style: pw.TextStyle(fontSize: 20)),
                  if (numeroIdentification != null && numeroIdentification.trim().isNotEmpty) ...[
                    pw.SizedBox(height: 6),
                    pw.Text(numeroIdentification, style: pw.TextStyle(fontSize: 14)),
                  ],
                  pw.SizedBox(height: 16),
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: qrData,
                    width: 220,
                    height: 220,
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(qrData, style: pw.TextStyle(fontSize: 10)),
                ],
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (_) => doc.save());
    }

    Future<void> runSafely(Future<void> Function() fn) async {
      if (isBusy.value) return;
      isBusy.value = true;
      try {
        await fn();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        isBusy.value = false;
      }
    }

    return lapinAsync.when(
      loading: () => const Scaffold(body: LoadingWidget()),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.qrLapinTitle)),
        body: ErrorDisplayWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(lapinDetailProvider(lapinId)),
        ),
      ),
      data: (lapin) {
        final qrData = 'lapinia://lapin/${lapin.id}';

        return Scaffold(
          appBar: AppBar(title: Text(l10n.qrLapinTitle)),
          body: Column(
            children: [
              const ConnectivityBanner(),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RepaintBoundary(
                          key: repaintKey,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  QrImageView(
                                    data: qrData,
                                    version: QrVersions.auto,
                                    size: 280,
                                    gapless: false,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    lapin.nom,
                                    style: Theme.of(context).textTheme.titleLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                  if ((lapin.numeroIdentification ?? '').trim().isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      lapin.numeroIdentification!,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Text(
                                    qrData,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: isBusy.value
                                    ? null
                                    : () => runSafely(
                                          () => shareQrPng(
                                            filename: 'lapin_qr_${lapin.id}.png',
                                          ),
                                        ),
                                icon: const Icon(Icons.share),
                                label: Text(l10n.qrShare),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: isBusy.value
                                    ? null
                                    : () => runSafely(
                                          () => printQrPdf(
                                            title: lapin.nom,
                                            qrData: qrData,
                                            numeroIdentification: lapin.numeroIdentification,
                                          ),
                                        ),
                                icon: const Icon(Icons.print),
                                label: Text(l10n.qrPrint),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
