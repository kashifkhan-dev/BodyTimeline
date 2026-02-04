import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/photo_record.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/value_objects/zone_type.dart';
import 'package:uuid/uuid.dart';

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

  CameraController? get controller => _controller;
  CameraState get state => _state;
  String? get errorMessage => _errorMessage;
  XFile? get capturedFile => _capturedFile;
  PhotoRecord? get ghostPhoto => _ghostPhoto;
  double get ghostOpacity => _ghostOpacity;
  bool get showGuides => _showGuides;

  CameraViewModel(this._workoutRepository, this.initialMode) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _state = CameraState.initializing;
      notifyListeners();

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _errorMessage = "No cameras found";
        _state = CameraState.error;
        notifyListeners();
        return;
      }

      // Spec: "front camera assumed" for consistency
      CameraDescription? selectedCamera;
      try {
        selectedCamera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front);
      } catch (_) {
        selectedCamera = cameras.first;
      }

      _controller = CameraController(selectedCamera, ResolutionPreset.high, enableAudio: false);

      await _controller!.initialize();

      // Load ghost photo
      _ghostPhoto = await _workoutRepository.getLatestPhoto(DateTime.now(), initialMode);

      _state = CameraState.idle;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = CameraState.error;
      notifyListeners();
    }
  }

  void setGhostOpacity(double opacity) {
    _ghostOpacity = opacity.clamp(0.0, 1.0);
    notifyListeners();
  }

  void toggleGuides() {
    _showGuides = !_showGuides;
    notifyListeners();
  }

  Future<void> capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      _state = CameraState.capturing;
      notifyListeners();

      _capturedFile = await _controller!.takePicture();

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

  Future<void> confirm() async {
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

      // Navigate back - handled by UI usually via state check or listener
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
