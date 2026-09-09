import 'dart:async';

// 教学模型：接收者始终存活，generation 单独保护业务选择的归属。
class SelectionModel {
  int generation = 0;
  String selected = '';
  String displayed = '';

  Future<void> choose(
    String id,
    Future<String> result, {
    required bool gate,
  }) async {
    selected = id;
    final requestGeneration = ++generation;
    final value = await result;
    if (gate && requestGeneration != generation) return;
    displayed = value;
  }
}

Future<SelectionModel> runScenario({required bool gate}) async {
  final model = SelectionModel();
  final a = Completer<String>();
  final b = Completer<String>();
  final first = model.choose('A', a.future, gate: gate);
  final second = model.choose('B', b.future, gate: gate);
  // 固定顺序，不靠真实网络速度或随机延迟制造竞态。
  b.complete('B');
  await second;
  a.complete('A');
  await first;
  return model;
}

Future<void> main() async {
  final unsafe = await runScenario(gate: false);
  final safe = await runScenario(gate: true);
  print(
    'without gate: selected=${unsafe.selected} displayed=${unsafe.displayed}',
  );
  print('with gate: selected=${safe.selected} displayed=${safe.displayed}');
  if (unsafe.displayed != 'A' || safe.displayed != 'B') {
    throw StateError(
      'The controlled completion order did not match the lesson.',
    );
  }
  print(
    'PASS: stale completion rejected; the receiver stayed alive throughout.',
  );
}
