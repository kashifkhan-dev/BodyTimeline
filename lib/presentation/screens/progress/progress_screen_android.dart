import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_quick_video_encoder/flutter_quick_video_encoder.dart';
import 'package:image/image.dart' as img;

import '../../view_models/progress_view_model.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';
import '../../../domain/value_objects/zone_type.dart';
import '../../widgets/timelapse_overlay.dart';
import 'package:workout/l10n/generated/app_localizations.dart';

class ProgressScreenAndroid extends StatelessWidget {
  const ProgressScreenAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProgressViewModel>();
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);

    // Get real photos from VM
    final allPhotos = vm.latestPhotos;

    // Extract paths and dates for Android UI
    final List<String> photos = allPhotos.map((p) => p.filePath).toList();
    final List<DateTime> dates = allPhotos.map((p) => p.capturedAt).toList();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.yourProgress),
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
      ),
      body: vm.isLoading
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : RefreshIndicator(
              onRefresh: () async {
                await vm.refresh();
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                children: [
                  _buildStatsRow(context, vm, colors),
                  const SizedBox(height: 24),
                  if (vm.availableZones.isNotEmpty) ...[
                    _buildZoneSelector(context, vm, colors),
                    const SizedBox(height: 32),
                  ],
                  _buildBeforeAfterSection(context, photos, dates, colors),
                  const SizedBox(height: 32),
                  _buildTimelineSection(context, photos, colors),
                  const SizedBox(height: 120),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsRow(BuildContext context, ProgressViewModel vm, AppColors colors) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: AppLocalizations.of(context)!.streak,
            value: vm.currentStreak.toString(),
            icon: '🔥',
            colors: colors,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            label: AppLocalizations.of(context)!.totalDays,
            value: vm.totalCompletedDays.toString(),
            colors: colors,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String label, required String value, String? icon, required AppColors colors}) {
    return Card(
      elevation: 0,
      color: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(label, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                if (icon != null) ...[const SizedBox(width: 4), Text(icon, style: const TextStyle(fontSize: 14))],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneSelector(BuildContext context, ProgressViewModel vm, AppColors colors) {
    // Dynamically build segments from available zones
    final zones = vm.availableZones.toList();

    // Sort logic to keep consistent order (Face, Front, Side, Back)
    zones.sort((a, b) => a.index.compareTo(b.index));

    return Container(
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: zones.map((zone) {
            String label;
            switch (zone) {
              case ZoneType.face:
                label = AppLocalizations.of(context)!.face;
                break;
              case ZoneType.bodyFront:
                label = AppLocalizations.of(context)!.bodyFront;
                break;
              case ZoneType.bodySide:
                label = AppLocalizations.of(context)!.bodySide;
                break;
              case ZoneType.bodyBack:
                label = AppLocalizations.of(context)!.bodyBack;
                break;
              default:
                label = '';
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _buildZoneSegment(
                label: label,
                isActive: vm.selectedZone == zone,
                onTap: () => vm.setSelectedZone(zone),
                colors: colors,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildZoneSegment({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required AppColors colors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : colors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildBeforeAfterSection(BuildContext context, List<String> photos, List<DateTime> dates, AppColors colors) {
    if (photos.isEmpty) return Center(child: Text(AppLocalizations.of(context)!.noRecords));
    final beforeImage = photos.first;
    final afterImage = photos.last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.beforeAfter,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: colors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildComparisonImage(
                        context,
                        beforeImage,
                        AppLocalizations.of(context)!.before,
                        dates.first,
                        colors,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildComparisonImage(
                        context,
                        afterImage,
                        AppLocalizations.of(context)!.after,
                        dates.last,
                        colors,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => TimelapseOverlay(images: photos, dates: dates),
                        ),
                        icon: const Icon(Icons.slow_motion_video),
                        label: Text(AppLocalizations.of(context)!.timelapse),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showExportOptions(context, photos, colors),
                        icon: const Icon(Icons.file_upload),
                        label: Text(AppLocalizations.of(context)!.export),
                        style: ElevatedButton.styleFrom(backgroundColor: colors.primary, foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonImage(BuildContext context, String path, String label, DateTime date, AppColors colors) {
    final isAsset = path.startsWith('assets/');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: isAsset ? Image.asset(path, fit: BoxFit.cover) : Image.file(File(path), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(_formatRelativeDate(context, date), style: TextStyle(fontSize: 12, color: colors.textSecondary)),
      ],
    );
  }

  Widget _buildTimelineSection(BuildContext context, List<String> photos, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.timeline, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3 / 4,
          ),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final path = photos[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: path.startsWith('assets/')
                  ? Image.asset(path, fit: BoxFit.cover)
                  : Image.file(File(path), fit: BoxFit.cover),
            );
          },
        ),
      ],
    );
  }

  void _showExportOptions(BuildContext context, List<String> photos, AppColors colors) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.exportQuality,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.lowQuality),
              onTap: () {
                Navigator.pop(context);
                _startExport(context, AppLocalizations.of(context)!.lowQuality, photos, colors, 480);
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.mediumQuality),
              onTap: () {
                Navigator.pop(context);
                _startExport(context, AppLocalizations.of(context)!.mediumQuality, photos, colors, 720);
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.highQuality),
              onTap: () {
                Navigator.pop(context);
                _startExport(context, AppLocalizations.of(context)!.highQuality, photos, colors, 1080);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _startExport(BuildContext context, String qualityName, List<String> photos, AppColors colors, int height) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog.fullscreen(
        child: _ExportProgressOverlayAndroid(qualityName: qualityName, height: height, photos: photos, colors: colors),
      ),
    );
  }

  String _formatRelativeDate(BuildContext context, DateTime date) {
    final day = date.day;
    final month = _getMonthName(context, date.month);
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$day $month $hour:$minute $period';
  }

  String _getMonthName(BuildContext context, int month) {
    final l10n = AppLocalizations.of(context)!;
    final months = [
      l10n.jan,
      l10n.feb,
      l10n.mar,
      l10n.apr,
      l10n.may,
      l10n.jun,
      l10n.jul,
      l10n.aug,
      l10n.sep,
      l10n.oct,
      l10n.nov,
      l10n.dec,
    ];
    return months[month - 1];
  }
}

class _ExportProgressOverlayAndroid extends StatefulWidget {
  final String qualityName;
  final int height;
  final List<String> photos;
  final AppColors colors;
  const _ExportProgressOverlayAndroid({
    required this.qualityName,
    required this.height,
    required this.photos,
    required this.colors,
  });
  @override
  State<_ExportProgressOverlayAndroid> createState() => _ExportProgressOverlayAndroidState();
}

class _ExportProgressOverlayAndroidState extends State<_ExportProgressOverlayAndroid> {
  double _progress = 0.0;
  String _status = 'Initializing...';
  bool _isDone = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to access context safely after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _status = AppLocalizations.of(context)!.initializing;
        });
        _runExport();
      }
    });
  }

  Future<void> _runExport() async {
    final frameCount = widget.photos.length;
    try {
      final width = (widget.height * 3 / 4).round();
      final docsDir = await getApplicationDocumentsDirectory();
      final outputPath = '${docsDir.path}/export_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await FlutterQuickVideoEncoder.setup(
        width: width,
        height: widget.height,
        fps: 5,
        videoBitrate: 2000000,
        audioChannels: 0,
        audioBitrate: 0,
        sampleRate: 44100,
        profileLevel: ProfileLevel.highAutoLevel,
        filepath: outputPath,
      );

      for (int i = 0; i < frameCount; i++) {
        if (mounted) {
          setState(() {
            _status = AppLocalizations.of(context)!.processing(i + 1, frameCount);
            _progress = i / frameCount;
          });
        }
        final byteData = await rootBundle.load(widget.photos[i]);
        final bytes = byteData.buffer.asUint8List();
        final original = img.decodeImage(bytes);
        if (original == null) continue;
        final canvas = img.Image(width: width, height: widget.height, numChannels: 4);
        img.fill(canvas, color: img.ColorUint8.rgba(0, 0, 0, 255));
        final resized = img.copyResize(
          original,
          width: width,
          height: widget.height,
          interpolation: img.Interpolation.linear,
        );
        img.compositeImage(canvas, resized);
        await FlutterQuickVideoEncoder.appendVideoFrame(canvas.toUint8List());
      }
      await FlutterQuickVideoEncoder.finish();
      _filePath = outputPath;
      if (mounted) {
        setState(() {
          _status = AppLocalizations.of(context)!.exportComplete;
          _progress = 1.0;
          _isDone = true;
        });
      }
      // ignore: deprecated_member_use
      // ignore: deprecated_member_use
      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(_filePath!)], subject: AppLocalizations.of(context)!.myTransformation);
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = AppLocalizations.of(context)!.exportFailed(e.toString());
          _isDone = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.colors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(value: _progress, color: widget.colors.primary),
              const SizedBox(height: 32),
              Text(
                AppLocalizations.of(context)!.exporting(widget.qualityName),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_status),
              const SizedBox(height: 48),
              if (_isDone)
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.dismiss),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
