
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/track.dart';
import '../../data/repositories/track_repository.dart';
import '../../core/errors/failures.dart';

// Events
abstract class DetailsEvent extends Equatable {
  const DetailsEvent();
  @override
  List<Object> get props => [];
}

class LoadTrackDetails extends DetailsEvent {
  final Track track;
  const LoadTrackDetails(this.track);
  @override
  List<Object> get props => [track];
}

// States
abstract class DetailsState extends Equatable {
  const DetailsState();
  @override
  List<Object> get props => [];
}

class DetailsLoading extends DetailsState {}

class DetailsLoaded extends DetailsState {
  final TrackDetails trackDetails;
  const DetailsLoaded(this.trackDetails);
  @override
  List<Object> get props => [trackDetails];
}

class DetailsError extends DetailsState {
  final String message;
  const DetailsError(this.message);
  @override
  List<Object> get props => [message];
}

class DetailsOffline extends DetailsState {
  const DetailsOffline();
}

// BLoC
class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  final TrackRepository repository;

  DetailsBloc({required this.repository}) : super(DetailsLoading()) {
    on<LoadTrackDetails>(_onLoadTrackDetails);
  }

  Future<void> _onLoadTrackDetails(LoadTrackDetails event, Emitter<DetailsState> emit) async {
    emit(DetailsLoading());
    try {
      final details = await repository.getTrackDetails(event.track);
      emit(DetailsLoaded(details));
    } catch (e) {
      print('Details Load Error: $e');
      if (e is NetworkFailure) {
        emit(const DetailsOffline());
      } else {
        emit(DetailsError(e.toString()));
      }
    }
  }
}
