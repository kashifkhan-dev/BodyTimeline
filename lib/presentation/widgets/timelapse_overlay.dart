import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:workout/domain/entities/photo_record.dart';

class TimelapseOverlay extends StatefulWidget {
  final List<String> images;
  final List<DateTime> dates;

  const TimelapseOverlay({super.key, required this.images, required this.dates});

  @override
  State<TimelapseOverlay> createState() => _TimelapseOverlayState();

  static void show(BuildContext context, List<PhotoRecord> photos) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => TimelapseOverlay(
        images: photos.map((p) => p.filePath).toList(),
        dates: photos.map((p) => p.capturedAt).toList(),
      ),
    );
  }
}

class _TimelapseOverlayState extends State<TimelapseOverlay> {
  int _currentIndex = 0;
  Timer? _timer;
  bool _isPlaying = false; // Default: Paused
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Default state: Paused. _startTimer will only run if _isPlaying is true.
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_isPlaying) {
        if (_currentIndex < widget.images.length - 1) {
          setState(() {
            _currentIndex++;
          });
          _scrollToCurrent();
        } else {
          // Finished: Stop on last frame, no loop
          setState(() {
            _isPlaying = false;
          });
          _timer?.cancel();
        }
      }
    });
  }

  void _scrollToCurrent() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _currentIndex * 60.0, // thumbnail width + padding
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );
    }
  }

  void _onPlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        if (_currentIndex >= widget.images.length - 1) {
          _currentIndex = 0; // Restart if at end and user clicks play
        }
        _startTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _onScrub(int index) {
    setState(() {
      _currentIndex = index;
      _isPlaying = false; // Pause while scrubbing
      _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
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
          // Image Display (Centered)
          Center(
            child: AspectRatio(
              aspectRatio: 3 / 4,
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

          // Top Controls (Close & Position)
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
                const SizedBox(width: 28),
              ],
            ),
          ),

          // Bottom Controls (Play/Pause, Timeline, Date)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  '${currentDate.day} ${_getMonthName(currentDate.month)} ${currentDate.year}',
                  style: const TextStyle(color: CupertinoColors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),

                // Play/Pause Button
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _onPlayPause,
                  child: Icon(
                    _isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                    color: CupertinoColors.white,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 24),

                // Horizontal Timeline Grid
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: widget.images.length,
                    itemBuilder: (context, index) {
                      final path = widget.images[index];
                      final isCurrent = index == _currentIndex;
                      return GestureDetector(
                        onTap: () => _onScrub(index),
                        child: Container(
                          width: 50,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isCurrent ? const Color(0xFFD0F288) : CupertinoColors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: path.startsWith('assets/')
                                ? Image.asset(path, fit: BoxFit.cover)
                                : Image.file(File(path), fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
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
