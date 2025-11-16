import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/vib3_colors.dart';
import 'widgets/bezel/bezel_tab_bar.dart';
import 'widgets/bezel/tabs/rotation_tab.dart';
import 'widgets/canvas/webgl_canvas.dart';

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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: VIB3Colors.darkNavy,
        primaryColor: VIB3Colors.cyan,
        colorScheme: ColorScheme.dark(
          primary: VIB3Colors.cyan,
          secondary: VIB3Colors.magenta,
          surface: VIB3Colors.darkPurple,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          // WebGL Canvas (full screen)
          const WebGLCanvas(),
          // Bezel tab bar at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BezelTabBar(
              tabs: [
                BezelTab(
                  label: '4D Rotate',
                  icon: Icons.threed_rotation,
                  content: const RotationTab(),
                ),
                BezelTab(
                  label: 'Visual',
                  icon: Icons.grid_on,
                  content: Center(
                    child: Text(
                      'Visual Controls - Coming Soon',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                BezelTab(
                  label: 'Color',
                  icon: Icons.palette,
                  content: Center(
                    child: Text(
                      'Color Controls - Coming Soon',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
