import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:visual_break_app/domain/entities/popup_config.dart';
import 'package:visual_break_app/core/logging/app_logger.dart';

class PopupManager {
  static Future<void> showPopup(PopupConfig config, {bool fullScreen = false}) async {
    AppLogger.i('Showing popup (Full-Screen: $fullScreen)');
    
    if (fullScreen) {
      await windowManager.setFullScreen(true);
      await windowManager.setAlwaysOnTop(true);
      await windowManager.setMinimizable(false);
      await windowManager.setClosable(false);
    } else {
      await windowManager.setSize(Size(config.width, config.height));
      await _setPosition(config.position, config.width, config.height);
      await windowManager.setAlwaysOnTop(config.alwaysOnTop);
    }
    
    await windowManager.show();
    await windowManager.focus();
  }

  static Future<void> hidePopup() async {
    AppLogger.i('Exiting break mode');
    
    // Re-enable window controls before exiting break mode.
    await windowManager.setMinimizable(true);
    await windowManager.setClosable(true);
    
    // On Linux, transitioning from full-screen to hidden can sometimes cause crashes.
    // We first exit full-screen and disable "always on top".
    await windowManager.setFullScreen(false);
    await windowManager.setAlwaysOnTop(false);
    
    // Give the window manager a moment to breathe before resizing/centering
    await Future.delayed(const Duration(milliseconds: 100));
    
    await windowManager.setSize(const Size(800, 600));
    await windowManager.center();
    
    // We don't call hide() here to allow the user to see the HomeScreen timer.
    // The window will stay visible but in normal mode.
  }

  static Future<void> _setPosition(PopupPosition position, double width, double height) async {
    Display primaryDisplay = await screenRetriever.getPrimaryDisplay();
    Offset offset = Offset.zero;

    switch (position) {
      case PopupPosition.center:
        // window_manager has a built-in center method
        await windowManager.center();
        return;
      case PopupPosition.bottomLeft:
        offset = Offset(0, primaryDisplay.size.height - height);
        break;
      case PopupPosition.bottomRight:
        offset = Offset(primaryDisplay.size.width - width, primaryDisplay.size.height - height);
        break;
      case PopupPosition.topCenter:
        offset = Offset((primaryDisplay.size.width - width) / 2, 0);
        break;
    }

    await windowManager.setPosition(offset);
  }
}
