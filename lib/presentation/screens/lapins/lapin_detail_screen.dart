import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_typography.dart';
import '../../../core/constants/enums.dart';
import '../../../core/models/growth_prediction.dart';
import '../../../core/models/lapin.dart';
import '../../../core/models/pesel.dart';
import '../../../domain/services/lapin_photo_service.dart';
import '../../providers/core_providers.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/pesee_provider.dart';
import '../../widgets/common/connectivity_banner.dart';
import '../../widgets/common/loading_widget.dart';

class LapinDetailScreen extends ConsumerWidget {
  final String lapinId;

  const LapinDetailScreen({super.key, required this.lapinId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lapinAsync = ref.watch(lapinDetailProvider(lapinId));
    final connectivity = ref.watch(connectivityCheckerProvider);

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

    Future<void> recordPesee({int? gmqTargetG}) async {
      final poidsController = TextEditingController();
      final notesController = TextEditingController();
      DateTime selectedDate = DateTime.now();

      final pesee = await showDialog<_PeseeInput?>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(l10n.lapinAddWeightTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: poidsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.lapinWeightGramLabel),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2010),
                      lastDate: DateTime.now(),
                    );
                    if (picked == null) return;
                    setState(() => selectedDate = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: l10n.commonSelectDate),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: AppTypography.body2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(labelText: l10n.timelineAddNote),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  final poids = int.tryParse(poidsController.text);
                  if (poids == null || poids <= 0) {
                    Navigator.pop(context);
                    return;
                  }
                  Navigator.pop(
                    context,
                    _PeseeInput(
                      poidsG: poids,
                      date: selectedDate,
                      notes: notesController.text,
                    ),
                  );
                },
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      );

      if (pesee == null) return;
      await ref.read(peseesProvider(lapinId).notifier).addPesee(
            poidsG: pesee.poidsG,
            date: pesee.date,
            notes: pesee.notes,
            gmqTargetG: gmqTargetG,
          );
      ref.invalidate(lapinDetailProvider(lapinId));
      unawaited(ref.read(lapinsProvider.notifier).refresh());
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
        final peseesAsync = ref.watch(peseesProvider(lapinId));

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
              onPressed: () => recordPesee(gmqTargetG: lapin.race?.gmqCibleG),
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
                      _growthTab(
                        context: context,
                        ref: ref,
                        l10n: l10n,
                        lapin: lapin,
                        connectivity: connectivity,
                        peseesAsync: peseesAsync,
                      ),
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
                                  _row(context, l10n.lapinFieldId, lapin.id),
                                  if (lapin.numeroIdentification != null)
                                    _row(
                                      context,
                                      l10n.lapinFieldNumeroIdentification,
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

  Widget _growthTab({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    required Lapin lapin,
    required dynamic connectivity,
    required AsyncValue<PeseesListState> peseesAsync,
  }) {
    return peseesAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => ErrorDisplayWidget(
        message: e.toString(),
        onRetry: () => ref.invalidate(peseesProvider(lapin.id)),
      ),
      data: (state) {
        final items = state.items;

        final gmqById = <String, double>{};
        final asc = [...items]..sort((a, b) => a.date.compareTo(b.date));
        for (var i = 1; i < asc.length; i++) {
          final prev = asc[i - 1];
          final cur = asc[i];
          final days = cur.date.difference(prev.date).inDays;
          final deltaDays = days <= 0 ? 1 : days;
          gmqById[cur.id] = (cur.poidsG - prev.poidsG) / deltaDays;
        }

        final race = lapin.race;
        final gmqTarget = race?.gmqCibleG;
        final bool lowGmq;
        final double? lastGmq;
        final int? lastDays;
        if (gmqTarget != null && asc.length >= 2) {
          final prev = asc[asc.length - 2];
          final cur = asc.last;
          final days = cur.date.difference(prev.date).inDays;
          final d = days <= 0 ? 1 : days;
          lastDays = d;
          lastGmq = (cur.poidsG - prev.poidsG) / d;
          lowGmq = d >= 7 && lastGmq < gmqTarget * 0.8;
        } else {
          lowGmq = false;
          lastGmq = null;
          lastDays = null;
        }

        final chart = _GrowthChart(
          l10n: l10n,
          items: items,
          gmqTarget: gmqTarget?.toDouble(),
        );

        return Column(
          children: [
            if (lowGmq && lastGmq != null && gmqTarget != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    '${l10n.growthLowGmqBadge}'
                    '${lastDays != null ? ' ($lastDays j)' : ''}'
                    ' — ${lastGmq.toStringAsFixed(1)} g/j vs ${gmqTarget.toStringAsFixed(0)} g/j',
                    style: AppTypography.body2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.lapinTabGrowth,
                          style: AppTypography.subtitle1,
                        ),
                      ),
                      if (connectivity.isOnline)
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => _showGrowthPrediction(
                            context: context,
                            ref: ref,
                            l10n: l10n,
                            lapin: lapin,
                            pesees: items,
                          ),
                          icon: const Icon(Icons.auto_graph),
                          label: Text(l10n.growthPredictButton),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  chart,
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref.read(peseesProvider(lapin.id).notifier).refresh();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length + (state.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= items.length) {
                      ref.read(peseesProvider(lapin.id).notifier).loadMore();
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    final pesee = items[index];
                    final d = pesee.date;
                    final gmq = gmqById[pesee.id];

                    return Card(
                      child: ListTile(
                        title: Text(
                          '${pesee.poidsG} g',
                          style: AppTypography.subtitle1,
                        ),
                        subtitle: Text(
                          '${d.day}/${d.month}/${d.year}'
                          '${gmq != null ? ' • ${gmq >= 0 ? '+' : ''}${gmq.toStringAsFixed(1)} g/j' : ''}',
                          style: AppTypography.body2,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}

Future<void> _showGrowthPrediction({
  required BuildContext context,
  required WidgetRef ref,
  required AppLocalizations l10n,
  required Lapin lapin,
  required List<Pesee> pesees,
}) async {
  final supabase = ref.read(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;
  final raceId = lapin.raceId;
  final poidsActuelG = lapin.poidsActuelG;
  final ageJours = lapin.ageJours;

  final Future<GrowthPrediction> predictionFuture;
  if (userId == null) {
    predictionFuture = Future.error(Exception('User not authenticated'));
  } else if (raceId == null || poidsActuelG == null || ageJours == null) {
    predictionFuture = Future.error(Exception('Missing lapin data for prediction'));
  } else {
    predictionFuture = ref.read(growthPredictionServiceProvider).predictGrowth(
          userId: userId,
          raceId: raceId,
          poidsActuelG: poidsActuelG,
          ageJours: ageJours,
        );
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<GrowthPrediction>(
            future: predictionFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SizedBox(
                  height: 220,
                  child: Center(child: Text(snapshot.error.toString())),
                );
              }
              final pred = snapshot.data;
              if (pred == null) {
                return SizedBox(
                  height: 220,
                  child: Center(child: Text(l10n.errorGeneric)),
                );
              }

                  GrowthPredictionPoint? p10;
                  GrowthPredictionPoint? p12;
                  GrowthPredictionPoint? p14;

                  final ageJours = lapin.ageJours;
                  if (ageJours != null) {
                    final wanted = <int>[70, 84, 98];
                    for (final targetAge in wanted) {
                      final delta = targetAge - ageJours;
                      if (delta < 0) continue;
                      final targetDate =
                          DateTime.now().add(Duration(days: delta));
                      GrowthPredictionPoint? best;
                      for (final p in pred.courbe) {
                        if (p.date.isBefore(targetDate)) continue;
                        best = p;
                        break;
                      }
                      if (best == null && pred.courbe.isNotEmpty) {
                        best = pred.courbe.last;
                      }
                      if (targetAge == 70) p10 = best;
                      if (targetAge == 84) p12 = best;
                      if (targetAge == 98) p14 = best;
                    }
                  }

                  final race = lapin.race;
                  final minKg = race?.poidsAdulteMinKg;
                  final targetSellG =
                      minKg != null ? (minKg * 1000).round() : null;

                  DateTime? sellDate;
                  if (targetSellG != null) {
                    for (final p in pred.courbe) {
                      if (p.poidsG >= targetSellG) {
                        sellDate = p.date;
                        break;
                      }
                    }
                  }

                  final saleLabel = sellDate != null
                      ? '${sellDate.day}/${sellDate.month}/${sellDate.year}'
                      : l10n.growthPredictNoSaleDate;

                  final chart = _GrowthChart(
                    l10n: l10n,
                    items: pesees,
                    gmqTarget: lapin.race?.gmqCibleG?.toDouble(),
                    prediction: pred.courbe,
                  );

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.growthPredictTitle,
                          style: AppTypography.subtitle1),
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.growthPredictNeededGmq}: ${pred.gmqNecessaireG} g/j\n'
                        '${l10n.growthPredictRaceGmq}: ${pred.gmqNormeG} g/j\n'
                        '${l10n.growthPredictWeek10}: ${p10 != null ? '${p10.poidsG} g' : l10n.growthPredictNoSaleDate}\n'
                        '${l10n.growthPredictWeek12}: ${p12 != null ? '${p12.poidsG} g' : l10n.growthPredictNoSaleDate}\n'
                        '${l10n.growthPredictWeek14}: ${p14 != null ? '${p14.poidsG} g' : l10n.growthPredictNoSaleDate}\n'
                        '${l10n.growthPredictSaleDate}: $saleLabel',
                        style: AppTypography.body2,
                      ),
                      const SizedBox(height: 12),
                      chart,
                      const SizedBox(height: 8),
                    ],
                  );
            },
          ),
        ),
      );
    },
  );
}

class _GrowthChart extends StatelessWidget {
  final AppLocalizations l10n;
  final List<Pesee> items;
  final double? gmqTarget;
  final List<GrowthPredictionPoint> prediction;

  const _GrowthChart({
    required this.l10n,
    required this.items,
    required this.gmqTarget,
    this.prediction = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            l10n.growthNoWeights,
            style: AppTypography.body2,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final sorted = [...items]..sort((a, b) => a.date.compareTo(b.date));
    final startDate = sorted.first.date;
    final startWeight = sorted.first.poidsG.toDouble();
    final endDate = sorted.last.date;
    final maxX =
        endDate.difference(startDate).inDays.toDouble().clamp(1.0, 3650.0);

    final actualSpots = sorted
        .map(
          (p) => FlSpot(
            p.date.difference(startDate).inDays.toDouble(),
            p.poidsG.toDouble(),
          ),
        )
        .toList();

    final domainDays = List<int>.generate(maxX.toInt() + 1, (i) => i);

    final baseLine = domainDays.map((d) => FlSpot(d.toDouble(), 0)).toList();
    final targetLine = gmqTarget != null
        ? domainDays
            .map((d) => FlSpot(d.toDouble(), startWeight + gmqTarget! * d))
            .toList()
        : <FlSpot>[];

    final lowLine = targetLine.isNotEmpty
        ? targetLine.map((s) => FlSpot(s.x, s.y * 0.8)).toList()
        : <FlSpot>[];
    final highLine = targetLine.isNotEmpty
        ? targetLine.map((s) => FlSpot(s.x, s.y * 1.1)).toList()
        : <FlSpot>[];

    final maxY = [
      ...actualSpots.map((s) => s.y),
      ...highLine.map((s) => s.y),
      ...prediction.map((p) => p.poidsG.toDouble()),
    ].fold<double>(0, (m, v) => v > m ? v : m);

    final lineBars = <LineChartBarData>[
      if (lowLine.isNotEmpty) ...[
        LineChartBarData(
          spots: baseLine,
          color: Colors.transparent,
          barWidth: 0,
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: lowLine,
          color: Colors.transparent,
          barWidth: 0,
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: highLine,
          color: Colors.transparent,
          barWidth: 0,
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: targetLine,
          color: Colors.green,
          barWidth: 2,
          isCurved: true,
          dotData: const FlDotData(show: false),
          dashArray: [6, 6],
        ),
      ],
      LineChartBarData(
        spots: actualSpots,
        color: Colors.blue,
        barWidth: 3,
        isCurved: true,
        dotData: const FlDotData(show: true),
      ),
      if (prediction.isNotEmpty)
        LineChartBarData(
          spots: prediction
              .map(
                (p) => FlSpot(
                  p.date.difference(startDate).inDays.toDouble(),
                  p.poidsG.toDouble(),
                ),
              )
              .toList(),
          color: Colors.orange,
          barWidth: 2,
          isCurved: true,
          dotData: const FlDotData(show: false),
        ),
    ];

    final betweenBars = <BetweenBarsData>[];
    if (lowLine.isNotEmpty) {
      betweenBars.add(
        BetweenBarsData(
          fromIndex: 0,
          toIndex: 1,
          color: Colors.red.withValues(alpha: 0.08),
        ),
      );
      betweenBars.add(
        BetweenBarsData(
          fromIndex: 1,
          toIndex: 2,
          color: Colors.green.withValues(alpha: 0.08),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: maxX,
          minY: 0,
          maxY: (maxY * 1.15).clamp(100.0, 100000.0),
          betweenBarsData: betweenBars,
          gridData: const FlGridData(show: true),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(
            show: true,
            border:
                Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
          ),
          lineBarsData: lineBars,
        ),
      ),
    );
  }
}

class _PeseeInput {
  final int poidsG;
  final DateTime date;
  final String? notes;

  const _PeseeInput({
    required this.poidsG,
    required this.date,
    this.notes,
  });
}
