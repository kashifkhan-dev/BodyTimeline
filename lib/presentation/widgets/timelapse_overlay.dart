import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';
import '../../core/theme/color_palette.dart';

class TimelapseOverlay extends StatefulWidget {
  final List<String> images;
  final List<DateTime> dates;

  const TimelapseOverlay({super.key, required this.images, required this.dates});

  @override
  State<TimelapseOverlay> createState() => _TimelapseOverlayState();
}

class _TimelapseOverlayState extends State<TimelapseOverlay> {
  int _currentIndex = 0;
  Timer? _timer;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_isPlaying) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.images.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    final currentImage = widget.images[_currentIndex];
    final currentDate = widget.dates[_currentIndex];
    final isAsset = currentImage.startsWith('assets/');

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image Display
          Center(
            child: AspectRatio(
              aspectRatio: 3 / 4, // Consistent aspect ratio
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: isAsset
                    ? Image.asset(currentImage, key: ValueKey(currentImage), fit: BoxFit.cover, width: double.infinity)
                    : Image.file(
                        File(currentImage),
                        key: ValueKey(currentImage),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
              ),
            ),
          ),

          // Top Controls
          Positioned(
            top: 44,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.xmark, color: CupertinoColors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: CupertinoColors.black.withAlpha(100),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Day ${_currentIndex + 1}/${widget.images.length}',
                    style: const TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 28), // Spacer
              ],
            ),
          ),

          // Bottom Info
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  '${currentDate.day} ${_getMonthName(currentDate.month)} ${currentDate.year}',
                  style: const TextStyle(color: CupertinoColors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoButton(
                      child: Icon(
                        _isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                        color: CupertinoColors.white,
                        size: 44,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPlaying = !_isPlaying;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
