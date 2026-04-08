import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';
import '../../features/dogs/data/dogs_repository.dart';
import '../../features/dogs/presentation/dogs_controller.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(
      () => const String.fromEnvironment('API_NINJAS_KEY'),
    ),
  );

  sl.registerLazySingleton<Dio>(
    () => createDio(sl<AuthInterceptor>()),
  );

  sl.registerLazySingleton<DogsRepository>(
    () => DogsRepository(sl<Dio>()),
  );

  sl.registerFactory<DogsController>(
    () => DogsController(
      sl<DogsRepository>(),
      sl<SharedPreferences>(),
    ),
  );
}