import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/vib3_colors.dart';
import 'utils/vib3_theme.dart';
import 'widgets/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: VIB3Colors.darkNavy,
    ),
  );

  runApp(
    const ProviderScope(
      child: VIB3LightLabApp(),
    ),
  );
}

class VIB3LightLabApp extends StatelessWidget {
  const VIB3LightLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIB3 Light Lab',
      debugShowCheckedModeBanner: false,
      theme: VIB3Theme.darkTheme,
      home: const MainScreen(),
    );
  }
}
