import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/vib3_colors.dart';
import '../../../utils/vib3_theme.dart';
import '../../../providers/camera_provider.dart';
import '../../../models/camera_system.dart';

class CameraTab extends ConsumerWidget {
  const CameraTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraProvider);

    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CAMERA CONTROL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: VIB3CategoryColors.camera,
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: Column(
              children: [
                _buildPresetSelector(ref, cameraState),
                SizedBox(height: 12),
                _buildCameraInfo(ref, cameraState),
                SizedBox(height: 12),
                _buildCinematicRails(ref, cameraState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetSelector(WidgetRef ref, CameraState cameraState) {
    return GlassmorphicContainer(
      opacity: 0.5,
      blur: 6,
      borderColor: VIB3CategoryColors.camera.withOpacity(0.4),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.videocam, size: 16, color: VIB3CategoryColors.camera),
              SizedBox(width: 8),
              Text(
                'Active Camera',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _presetButton(
                'Free Orbit',
                cameraState.activePreset == CameraPreset.freeOrbit,
                () {
                  ref.read(cameraProvider.notifier).setPreset(CameraPreset.freeOrbit);
                },
              ),
              _presetButton(
                'Rail 1',
                cameraState.activePreset == CameraPreset.cinematicRail1,
                () {
                  ref.read(cameraProvider.notifier).setPreset(CameraPreset.cinematicRail1);
                },
              ),
              _presetButton(
                'Rail 2',
                cameraState.activePreset == CameraPreset.cinematicRail2,
                () {
                  ref.read(cameraProvider.notifier).setPreset(CameraPreset.cinematicRail2);
                },
              ),
              _presetButton(
                'Rail 3',
                cameraState.activePreset == CameraPreset.cinematicRail3,
                () {
                  ref.read(cameraProvider.notifier).setPreset(CameraPreset.cinematicRail3);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCameraInfo(WidgetRef ref, CameraState cameraState) {
    final position = cameraState.system.getPosition();
    final fov = cameraState.system.getFOV();

    return GlassmorphicContainer(
      opacity: 0.5,
      blur: 6,
      borderColor: VIB3CategoryColors.camera.withOpacity(0.4),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Camera Position',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _infoChip('X', position.x.toStringAsFixed(2)),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _infoChip('Y', position.y.toStringAsFixed(2)),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _infoChip('Z', position.z.toStringAsFixed(2)),
              ),
            ],
          ),
          SizedBox(height: 8),
          _infoChip('FOV', '${fov.toInt()}°'),
        ],
      ),
    );
  }

  Widget _buildCinematicRails(WidgetRef ref, CameraState cameraState) {
    return Expanded(
      child: GlassmorphicContainer(
        opacity: 0.5,
        blur: 6,
        borderColor: VIB3CategoryColors.camera.withOpacity(0.4),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cinematic Rails',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: cameraState.system.rails.length,
                separatorBuilder: (context, index) => SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final rail = cameraState.system.rails[index];
                  return Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: VIB3CategoryColors.camera.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: VIB3CategoryColors.camera.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.linear_scale,
                                size: 12, color: VIB3CategoryColors.camera),
                            SizedBox(width: 6),
                            Text(
                              rail.name,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Spacer(),
                            if (rail.beatSynced)
                              Icon(Icons.music_note,
                                  size: 10, color: VIB3Colors.green),
                            SizedBox(width: 4),
                            if (rail.audioReactive)
                              Icon(Icons.graphic_eq,
                                  size: 10, color: VIB3Colors.green),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              rail.pathType.toString().split('.').last,
                              style: TextStyle(
                                  fontSize: 9, color: Colors.white60),
                            ),
                            SizedBox(width: 12),
                            Text(
                              '${rail.duration.toInt()}s',
                              style: TextStyle(
                                  fontSize: 9, color: Colors.white60),
                            ),
                            SizedBox(width: 12),
                            Text(
                              rail.loopMode.toString().split('.').last,
                              style: TextStyle(
                                  fontSize: 9, color: Colors.white60),
                            ),
                          ],
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

  Widget _presetButton(String label, bool isActive, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive
            ? VIB3CategoryColors.camera
            : VIB3CategoryColors.camera.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size(0, 0),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: VIB3CategoryColors.camera.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 9, color: Colors.white60),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: VIB3CategoryColors.camera,
            ),
          ),
        ],
      ),
    );
  }
}
