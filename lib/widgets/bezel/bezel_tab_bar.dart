import 'package:flutter/material.dart';
import '../../utils/vib3_theme.dart';
import '../../utils/vib3_colors.dart';
import '../bezel/tabs/rotation_tab.dart';
import '../bezel/tabs/visual_tab.dart';
import '../bezel/tabs/color_tab.dart';
import '../bezel/tabs/audio_tab.dart';
import '../bezel/tabs/effects_tab.dart';
import '../bezel/tabs/timeline_tab.dart';
import '../bezel/tabs/camera_tab.dart';
import '../bezel/tabs/lighting_tab.dart';
import '../bezel/tabs/macros_tab.dart';

class BezelTabBar extends StatelessWidget {
  final VIB3ControlCategory? expandedTab;
  final Function(VIB3ControlCategory) onTabTapped;

  const BezelTabBar({
    super.key,
    this.expandedTab,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isExpanded = expandedTab != null;
    final expandedHeight = screenHeight * 0.3;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: isExpanded ? expandedHeight : 50,
      child: Column(
        children: [
          // Tab buttons (always visible)
          _buildTabButtons(),

          // Expanded content
          if (isExpanded)
            Expanded(
              child: GlassmorphicContainer(
                opacity: 0.75,
                blur: 8,
                borderColor: expandedTab!.color.withOpacity(0.6),
                child: Column(
                  children: [
                    Expanded(
                      child: _buildExpandedContent(expandedTab!),
                    ),
                    _buildCollapseButton(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabButtons() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: VIB3Colors.darkPurple.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: VIB3Colors.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: VIB3ControlCategory.values.map((category) {
          final isActive = expandedTab == category;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabTapped(category),
              child: Container(
                decoration: BoxDecoration(
                  color: isActive
                      ? category.color.withOpacity(0.3)
                      : Colors.transparent,
                  border: Border(
                    right: BorderSide(
                      color: VIB3Colors.glassBorder.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category.icon,
                      size: 18,
                      color: isActive ? category.color : Colors.white70,
                    ),
                    SizedBox(height: 2),
                    Text(
                      category.displayName.split(' ').first,
                      style: TextStyle(
                        fontSize: 8,
                        color: isActive ? category.color : Colors.white60,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpandedContent(VIB3ControlCategory category) {
    switch (category) {
      case VIB3ControlCategory.rotation:
        return RotationTab();
      case VIB3ControlCategory.visual:
        return VisualTab();
      case VIB3ControlCategory.color:
        return ColorTab();
      case VIB3ControlCategory.audio:
        return AudioTab();
      case VIB3ControlCategory.effects:
        return EffectsTab();
      case VIB3ControlCategory.timeline:
        return TimelineTab();
      case VIB3ControlCategory.camera:
        return CameraTab();
      case VIB3ControlCategory.lighting:
        return LightingTab();
      case VIB3ControlCategory.macros:
        return MacrosTab();
    }
  }

  Widget _buildCollapseButton() {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: expandedTab!.color.withOpacity(0.2),
        border: Border(
          top: BorderSide(
            color: expandedTab!.color.withOpacity(0.4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: expandedTab!.color,
          ),
          SizedBox(width: 4),
          Text(
            'Collapse',
            style: TextStyle(
              fontSize: 12,
              color: expandedTab!.color,
            ),
          ),
        ],
      ),
    );
  }
}
