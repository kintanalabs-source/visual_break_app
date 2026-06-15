abstract class ISystemHooks {
  /// Stream emitting user idle status.
  Stream<bool> get onIdleStatusChanged;

  /// Sets the application window to be always on top.
  Future<void> setAlwaysOnTop(bool value);

  /// Gets the current idle status.
  Future<bool> isUserIdle();
}
