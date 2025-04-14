import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/dashboard/domain/use_cases/get_dashboard_data.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardData getDashboardData;

  DashboardBloc({required this.getDashboardData})
      : super(const DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    final result = await getDashboardData(NoParams());
    result.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (data) => emit(DashboardLoaded(data: data)),
    );
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(const DashboardLoading());
      final result = await getDashboardData(NoParams());
      result.fold(
        (failure) => emit(DashboardError(message: failure.message)),
        (data) => emit(DashboardLoaded(data: data)),
      );
    }
  }
}
