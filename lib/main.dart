import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:visual_break_app/core/logging/app_logger.dart';
import 'package:visual_break_app/core/service_locator.dart';
import 'package:visual_break_app/application/timer_service/break_timer_service.dart';
import 'package:visual_break_app/presentation/popups/visual_break_popup.dart';
import 'package:visual_break_app/presentation/tray_menu/tray_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup Dependency Injection
  await setupLocator();

  // Initialize Window Manager
  await windowManager.ensureInitialized();
  
  // Initialize System Tray
  final trayManager = TrayManager();
  await trayManager.initTray();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  AppLogger.i('Application Started');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visual Break App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ListenableBuilder(
        listenable: getIt<BreakTimerService>(),
        builder: (context, child) {
          final status = getIt<BreakTimerService>().status;
          if (status == TimerStatus.breaking) {
            return const VisualBreakPopup();
          }
          return const HomeScreen();
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    getIt<BreakTimerService>().startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final timerService = getIt<BreakTimerService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Visual Break Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListenableBuilder(
              listenable: timerService,
              builder: (context, child) {
                return Column(
                  children: [
                    const Text(
                      'Prochaine pause dans :',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      timerService.formattedTime,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
            const Text(
              'L\'application est active et surveille votre temps d\'écran.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
