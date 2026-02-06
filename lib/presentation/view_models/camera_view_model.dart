import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/photo_record.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/value_objects/zone_type.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

enum CameraState { initializing, idle, capturing, review, saving, error }

class CameraViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;
  final ZoneType initialMode;

  CameraController? _controller;
  CameraState _state = CameraState.initializing;
  String? _errorMessage;

  XFile? _capturedFile;
  PhotoRecord? _ghostPhoto;
  double _ghostOpacity = 0.4;
  bool _showGuides = true;
  CameraLensDirection _lensDirection = CameraLensDirection.front;

  CameraController? get controller => _controller;
  CameraState get state => _state;
  String? get errorMessage => _errorMessage;
  XFile? get capturedFile => _capturedFile;
  PhotoRecord? get ghostPhoto => _ghostPhoto;
  double get ghostOpacity => _ghostOpacity;
  bool get showGuides => _showGuides;
  CameraLensDirection get lensDirection => _lensDirection;

  CameraViewModel(this._workoutRepository, this.initialMode) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final oldState = _state;
      _state = CameraState.initializing;
      notifyListeners();

      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _errorMessage = "No cameras found";
        _state = CameraState.error;
        notifyListeners();
        return;
      }

      CameraDescription? selectedCamera;
      try {
        selectedCamera = cameras.firstWhere((c) => c.lensDirection == _lensDirection);
      } catch (_) {
        selectedCamera = cameras.first;
        _lensDirection = selectedCamera.lensDirection;
      }

      _controller = CameraController(selectedCamera, ResolutionPreset.high, enableAudio: false);

      await _controller!.initialize();

      // Load ghost photo (only if not already loaded)
      _ghostPhoto ??= await _workoutRepository.getLatestPhoto(DateTime.now(), initialMode);

      _state = oldState == CameraState.initializing ? CameraState.idle : oldState;
      // If we were in review, we probably don't want to stay in review if we toggle camera?
      if (_state == CameraState.review) _state = CameraState.idle;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = CameraState.error;
      notifyListeners();
    }
  }

  Future<void> toggleCamera() async {
    if (_state == CameraState.initializing || _state == CameraState.capturing) return;

    _lensDirection = _lensDirection == CameraLensDirection.front ? CameraLensDirection.back : CameraLensDirection.front;

    await _initialize();
  }

  void setGhostOpacity(double opacity) {
    _ghostOpacity = opacity.clamp(0.0, 1.0);
    notifyListeners();
  }

  void toggleGuides() {
    _showGuides = !_showGuides;
    notifyListeners();
  }

  Future<void> capturePhoto(double screenAspectRatio) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      _state = CameraState.capturing;
      notifyListeners();

      final XFile rawFile = await _controller!.takePicture();

      // Process image to match preview (Mirroring + Aspect Ratio Crop)
      final bytes = await rawFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image != null) {
        // 1. Flip if front camera
        if (_lensDirection == CameraLensDirection.front) {
          image = img.flipHorizontal(image);
        }

        // 2. Crop to match screen aspect ratio (Fit cover behavior)
        final int imgW = image.width;
        final int imgH = image.height;
        final double imgAspectRatio = imgW / imgH;

        int cropW = imgW;
        int cropH = imgH;
        int offsetX = 0;
        int offsetY = 0;

        if (imgAspectRatio > screenAspectRatio) {
          // Image is wider than screen, crop sides
          cropW = (imgH * screenAspectRatio).toInt();
          offsetX = (imgW - cropW) ~/ 2;
        } else {
          // Image is taller than screen, crop top/bottom
          cropH = (imgW / screenAspectRatio).toInt();
          offsetY = (imgH - cropH) ~/ 2;
        }

        image = img.copyCrop(image, x: offsetX, y: offsetY, width: cropW, height: cropH);

        // Save processed image
        final processedBytes = img.encodeJpg(image, quality: 90);
        final tempDir = await getTemporaryDirectory();
        final processedPath = '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await File(processedPath).writeAsBytes(processedBytes);

        _capturedFile = XFile(processedPath);
      } else {
        _capturedFile = rawFile;
      }

      _state = CameraState.review;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = CameraState.error;
      notifyListeners();
    }
  }

  void retake() {
    _capturedFile = null;
    _state = CameraState.idle;
    notifyListeners();
  }

  Future<void> confirm({void Function(PhotoRecord)? onSaved}) async {
    if (_capturedFile == null) return;

    try {
      _state = CameraState.saving;
      notifyListeners();

      final now = DateTime.now();
      final photo = PhotoRecord(
        id: const Uuid().v4(),
        filePath: _capturedFile!.path,
        capturedAt: now,
        zoneType: initialMode,
      );

      await _workoutRepository.savePhoto(now, photo);
      if (onSaved != null) onSaved(photo);
    } catch (e) {
      _errorMessage = e.toString();
      _state = CameraState.error;
      notifyListeners();
    }
  }

  void resetCapture() {
    _capturedFile = null;
    _state = CameraState.idle;
    _ghostOpacity = 0.4;
    _showGuides = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
