import 'package:bloc/bloc.dart';

/// Simple cubit that holds the current index of the dashboard's bottom navigation.
class DashboardIndexCubit extends Cubit<int> {
  DashboardIndexCubit() : super(0);

  void setIndex(int index) => emit(index);
}

