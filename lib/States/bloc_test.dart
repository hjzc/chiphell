import 'package:bloc/bloc.dart';
import 'bloc_center.dart';
import 'counter_cubit.dart';
import '../utils/zs_log.dart';

//bloc_concurrency: ^0.3.0
// bloc_concurrency provides an opinionated set of event transformers:
// concurrent - process events concurrently //并发处理事件
// sequential - process events sequentially  //按顺序处理事件
// droppable - ignore any events added while an event is processing //忽略事件处理过程中添加的任何事件
// restartable - process only the latest event and cancel previous event handlers //仅处理最新事件并取消以前的事件处理程序

//replay_bloc: ^0.3.0
//为bloc和肘管状态添加了自动撤消和重做支持。专为与package:bloc配合使用而构建。

void mainTest() {
  Bloc.observer = const BlocCenter();
  cubitMain();
  blocMain();

  // Bloc.observer = MultiBlocObserver(
  //   observers: [
  //     MyLoggingObserver(),
  //     MyErrorObserver(),
  //     MyPerformanceObserver(),
  //   ],
  // );
}

void cubitMain() {
  ZsLog.d('----------CUBIT MAIN----------');

  /// Create a `CounterCubit` instance.
  final cubit = CounterCubit();

  /// Access the state of the `cubit` via `state`.
  ZsLog.d(cubit.state); // 0

  /// Interact with the `cubit` to trigger `state` changes.
  cubit.increment();

  /// Access the new `state`.
  ZsLog.d(cubit.state); // 1

  /// Close the `cubit` when it is no longer needed.
  cubit.close();
}

Future<void> blocMain() async {
  ZsLog.d('----------BLOC MAIN----------');

  /// Create a `CounterBloc` instance.
  final bloc = CounterBloc();

  /// Access the state of the `bloc` via `state`.
  ZsLog.d(bloc.state);

  /// Interact with the `bloc` to trigger `state` changes.
  bloc.add(CounterIncrementPressed());

  /// Wait for next iteration of the event-loop
  /// to ensure event has been processed.
  await Future<void>.delayed(Duration.zero);

  /// Access the new `state`.
  ZsLog.d(bloc.state);

  /// Close the `bloc` when it is no longer needed.
  await bloc.close();
}


// class RelpayCounterCubit extends ReplayCubit<int> {
//   RelpayCounterCubit() : super(0);
//   void increment() => emit(state + 1);
// }
// void RelpayMain() {
//   final cubit = CounterCubit();
//   // trigger a state change
//   cubit.increment();
//   print(cubit.state); // 1
//   // undo the change
//   cubit.undo();
//   print(cubit.state); // 0

//   // redo the change
//   cubit.redo();
//   print(cubit.state); // 1
// }