part of 'timer_bloc.dart';

//obs sealed a classe so vai poder ser utilizada aqui e é abstract
sealed class TimerState extends Equatable {
  //classe de estado
  final int duration;
  const TimerState(this.duration);

  @override
  List<Object> get props => [duration];
}

// alguns estados do timer irao herdar da classe principal
// para sabermos o tempo restante do timer

final class TimerInitial extends TimerState {
  const TimerInitial(super.duration);

  @override
  String toString() => 'TimerInitial { duration: $duration }';
}

final class TimerRunPause extends TimerState {
  const TimerRunPause(super.duration);

  @override
  String toString() => 'TimerRunPause { duration: $duration }';
}

final class TimerRunInProgress extends TimerState {
  const TimerRunInProgress(super.duration);

  @override
  String toString() => 'TimerRunInProgress { duration: $duration }';
}

final class TimerRunComplete extends TimerState {
  const TimerRunComplete() : super(0);
}
