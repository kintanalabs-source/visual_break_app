import 'package:get_it/get_it.dart';
import 'package:visual_break_app/application/timer_service/break_timer_service.dart';
import 'package:visual_break_app/domain/repositories/i_system_hooks.dart';
import 'package:visual_break_app/infrastructure/os_hooks/system_hooks_factory.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // Repositories
  getIt.registerLazySingleton<ISystemHooks>(() => SystemHooksFactory.create());

  // Services
  getIt.registerLazySingleton<BreakTimerService>(() => BreakTimerService());
}
