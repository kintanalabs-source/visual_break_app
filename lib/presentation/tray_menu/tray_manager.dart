import 'dart:io';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'package:visual_break_app/core/logging/app_logger.dart';

class TrayManager {
  final SystemTray _systemTray = SystemTray();
  final AppWindow _appWindow = AppWindow();

  Future<void> initTray() async {
    String iconPath = Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png';

    // We need to ensure assets exist or use a fallback
    // For now, we'll use a placeholder if the icon is missing
    try {
      await _systemTray.initSystemTray(
        title: "Visual Break",
        iconPath: iconPath,
      );

      final Menu menu = Menu();
      await menu.buildFrom([
        MenuItemLabel(label: 'Afficher', onClicked: (menuItem) => windowManager.show()),
        MenuItemLabel(label: 'Cacher', onClicked: (menuItem) => windowManager.hide()),
        MenuSeparator(),
        MenuItemLabel(label: 'Quitter', onClicked: (menuItem) => exit(0)),
      ]);

      await _systemTray.setContextMenu(menu);

      // Handle left click to show window
      _systemTray.registerSystemTrayEventHandler((eventName) {
        if (eventName == kSystemTrayEventClick) {
          Platform.isWindows ? _appWindow.show() : windowManager.show();
        } else if (eventName == kSystemTrayEventRightClick) {
          _systemTray.popUpContextMenu();
        }
      });
      
      AppLogger.i('System Tray initialized');
    } catch (e) {
      AppLogger.e('Failed to initialize System Tray: $e');
    }
  }
}
