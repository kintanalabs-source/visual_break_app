import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:visual_break_app/core/logging/app_logger.dart';
import 'package:visual_break_app/application/break_controller/popup_manager.dart';
import 'package:visual_break_app/domain/entities/popup_config.dart';
import 'package:visual_break_app/domain/repositories/i_system_hooks.dart';
import 'package:visual_break_app/core/service_locator.dart';

enum TimerStatus { working, breaking, paused }

class BreakTimerService extends ChangeNotifier {
  static const int workDurationSeconds = 10;//2 * 3600 + 30 * 60; // 2h30
  static const int breakDurationSeconds = 10;

  Timer? _timer;
  int _remainingSeconds = workDurationSeconds;
  TimerStatus _status = TimerStatus.working;
  StreamSubscription<bool>? _idleSubscription;

  int get remainingSeconds => _remainingSeconds;
  TimerStatus get status => _status;

  BreakTimerService() {
    _initIdleDetection();
  }

  void _initIdleDetection() {
    final systemHooks = getIt<ISystemHooks>();
    _idleSubscription = systemHooks.onIdleStatusChanged.listen((isIdle) {
      if (isIdle && _status == TimerStatus.working) {
        _status = TimerStatus.paused;
        AppLogger.i('Timer paused due to user inactivity');
      } else if (!isIdle && _status == TimerStatus.paused) {
        _status = TimerStatus.working;
        AppLogger.i('Timer resumed as user returned');
      }
      notifyListeners();
    });
  }

  String get formattedTime {
    if (_status == TimerStatus.paused) return 'En pause (Inactif)';
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    AppLogger.i('Timer started: $_status');
  }

  void stopTimer() {
    _timer?.cancel();
    AppLogger.i('Timer stopped');
  }

  void _onTick(Timer timer) {
    if (_status == TimerStatus.paused) return; // Don't tick if paused

    if (_remainingSeconds > 0) {
      _remainingSeconds--;
      notifyListeners();
    } else {
      _onTimerFinished();
    }
  }

  void _onTimerFinished() {
    if (_status == TimerStatus.working) {
      _status = TimerStatus.breaking;
      _remainingSeconds = breakDurationSeconds;
      AppLogger.i('Work period finished. Starting break.');
      PopupManager.showPopup(const PopupConfig(position: PopupPosition.center), fullScreen: true);
    } else if (_status == TimerStatus.breaking) {
      _status = TimerStatus.working;
      _remainingSeconds = workDurationSeconds;
      AppLogger.i('Break finished. Resuming work.');
      PopupManager.hidePopup();
    }
    notifyListeners();
  }

  void skipBreak() {
    if (_status == TimerStatus.breaking) {
      _onTimerFinished();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _idleSubscription?.cancel();
    super.dispose();
  }
}
