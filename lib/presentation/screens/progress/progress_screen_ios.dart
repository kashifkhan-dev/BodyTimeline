import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator, AlwaysStoppedAnimation;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_quick_video_encoder/flutter_quick_video_encoder.dart';
import 'package:image/image.dart' as img;

import '../../view_models/progress_view_model.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';
import '../../../domain/value_objects/zone_type.dart';
import '../../widgets/timelapse_overlay.dart';
import 'package:workout/l10n/generated/app_localizations.dart';

class ProgressScreenIOS extends StatelessWidget {
  const ProgressScreenIOS({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProgressViewModel>();
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);

    final List<String> photos;
    final List<DateTime> dates;

    if (vm.selectedZone == ZoneType.face) {
      photos = ['assets/images/face/face1.png', 'assets/images/face/face2.png'];
      final allDates = vm.photoDates;
      dates = allDates.length >= 2 ? [allDates.first, allDates.last] : allDates;
    } else {
      photos = List.generate(19, (i) => 'assets/images/transformation/${i + 1}.png');
      dates = vm.photoDates;
    }

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(AppLocalizations.of(context)!.yourProgress, style: TextStyle(color: colors.textPrimary)),
            backgroundColor: colors.background.withAlpha(200),
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          if (vm.isLoading)
            SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator(color: colors.primary)),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatsRow(context, vm, colors),
                  const SizedBox(height: 24),
                  _buildZoneSelector(context, vm, colors),
                  const SizedBox(height: 32),
                  _buildBeforeAfterSection(context, photos, dates, colors),
                  const SizedBox(height: 32),
                  _buildTimelineSection(context, photos, colors),
                  const SizedBox(height: 120),
                ]),
              ),
            ),
        ],
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
            label: AppLocalizations.of(context)!.completedDays,
            value: vm.totalCompletedDays.toString(),
            colors: colors,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String label, required String value, String? icon, required AppColors colors}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: colors.textPrimary.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
      ),
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
    );
  }

  Widget _buildZoneSelector(BuildContext context, ProgressViewModel vm, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: _buildZoneSegment(
              label: AppLocalizations.of(context)!.facePhoto,
              isActive: vm.selectedZone == ZoneType.face,
              onTap: () => vm.setSelectedZone(ZoneType.face),
              colors: colors,
            ),
          ),
          Expanded(
            child: _buildZoneSegment(
              label: AppLocalizations.of(context)!.bodyFrontPhoto,
              isActive: vm.selectedZone == ZoneType.bodyFront,
              onTap: () => vm.setSelectedZone(ZoneType.bodyFront),
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneSegment({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required AppColors colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? colors.textPrimary : CupertinoColors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? colors.card : colors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildBeforeAfterSection(BuildContext context, List<String> photos, List<DateTime> dates, AppColors colors) {
    if (photos.isEmpty) return _buildEmptyState(AppLocalizations.of(context)!.noPhotosZone, colors);
    final beforeImage = photos.first;
    final afterImage = photos.last;
    final beforeDate = dates.first;
    final afterDate = dates.last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.beforeAfter,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            Text(AppLocalizations.of(context)!.viewDifference, style: TextStyle(fontSize: 14, color: colors.textMuted)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: colors.textPrimary.withAlpha(5), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildComparisonImage(
                      context,
                      beforeImage,
                      AppLocalizations.of(context)!.before,
                      beforeDate,
                      colors,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildComparisonImage(
                      context,
                      afterImage,
                      AppLocalizations.of(context)!.today,
                      afterDate,
                      colors,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CNButton(
                      label: AppLocalizations.of(context)!.timelapse,
                      onPressed: () => showCupertinoModalPopup(
                        context: context,
                        builder: (context) => TimelapseOverlay(images: photos, dates: dates),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CNButton(
                      label: AppLocalizations.of(context)!.exportVideo,
                      onPressed: () => _showExportOptions(context, photos, colors),
                    ),
                  ),
                ],
              ),
            ],
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
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          '${date.day} ${_getMonthName(context, date.month)}',
          style: TextStyle(fontSize: 11, color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTimelineSection(BuildContext context, List<String> photos, AppColors colors) {
    if (photos.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.timeline,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            Text(
              AppLocalizations.of(context)!.photosCount(photos.length),
              style: TextStyle(fontSize: 14, color: colors.textSecondary),
            ),
          ],
        ),
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
            final isAsset = path.startsWith('assets/');
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: isAsset ? Image.asset(path, fit: BoxFit.cover) : Image.file(File(path), fit: BoxFit.cover),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(CupertinoIcons.photo_on_rectangle, size: 48, color: colors.textMuted),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
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

  void _showExportOptions(BuildContext context, List<String> photos, AppColors colors) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(AppLocalizations.of(context)!.exportTransformation),
        message: Text(AppLocalizations.of(context)!.selectVideoQuality),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _startExport(context, AppLocalizations.of(context)!.lowQuality, photos, colors, 480);
            },
            child: Text(AppLocalizations.of(context)!.lowQuality),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _startExport(context, AppLocalizations.of(context)!.mediumQuality, photos, colors, 720);
            },
            child: Text(AppLocalizations.of(context)!.mediumQuality),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _startExport(context, AppLocalizations.of(context)!.highQuality, photos, colors, 1080);
            },
            child: Text(AppLocalizations.of(context)!.highQuality),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
      ),
    );
  }

  void _startExport(BuildContext context, String qualityName, List<String> photos, AppColors colors, int height) async {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _ExportProgressOverlayIOS(qualityName: qualityName, height: height, photos: photos, colors: colors),
    );
  }
}

class _ExportProgressOverlayIOS extends StatefulWidget {
  final String qualityName;
  final int height;
  final List<String> photos;
  final AppColors colors;
  const _ExportProgressOverlayIOS({
    required this.qualityName,
    required this.height,
    required this.photos,
    required this.colors,
  });
  @override
  State<_ExportProgressOverlayIOS> createState() => _ExportProgressOverlayIOSState();
}

class _ExportProgressOverlayIOSState extends State<_ExportProgressOverlayIOS> {
  double _progress = 0.0;
  String _status = 'Initializing...';
  bool _isDone = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _runExport();
  }

  Future<void> _runExport() async {
    final int frameCount = widget.photos.length;
    final int steps = frameCount + 5;
    int currentStep = 0;
    void update(String status, {double? overrideProgress}) {
      currentStep++;
      if (mounted) {
        setState(() {
          _status = status;
          _progress = overrideProgress ?? (currentStep / steps).clamp(0.0, 0.99);
        });
      }
    }

    try {
      update(AppLocalizations.of(context)!.checkingPermissions);
      final status = await Permission.storage.request();
      if (!status.isGranted && !status.isLimited) {
        if (mounted) {
          setState(() {
            _status = AppLocalizations.of(context)!.storagePermissionRequired;
            _isDone = true;
          });
        }
        return;
      }
      update(AppLocalizations.of(context)!.preparingVideoEngine);
      final width = (widget.height * 3 / 4).round();
      final docsDir = await getApplicationDocumentsDirectory();
      final outputPath = '${docsDir.path}/transformation_${DateTime.now().millisecondsSinceEpoch}.mp4';

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
        update(AppLocalizations.of(context)!.encodingFrame(i + 1, frameCount));
        final byteData = await rootBundle.load(widget.photos[i]);
        final bytes = byteData.buffer.asUint8List();
        final original = img.decodeImage(bytes);
        if (original == null) throw Exception('Failed to decode frame $i');
        final frameCanvas = img.Image(width: width, height: widget.height, numChannels: 4);
        img.fill(frameCanvas, color: img.ColorUint8.rgba(0, 0, 0, 255));
        double scale = (width / original.width < widget.height / original.height)
            ? width / original.width
            : widget.height / original.height;
        int targetWidth = (original.width * scale).round();
        int targetHeight = (original.height * scale).round();
        final resized = img.copyResize(
          original,
          width: targetWidth,
          height: targetHeight,
          interpolation: img.Interpolation.linear,
        );
        img.compositeImage(
          frameCanvas,
          resized,
          dstX: (width - targetWidth) ~/ 2,
          dstY: (widget.height - targetHeight) ~/ 2,
        );
        await FlutterQuickVideoEncoder.appendVideoFrame(frameCanvas.toUint8List());
      }
      update(AppLocalizations.of(context)!.finalizingVideo);
      await FlutterQuickVideoEncoder.finish();
      _filePath = outputPath;
      update(AppLocalizations.of(context)!.exportComplete, overrideProgress: 1.0);
      if (mounted) {
        setState(() {
          _isDone = true;
        });
      }
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
    return Container(
      color: widget.colors.background.withAlpha(240),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isDone ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.video_camera_solid,
                size: 64,
                color: _isDone ? const Color(0xFFD0F288) : widget.colors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.exporting(widget.qualityName),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.colors.textPrimary,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: widget.colors.textSecondary, decoration: TextDecoration.none),
              ),
              const SizedBox(height: 32),
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: widget.colors.progressBackground,
                valueColor: const AlwaysStoppedAnimation(Color(0xFFD0F288)),
                minHeight: 8,
              ),
              const SizedBox(height: 48),
              if (_isDone) CNButton(label: AppLocalizations.of(context)!.done, onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }
}
