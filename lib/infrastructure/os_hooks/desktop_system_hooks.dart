import 'dart:async';
import 'package:visual_break_app/domain/repositories/i_system_hooks.dart';
import 'package:window_manager/window_manager.dart';

/// Base implementation for Linux/macOS or any platform not yet specifically implemented.
class DesktopSystemHooks implements ISystemHooks {
  final _idleController = StreamController<bool>.broadcast();

  @override
  Stream<bool> get onIdleStatusChanged => _idleController.stream;

  @override
  Future<void> setAlwaysOnTop(bool value) async {
    await windowManager.setAlwaysOnTop(value);
  }

  @override
  Future<bool> isUserIdle() async => false;

  void dispose() {
    _idleController.close();
  }
}
