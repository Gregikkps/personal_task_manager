import 'package:get_it/get_it.dart';
import '../../features/tasks/data/datasources/task_local_datasources.dart';
import '../../features/tasks/data/repositoriers/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  sl.registerSingleton<DatabaseService>(DatabaseService());
  await sl<DatabaseService>().initDatabase();
  sl.registerSingleton<NotificationService>(NotificationService());
  await sl<NotificationService>().init();

  sl.registerSingleton<TaskLocalDataSource>(
    TaskLocalDataSource(sl<DatabaseService>()),
  );

  sl.registerSingleton<TaskRepository>(
    TaskRepositoryImpl(sl<TaskLocalDataSource>()),
  );
}
