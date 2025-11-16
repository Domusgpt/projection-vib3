import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/vib3_colors.dart';

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: VIB3Colors.backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'VIB3 LIGHT LAB',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: VIB3Colors.cyan,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Professional VJ Controller',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Ready to build! 🚀',
                  style: TextStyle(
                    fontSize: 20,
                    color: VIB3Colors.magenta,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
