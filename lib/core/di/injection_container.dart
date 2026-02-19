
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../network/network_info.dart';
import '../../data/providers/music_service.dart';
import '../../data/repositories/track_repository.dart';
import '../../logic/blocs/library_bloc.dart';
import '../../logic/blocs/details_bloc.dart';
import '../../logic/blocs/home_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoCs
  sl.registerFactory(() => LibraryBloc(repository: sl()));
  sl.registerFactory(() => DetailsBloc(repository: sl()));
  sl.registerFactory(() => HomeBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton(() => TrackRepository(musicService: sl(), networkInfo: sl()));

  // Data sources
  sl.registerLazySingleton(() => MusicService(client: sl()));

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // External
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
}
