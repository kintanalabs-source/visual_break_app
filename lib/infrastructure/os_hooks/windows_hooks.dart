import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:visual_break_app/domain/repositories/i_system_hooks.dart';
import 'package:window_manager/window_manager.dart';

// FFI Definitions for Windows
typedef _GetLastInputInfoNative = Int32 Function(Pointer<_LastInputInfo> plii);
typedef _GetLastInputInfoDart = int Function(Pointer<_LastInputInfo> plii);

typedef _GetTickCount64Native = Uint64 Function();
typedef _GetTickCount64Dart = int Function();

final class _LastInputInfo extends Struct {
  @Uint32()
  external int cbSize;
  @Uint32()
  external int dwTime;
}

class WindowsSystemHooks implements ISystemHooks {
  final _idleController = StreamController<bool>.broadcast();
  Timer? _idleCheckTimer;
  bool _isCurrentlyIdle = false;
  static const int idleThresholdSeconds = 300;

  _GetLastInputInfoDart? _getLastInputInfo;
  _GetTickCount64Dart? _getTickCount64;
  bool _isInitialized = false;

  WindowsSystemHooks() {
    if (Platform.isWindows) {
      try {
        final user32 = DynamicLibrary.open('user32.dll');
        final kernel32 = DynamicLibrary.open('kernel32.dll');

        _getLastInputInfo = user32
            .lookupFunction<_GetLastInputInfoNative, _GetLastInputInfoDart>('GetLastInputInfo');
        _getTickCount64 = kernel32
            .lookupFunction<_GetTickCount64Native, _GetTickCount64Dart>('GetTickCount64');
        _isInitialized = true;
      } catch (e) {
        _isInitialized = false;
      }
    }
    _startIdleCheck();
  }

  @override
  Stream<bool> get onIdleStatusChanged => _idleController.stream;

  @override
  Future<void> setAlwaysOnTop(bool value) async {
    await windowManager.setAlwaysOnTop(value);
  }

  @override
  Future<bool> isUserIdle() async {
    if (!_isInitialized || _getLastInputInfo == null || _getTickCount64 == null) return false;
    return _getWindowsIdleTime() > idleThresholdSeconds;
  }

  void _startIdleCheck() {
    _idleCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      bool idle = await isUserIdle();
      if (idle != _isCurrentlyIdle) {
        _isCurrentlyIdle = idle;
        _idleController.add(idle);
      }
    });
  }

  int _getWindowsIdleTime() {
    if (_getLastInputInfo == null || _getTickCount64 == null) return 0;

    final lastInputInfo = calloc<_LastInputInfo>();
    lastInputInfo.ref.cbSize = sizeOf<_LastInputInfo>();
    
    if (_getLastInputInfo!(lastInputInfo) != 0) {
      final currentTime = _getTickCount64!();
      final lastInputTime = lastInputInfo.ref.dwTime;
      calloc.free(lastInputInfo);
      return (currentTime - lastInputTime) ~/ 1000;
    }
    
    calloc.free(lastInputInfo);
    return 0;
  }

  void dispose() {
    _idleCheckTimer?.cancel();
    _idleController.close();
  }
}
