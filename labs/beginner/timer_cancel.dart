import 'dart:async';

Future<void> main() async {
  var cancelledCallbackRan = false;
  final cancelled = Timer(Duration.zero, () {
    cancelledCallbackRan = true;
  });
  // 在事件循环有机会执行回调前取消；不依赖“操作快于某个毫秒数”的猜测。
  cancelled.cancel();
  cancelled.cancel();
  await Future<void>.delayed(Duration.zero);
  if (cancelledCallbackRan) {
    throw StateError('A cancelled timer must not call its callback.');
  }
  print('cancelled timer calls=0');

  final finished = Completer<void>();
  var calls = 0;
  Timer(Duration.zero, () {
    calls++;
    finished.complete();
  });
  await finished.future;
  if (calls != 1) throw StateError('The one-shot timer must call once.');
  print('one-shot timer calls=1');
  print('PASS: cancellation and one-shot behavior match the lesson.');
}
