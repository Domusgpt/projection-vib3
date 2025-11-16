import 'package:flutter/material.dart';
import '../../../utils/vib3_theme.dart';

class TimelineTab extends StatelessWidget {
  const TimelineTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Timeline Tab - TODO',
        style: TextStyle(color: VIB3CategoryColors.timeline),
      ),
    );
  }
}
