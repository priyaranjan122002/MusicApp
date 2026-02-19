
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/models/track.dart';
import '../../data/repositories/track_repository.dart';
import '../../core/errors/failures.dart';

// Events
abstract class LibraryEvent extends Equatable {
  const LibraryEvent();
  @override
  List<Object> get props => [];
}

class FilterTracks extends LibraryEvent {
  final String filter;
  const FilterTracks(this.filter);
  @override
  List<Object> get props => [filter];
}

class LoadTracks extends LibraryEvent {}

class SearchTracks extends LibraryEvent {
  final String query;
  const SearchTracks(this.query);
  @override
  List<Object> get props => [query];
}

class LoadMoreTracks extends LibraryEvent {}

// States
abstract class LibraryState extends Equatable {
  const LibraryState();
  @override
  List<Object> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<Track> tracks;
  final bool hasReachedMax;
  final String searchQuery;
  final String selectedFilter;

  const LibraryLoaded({
    this.tracks = const [],
    this.hasReachedMax = false,
    this.searchQuery = '',
    this.selectedFilter = 'All',
  });

  LibraryLoaded copyWith({
    List<Track>? tracks,
    bool? hasReachedMax,
    String? searchQuery,
    String? selectedFilter,
  }) {
    return LibraryLoaded(
      tracks: tracks ?? this.tracks,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object> get props => [tracks, hasReachedMax, searchQuery, selectedFilter];
}

class LibraryError extends LibraryState {
  final String message;
  const LibraryError(this.message);
  @override
  List<Object> get props => [message];
}

class LibraryNoInternet extends LibraryState {
    const LibraryNoInternet();
}


// BLoC
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final TrackRepository repository;

  LibraryBloc({required this.repository}) : super(LibraryInitial()) {
    on<LoadTracks>(_onLoadTracks);
    on<LoadMoreTracks>(_onLoadMoreTracks);
    on<FilterTracks>(_onFilterTracks);
    on<SearchTracks>(_onSearchTracks, transformer: debounce(const Duration(milliseconds: 500)));
  }

  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

  Future<void> _onLoadTracks(LoadTracks event, Emitter<LibraryState> emit) async {
    emit(LibraryLoading());
    try {
      final tracks = await repository.fetchTracks(0, 50);
      emit(LibraryLoaded(tracks: tracks, hasReachedMax: false));
    } catch (e) {
      print('Bloc Load Error: $e');
      if (e is NetworkFailure) {
        emit(const LibraryNoInternet()); 
      } else if (e is Failure) {
        emit(LibraryError(e.message));
      } else {
        emit(LibraryError(e.toString()));
      }
    }
  }

  Future<void> _onLoadMoreTracks(LoadMoreTracks event, Emitter<LibraryState> emit) async {
    if (state is LibraryLoaded) {
      final currentState = state as LibraryLoaded;
      if (currentState.hasReachedMax) return;
      if (currentState.searchQuery.isNotEmpty) {
          // TODO: Implement load more for search if needed
          return; 
      }

      try {
        final tracks = await repository.fetchTracks(currentState.tracks.length, 50);
        if (tracks.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          emit(currentState.copyWith(
            tracks: List.of(currentState.tracks)..addAll(tracks),
            hasReachedMax: false,
          ));
        }
      } catch (e) {
         // Optionally emit error or ignore
      }
    }
  }

  Future<void> _onFilterTracks(FilterTracks event, Emitter<LibraryState> emit) async {
    if (state is LibraryLoaded) {
      final currentState = state as LibraryLoaded;
      emit(currentState.copyWith(selectedFilter: event.filter));
    }
  }

  Future<void> _onSearchTracks(SearchTracks event, Emitter<LibraryState> emit) async {
    final query = event.query;
    if (query.isEmpty) {
      add(LoadTracks());
      return;
    }

    emit(LibraryLoading());
    try {
      final tracks = await repository.searchTracks(query, 0);
      emit(LibraryLoaded(tracks: tracks, hasReachedMax: true, searchQuery: query));
    } catch (e) {
      print('Bloc Search Error: $e');
      if (e is NetworkFailure) {
        emit(const LibraryNoInternet());
      } else {
        emit(LibraryError(e.toString()));
      }
    }
  }
}
