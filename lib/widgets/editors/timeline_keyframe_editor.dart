import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/timeline.dart';
import '../../models/vib3_parameters.dart';
import '../../providers/timeline_provider.dart';
import '../../utils/vib3_colors.dart';
import '../../utils/vib3_theme.dart';

/// Timeline keyframe editor for creating and editing automation tracks
class TimelineKeyframeEditor extends ConsumerStatefulWidget {
  const TimelineKeyframeEditor({super.key});

  @override
  ConsumerState<TimelineKeyframeEditor> createState() =>
      _TimelineKeyframeEditorState();
}

class _TimelineKeyframeEditorState
    extends ConsumerState<TimelineKeyframeEditor> {
  TimelineTrack? _selectedTrack;
  VIB3Parameter _selectedParameter = VIB3Parameter.rotationXY;
  TimelineTrackType _selectedTrackType = TimelineTrackType.parameter;

  @override
  Widget build(BuildContext context) {
    final timelineState = ref.watch(timelineProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: VIB3Colors.backgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, timelineState),

            // Transport controls
            _buildTransportControls(timelineState),

            // Timeline ruler
            _buildTimelineRuler(timelineState),

            // Tracks list
            Expanded(
              child: _buildTracksView(timelineState),
            ),

            // Add track panel
            _buildAddTrackPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TimelineState timelineState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: VIB3Colors.green.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.timeline, color: VIB3Colors.green, size: 24),
          const SizedBox(width: 12),
          const Text(
            'Timeline Keyframe Editor',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          // Duration display
          Text(
            'Duration: ${timelineState.totalDuration.toStringAsFixed(1)}s',
            style: TextStyle(
              fontSize: 14,
              color: VIB3Colors.green.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.close),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportControls(TimelineState timelineState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Stop
          _transportButton(
            Icons.stop,
            !timelineState.isPlaying,
            () => ref.read(timelineProvider.notifier).stop(),
          ),
          const SizedBox(width: 8),

          // Play/Pause
          _transportButton(
            timelineState.isPlaying ? Icons.pause : Icons.play_arrow,
            timelineState.isPlaying,
            () {
              if (timelineState.isPlaying) {
                ref.read(timelineProvider.notifier).pause();
              } else {
                ref.read(timelineProvider.notifier).play();
              }
            },
          ),
          const SizedBox(width: 8),

          // Loop
          _transportButton(
            Icons.repeat,
            timelineState.isLooping,
            () => ref.read(timelineProvider.notifier).toggleLoop(),
          ),

          const SizedBox(width: 24),

          // Playhead position
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: VIB3Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: VIB3Colors.green.withOpacity(0.5),
              ),
            ),
            child: Text(
              '${timelineState.playheadPosition.toStringAsFixed(2)}s',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const Spacer(),

          // BPM sync toggle
          Row(
            children: [
              Icon(
                Icons.music_note,
                size: 16,
                color: timelineState.syncToBPM
                    ? VIB3Colors.green
                    : Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                'BPM Sync',
                style: TextStyle(
                  fontSize: 12,
                  color: timelineState.syncToBPM
                      ? VIB3Colors.green
                      : Colors.white.withOpacity(0.5),
                ),
              ),
              Switch(
                value: timelineState.syncToBPM,
                activeColor: VIB3Colors.green,
                onChanged: (_) =>
                    ref.read(timelineProvider.notifier).toggleBPMSync(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _transportButton(IconData icon, bool isActive, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive
              ? VIB3Colors.green.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? VIB3Colors.green : Colors.white.withOpacity(0.3),
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? VIB3Colors.green : Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTimelineRuler(TimelineState timelineState) {
    return Container(
      height: 50,
      color: Colors.black.withOpacity(0.3),
      child: CustomPaint(
        painter: TimelineRulerPainter(
          playheadPosition: timelineState.playheadPosition,
          totalDuration: timelineState.totalDuration,
          color: VIB3Colors.green,
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildTracksView(TimelineState timelineState) {
    if (timelineState.tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_road,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No automation tracks yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create one using the panel below',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: timelineState.tracks.length,
      itemBuilder: (context, index) {
        final track = timelineState.tracks[index];
        return _buildTrackCard(track, timelineState);
      },
    );
  }

  Widget _buildTrackCard(TimelineTrack track, TimelineState timelineState) {
    final isSelected = _selectedTrack?.id == track.id;

    return GlassmorphicContainer(
      opacity: 0.15,
      blur: 10,
      borderColor: isSelected
          ? VIB3Colors.green.withOpacity(0.5)
          : Colors.white.withOpacity(0.2),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Track type icon
              Icon(
                _getTrackTypeIcon(track.type),
                color: VIB3Colors.green,
                size: 20,
              ),
              const SizedBox(width: 12),

              // Track name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${track.keyframes.length} keyframes',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Mute toggle
              IconButton(
                icon: Icon(
                  track.isMuted ? Icons.volume_off : Icons.volume_up,
                  size: 20,
                ),
                color: track.isMuted
                    ? Colors.red.withOpacity(0.7)
                    : VIB3Colors.green,
                onPressed: () {
                  ref.read(timelineProvider.notifier).toggleTrackMute(track.id);
                },
              ),

              // Delete track
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                color: Colors.red.withOpacity(0.7),
                onPressed: () {
                  ref.read(timelineProvider.notifier).removeTrack(track.id);
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Keyframe timeline visualization
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedTrack = track;
              });
            },
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: VIB3Colors.green.withOpacity(0.3),
                ),
              ),
              child: CustomPaint(
                painter: KeyframeTrackPainter(
                  track: track,
                  playheadPosition: timelineState.playheadPosition,
                  totalDuration: timelineState.totalDuration,
                  color: VIB3Colors.green,
                ),
                size: Size.infinite,
              ),
            ),
          ),

          if (isSelected) ...[
            const SizedBox(height: 12),
            _buildKeyframeControls(track),
          ],
        ],
      ),
    );
  }

  Widget _buildKeyframeControls(TimelineTrack track) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: VIB3Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KEYFRAME CONTROLS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: VIB3Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildKeyframeButton(
                'Add Keyframe',
                Icons.add,
                () {
                  // TODO: Add keyframe at current playhead position
                },
              ),
              _buildKeyframeButton(
                'Clear All',
                Icons.clear_all,
                () {
                  // TODO: Clear all keyframes
                },
              ),
              _buildKeyframeButton(
                'Smooth Curve',
                Icons.show_chart,
                () {
                  // TODO: Apply smooth curve to keyframes
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyframeButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: VIB3Colors.green.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: VIB3Colors.green),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTrackPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          top: BorderSide(
            color: VIB3Colors.green.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ADD NEW TRACK',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: VIB3Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Track type selector
              Expanded(
                child: DropdownButton<TimelineTrackType>(
                  value: _selectedTrackType,
                  dropdownColor: VIB3Colors.darkNavy,
                  style: const TextStyle(color: Colors.white),
                  items: TimelineTrackType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Icon(_getTrackTypeIcon(type),
                                    size: 16, color: VIB3Colors.green),
                                const SizedBox(width: 8),
                                Text(type.name.toUpperCase()),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTrackType = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Parameter selector (for parameter tracks)
              if (_selectedTrackType == TimelineTrackType.parameter)
                Expanded(
                  child: DropdownButton<VIB3Parameter>(
                    value: _selectedParameter,
                    dropdownColor: VIB3Colors.darkNavy,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    isExpanded: true,
                    items: VIB3Parameter.values
                        .map((param) => DropdownMenuItem(
                              value: param,
                              child: Text(
                                param.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedParameter = value;
                        });
                      }
                    },
                  ),
                ),

              const SizedBox(width: 16),

              // Add button
              ElevatedButton.icon(
                onPressed: _addTrack,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Track'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VIB3Colors.green,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTrackTypeIcon(TimelineTrackType type) {
    switch (type) {
      case TimelineTrackType.parameter:
        return Icons.tune;
      case TimelineTrackType.camera:
        return Icons.videocam;
      case TimelineTrackType.lighting:
        return Icons.lightbulb;
      case TimelineTrackType.color:
        return Icons.palette;
    }
  }

  void _addTrack() {
    // TODO: Implement track creation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Track creation coming soon'),
        backgroundColor: VIB3Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Custom painter for timeline ruler
class TimelineRulerPainter extends CustomPainter {
  final double playheadPosition;
  final double totalDuration;
  final Color color;

  TimelineRulerPainter({
    required this.playheadPosition,
    required this.totalDuration,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    // Draw tick marks every second
    for (double t = 0; t <= totalDuration; t += 1.0) {
      final x = (t / totalDuration) * size.width;
      final isMajor = t % 5 == 0;
      canvas.drawLine(
        Offset(x, isMajor ? 0 : 10),
        Offset(x, size.height),
        paint,
      );

      if (isMajor) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${t.toInt()}s',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x + 4, 5));
      }
    }

    // Draw playhead
    final playheadX = (playheadPosition / totalDuration) * size.width;
    final playheadPaint = Paint()
      ..color = color
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(playheadX, 0),
      Offset(playheadX, size.height),
      playheadPaint,
    );
  }

  @override
  bool shouldRepaint(TimelineRulerPainter oldDelegate) {
    return oldDelegate.playheadPosition != playheadPosition ||
        oldDelegate.totalDuration != totalDuration;
  }
}

/// Custom painter for keyframe track visualization
class KeyframeTrackPainter extends CustomPainter {
  final TimelineTrack track;
  final double playheadPosition;
  final double totalDuration;
  final Color color;

  KeyframeTrackPainter({
    required this.track,
    required this.playheadPosition,
    required this.totalDuration,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (track.keyframes.isEmpty) return;

    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw curve connecting keyframes
    final path = Path();
    bool first = true;

    for (final keyframe in track.keyframes) {
      final x = (keyframe.time / totalDuration) * size.width;
      final y = size.height - (keyframe.value * size.height);

      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }

      // Draw keyframe point
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }

    canvas.drawPath(path, paint);

    // Draw playhead indicator
    final playheadX = (playheadPosition / totalDuration) * size.width;
    final playheadPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(playheadX, 0),
      Offset(playheadX, size.height),
      playheadPaint,
    );
  }

  @override
  bool shouldRepaint(KeyframeTrackPainter oldDelegate) {
    return oldDelegate.playheadPosition != playheadPosition ||
        oldDelegate.track != track;
  }
}
