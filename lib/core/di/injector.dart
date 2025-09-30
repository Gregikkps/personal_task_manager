import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:personal_task_manager/core/services/weather_cache_service.dart';
import 'package:personal_task_manager/features/weather/data/datasources/weather_remote_datasource.dart';
import 'package:personal_task_manager/features/weather/domain/repositories/weather_repository.dart';
import 'package:personal_task_manager/features/weather/domain/repositories/weather_repository_iml.dart';
import '../../features/tasks/data/datasources/task_local_datasources.dart';
import '../../features/tasks/data/repositoriers/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  sl.registerSingleton<DatabaseService>(DatabaseService());
  sl.registerSingleton<NotificationService>(NotificationService());
  sl.registerSingleton<http.Client>(http.Client());

  await Future.wait([
    sl<DatabaseService>().initDatabase(),
    sl<NotificationService>().init(),
  ]);

  sl.registerSingleton<TaskLocalDataSource>(
    TaskLocalDataSource(sl<DatabaseService>()),
  );

  sl.registerSingleton<TaskRepository>(
    TaskRepositoryImpl(sl<TaskLocalDataSource>()),
  );

  sl.registerSingleton<WeatherCacheService>(
    WeatherCacheService(sl<DatabaseService>()),
  );

  sl.registerSingleton<WeatherRemoteDataSource>(
    WeatherRemoteDataSource(sl<http.Client>(), sl<WeatherCacheService>()),
  );

  sl.registerSingleton<WeatherRepository>(
    WeatherRepositoryImpl(
      sl<WeatherRemoteDataSource>(),
      sl<WeatherCacheService>(),
    ),
  );
}
