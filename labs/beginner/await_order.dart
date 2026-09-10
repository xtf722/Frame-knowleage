// 在知识库根目录运行：dart labs/beginner/await_order.dart
// 固定输入、离线运行；只检查先后关系，不依赖机器速度。
Future<String> loadPhoto(void Function(String) record) async {
  record('进入加载');
  // 零时长仍安排稍后完成，让调用方的同步语句有机会继续。
  await Future<void>.delayed(Duration.zero);
  record('加载完成');
  return 'mili.jpg';
}

void requireEqual(String actual, String expected, String caseName) {
  if (actual != expected) {
    throw StateError('$caseName 顺序错误：$actual');
  }
}

Future<void> main() async {
  var trace = '';
  void record(String message) {
    print(message);
    trace += '$message\n';
  }

  print('实验一：先调用，后等待');
  final pending = loadPhoto(record);
  record('调用方继续');
  final first = await pending;
  record('显示：$first');
  requireEqual(trace, '进入加载\n调用方继续\n加载完成\n显示：mili.jpg\n', '先调用后等待');

  // 上一轮已经 await 到完成，清空记录不会混入未完成的旧任务。
  trace = '';
  print('实验二：在调用处等待');
  final second = await loadPhoto(record);
  record('调用方继续');
  record('显示：$second');
  requireEqual(trace, '进入加载\n加载完成\n调用方继续\n显示：mili.jpg\n', '在调用处等待');
  print('PASS await_order');
}
