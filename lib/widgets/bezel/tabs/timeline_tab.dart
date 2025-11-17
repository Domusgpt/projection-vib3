import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/vib3_theme.dart';
import '../../../models/timeline.dart';
import '../../../providers/timeline_provider.dart';

class TimelineTab extends ConsumerWidget {
  const TimelineTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineState = ref.watch(timelineProvider);

    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TIMELINE SEQUENCER',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: VIB3CategoryColors.timeline,
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: Column(
              children: [
                _buildTransportControls(ref, timelineState),
                SizedBox(height: 12),
                _buildPlayheadDisplay(timelineState),
                SizedBox(height: 12),
                _buildTracksList(timelineState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportControls(WidgetRef ref, TimelineState timelineState) {
    return GlassmorphicContainer(
      opacity: 0.5,
      blur: 6,
      borderColor: VIB3CategoryColors.timeline.withOpacity(0.4),
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.stop, color: Colors.white),
            onPressed: () {
              ref.read(timelineProvider.notifier).stop();
            },
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(
              timelineState.isPlaying ? Icons.pause : Icons.play_arrow,
              color: VIB3CategoryColors.timeline,
              size: 32,
            ),
            onPressed: () {
              if (timelineState.isPlaying) {
                ref.read(timelineProvider.notifier).pause();
              } else {
                ref.read(timelineProvider.notifier).play();
              }
            },
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.loop,
              color: timelineState.isLooping
                  ? VIB3CategoryColors.timeline
                  : Colors.white38,
            ),
            onPressed: () {
              ref.read(timelineProvider.notifier).toggleLoop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayheadDisplay(TimelineState timelineState) {
    return GlassmorphicContainer(
      opacity: 0.5,
      blur: 6,
      borderColor: VIB3CategoryColors.timeline.withOpacity(0.4),
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Playhead:',
                style: TextStyle(fontSize: 10, color: Colors.white60),
              ),
              Spacer(),
              Text(
                '${timelineState.playheadPosition.toStringAsFixed(2)}s / ${timelineState.totalDuration.toStringAsFixed(0)}s',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: VIB3CategoryColors.timeline,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: timelineState.playheadPosition / timelineState.totalDuration,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: VIB3CategoryColors.timeline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                'BPM: ${timelineState.bpm.toInt()}',
                style: TextStyle(fontSize: 9, color: Colors.white54),
              ),
              SizedBox(width: 16),
              Text(
                'Time Sig: ${_formatTimeSignature(timelineState.timeSignature)}',
                style: TextStyle(fontSize: 9, color: Colors.white54),
              ),
              Spacer(),
              Text(
                'Measure: ${timelineState.currentMeasure}  Beat: ${timelineState.currentBeat}',
                style: TextStyle(fontSize: 9, color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTracksList(TimelineState timelineState) {
    return Expanded(
      child: GlassmorphicContainer(
        opacity: 0.5,
        blur: 6,
        borderColor: VIB3CategoryColors.timeline.withOpacity(0.4),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tracks (${timelineState.tracks.length})',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 12),
            if (timelineState.tracks.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timeline,
                        size: 40,
                        color: VIB3CategoryColors.timeline.withOpacity(0.3),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No tracks yet',
                        style: TextStyle(fontSize: 10, color: Colors.white54),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Full timeline editor coming soon',
                        style: TextStyle(fontSize: 8, color: Colors.white38),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: timelineState.tracks.length,
                  separatorBuilder: (context, index) => SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final track = timelineState.tracks[index];
                    return Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: VIB3CategoryColors.timeline.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            !track.isMuted ? Icons.check_circle : Icons.circle_outlined,
                            size: 12,
                            color: !track.isMuted
                                ? VIB3CategoryColors.timeline
                                : Colors.white38,
                          ),
                          SizedBox(width: 8),
                          Text(
                            track.name,
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimeSignature(TimeSignature sig) {
    switch (sig) {
      case TimeSignature.fourFour:
        return '4/4';
      case TimeSignature.threeFour:
        return '3/4';
      case TimeSignature.sixEight:
        return '6/8';
      case TimeSignature.sevenEight:
        return '7/8';
    }
  }
}
