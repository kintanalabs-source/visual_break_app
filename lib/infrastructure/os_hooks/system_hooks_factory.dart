import 'dart:io';
import 'package:visual_break_app/domain/repositories/i_system_hooks.dart';
import 'package:visual_break_app/infrastructure/os_hooks/desktop_system_hooks.dart';
import 'package:visual_break_app/infrastructure/os_hooks/windows_hooks.dart';

class SystemHooksFactory {
  static ISystemHooks create() {
    if (Platform.isWindows) {
      return WindowsSystemHooks();
    }
    return DesktopSystemHooks();
  }
}
