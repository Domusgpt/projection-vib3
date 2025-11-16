import 'package:flutter/material.dart';
import '../../../utils/vib3_theme.dart';

class ColorTab extends StatelessWidget {
  const ColorTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Color Tab - TODO',
        style: TextStyle(color: VIB3CategoryColors.color),
      ),
    );
  }
}
