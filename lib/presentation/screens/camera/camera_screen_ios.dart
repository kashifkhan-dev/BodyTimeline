import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../domain/repositories/workout_repository.dart';
import '../../../domain/value_objects/zone_type.dart';
import '../../view_models/camera_view_model.dart';
import '../../widgets/silhouette_painter.dart';

class CameraScreenIOS extends StatelessWidget {
  final ZoneType mode;

  const CameraScreenIOS({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CameraViewModel(context.read<WorkoutRepository>(), mode),
      child: const _CameraView(),
    );
  }
}

class _CameraView extends StatelessWidget {
  const _CameraView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CameraViewModel>();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (vm.state != CameraState.initializing && vm.controller != null)
            _buildCameraPreview(vm)
          else
            const Center(child: CupertinoActivityIndicator(color: CupertinoColors.white)),

          if (vm.initialMode == ZoneType.bodyFront && vm.state == CameraState.idle)
            IgnorePointer(child: _buildGhostOverlay(vm)),

          if (vm.showGuides && (vm.state == CameraState.idle || vm.state == CameraState.review))
            IgnorePointer(
              child: CustomPaint(painter: SilhouettePainter(mode: vm.initialMode, showGuides: true)),
            ),

          _buildTopBar(context, vm),
          _buildBottomArea(context, vm),

          if (vm.state == CameraState.review) _buildReviewControls(vm),

          if (vm.state == CameraState.saving)
            Container(
              color: CupertinoColors.black.withAlpha(150),
              child: const Center(child: CupertinoActivityIndicator(color: CupertinoColors.white)),
            ),

          if (vm.state == CameraState.error)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CupertinoActivityIndicator(color: CupertinoColors.white, radius: 14),
                    const SizedBox(height: 24),
                    const Text(
                      'Camera unavailable or loading...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 15),
                    ),
                    const SizedBox(height: 32),
                    CNButton(label: 'Close', onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(CameraViewModel vm) {
    if (vm.state == CameraState.review && vm.capturedFile != null) {
      return SizedBox.expand(child: Image.file(File(vm.capturedFile!.path), fit: BoxFit.cover));
    }

    if (vm.controller == null || !vm.controller!.value.isInitialized) {
      return const Center(child: CupertinoActivityIndicator(color: CupertinoColors.white));
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: vm.controller!.value.previewSize?.height ?? 1,
          height: vm.controller!.value.previewSize?.width ?? 1,
          child: CameraPreview(vm.controller!),
        ),
      ),
    );
  }

  Widget _buildGhostOverlay(CameraViewModel vm) {
    if (vm.initialMode != ZoneType.bodyFront) return const SizedBox.shrink();
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: Opacity(
        opacity: vm.ghostOpacity,
        child: Image.asset('assets/images/front.png', fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, CameraViewModel vm) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 44, bottom: 16, left: 20, right: 20),
        decoration: BoxDecoration(
          color: CupertinoColors.black.withAlpha(180), // More solid dimmed panel
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.xmark, color: CupertinoColors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              _getModeLabel(vm.initialMode),
              style: const TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold, fontSize: 17),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                vm.lensDirection == CameraLensDirection.front
                    ? CupertinoIcons.arrow_counterclockwise
                    : CupertinoIcons.arrow_counterclockwise_circle_fill,
                color: CupertinoColors.white,
              ),
              onPressed: () => vm.toggleCamera(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomArea(BuildContext context, CameraViewModel vm) {
    if (vm.state == CameraState.review) return const SizedBox.shrink();
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 24, bottom: 60, left: 20, right: 20),
        decoration: BoxDecoration(
          color: CupertinoColors.black.withAlpha(180), // More solid dimmed panel
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  vm.showGuides ? CupertinoIcons.grid : CupertinoIcons.grid_circle,
                  color: vm.showGuides ? const Color(0xFFD0F288) : CupertinoColors.white,
                  size: 28,
                ),
                onPressed: () => vm.toggleGuides(),
              ),
            ),
            GestureDetector(
              onTap: vm.state == CameraState.idle
                  ? () => vm.capturePhoto(MediaQuery.of(context).size.aspectRatio)
                  : null,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CupertinoColors.white, width: 4),
                ),
                child: Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(color: CupertinoColors.white, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
            if (vm.initialMode == ZoneType.bodyFront)
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.photo, color: CupertinoColors.white, size: 14),
                      CNSlider(
                        value: vm.ghostOpacity * 100,
                        min: 0,
                        max: 100,
                        onChanged: (v) => vm.setGhostOpacity(v / 100),
                      ),
                      Text(
                        '${(vm.ghostOpacity * 100).toInt()}%',
                        style: const TextStyle(color: CupertinoColors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              )
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewControls(CameraViewModel vm) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CNButton(label: 'Retake', onPressed: () => vm.retake()),
          CNButton(
            label: 'Use Photo',
            onPressed: () async {
              await vm.confirm();
            },
          ),
        ],
      ),
    );
  }

  String _getModeLabel(ZoneType mode) {
    switch (mode) {
      case ZoneType.face:
        return 'Face Photo';
      case ZoneType.bodyFront:
        return 'Body Front Photo';
      case ZoneType.bodySide:
        return 'Body Side Photo';
      default:
        return 'Capture';
    }
  }
}
