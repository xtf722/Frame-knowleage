// 在知识库根目录运行：dart labs/beginner/types.dart
// 所有输入写在 main 中，不访问网络、不读取项目数据。
String displayName(String? name) => name?.trim() ?? '尚未选择';

int countFor(Map<String, int> counts, String petName) {
  // 本实验明确要求缺失时显示 0；这是显示约定，不是所有数据的默认规则。
  return counts[petName] ?? 0;
}

String makeTitle({required String petName, int count = 0}) {
  return '$petName：$count张照片';
}

Future<String> loadName() async => '米粒';

void requireValue(bool condition, String reason) {
  if (!condition) {
    throw StateError(reason);
  }
}

Future<void> main() async {
  List<String> pets = ['米粒', '小白'];
  Map<String, int> counts = {'米粒': 3};
  requireValue(pets[0] == '米粒', '列表第一个元素错误');
  requireValue(counts['小白'] == null, '缺失键应该得到 null');
  requireValue(countFor(counts, '米粒') == 3, '已有照片数不应被替换');
  requireValue(countFor(counts, '小白') == 0, '缺失键没有得到约定的备用值');
  print('米粒照片数：${countFor(counts, '米粒')}');
  print('小白照片数：${countFor(counts, '小白')}');

  requireValue(displayName(null) == '尚未选择', 'null 没有显示备用文本');
  requireValue(displayName(' 米粒 ') == '米粒', '字符串两端空白未去掉');
  requireValue(displayName('') == '', '空字符串不应该触发 ??');
  print('未选择时：${displayName(null)}');

  Future<String> pending = loadName();
  String name = await pending;
  requireValue(name == '米粒', 'Future 的成功结果不符');
  requireValue(makeTitle(petName: name) == '米粒：0张照片', '默认参数不符');
  requireValue(makeTitle(petName: name, count: 3) == '米粒：3张照片', '显式命名参数不符');
  print(makeTitle(petName: name, count: 3));
  print('PASS types');
}
