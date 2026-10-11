import 'package:bloc/bloc.dart';
import '../utils/zs_log.dart';

class BlocCenter extends BlocObserver {
  const BlocCenter();
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    ZsLog.d('onCreate -- bloc: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    ZsLog.d('onEvent -- bloc: ${bloc.runtimeType}, event: $event');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    ZsLog.d('onChange -- bloc: ${bloc.runtimeType}, change: $change');
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    ZsLog.d(
      'onTransition -- bloc: ${bloc.runtimeType}, transition: $transition',
    );
  }

  @override
  void onDone(
    Bloc<dynamic, dynamic> bloc,
    Object? event, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    super.onDone(bloc, event, error, stackTrace);
    ZsLog.d(
      'onDone -- bloc: ${bloc.runtimeType}, event: $event, error: $error',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    ZsLog.d('onError -- bloc: ${bloc.runtimeType}, error: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    ZsLog.d('onClose -- bloc: ${bloc.runtimeType}');
  }
}
