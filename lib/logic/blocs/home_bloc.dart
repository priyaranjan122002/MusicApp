
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/track.dart';
import '../../data/repositories/track_repository.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object> get props => [];
}

class LoadHomeData extends HomeEvent {}

// States
abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object> get props => [];
}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Track> recommended;
  final List<Track> recent;
  final List<Track> topArtists; // Actually tracks of top artists

  const HomeLoaded({
    required this.recommended, 
    this.recent = const [], 
    this.topArtists = const []
  });

  @override
  List<Object> get props => [recommended, recent, topArtists];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final TrackRepository repository;

  HomeBloc({required this.repository}) : super(HomeLoading()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      // 1. Fetch Recommended (Generic Pop or Trending)
      // Using 'hits' or 'top' or 'chart' query
      final recommended = await repository.searchTracks('chart', 0);
      
      // 2. Fetch recent from memory
      final recent = repository.getRecentTracks();

      // 3. Fetch Top Artist Tracks (e.g., 'The Weeknd' or similar popular)
      // We can just reuse recommended if we want or fetch another generic term
      final topArtists = await repository.searchTracks('Drake', 0);

      emit(HomeLoaded(
        recommended: recommended.take(10).toList(),
        recent: recent,
        topArtists: topArtists.take(10).toList(),
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
