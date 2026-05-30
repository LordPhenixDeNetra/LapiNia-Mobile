import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_typography.dart';
import '../../../core/constants/enums.dart';
import '../../../core/models/lapin.dart';
import '../../../domain/services/lapin_photo_service.dart';
import '../../providers/core_providers.dart';
import '../../providers/lapin_provider.dart';
import '../../widgets/common/connectivity_banner.dart';
import '../../widgets/common/loading_widget.dart';

class LapinDetailScreen extends ConsumerWidget {
  final String lapinId;

  const LapinDetailScreen({super.key, required this.lapinId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lapinAsync = ref.watch(lapinDetailProvider(lapinId));

    Future<void> deleteLapin(Lapin lapin) async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.deleteConfirmTitle),
          content: Text(l10n.deleteConfirmBody(lapin.nom)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.delete),
            ),
          ],
        ),
      );
      if (ok != true) return;

      await ref.read(lapinsProvider.notifier).remove(lapin.id);
      if (!context.mounted) return;
      context.pop();
    }

    Future<void> recordPesee() async {
      final poidsController = TextEditingController();
      final poids = await showDialog<int?>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.lapinAddWeightTitle),
          content: TextField(
            controller: poidsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.lapinWeightGramLabel),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, int.tryParse(poidsController.text));
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      );

      if (poids == null) return;
      await ref
          .read(lapinsProvider.notifier)
          .recordPesee(lapinId: lapinId, poidsG: poids);
      ref.invalidate(lapinDetailProvider(lapinId));
      await ref.read(lapinsProvider.notifier).refresh();
    }

    Future<ImageSource?> selectPhotoSource() async {
      return showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: Text(l10n.photoCamera),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(l10n.photoGallery),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );
    }

    Future<void> changePhoto(Lapin lapin) async {
      final connectivity = ref.read(connectivityCheckerProvider);
      if (!connectivity.isOnline) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.photoChangeRequiresOnline)),
        );
        return;
      }

      final source = await selectPhotoSource();
      if (source == null) return;

      try {
        final supabase = ref.read(supabaseClientProvider);
        final userId = supabase.auth.currentUser?.id;
        if (userId == null) {
          throw Exception('User not authenticated');
        }
        final service = ref.read(lapinPhotoServiceProvider);
        final filePath = await service.pickCropAndValidate(source: source);
        if (filePath == null) return;
        final url =
            await service.uploadLapinPhoto(userId: userId, lapinId: lapin.id, filePath: filePath);

        await ref
            .read(lapinsProvider.notifier)
            .updateLapin(lapin.copyWith(photoUrl: url));
        ref.invalidate(lapinDetailProvider(lapinId));
      } catch (e) {
        if (!context.mounted) return;
        final raw = e.toString();
        final extra = raw.contains('row-level security policy') || raw.contains('statusCode: 403')
            ? '\n\nUpload refusé par Storage (RLS). Vérifie les policies du bucket "lapins" (chemin attendu: "${lapin.userId}/${lapin.id}.jpg").'
            : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is LapinPhotoException && e.error == LapinPhotoError.tooLarge
                  ? l10n.photoTooLarge
                  : '${e.toString()}$extra',
            ),
          ),
        );
      }
    }

    return lapinAsync.when(
      loading: () => const Scaffold(
        body: LoadingWidget(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.lapinTitle)),
        body: ErrorDisplayWidget(
          message: e is LapinOfflineNotFoundException
              ? l10n.lapinOfflineNotFound
              : e.toString(),
          onRetry: () => ref.invalidate(lapinDetailProvider(lapinId)),
        ),
      ),
      data: (lapin) {
        final poidsKg = lapin.poidsKg;
        final photoUrl = lapin.photoUrl?.trim();

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: Text(lapin.nom),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.push('/lapin/${lapin.id}/edit'),
                ),
                IconButton(
                  icon: const Icon(Icons.photo_camera_outlined),
                  onPressed: () => changePhoto(lapin),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => deleteLapin(lapin),
                ),
              ],
              bottom: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                dividerColor: Colors.transparent,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: l10n.lapinTabGrowth),
                  Tab(text: l10n.lapinTabHealth),
                  Tab(text: l10n.lapinTabRepro),
                  Tab(text: l10n.lapinTabInfo),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: recordPesee,
              icon: const Icon(Icons.scale),
              label: Text(l10n.quickEventWeight),
            ),
            body: Column(
              children: [
                const ConnectivityBanner(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      if (photoUrl != null && photoUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(44),
                          child: CachedNetworkImage(
                            imageUrl: photoUrl,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 88,
                              height: 88,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                            ),
                            errorWidget: (context, url, error) => _photoFallback(lapin),
                          ),
                        )
                      else
                        _photoFallback(lapin),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lapin.nom, style: AppTypography.headline3),
                            const SizedBox(height: 4),
                            Text(
                              lapin.race?.nom ?? '—',
                              style: AppTypography.body2.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    children: [
                      _placeholderTab(l10n: l10n, title: l10n.lapinTabGrowth),
                      _placeholderTab(l10n: l10n, title: l10n.lapinTabHealth),
                      _placeholderTab(l10n: l10n, title: l10n.lapinTabRepro),
                      ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.lapinInfoSection,
                                    style: AppTypography.subtitle1,
                                  ),
                                  const SizedBox(height: 12),
                                  _row(context, l10n.lapinFieldRace,
                                      lapin.race?.nom ?? '—'),
                                  _row(context, l10n.lapinFieldSexe,
                                      lapin.sexe.label),
                                  _row(context, l10n.lapinFieldStatut,
                                      lapin.statut.label),
                                  _row(
                                    context,
                                    l10n.lapinFieldPoids,
                                    poidsKg != null
                                        ? '${poidsKg.toStringAsFixed(2)} kg'
                                        : '—',
                                  ),
                                  _row(context, l10n.lapinFieldAge,
                                      lapin.ageFormate ?? '—'),
                                  if (lapin.numeroIdentification != null)
                                    _row(
                                      context,
                                      l10n.lapinFieldId,
                                      lapin.numeroIdentification!,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (lapin.notes != null &&
                              lapin.notes!.trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.lapinNotesSection,
                                      style: AppTypography.subtitle1,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(lapin.notes!,
                                        style: AppTypography.body2),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _placeholderTab({
    required AppLocalizations l10n,
    required String title,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          l10n.comingSoonLabel(title),
          style: AppTypography.body1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _photoFallback(Lapin lapin) {
    final isMale = lapin.sexe == SexeLapin.male;
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: isMale
            ? const Color(0xFF2196F3).withValues(alpha: 0.12)
            : const Color(0xFFE91E63).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(44),
      ),
      child: Icon(
        isMale ? Icons.male : Icons.female,
        size: 40,
        color: isMale ? const Color(0xFF2196F3) : const Color(0xFFE91E63),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.body2.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTypography.body2.copyWith(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
