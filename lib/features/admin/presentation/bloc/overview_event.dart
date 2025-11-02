part of 'overview_bloc.dart';

abstract class OverviewEvent extends Equatable {
  const OverviewEvent();

  @override
  List<Object?> get props => [];
}

class LoadOverviewStats extends OverviewEvent {
  const LoadOverviewStats();
}

class OverviewStatsUpdated extends OverviewEvent {
  final OverviewStats stats;

  const OverviewStatsUpdated(this.stats);

  @override
  List<Object?> get props => [stats];
}

