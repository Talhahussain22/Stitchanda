import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/rider_model.dart';
import '../data/repository/rider_repository.dart';

// States
abstract class RiderState {}

class RiderInitial extends RiderState {}

class RiderLoading extends RiderState {}

class RiderLoaded extends RiderState {
  final RiderModel rider;
  RiderLoaded(this.rider);
}

class RiderError extends RiderState {
  final String message;
  RiderError(this.message);
}

// Cubit
class RiderCubit extends Cubit<RiderState> {
  final RiderRepository _riderRepository;

  RiderCubit(this._riderRepository) : super(RiderInitial());

  /// Fetch rider details by riderId
  Future<void> fetchRiderById(String riderId) async {
    try {

      if (riderId.isEmpty) {
        emit(RiderError('Rider ID is empty'));
        return;
      }

      emit(RiderLoading());

      final rider = await _riderRepository.getRiderById(riderId);

      if (rider == null) {
        emit(RiderError('Rider information not available'));
        return;
      }

      emit(RiderLoaded(rider));
    } catch (e) {
      emit(RiderError('Failed to load rider details: $e'));
    }
  }

  /// Reset state
  void reset() {
    emit(RiderInitial());
  }
}

