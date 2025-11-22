import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/tailor_model.dart';
import '../data/repository/tailor_repository.dart';

// Tailor State
abstract class TailorState extends Equatable {
  const TailorState();

  @override
  List<Object?> get props => [];
}

class TailorInitial extends TailorState {}

class TailorLoading extends TailorState {}

class TailorLoaded extends TailorState {
  final List<Tailor> tailors;
  final List<Tailor> filteredTailors;

  const TailorLoaded({
    required this.tailors,
    required this.filteredTailors,
  });

  @override
  List<Object?> get props => [tailors, filteredTailors];
}

class TailorError extends TailorState {
  final String message;

  const TailorError(this.message);

  @override
  List<Object?> get props => [message];
}

// Tailor Cubit using repository
class TailorCubit extends Cubit<TailorState> {
  final TailorRepository _repository;

  TailorCubit({TailorRepository? repository})
      : _repository = repository ?? TailorRepository(),
        super(TailorInitial()) {
    loadTailors();
  }

  Future<void> loadTailors() async {
    try {
      emit(TailorLoading());
      final tailors = await _repository.getAllTailors();
      emit(TailorLoaded(tailors: tailors, filteredTailors: tailors));
    } catch (e) {
      emit(TailorError(e.toString()));
    }
  }

  void searchTailors(String query) {
    final current = state;
    if (current is TailorLoaded) {
      if (query.trim().isEmpty) {
        emit(TailorLoaded(tailors: current.tailors, filteredTailors: current.tailors));
        return;
      }
      final lower = query.toLowerCase();
      final filtered = current.tailors.where((t) {
        return t.name.toLowerCase().contains(lower) ||
            t.area.toLowerCase().contains(lower) ||
            t.category.toLowerCase().contains(lower);
      }).toList();
      emit(TailorLoaded(tailors: current.tailors, filteredTailors: filtered));
    }
  }

  Future<void> refreshTailors() async {
    await loadTailors();
  }
}
