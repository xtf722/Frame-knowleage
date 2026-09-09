# 两个可以独立运行的 Dart 学习实验

[返回首页](../README.md) · [异步基础](../foundations/async-lifecycle.md) · [更新基础](../foundations/updates-trust.md)

只需 Dart SDK，不依赖 Flutter、第三方包、网络、设备或项目凭据。在本知识库根目录运行：

```shell
dart labs/future_race.dart
dart labs/event_replay.dart
```

两个程序都是原创教学模拟，不包含 Frame 产品实现。它们不会访问真实后端、APK、缓存或安装器。

## 实验一：旧请求覆盖新选择

[future_race.dart](future_race.dart) 用两个 `Completer` 人工控制 A、B 的完成顺序：先选 A，后选 B，却让 B 先完成、A 最后返回。

- 无 generation：最终错误地显示 A。
- 有 generation：拒绝 A 的旧结果，保留 B。

预期末尾输出：

```text
without gate: selected=B displayed=A
with gate: selected=B displayed=B
PASS: stale completion rejected; the receiver stayed alive throughout.
```

运行前先回答：整个过程中接收对象都活着，`mounted` 一直为 true 能拦住哪个错误？运行后把 generation 检查删掉，预测程序如何失败，再恢复示例。

## 实验二：已接受事件但回包丢失

[event_replay.dart](event_replay.dart) 用内存状态模拟持久化记录和接收端。第一次发送时接收端已经计数，却丢失回执；第二个协调器实例从记录中恢复，重放同一个 eventId。

预期末尾输出：

```text
deliveries=2 effects=1 acknowledged=true
PASS: restart replayed the same event identity.
```

把重放改为创建新的 eventId，再推演接收端为什么会认为这是第二件事。

限制：这个实验**不做真实磁盘写入，也不实际重启操作系统进程**；新建对象只模拟协调器内存丢失。它展示事件身份与去重的关系，不能证明 Frame 的持久化原子性或服务端契约。

## 实验记录

请把预测、实际输出与误解写入 [复盘卡](../review/note-template.md)。本库的初次执行结果见 [验证记录](../evidence/validation.md)，实际项目测试仍回到专题中的检索入口。
