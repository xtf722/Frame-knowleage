// 在知识库根目录运行：dart labs/beginner/callbacks.dart
// 输入固定且不访问网络；观察函数交付与实际调用的区别。
void receivePhoto(void Function() onReady, void Function(String) record) {
  record('接收方开始');
  // 调用点属于接收方，本例立即调用，不包含任何异步调度。
  onReady();
  record('接收方结束');
}

void main() {
  var trace = '';
  var photoCalls = 0;

  void record(String message) {
    print(message);
    trace += '$message\n';
  }

  void showPhoto() {
    photoCalls += 1;
    record('显示米粒的照片');
  }

  void Function() saved = showPhoto;
  if (photoCalls != 0) {
    throw StateError('保存函数时不应执行函数体');
  }
  record('保存完成');
  receivePhoto(saved, record);
  record('回到调用方');

  const expected = '保存完成\n接收方开始\n显示米粒的照片\n接收方结束\n回到调用方\n';
  // 失败直接抛错，关闭 assert 的运行环境也不会跳过检查。
  // StateError 这里只是实验报错类型，与 Flutter 的 State 对象不同。
  if (trace != expected || photoCalls != 1) {
    throw StateError('回调顺序或次数不符：$trace；次数=$photoCalls');
  }
  print('PASS callbacks');
}
