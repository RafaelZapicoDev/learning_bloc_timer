import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:learning_bloc_timer/ticker.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  //bloc principal
  static const int _duration = 60; //duração do timer
  final Ticker _ticker; //ticker
  StreamSubscription<int>? _tickerSubscription; //permite ouvir uma stream

  TimerBloc({required Ticker ticker}) //ao construir o bloc passa o ticker
    : _ticker = ticker,
      super(TimerInitial(_duration)) //definindo o estado inicial do bloc
      {
    //registrando como o bloc deve reagir aos eventos
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<_TimerTicked>(_onTicked);
  }

  @override
  Future<void> close() {
    //para fechar o bloc, cancela a inscrição na stream como um dispose
    _tickerSubscription?.cancel();
    return super.close();
  }

  //lidando com o evento de startar o timer
  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(event.duration)); // muda o estao para running
    _tickerSubscription?.cancel(); //cancela o ticker anterior
    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen(
          (duration) => add(_TimerTicked(duration: duration)),
        ); //ouve o ticker com a duranção e adiciona o eve nto de tick
  }

  //lidando com o evento de resetar o timer
  void _onReset(TimerReset reset, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel(); //cancela o timer
    emit(const TimerInitial(_duration)); //volta pro estado inicial
  }

  //lidando com o evento de voltar a contar
  void _onResumed(TimerResumed resume, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      // se esta no estado de pausa
      _tickerSubscription?.resume(); //volta
      emit(
        TimerRunInProgress(state.duration),
      ); //e atualiza pro status de rodando
    }
  }

  //lidando com o evento de pausado
  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      //se esta no estado de progresso
      _tickerSubscription?.pause(); //pausa o ticker
      emit(TimerRunPause(state.duration)); //e emite o estado de pausado
    }
  }

  //lidando com o evento de tick
  void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
    emit(
      //se a duração ainda for maior que zero, emit o evento de em progresso,
      //senão ele emit a duração completou já o tick
      event.duration > 0
          ? TimerRunInProgress(event.duration)
          : TimerRunComplete(),
    );
  }
}
