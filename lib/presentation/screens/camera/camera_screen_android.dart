import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/repositories/workout_repository.dart';
import '../../../domain/value_objects/zone_type.dart';
import '../../view_models/camera_view_model.dart';
import '../../widgets/silhouette_painter.dart';

class CameraScreenAndroid extends StatelessWidget {
  final ZoneType mode;

  const CameraScreenAndroid({super.key, required this.mode});

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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (vm.state != CameraState.initializing && vm.controller != null)
            _buildCameraPreview(vm)
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

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
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),

          if (vm.state == CameraState.error)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    const SizedBox(height: 24),
                    const Text(
                      'Camera unavailable or loading...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 32),
                    TextButton(
                      child: const Text('Close', style: TextStyle(color: Colors.white)),
                      onPressed: () => Navigator.pop(context),
                    ),
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
      return const Center(child: CircularProgressIndicator(color: Colors.white));
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
          color: Colors.black.withAlpha(180), // More solid dimmed panel
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              _getModeLabel(vm.initialMode),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
            ),
            IconButton(
              icon: Icon(
                vm.lensDirection == CameraLensDirection.front ? Icons.flip_camera_ios : Icons.flip_camera_android,
                color: Colors.white,
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
          color: Colors.black.withAlpha(180), // More solid dimmed panel
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => vm.toggleGuides(),
                icon: Icon(Icons.grid_on, color: vm.showGuides ? const Color(0xFFD0F288) : Colors.white, size: 28),
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
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
                      const Icon(Icons.photo, color: Colors.white, size: 14),
                      Slider(
                        value: vm.ghostOpacity * 100,
                        min: 0,
                        max: 100,
                        onChanged: (v) => vm.setGhostOpacity(v / 100),
                        activeColor: const Color(0xFFD0F288),
                        inactiveColor: Colors.white24,
                      ),
                      Text(
                        '${(vm.ghostOpacity * 100).toInt()}%',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
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
          ElevatedButton(
            onPressed: () => vm.retake(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
            child: const Text('Retake', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () => vm.confirm(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD0F288)),
            child: const Text('Use Photo', style: TextStyle(color: Colors.black)),
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
