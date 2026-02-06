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

class ProgressScreenAndroid extends StatelessWidget {
  const ProgressScreenAndroid({super.key});

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

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Your Progress'),
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
      ),
      body: vm.isLoading
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : RefreshIndicator(
              onRefresh: () async {}, // Implement if needed
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                children: [
                  _buildStatsRow(vm, colors),
                  const SizedBox(height: 24),
                  _buildZoneSelector(vm, colors),
                  const SizedBox(height: 32),
                  _buildBeforeAfterSection(context, photos, dates, colors),
                  const SizedBox(height: 32),
                  _buildTimelineSection(photos, colors),
                  const SizedBox(height: 120),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsRow(ProgressViewModel vm, AppColors colors) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(label: 'Streak', value: vm.currentStreak.toString(), icon: '🔥', colors: colors),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(label: 'Total Days', value: vm.totalCompletedDays.toString(), colors: colors),
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

  Widget _buildZoneSelector(ProgressViewModel vm, AppColors colors) {
    return Container(
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            child: _buildZoneSegment(
              label: 'Face',
              isActive: vm.selectedZone == ZoneType.face,
              onTap: () => vm.setSelectedZone(ZoneType.face),
              colors: colors,
            ),
          ),
          Expanded(
            child: _buildZoneSegment(
              label: 'Body',
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
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
    if (photos.isEmpty) return const Center(child: Text('No photos recorded'));
    final beforeImage = photos.first;
    final afterImage = photos.last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Before & After',
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
                    Expanded(child: _buildComparisonImage(beforeImage, 'Before', dates.first, colors)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildComparisonImage(afterImage, 'After', dates.last, colors)),
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
                        label: const Text('Timelapse'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showExportOptions(context, photos, colors),
                        icon: const Icon(Icons.file_upload),
                        label: const Text('Export'),
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

  Widget _buildComparisonImage(String path, String label, DateTime date, AppColors colors) {
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
        Text('${date.day}/${date.month}', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
      ],
    );
  }

  Widget _buildTimelineSection(List<String> photos, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Timeline', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
            const ListTile(
              title: Text('Export Quality', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              title: const Text('Low (480p)'),
              onTap: () {
                Navigator.pop(context);
                _startExport(context, '480p', photos, colors, 480);
              },
            ),
            ListTile(
              title: const Text('Medium (720p)'),
              onTap: () {
                Navigator.pop(context);
                _startExport(context, '720p', photos, colors, 720);
              },
            ),
            ListTile(
              title: const Text('High (1080p)'),
              onTap: () {
                Navigator.pop(context);
                _startExport(context, '1080p', photos, colors, 1080);
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
    _runExport();
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
            _status = 'Processing ${i + 1}/$frameCount';
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
          _status = 'Complete!';
          _progress = 1.0;
          _isDone = true;
        });
      }
      // ignore: deprecated_member_use
      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(_filePath!)], subject: 'My Transformation');
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Error: $e';
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
                'Exporting ${widget.qualityName}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_status),
              const SizedBox(height: 48),
              if (_isDone) ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Dismiss')),
            ],
          ),
        ),
      ),
    );
  }
}
