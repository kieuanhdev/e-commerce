import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:e_commerce/features/admin/domain/usecase/get_overview_stats.dart';
import 'package:equatable/equatable.dart';

part 'overview_event.dart';
part 'overview_state.dart';

class OverviewBloc extends Bloc<OverviewEvent, OverviewState> {
  final GetOverviewStatsUseCase _getOverviewStatsUseCase;
  StreamSubscription<OverviewStats>? _statsSubscription;

  OverviewBloc({required GetOverviewStatsUseCase getOverviewStatsUseCase})
    : _getOverviewStatsUseCase = getOverviewStatsUseCase,
      super(OverviewInitial()) {
    on<LoadOverviewStats>(_onLoadOverviewStats);
    on<OverviewStatsUpdated>(_onOverviewStatsUpdated);
  }

  void _onLoadOverviewStats(
    LoadOverviewStats event,
    Emitter<OverviewState> emit,
  ) {
    _statsSubscription?.cancel();
    _statsSubscription = _getOverviewStatsUseCase().listen(
      (stats) {
        add(OverviewStatsUpdated(stats));
      },
      onError: (error) {
        emit(OverviewError(error.toString()));
      },
    );
  }

  void _onOverviewStatsUpdated(
    OverviewStatsUpdated event,
    Emitter<OverviewState> emit,
  ) {
    emit(OverviewLoaded(event.stats));
  }

  @override
  Future<void> close() {
    _statsSubscription?.cancel();
    return super.close();
  }
}
