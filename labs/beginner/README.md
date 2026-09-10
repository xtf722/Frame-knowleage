# 把小例子跑起来

[课程入口](../../beginner/README.md) · [全部实验](../README.md) · [语法速查](../../beginner/syntax-desk.md)

先做预测，再运行一个文件对照结果。这里的程序都是原创教学例子，使用固定输入，不需要 Frame 源码、账号、网络接口或设备。
文档中的“片段”用于逐句阅读；本页链接的 `.dart` 文件则是完整程序。不要把某个 State 方法片段单独当作 main.dart 运行。

## Dart：四个短实验

准备好 Dart SDK，在终端进入这份知识库的根目录，输入下面的一条命令即可。`dart --version` 可以检查 SDK 是否可用；安装了 Flutter 的环境通常也提供 Dart。

| 对应课 | 文件与命令 | 先猜什么 | 成功标志 |
| --- | --- | --- | --- |
| [02 回调](../../beginner/02-callbacks.md) | [callbacks.dart](callbacks.dart)：`dart labs/beginner/callbacks.dart` | 保存函数时会不会执行？谁真正调用它？ | `PASS callbacks` |
| [03 await](../../beginner/03-future-await.md) | [await_order.dart](await_order.dart)：`dart labs/beginner/await_order.dart` | await 放的位置改变后，哪一行先打印？ | `PASS await_order` |
| [04 类型与空值](../../beginner/04-types-nullability.md) | [types.dart](types.dart)：`dart labs/beginner/types.dart` | Map 找不到键、name 是 null 时显示什么？ | `PASS types` |
| [10 定时器](../../beginner/10-timers-listeners.md) | [timer_cancel.dart](timer_cancel.dart)：`dart labs/beginner/timer_cancel.dart` | 取消后的回调还能不能执行？ | `PASS: cancellation and one-shot behavior match the lesson.` |

例如，第一个实验按顺序打印：

```text
保存完成
接收方开始
显示米粒的照片
接收方结束
回到调用方
PASS callbacks
```

实验里有 `if (...) throw StateError(...)`，表示结果与预期不符就报错，不用先学会测试框架。这里的 `StateError` 是 Dart 的错误类型，与 Flutter 页面的 `State` 不是一回事。
修改练习时暂时看到错误是正常的：先判断错误是否正是你预测的结果，再恢复示例。请保存自己的改动副本，方便对照。

## Flutter：两个可以看到画面的例子

这两份文件依赖 Flutter 的 Material 组件，要放进一个**独立 Flutter 练习项目**的 `lib/main.dart`，不能用 `dart 文件名` 代替 Flutter 运行方式。

| 对应课 | 完整文件 | 操作 | 应看到什么 |
| --- | --- | --- | --- |
| [05 Widget 与 State](../../beginner/05-widget-state.md) | [flutter_state_demo.dart](flutter_state_demo.dart) | 点击“点赞” | 0 → 1 → 2，字段变化后画面跟随更新 |
| [08 异步 UI](../../beginner/08-async-ui.md) | [flutter_async_demo.dart](flutter_async_demo.dart) | 点击“加载 / 重试” | 先出现“加载中…”，约两秒后显示结果并恢复按钮 |

已经有空的 Flutter 练习项目，可以直接使用它。还没有的话，在自己选择的练习目录运行：

```shell
flutter create --platforms=web frame_learning
cd frame_learning
```

然后打开上表的一份 `.dart` 文件，复制**全部内容**替换这个练习项目的 `lib/main.dart`。一次只放一份例子；修改产品项目不是本练习的步骤。

```shell
flutter run -d chrome
```

这条命令需要已配置的 Flutter Web 环境和 Chrome。Windows 也可按 [Flutter Web 运行说明](https://docs.flutter.dev/platform-integration/web/building) 改用 `flutter run -d edge`。SDK 安装或平台配置报错时，先按 [Flutter 官方安装入口](https://docs.flutter.dev/install) 处理环境，再回到课程。
运行窗口中的热重载通常保留 State；需要恢复从 0 开始的初始状态时，用热重启或停止后重新运行。

第 08 课的失败练习只需把 `_fetchMessage()` 的 `return` 改为 `throw Exception('练习失败');`：观察错误出现后，按钮是否恢复。恢复 `return` 后再试一次。
不要把“看见成功文本”作为失败路径也正确的证据。

## 学到异步竞争时，再做原来的进阶实验

- [第 09 课：旧结果](../../beginner/09-stale-results.md) 对应 [future_race.dart](../future_race.dart)：先选 A，后选 B，却让 A 最后完成。
- [更新导读](../../beginner/guided/app-update.md) 之后，对照 [event_replay.dart](../event_replay.dart)：回执丢失时为什么要重放同一个事件身份。

两份的运行方法和预期输出见 [进阶实验说明](../README.md)。现在不必为了“全部跑完”提前学习事件持久化。

## 跑通以后怎样才算学到？

只记录三行即可：我原先预测什么、实际发生什么、哪一行导致差异。然后按本课微练习改一处，再预测一次。
`PASS` 说明这个例子的检查通过，不会自动代表你已掌握，也不代表 Frame 产品经过测试。课程交付时的执行记录单独放在 [课程验证](../../evidence/beginner-validation.md)。
