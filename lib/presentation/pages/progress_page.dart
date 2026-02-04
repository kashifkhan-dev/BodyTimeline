import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cupertino_native/cupertino_native.dart';
import '../view_models/progress_view_model.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/color_palette.dart';
import '../../domain/value_objects/zone_type.dart';
import '../widgets/timelapse_overlay.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProgressViewModel>();
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);

    // STRICT ORDERING: load images strictly by index 1-19 as requested
    final photos = List.generate(19, (i) => 'assets/images/transformation/${i + 1}.png');
    final dates = vm.photoDates;

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text('Your Progress', style: TextStyle(color: colors.textPrimary)),
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
                  _buildStatsRow(vm, colors),
                  const SizedBox(height: 24),
                  _buildZoneSelector(vm, colors),
                  const SizedBox(height: 32),
                  _buildBeforeAfterSection(context, photos, dates, colors),
                  const SizedBox(height: 32),
                  _buildTimelineSection(photos, colors),
                  const SizedBox(height: 120),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ProgressViewModel vm, AppColors colors) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Current Streak',
            value: vm.currentStreak.toString(),
            icon: '🔥',
            colors: colors,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(label: 'Completed Days', value: vm.totalCompletedDays.toString(), colors: colors),
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

  Widget _buildZoneSelector(ProgressViewModel vm, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(12)),
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
              label: 'Body Front',
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
    if (photos.isEmpty) {
      return _buildEmptyState('No photos captured for this zone.', colors);
    }

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
              'Before & After',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            Text('View difference', style: TextStyle(fontSize: 14, color: colors.textMuted)),
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
                  Expanded(child: _buildComparisonImage(beforeImage, 'Before', beforeDate, colors)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildComparisonImage(afterImage, 'Today', afterDate, colors)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CNButton(
                      label: 'Timelapse',
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => TimelapseOverlay(images: photos, dates: dates),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CNButton(
                      label: 'Export Video',
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
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text('${date.day} ${_getMonthName(date.month)}', style: TextStyle(fontSize: 11, color: colors.textSecondary)),
      ],
    );
  }

  Widget _buildTimelineSection(List<String> photos, AppColors colors) {
    if (photos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Timeline',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            Text('${photos.length} photos', style: TextStyle(fontSize: 14, color: colors.textSecondary)),
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

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  void _showExportOptions(BuildContext context, List<String> photos, AppColors colors) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Export Transformation'),
        message: const Text('Select video quality'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _startExport(context, 'Low (480p)', photos, colors);
            },
            child: const Text('Low (480p)'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _startExport(context, 'Medium (720p)', photos, colors);
            },
            child: const Text('Medium (720p)'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _startExport(context, 'High (1080p)', photos, colors);
            },
            child: const Text('High (1080p)'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _startExport(BuildContext context, String quality, List<String> photos, AppColors colors) async {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ExportProgressOverlay(quality: quality, photos: photos, colors: colors),
    );
  }
}

class _ExportProgressOverlay extends StatefulWidget {
  final String quality;
  final List<String> photos;
  final AppColors colors;

  const _ExportProgressOverlay({required this.quality, required this.photos, required this.colors});

  @override
  State<_ExportProgressOverlay> createState() => _ExportProgressOverlayState();
}

class _ExportProgressOverlayState extends State<_ExportProgressOverlay> {
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
    final int steps = frameCount + 10; // Extra steps for init and final
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
      // 1. Permissions (GRACEFUL)
      update('Checking permissions...');
      final status = await Permission.storage.request();
      if (status.isPermanentlyDenied) {
        if (mounted) {
          setState(() {
            _status = 'Storage permission permanently denied. Please enable in Settings.';
            _isDone = true;
          });
        }
        await openAppSettings();
        return;
      }
      if (!status.isGranted) {
        setState(() {
          _status = 'Storage permission required for export.';
          _isDone = true;
        });
        return;
      }

      // 2. Prepare Temp Directory
      update('Preparing workspace...');
      final tempDir = await getTemporaryDirectory();
      final exportDir = Directory('${tempDir.path}/export_${DateTime.now().millisecondsSinceEpoch}');
      await exportDir.create();

      // 3. Extract Assets (MANDATORY for FFmpeg)
      for (int i = 0; i < frameCount; i++) {
        update('Processing frame ${i + 1}/$frameCount');
        final byteData = await rootBundle.load(widget.photos[i]);
        final bytes = byteData.buffer.asUint8List();
        final frameFile = File('${exportDir.path}/frame_${(i + 1).toString().padLeft(3, '0')}.png');
        await frameFile.writeAsBytes(bytes);
      }

      // 4. Run FFmpeg (REAL MP4)
      update('Encoding H.264 video...');
      final docsDir = await getApplicationDocumentsDirectory();
      final outputPath = '${docsDir.path}/transformation_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Commands:
      // -framerate 5: 0.2s per frame
      // -i frame_%03d.png: sequence input
      // -c:v libx264: H.264 video
      // -pix_fmt yuv420p: Compatibility
      // -y: overwrite
      final String ffmpegCommand =
          '-framerate 5 -i ${exportDir.path}/frame_%03d.png -c:v libx264 -pix_fmt yuv420p -y $outputPath';

      final session = await FFmpegKit.execute(ffmpegCommand);
      final returnCode = await session.getReturnCode();

      if (!ReturnCode.isSuccess(returnCode)) {
        final logs = await session.getLogs();
        debugPrint('FFmpeg failed: ${logs.join('\n')}');
        throw Exception('Encoding failed');
      }

      // Verify file exists
      final outputFile = File(outputPath);
      if (!await outputFile.exists()) {
        throw Exception('Exported file not found');
      }

      _filePath = outputPath;
      update('Export complete!', overrideProgress: 1.0);

      setState(() {
        _isDone = true;
      });

      // 5. Open via System Share Sheet (REQUIRED)
      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(_filePath!)], subject: 'My Transformation');
    } catch (e) {
      debugPrint('Export Error: $e');
      if (mounted) {
        setState(() {
          _status = 'Export failed: ${e.toString()}';
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
                'Exporting ${widget.quality}',
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
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 8,
                  width: double.infinity,
                  color: widget.colors.progressBackground,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress,
                    child: Container(color: const Color(0xFFD0F288)),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              if (_isDone) ...[CNButton(label: 'Done', onPressed: () => Navigator.pop(context))],
            ],
          ),
        ),
      ),
    );
  }
}
