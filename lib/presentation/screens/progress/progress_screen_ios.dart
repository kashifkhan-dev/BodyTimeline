import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator, AlwaysStoppedAnimation, Colors;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_quick_video_encoder/flutter_quick_video_encoder.dart';
import 'package:image/image.dart' as img;

import '../../view_models/progress_view_model.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';
import '../../../domain/value_objects/zone_type.dart';
import '../../../domain/entities/photo_record.dart';
import '../../widgets/timelapse_overlay.dart';
import 'package:workout/l10n/generated/app_localizations.dart';

class ProgressScreenIOS extends StatefulWidget {
  const ProgressScreenIOS({super.key});

  @override
  State<ProgressScreenIOS> createState() => _ProgressScreenIOSState();
}

class _ProgressScreenIOSState extends State<ProgressScreenIOS> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final vm = context.read<ProgressViewModel>();
    final zones = vm.availableZones.toList()..sort((a, b) => a.index.compareTo(b.index));
    final initialIndex = zones.indexOf(vm.selectedZone);
    _pageController = PageController(initialPage: initialIndex != -1 ? initialIndex : 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProgressViewModel>();
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);
    final zones = vm.availableZones.toList()..sort((a, b) => a.index.compareTo(b.index));

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        middle: Text(AppLocalizations.of(context)!.yourProgress, style: TextStyle(color: colors.textPrimary)),
        backgroundColor: colors.background.withAlpha(200),
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), child: _buildStatsRow(context, vm, colors)),
            if (zones.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: _buildZoneSelector(context, vm, zones, colors),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: zones.length,
                  onPageChanged: (index) {
                    vm.setSelectedZone(zones[index]);
                  },
                  itemBuilder: (context, index) {
                    return _ZonePage(
                      zone: zones[index],
                      colors: colors,
                      onExport: (photos) => _showExportOptions(context, photos.map((p) => p.filePath).toList(), colors),
                    );
                  },
                ),
              ),
            ] else if (vm.isLoading)
              const Expanded(child: Center(child: CupertinoActivityIndicator()))
            else
              Expanded(child: _buildEmptyState(AppLocalizations.of(context)!.noPhotosZone, colors)),
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

  Widget _buildZoneSelector(BuildContext context, ProgressViewModel vm, List<ZoneType> zones, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: zones.map((zone) {
            String label = _getZoneLabel(context, zone);
            final isSelected = vm.selectedZone == zone;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: isSelected ? colors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                onPressed: () {
                  final index = zones.indexOf(zone);
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.black : colors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getZoneLabel(BuildContext context, ZoneType zone) {
    switch (zone) {
      case ZoneType.face:
        return AppLocalizations.of(context)!.face;
      case ZoneType.bodyFront:
        return AppLocalizations.of(context)!.bodyFront;
      case ZoneType.bodySide:
        return AppLocalizations.of(context)!.bodySide;
      case ZoneType.bodyBack:
        return AppLocalizations.of(context)!.bodyBack;
      default:
        return '';
    }
  }

  Widget _buildEmptyState(String message, AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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

class _ZonePage extends StatefulWidget {
  final ZoneType zone;
  final AppColors colors;
  final Function(List<PhotoRecord>) onExport;

  const _ZonePage({required this.zone, required this.colors, required this.onExport});

  @override
  State<_ZonePage> createState() => _ZonePageState();
}

class _ZonePageState extends State<_ZonePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final vm = context.watch<ProgressViewModel>();

    // Extract photos for this specific zone
    final history = vm.history;
    final List<PhotoRecord> photos = [];
    for (var day in history) {
      for (var photo in day.photos) {
        if (photo.zoneType == widget.zone) {
          photos.add(photo);
        }
      }
    }
    photos.sort((a, b) => a.capturedAt.compareTo(b.capturedAt));

    if (photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.photo, size: 48, color: widget.colors.textMuted),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.noPhotosZone, style: TextStyle(color: widget.colors.textSecondary)),
          ],
        ),
      );
    }

    final int startIndex = (photos.length > 20) ? photos.length - 20 : 0;
    final timelinePhotos = photos.sublist(startIndex);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        _buildBeforeAfterSection(context, photos, widget.colors),
        const SizedBox(height: 32),
        _buildTimelineSection(context, timelinePhotos, widget.colors),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildBeforeAfterSection(BuildContext context, List<PhotoRecord> photos, AppColors colors) {
    final before = photos.first;
    final after = photos.last;

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
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                TimelapseOverlay.show(context, photos);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.timelapse, style: TextStyle(color: colors.primary, fontSize: 16)),
                  const SizedBox(width: 4),
                  Icon(CupertinoIcons.play_circle_fill, color: colors.primary, size: 20),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildComparisonCard(context, AppLocalizations.of(context)!.before, before, colors)),
            const SizedBox(width: 12),
            Expanded(child: _buildComparisonCard(context, AppLocalizations.of(context)!.after, after, colors)),
          ],
        ),
        const SizedBox(height: 16),
        CNButton(
          label: AppLocalizations.of(context)!.exportVideo,
          config: const CNButtonConfig(style: CNButtonStyle.prominentGlass),
          onPressed: () => widget.onExport(photos),
        ),
      ],
    );
  }

  Widget _buildComparisonCard(BuildContext context, String label, PhotoRecord photo, AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: photo.filePath.startsWith('assets/')
                ? Image.asset(photo.filePath, fit: BoxFit.cover)
                : Image.file(File(photo.filePath), fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: colors.textMuted, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatRelativeDate(context, photo.capturedAt),
                  style: TextStyle(fontSize: 14, color: colors.textPrimary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildTimelineSection(BuildContext context, List<PhotoRecord> photos, AppColors colors) {
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
            final path = photos[index].filePath;
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

        // Handle physical file vs asset
        final path = widget.photos[i];
        Uint8List bytes;
        if (path.startsWith('assets/')) {
          final byteData = await rootBundle.load(path);
          bytes = byteData.buffer.asUint8List();
        } else {
          bytes = await File(path).readAsBytes();
        }

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
              if (_isDone)
                CNButton(
                  label: AppLocalizations.of(context)!.done,
                  config: const CNButtonConfig(style: CNButtonStyle.prominentGlass),
                  onPressed: () => Navigator.pop(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
